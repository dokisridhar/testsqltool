#!/bin/bash
# Run on the SOURCE application tier: ./download.sh <environment file> [run]
set -u
cd "$(dirname "$0")" || exit 1
LIB="$(pwd)/lib"; mkdir -p logs
[ $# -ge 1 ] || { echo "Usage: ./download.sh <environment file> [run]"; exit 2; }
. "$1" ${2:-} >/dev/null 2>&1 </dev/null || { echo "@@ENV could not source $1"; exit 3; }
[ -n "${FND_TOP:-}" ] || { echo "@@ENV $1 did not set FND_TOP"; exit 3; }
if [ -z "${APPS_PWD:-}" ]; then read -rsp 'APPS password: ' APPS_PWD; echo; fi
export APPS_PWD
. "$LIB/common.sh"
warn_no_expect
ok() { echo "@@OK $1"; }
fail() { echo "@@FAIL $1: $(check_log "logs/$1.log" "$LOADER_ERRORS" | sed -n 2p | sed "s/^ *//")"; }
lct() { top_path "$1"; }
run_loader logs/lookup_type_custom_xxcenhid_eligible_item_types.ldt.log FNDLOAD apps 0 Y DOWNLOAD "$(lct '$FND_TOP/patch/115/import/aflvmlu.lct')" lookup_type_custom_xxcenhid_eligible_item_types.ldt FND_LOOKUP_TYPE APPLICATION_SHORT_NAME=CUSTOM LOOKUP_TYPE=XXCENHID_ELIGIBLE_ITEM_TYPES > /dev/null && [ -s lookup_type_custom_xxcenhid_eligible_item_types.ldt ] && ok lookup_type_custom_xxcenhid_eligible_item_types.ldt || fail lookup_type_custom_xxcenhid_eligible_item_types.ldt
run_loader logs/concurrent_program_xxcenhid_xxcenhid_appr_get_eligible_wfs.ldt.log FNDLOAD apps 0 Y DOWNLOAD "$(lct '$FND_TOP/patch/115/import/afcpprog.lct')" concurrent_program_xxcenhid_xxcenhid_appr_get_eligible_wfs.ldt PROGRAM APPLICATION_SHORT_NAME=XXCENHID CONCURRENT_PROGRAM_NAME=XXCENHID_APPR_GET_ELIGIBLE_WFS > /dev/null && [ -s concurrent_program_xxcenhid_xxcenhid_appr_get_eligible_wfs.ldt ] && ok concurrent_program_xxcenhid_xxcenhid_appr_get_eligible_wfs.ldt || fail concurrent_program_xxcenhid_xxcenhid_appr_get_eligible_wfs.ldt
run_loader logs/request_group_fnd_system_administrator_reports.ldt.log FNDLOAD apps 0 Y DOWNLOAD "$(lct '$FND_TOP/patch/115/import/afcpreqg.lct')" request_group_fnd_system_administrator_reports.ldt REQUEST_GROUP APPLICATION_SHORT_NAME=FND 'REQUEST_GROUP_NAME=System Administrator Reports' > /dev/null && [ -s request_group_fnd_system_administrator_reports.ldt ] && ok request_group_fnd_system_administrator_reports.ldt || fail request_group_fnd_system_administrator_reports.ldt
unset APPS_PWD
echo "Done; copy the files back next to deploy.sh (see the @@ lines above)"
