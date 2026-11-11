# Functions shared by deploy.sh and the download script. Needs $APPS_PWD exported and $LIB (this folder).
SQL_ERRORS='ORA-[0-9]|PLS-[0-9]|SP2-[0-9]|compilation errors|^ERROR'
LOADER_ERRORS='ORA-[0-9]|APP-[A-Z]+-[0-9]|[Ee]rror|[Ff]ailed|[Ee]xception|[Ii]nvalid username'

# check_log LOG PATTERN: 0 when the log has no line matching PATTERN; prints the first few that do
check_log() {
    if grep -Eq -- "$2" "$1"; then
        echo "  errors in $1:"; grep -En -- "$2" "$1" | head -5 | sed 's/^/    /'
        return 1
    fi
    return 0
}

# run_sql FILE LOG [USER PASSWORD]: SQL*Plus as APPS (or USER), password on its standard input
run_sql() {
    { printf 'connect %s/"%s"\n' "${3:-apps}" "${4:-$APPS_PWD}"
      printf 'set echo on define off sqlblanklines on serveroutput on\nwhenever oserror exit 9\n'
      printf '@"%s"\nshow errors\nexit\n' "$1"; } | sqlplus -s /nolog > "$2" 2>&1
    local rc=$?
    check_log "$2" "$SQL_ERRORS" && [ $rc -eq 0 ]
}

# run_loader LOG FNDLOAD|WFLOAD apps ...: expect answers the password prompt; the program's own log
# (FNDLOAD "Log filename : L123.log") is moved into logs/ and checked too
run_loader() {
    local log=$1; shift
    if command -v expect >/dev/null 2>&1; then
        expect "$LIB/loader.exp" "$@" > "$log" 2>&1
    else
        printf '%s\n' "$APPS_PWD" | "$@" > "$log" 2>&1
    fi
    local rc=$? own ok=0
    own=$(sed -n 's/.*[Ll]og *[Ff]ile[Nn]ame *: *\([^ ]*\).*/\1/p' "$log" | tail -1)
    if [ -n "$own" ] && [ -f "$own" ]; then
        mv -f "$own" "$(dirname "$log")/" && own="$(dirname "$log")/$(basename "$own")"
        echo "  program log: $own" >> "$log"
        check_log "$own" "$LOADER_ERRORS" || ok=1
    fi
    check_log "$log" "$LOADER_ERRORS" || ok=1
    [ $rc -eq 0 ] && [ $ok -eq 0 ]
}

# top_path '$XX_TOP/dir/file': the path with the variable taken from the environment (no eval)
top_path() {
    local var=${1%%/*}
    var=${var#\$}
    if [ -z "${!var:-}" ]; then echo "  $var is not set by the environment" >&2; return 1; fi
    printf '%s/%s\n' "${!var}" "${1#*/}"
}

# same_aol A B: 0 when two FNDLOAD / WFLOAD files hold the same definitions (comments and dates ignored)
aol_norm() { grep -Ev '^[[:space:]]*#|LAST_UPDATE_DATE|CREATION_DATE|^[[:space:]]*$' "$1" | sed 's/[[:space:]]*$//'; }
same_aol() { local x; x=$(aol_norm "$1"); [ -n "$x" ] && [ "$x" = "$(aol_norm "$2")" ]; }

warn_no_expect() {
    if ! command -v expect >/dev/null 2>&1; then
        echo "WARNING: expect is not installed. FNDLOAD / WFLOAD get the APPS password on their standard input"
        echo "         instead of answering a prompt; install expect to avoid it."
    fi
}
