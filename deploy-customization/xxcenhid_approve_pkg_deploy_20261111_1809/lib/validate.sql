-- Validation of the bundle on the TARGET: run by deploy.sh as APPS; changes nothing.
SET SERVEROUTPUT ON SIZE UNLIMITED FORMAT WRAPPED
SET LINESIZE 32767 TRIMSPOOL ON TRIMOUT ON FEEDBACK OFF HEADING OFF PAGESIZE 0 DEFINE OFF VERIFY OFF
SET SQLBLANKLINES ON
DECLARE
  k NUMBER;
  PROCEDURE o(k VARCHAR2, f VARCHAR2, a VARCHAR2 := NULL, b VARCHAR2 := NULL, c VARCHAR2 := NULL) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('@@' || k || '|' || f || '|' || REPLACE(REPLACE(a, CHR(10), ' '), '|', '/') || '|'
                         || REPLACE(REPLACE(b, CHR(10), ' '), '|', '/') || '|' || REPLACE(REPLACE(c, CHR(10), ' '), '|', '/'));
  END;
BEGIN
  IF ad_zd.get_edition('PATCH') IS NOT NULL THEN
    o('FAIL', 'environment', 'adop cycle in progress', 'a patch edition exists while deploying in hotpatch mode', 'complete or abort the adop cycle first, or generate the bundle in adop mode');
  END IF;
  SELECT COUNT(*) INTO k FROM fnd_application WHERE application_short_name = 'CUSTOM';
  IF k = 0 THEN
    o('FAIL', 'application CUSTOM', 'custom application not registered', 'CUSTOM does not exist on the target', 'register the application (and its _TOP) on the target first');
  END IF;
  SELECT COUNT(*) INTO k FROM fnd_application WHERE application_short_name = 'FND';
  IF k = 0 THEN
    o('FAIL', 'application FND', 'custom application not registered', 'FND does not exist on the target', 'register the application (and its _TOP) on the target first');
  END IF;
  SELECT COUNT(*) INTO k FROM fnd_application WHERE application_short_name = 'XXCENHID';
  IF k = 0 THEN
    o('FAIL', 'application XXCENHID', 'custom application not registered', 'XXCENHID does not exist on the target', 'register the application (and its _TOP) on the target first');
  END IF;
  SELECT COUNT(*) INTO k FROM dba_users WHERE username = 'XXCENHID';
  IF k = 0 THEN
    o('FAIL', 'schema XXCENHID', 'custom schema missing', 'XXCENHID does not exist on the target', 'create the custom schema and register it with EBS (AD Splicer) first');
  ELSE
    SELECT COUNT(*) INTO k FROM fnd_oracle_userid WHERE oracle_username = 'XXCENHID';
    IF k = 0 THEN
      o('WARN', 'schema XXCENHID', 'custom schema not registered in EBS', 'XXCENHID is not in FND_ORACLE_USERID: deploying anyway; adop does not manage the schema, so check the editioning view step and the APPS synonym after deployment', '');
    END IF;
    SELECT COUNT(*) INTO k FROM session_privs WHERE privilege IN ('CREATE ANY TABLE', 'ALTER ANY TABLE', 'CREATE ANY INDEX', 'GRANT ANY OBJECT PRIVILEGE');
    IF k < 4 THEN
      o('NEEDPWD', 'XXCENHID', 'APPS cannot create or alter tables in XXCENHID');
    END IF;
  END IF;
EXCEPTION WHEN OTHERS THEN
  o('FAIL', 'environment', 'the check could not run', SQLERRM, 'APPS needs SELECT on the DBA_ views; fix the error and validate again');
END;
/

DECLARE
  k NUMBER;
  PROCEDURE o(k VARCHAR2, f VARCHAR2, a VARCHAR2 := NULL, b VARCHAR2 := NULL, c VARCHAR2 := NULL) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('@@' || k || '|' || f || '|' || REPLACE(REPLACE(a, CHR(10), ' '), '|', '/') || '|'
                         || REPLACE(REPLACE(b, CHR(10), ' '), '|', '/') || '|' || REPLACE(REPLACE(c, CHR(10), ' '), '|', '/'));
  END;
BEGIN
  o('FAIL', 'TABLE APPS.XXCENHID_DEBUG', 'custom table owned by APPS', 'EBS keeps custom tables in a registered custom schema; APPS holds only the synonym', 'create the table in the custom schema on the source (with a synonym in APPS) and generate the bundle again');
EXCEPTION WHEN OTHERS THEN
  o('FAIL', 'bundle', 'the check could not run', SQLERRM, 'APPS needs SELECT on the DBA_ views; fix the error and validate again');
END;
/

DECLARE
  k NUMBER;
  PROCEDURE o(k VARCHAR2, f VARCHAR2, a VARCHAR2 := NULL, b VARCHAR2 := NULL, c VARCHAR2 := NULL) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('@@' || k || '|' || f || '|' || REPLACE(REPLACE(a, CHR(10), ' '), '|', '/') || '|'
                         || REPLACE(REPLACE(b, CHR(10), ' '), '|', '/') || '|' || REPLACE(REPLACE(c, CHR(10), ' '), '|', '/'));
  END;
BEGIN
  SELECT COUNT(*) INTO k FROM dba_objects WHERE owner = 'XXCENHID' AND object_name = 'XXCENHID_NOTFNS_LIST_LINE_SEQ' AND object_type = 'SEQUENCE';
  IF k > 0 THEN o('SKIP', 'xxcenhid_notfns_list_line_seq.sql', 'already exists (kept with its current value)');
  ELSE o('PLAN', 'xxcenhid_notfns_list_line_seq.sql', 'create sequence XXCENHID.XXCENHID_NOTFNS_LIST_LINE_SEQ'); END IF;
EXCEPTION WHEN OTHERS THEN
  o('FAIL', 'xxcenhid_notfns_list_line_seq.sql', 'the check could not run', SQLERRM, 'APPS needs SELECT on the DBA_ views; fix the error and validate again');
END;
/

DECLARE
  k NUMBER;
  PROCEDURE o(k VARCHAR2, f VARCHAR2, a VARCHAR2 := NULL, b VARCHAR2 := NULL, c VARCHAR2 := NULL) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('@@' || k || '|' || f || '|' || REPLACE(REPLACE(a, CHR(10), ' '), '|', '/') || '|'
                         || REPLACE(REPLACE(b, CHR(10), ' '), '|', '/') || '|' || REPLACE(REPLACE(c, CHR(10), ' '), '|', '/'));
  END;
BEGIN
  SELECT COUNT(*) INTO k FROM dba_objects WHERE owner = 'XXCENHID' AND object_name = 'XXCENHID_NOTFNS_LIST_SEQ' AND object_type = 'SEQUENCE';
  IF k > 0 THEN o('SKIP', 'xxcenhid_notfns_list_seq.sql', 'already exists (kept with its current value)');
  ELSE o('PLAN', 'xxcenhid_notfns_list_seq.sql', 'create sequence XXCENHID.XXCENHID_NOTFNS_LIST_SEQ'); END IF;
EXCEPTION WHEN OTHERS THEN
  o('FAIL', 'xxcenhid_notfns_list_seq.sql', 'the check could not run', SQLERRM, 'APPS needs SELECT on the DBA_ views; fix the error and validate again');
END;
/

DECLARE
  TYPE r IS RECORD (n VARCHAR2(128), t VARCHAR2(128), l NUMBER, cl NUMBER, cu VARCHAR2(1), p NUMBER,
                    s NUMBER, nl VARCHAR2(1), d VARCHAR2(4000), spec VARCHAR2(400));
  TYPE rs IS TABLE OF r;
  TYPE ss IS TABLE OF VARCHAR2(32767);
  src rs := rs(); todo ss := ss();
  fails PLS_INTEGER := 0; k NUMBER; has_rows BOOLEAN := TRUE;
  tgt CONSTANT VARCHAR2(300) := '"APPS"."XXCENHID_DEBUG"';
  lbl CONSTANT VARCHAR2(300) := 'TABLE APPS.XXCENHID_DEBUG';
  PROCEDURE o(k VARCHAR2, f VARCHAR2, a VARCHAR2 := NULL, b VARCHAR2 := NULL, c VARCHAR2 := NULL) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('@@' || k || '|' || f || '|' || REPLACE(REPLACE(a, CHR(10), ' '), '|', '/') || '|'
                         || REPLACE(REPLACE(b, CHR(10), ' '), '|', '/') || '|' || REPLACE(REPLACE(c, CHR(10), ' '), '|', '/'));
  END;
  PROCEDURE c(n VARCHAR2, t VARCHAR2, l NUMBER, cl NUMBER, cu VARCHAR2, p NUMBER, s NUMBER, nl VARCHAR2,
              d VARCHAR2, spec VARCHAR2) IS
  BEGIN
    src.EXTEND; src(src.COUNT).n := n; src(src.COUNT).t := t; src(src.COUNT).l := l; src(src.COUNT).cl := cl;
    src(src.COUNT).cu := cu; src(src.COUNT).p := p; src(src.COUNT).s := s; src(src.COUNT).nl := nl;
    src(src.COUNT).d := d; src(src.COUNT).spec := spec;
  END;
  PROCEDURE fail(rule VARCHAR2, detail VARCHAR2, fix VARCHAR2) IS
  BEGIN fails := fails + 1; o('FAIL', lbl, rule, detail, fix); END;
  PROCEDURE ddl(stmt VARCHAR2) IS BEGIN todo.EXTEND; todo(todo.COUNT) := stmt; END;
  FUNCTION norm(v VARCHAR2) RETURN VARCHAR2 IS
  BEGIN RETURN UPPER(REGEXP_REPLACE(v, '^[[:space:]]+|[[:space:]]+$', '')); END;
  FUNCTION has_nulls(col VARCHAR2) RETURN BOOLEAN IS x NUMBER;
  BEGIN
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || tgt || ' WHERE "' || col || '" IS NULL AND ROWNUM = 1' INTO x;
    RETURN x > 0;
  EXCEPTION WHEN OTHERS THEN RETURN TRUE;
  END;
BEGIN
  c('CORRELATION_ID', 'VARCHAR2', 500, 500, 'B', NULL, NULL, 'Y', NULL, 'VARCHAR2(500 BYTE)');
  c('RESPONSE_MESG_TXT', 'CLOB', 4000, 4000, '', NULL, NULL, 'Y', NULL, 'CLOB');
  c('CREATION_DATE', 'DATE', 7, 7, '', NULL, NULL, 'Y', NULL, 'DATE');
  c('CREATED_BY', 'NUMBER', 22, 22, '', NULL, NULL, 'Y', NULL, 'NUMBER');
  SELECT COUNT(*) INTO k FROM dba_tables WHERE owner = 'APPS' AND table_name = 'XXCENHID_DEBUG';
  IF k = 0 THEN
    o('PLAN', 'xxcenhid_debug_table.sql', 'create table ' || tgt);
    RETURN;
  END IF;
  BEGIN
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || tgt || ' WHERE ROWNUM = 1' INTO k;
    has_rows := k > 0;
  EXCEPTION WHEN OTHERS THEN has_rows := TRUE;
  END;
  FOR i IN 1 .. src.COUNT LOOP
    DECLARE
      t r; found BOOLEAN := FALSE; narrow BOOLEAN := FALSE; wider BOOLEAN := FALSE; s r := src(i);
    BEGIN
      FOR x IN (SELECT data_type, data_length, char_length, char_used, data_precision, data_scale, nullable,
                       data_default FROM dba_tab_columns
                 WHERE owner = 'APPS' AND table_name = 'XXCENHID_DEBUG' AND column_name = s.n) LOOP
        found := TRUE; t.t := x.data_type; t.l := x.data_length; t.cl := x.char_length;
        t.cu := x.char_used; t.p := x.data_precision; t.s := x.data_scale; t.nl := x.nullable;
        t.d := SUBSTR(x.data_default, 1, 4000);
      END LOOP;
      IF NOT found THEN
        IF s.nl = 'N' AND s.d IS NULL AND has_rows THEN
          fail('new NOT NULL column without a default', s.n || ': the table has rows',
               'add it nullable with a default, fill it, then make it NOT NULL in a Manual step');
        ELSE
          ddl('ALTER TABLE ' || tgt || ' ADD ("' || s.n || '" ' || s.spec
              || CASE WHEN s.d IS NOT NULL THEN ' DEFAULT ' || s.d END
              || CASE WHEN s.nl = 'N' THEN ' NOT NULL' END || ')');
        END IF;
      ELSIF t.t <> s.t THEN
        fail('data type change', s.n || ': ' || t.t || ' on the target, ' || s.t || ' in the bundle',
             'migrate it in a Manual step (add a new column, copy the data, then drop the old one)');
      ELSE
        IF s.t IN ('VARCHAR2', 'CHAR', 'NVARCHAR2', 'NCHAR') THEN
          IF s.cl < t.cl THEN narrow := TRUE;
          ELSIF s.cl > t.cl OR NVL(s.cu, '-') <> NVL(t.cu, '-') THEN wider := TRUE; END IF;
        ELSIF s.t = 'RAW' THEN
          IF s.l < t.l THEN narrow := TRUE; ELSIF s.l > t.l THEN wider := TRUE; END IF;
        ELSIF s.t IN ('NUMBER', 'FLOAT') THEN
          IF t.p IS NULL AND t.s IS NULL THEN
            narrow := s.p IS NOT NULL OR s.s IS NOT NULL;
          ELSIF s.p IS NULL AND s.s IS NULL THEN wider := TRUE;
          ELSIF NVL(s.s, 0) < NVL(t.s, 0) OR NVL(s.p, 38) - NVL(s.s, 0) < NVL(t.p, 38) - NVL(t.s, 0) THEN
            narrow := TRUE;
          ELSIF NVL(s.p, 38) <> NVL(t.p, 38) OR NVL(s.s, 0) <> NVL(t.s, 0) THEN wider := TRUE;
          END IF;
        END IF;
        IF narrow THEN
          fail('column made smaller', s.n || ': ' || s.spec || ' in the bundle is smaller than the target''s',
               'check the data fits, then -- ALTER TABLE ' || tgt || ' MODIFY ("' || s.n || '" ' || s.spec
               || ') in a Manual step');
        ELSIF wider THEN
          ddl('ALTER TABLE ' || tgt || ' MODIFY ("' || s.n || '" ' || s.spec || ')');
        END IF;
        IF NVL(norm(s.d), '~') <> NVL(norm(t.d), '~') THEN
          ddl('ALTER TABLE ' || tgt || ' MODIFY ("' || s.n || '" DEFAULT ' || NVL(s.d, 'NULL') || ')');
        END IF;
        IF s.nl = 'N' AND t.nl = 'Y' THEN
          IF has_nulls(s.n) THEN
            fail('NOT NULL on a column with nulls', s.n || ' has null values on the target',
                 'fill the nulls in a Manual step first');
          ELSE
            ddl('ALTER TABLE ' || tgt || ' MODIFY ("' || s.n || '" NOT NULL)');
          END IF;
        ELSIF s.nl = 'Y' AND t.nl = 'N' THEN
          ddl('ALTER TABLE ' || tgt || ' MODIFY ("' || s.n || '" NULL)');
        END IF;
      END IF;
    END;
  END LOOP;
  FOR x IN (SELECT column_name FROM dba_tab_columns WHERE owner = 'APPS' AND table_name = 'XXCENHID_DEBUG'
              AND column_name NOT LIKE '%#%' AND column_name NOT IN ('CORRELATION_ID', 'RESPONSE_MESG_TXT', 'CREATION_DATE', 'CREATED_BY')) LOOP
    fail('column only on the target', x.column_name || ' is not in the bundle (its data would be lost)',
         'add it back on the source, or -- ALTER TABLE ' || tgt || ' DROP COLUMN "' || x.column_name
         || '" in a Manual step if it really goes');
  END LOOP;
  IF fails > 0 THEN
    RETURN;
  END IF;
  IF todo.COUNT = 0 THEN
    o('SKIP', 'xxcenhid_debug_table.sql', 'the target table already matches');
    RETURN;
  END IF;
  FOR i IN 1 .. todo.COUNT LOOP
    o('PLAN', 'xxcenhid_debug_table.sql', todo(i));
  END LOOP;
END;
/

DECLARE
  k NUMBER;
  PROCEDURE o(k VARCHAR2, f VARCHAR2, a VARCHAR2 := NULL, b VARCHAR2 := NULL, c VARCHAR2 := NULL) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('@@' || k || '|' || f || '|' || REPLACE(REPLACE(a, CHR(10), ' '), '|', '/') || '|'
                         || REPLACE(REPLACE(b, CHR(10), ' '), '|', '/') || '|' || REPLACE(REPLACE(c, CHR(10), ' '), '|', '/'));
  END;
BEGIN
  SELECT COUNT(*) INTO k FROM dual WHERE EXISTS (SELECT 1 FROM dba_indexes WHERE owner = 'APPS' AND index_name = 'SYS_IL0001007142C00002$$');
  IF k > 0 THEN o('SKIP', 'xxcenhid_debug_indexes.sql', 'every index is already there');
  ELSE o('PLAN', 'xxcenhid_debug_indexes.sql', 'create the missing indexes'); END IF;
EXCEPTION WHEN OTHERS THEN
  o('FAIL', 'xxcenhid_debug_indexes.sql', 'the check could not run', SQLERRM, 'APPS needs SELECT on the DBA_ views; fix the error and validate again');
END;
/

DECLARE
  TYPE r IS RECORD (n VARCHAR2(128), t VARCHAR2(128), l NUMBER, cl NUMBER, cu VARCHAR2(1), p NUMBER,
                    s NUMBER, nl VARCHAR2(1), d VARCHAR2(4000), spec VARCHAR2(400));
  TYPE rs IS TABLE OF r;
  TYPE ss IS TABLE OF VARCHAR2(32767);
  src rs := rs(); todo ss := ss();
  fails PLS_INTEGER := 0; k NUMBER; has_rows BOOLEAN := TRUE;
  tgt CONSTANT VARCHAR2(300) := '"XXCENHID"."XXCENHID_NOTFNS_LIST_LINES"';
  lbl CONSTANT VARCHAR2(300) := 'TABLE XXCENHID.XXCENHID_NOTFNS_LIST_LINES';
  PROCEDURE o(k VARCHAR2, f VARCHAR2, a VARCHAR2 := NULL, b VARCHAR2 := NULL, c VARCHAR2 := NULL) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('@@' || k || '|' || f || '|' || REPLACE(REPLACE(a, CHR(10), ' '), '|', '/') || '|'
                         || REPLACE(REPLACE(b, CHR(10), ' '), '|', '/') || '|' || REPLACE(REPLACE(c, CHR(10), ' '), '|', '/'));
  END;
  PROCEDURE c(n VARCHAR2, t VARCHAR2, l NUMBER, cl NUMBER, cu VARCHAR2, p NUMBER, s NUMBER, nl VARCHAR2,
              d VARCHAR2, spec VARCHAR2) IS
  BEGIN
    src.EXTEND; src(src.COUNT).n := n; src(src.COUNT).t := t; src(src.COUNT).l := l; src(src.COUNT).cl := cl;
    src(src.COUNT).cu := cu; src(src.COUNT).p := p; src(src.COUNT).s := s; src(src.COUNT).nl := nl;
    src(src.COUNT).d := d; src(src.COUNT).spec := spec;
  END;
  PROCEDURE fail(rule VARCHAR2, detail VARCHAR2, fix VARCHAR2) IS
  BEGIN fails := fails + 1; o('FAIL', lbl, rule, detail, fix); END;
  PROCEDURE ddl(stmt VARCHAR2) IS BEGIN todo.EXTEND; todo(todo.COUNT) := stmt; END;
  FUNCTION norm(v VARCHAR2) RETURN VARCHAR2 IS
  BEGIN RETURN UPPER(REGEXP_REPLACE(v, '^[[:space:]]+|[[:space:]]+$', '')); END;
  FUNCTION has_nulls(col VARCHAR2) RETURN BOOLEAN IS x NUMBER;
  BEGIN
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || tgt || ' WHERE "' || col || '" IS NULL AND ROWNUM = 1' INTO x;
    RETURN x > 0;
  EXCEPTION WHEN OTHERS THEN RETURN TRUE;
  END;
BEGIN
  c('LIST_LINE_ID', 'NUMBER', 22, 22, '', NULL, NULL, 'Y', NULL, 'NUMBER');
  c('PROCESS_ACTIVITY', 'NUMBER', 22, 22, '', NULL, NULL, 'Y', NULL, 'NUMBER');
  c('ACTIVITY_STATUS', 'VARCHAR2', 50, 50, 'B', NULL, NULL, 'Y', NULL, 'VARCHAR2(50 BYTE)');
  c('ACTIVITY_TYPE', 'VARCHAR2', 50, 50, 'B', NULL, NULL, 'Y', NULL, 'VARCHAR2(50 BYTE)');
  c('ACTIVITY_DISPLAY_NAME', 'VARCHAR2', 240, 240, 'B', NULL, NULL, 'Y', NULL, 'VARCHAR2(240 BYTE)');
  c('PARENT_ACTIVITY_DISPLAY', 'VARCHAR2', 240, 240, 'B', NULL, NULL, 'Y', NULL, 'VARCHAR2(240 BYTE)');
  c('ACTIVITY_NAME', 'VARCHAR2', 240, 240, 'B', NULL, NULL, 'Y', NULL, 'VARCHAR2(240 BYTE)');
  c('PARENT_ACTIVITY', 'VARCHAR2', 240, 240, 'B', NULL, NULL, 'Y', NULL, 'VARCHAR2(240 BYTE)');
  c('NID', 'NUMBER', 22, 22, '', NULL, NULL, 'Y', NULL, 'NUMBER');
  c('ASSIGNED_USER', 'VARCHAR2', 300, 300, 'B', NULL, NULL, 'Y', NULL, 'VARCHAR2(300 BYTE)');
  c('NOTIFICATION_SUBJECT', 'VARCHAR2', 2000, 2000, 'B', NULL, NULL, 'Y', NULL, 'VARCHAR2(2000 BYTE)');
  c('ROLE_EMAIL_ADDRESS', 'VARCHAR2', 300, 300, 'B', NULL, NULL, 'Y', NULL, 'VARCHAR2(300 BYTE)');
  c('ROLE_DISPLAY_NAME', 'VARCHAR2', 300, 300, 'B', NULL, NULL, 'Y', NULL, 'VARCHAR2(300 BYTE)');
  c('HID_APPR_MAPPED_USER', 'VARCHAR2', 300, 300, 'B', NULL, NULL, 'Y', NULL, 'VARCHAR2(300 BYTE)');
  c('HID_APPR_NOTFN_SENT', 'VARCHAR2', 30, 30, 'B', NULL, NULL, 'Y', NULL, 'VARCHAR2(30 BYTE)');
  c('HID_APPR_NOTFN_RESPONSE', 'VARCHAR2', 4000, 4000, 'B', NULL, NULL, 'Y', NULL, 'VARCHAR2(4000 BYTE)');
  c('HID_APPR_PROCESS_STATUS', 'VARCHAR2', 30, 30, 'B', NULL, NULL, 'Y', NULL, 'VARCHAR2(30 BYTE)');
  c('ERROR_MESSAGE', 'VARCHAR2', 4000, 4000, 'B', NULL, NULL, 'Y', NULL, 'VARCHAR2(4000 BYTE)');
  c('CREATION_DATE', 'DATE', 7, 7, '', NULL, NULL, 'Y', NULL, 'DATE');
  c('CREATED_BY', 'NUMBER', 22, 22, '', NULL, NULL, 'Y', NULL, 'NUMBER');
  c('LAST_UPDATE_DATE', 'DATE', 7, 7, '', NULL, NULL, 'Y', NULL, 'DATE');
  c('LAST_UPDATED_BY', 'NUMBER', 22, 22, '', NULL, NULL, 'Y', NULL, 'NUMBER');
  c('LIST_ID', 'NUMBER', 22, 22, '', NULL, NULL, 'Y', NULL, 'NUMBER');
  c('CORRELATION_ID', 'VARCHAR2', 500, 500, 'B', NULL, NULL, 'Y', NULL, 'VARCHAR2(500 BYTE)');
  SELECT COUNT(*) INTO k FROM dba_tables WHERE owner = 'XXCENHID' AND table_name = 'XXCENHID_NOTFNS_LIST_LINES';
  IF k = 0 THEN
    o('PLAN', 'xxcenhid_notfns_list_lines_table.sql', 'create table ' || tgt);
    RETURN;
  END IF;
  BEGIN
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || tgt || ' WHERE ROWNUM = 1' INTO k;
    has_rows := k > 0;
  EXCEPTION WHEN OTHERS THEN has_rows := TRUE;
  END;
  FOR i IN 1 .. src.COUNT LOOP
    DECLARE
      t r; found BOOLEAN := FALSE; narrow BOOLEAN := FALSE; wider BOOLEAN := FALSE; s r := src(i);
    BEGIN
      FOR x IN (SELECT data_type, data_length, char_length, char_used, data_precision, data_scale, nullable,
                       data_default FROM dba_tab_columns
                 WHERE owner = 'XXCENHID' AND table_name = 'XXCENHID_NOTFNS_LIST_LINES' AND column_name = s.n) LOOP
        found := TRUE; t.t := x.data_type; t.l := x.data_length; t.cl := x.char_length;
        t.cu := x.char_used; t.p := x.data_precision; t.s := x.data_scale; t.nl := x.nullable;
        t.d := SUBSTR(x.data_default, 1, 4000);
      END LOOP;
      IF NOT found THEN
        IF s.nl = 'N' AND s.d IS NULL AND has_rows THEN
          fail('new NOT NULL column without a default', s.n || ': the table has rows',
               'add it nullable with a default, fill it, then make it NOT NULL in a Manual step');
        ELSE
          ddl('ALTER TABLE ' || tgt || ' ADD ("' || s.n || '" ' || s.spec
              || CASE WHEN s.d IS NOT NULL THEN ' DEFAULT ' || s.d END
              || CASE WHEN s.nl = 'N' THEN ' NOT NULL' END || ')');
        END IF;
      ELSIF t.t <> s.t THEN
        fail('data type change', s.n || ': ' || t.t || ' on the target, ' || s.t || ' in the bundle',
             'migrate it in a Manual step (add a new column, copy the data, then drop the old one)');
      ELSE
        IF s.t IN ('VARCHAR2', 'CHAR', 'NVARCHAR2', 'NCHAR') THEN
          IF s.cl < t.cl THEN narrow := TRUE;
          ELSIF s.cl > t.cl OR NVL(s.cu, '-') <> NVL(t.cu, '-') THEN wider := TRUE; END IF;
        ELSIF s.t = 'RAW' THEN
          IF s.l < t.l THEN narrow := TRUE; ELSIF s.l > t.l THEN wider := TRUE; END IF;
        ELSIF s.t IN ('NUMBER', 'FLOAT') THEN
          IF t.p IS NULL AND t.s IS NULL THEN
            narrow := s.p IS NOT NULL OR s.s IS NOT NULL;
          ELSIF s.p IS NULL AND s.s IS NULL THEN wider := TRUE;
          ELSIF NVL(s.s, 0) < NVL(t.s, 0) OR NVL(s.p, 38) - NVL(s.s, 0) < NVL(t.p, 38) - NVL(t.s, 0) THEN
            narrow := TRUE;
          ELSIF NVL(s.p, 38) <> NVL(t.p, 38) OR NVL(s.s, 0) <> NVL(t.s, 0) THEN wider := TRUE;
          END IF;
        END IF;
        IF narrow THEN
          fail('column made smaller', s.n || ': ' || s.spec || ' in the bundle is smaller than the target''s',
               'check the data fits, then -- ALTER TABLE ' || tgt || ' MODIFY ("' || s.n || '" ' || s.spec
               || ') in a Manual step');
        ELSIF wider THEN
          ddl('ALTER TABLE ' || tgt || ' MODIFY ("' || s.n || '" ' || s.spec || ')');
        END IF;
        IF NVL(norm(s.d), '~') <> NVL(norm(t.d), '~') THEN
          ddl('ALTER TABLE ' || tgt || ' MODIFY ("' || s.n || '" DEFAULT ' || NVL(s.d, 'NULL') || ')');
        END IF;
        IF s.nl = 'N' AND t.nl = 'Y' THEN
          IF has_nulls(s.n) THEN
            fail('NOT NULL on a column with nulls', s.n || ' has null values on the target',
                 'fill the nulls in a Manual step first');
          ELSE
            ddl('ALTER TABLE ' || tgt || ' MODIFY ("' || s.n || '" NOT NULL)');
          END IF;
        ELSIF s.nl = 'Y' AND t.nl = 'N' THEN
          ddl('ALTER TABLE ' || tgt || ' MODIFY ("' || s.n || '" NULL)');
        END IF;
      END IF;
    END;
  END LOOP;
  FOR x IN (SELECT column_name FROM dba_tab_columns WHERE owner = 'XXCENHID' AND table_name = 'XXCENHID_NOTFNS_LIST_LINES'
              AND column_name NOT LIKE '%#%' AND column_name NOT IN ('LIST_LINE_ID', 'PROCESS_ACTIVITY', 'ACTIVITY_STATUS', 'ACTIVITY_TYPE', 'ACTIVITY_DISPLAY_NAME', 'PARENT_ACTIVITY_DISPLAY', 'ACTIVITY_NAME', 'PARENT_ACTIVITY', 'NID', 'ASSIGNED_USER', 'NOTIFICATION_SUBJECT', 'ROLE_EMAIL_ADDRESS', 'ROLE_DISPLAY_NAME', 'HID_APPR_MAPPED_USER', 'HID_APPR_NOTFN_SENT', 'HID_APPR_NOTFN_RESPONSE', 'HID_APPR_PROCESS_STATUS', 'ERROR_MESSAGE', 'CREATION_DATE', 'CREATED_BY', 'LAST_UPDATE_DATE', 'LAST_UPDATED_BY', 'LIST_ID', 'CORRELATION_ID')) LOOP
    fail('column only on the target', x.column_name || ' is not in the bundle (its data would be lost)',
         'add it back on the source, or -- ALTER TABLE ' || tgt || ' DROP COLUMN "' || x.column_name
         || '" in a Manual step if it really goes');
  END LOOP;
  IF fails > 0 THEN
    RETURN;
  END IF;
  IF todo.COUNT = 0 THEN
    o('SKIP', 'xxcenhid_notfns_list_lines_table.sql', 'the target table already matches');
    RETURN;
  END IF;
  FOR i IN 1 .. todo.COUNT LOOP
    o('PLAN', 'xxcenhid_notfns_list_lines_table.sql', todo(i));
  END LOOP;
END;
/

DECLARE
  TYPE r IS RECORD (n VARCHAR2(128), t VARCHAR2(128), l NUMBER, cl NUMBER, cu VARCHAR2(1), p NUMBER,
                    s NUMBER, nl VARCHAR2(1), d VARCHAR2(4000), spec VARCHAR2(400));
  TYPE rs IS TABLE OF r;
  TYPE ss IS TABLE OF VARCHAR2(32767);
  src rs := rs(); todo ss := ss();
  fails PLS_INTEGER := 0; k NUMBER; has_rows BOOLEAN := TRUE;
  tgt CONSTANT VARCHAR2(300) := '"XXCENHID"."XXCENHID_NOTIFICATIONS_LIST"';
  lbl CONSTANT VARCHAR2(300) := 'TABLE XXCENHID.XXCENHID_NOTIFICATIONS_LIST';
  PROCEDURE o(k VARCHAR2, f VARCHAR2, a VARCHAR2 := NULL, b VARCHAR2 := NULL, c VARCHAR2 := NULL) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('@@' || k || '|' || f || '|' || REPLACE(REPLACE(a, CHR(10), ' '), '|', '/') || '|'
                         || REPLACE(REPLACE(b, CHR(10), ' '), '|', '/') || '|' || REPLACE(REPLACE(c, CHR(10), ' '), '|', '/'));
  END;
  PROCEDURE c(n VARCHAR2, t VARCHAR2, l NUMBER, cl NUMBER, cu VARCHAR2, p NUMBER, s NUMBER, nl VARCHAR2,
              d VARCHAR2, spec VARCHAR2) IS
  BEGIN
    src.EXTEND; src(src.COUNT).n := n; src(src.COUNT).t := t; src(src.COUNT).l := l; src(src.COUNT).cl := cl;
    src(src.COUNT).cu := cu; src(src.COUNT).p := p; src(src.COUNT).s := s; src(src.COUNT).nl := nl;
    src(src.COUNT).d := d; src(src.COUNT).spec := spec;
  END;
  PROCEDURE fail(rule VARCHAR2, detail VARCHAR2, fix VARCHAR2) IS
  BEGIN fails := fails + 1; o('FAIL', lbl, rule, detail, fix); END;
  PROCEDURE ddl(stmt VARCHAR2) IS BEGIN todo.EXTEND; todo(todo.COUNT) := stmt; END;
  FUNCTION norm(v VARCHAR2) RETURN VARCHAR2 IS
  BEGIN RETURN UPPER(REGEXP_REPLACE(v, '^[[:space:]]+|[[:space:]]+$', '')); END;
  FUNCTION has_nulls(col VARCHAR2) RETURN BOOLEAN IS x NUMBER;
  BEGIN
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || tgt || ' WHERE "' || col || '" IS NULL AND ROWNUM = 1' INTO x;
    RETURN x > 0;
  EXCEPTION WHEN OTHERS THEN RETURN TRUE;
  END;
BEGIN
  c('ITEM_TYPE', 'VARCHAR2', 8, 8, 'B', NULL, NULL, 'N', NULL, 'VARCHAR2(8 BYTE)');
  c('ITEM_KEY', 'VARCHAR2', 240, 240, 'B', NULL, NULL, 'N', NULL, 'VARCHAR2(240 BYTE)');
  c('ROOT_ACTIVITY', 'VARCHAR2', 30, 30, 'B', NULL, NULL, 'N', NULL, 'VARCHAR2(30 BYTE)');
  c('PROCESS_NAME', 'VARCHAR2', 80, 80, 'B', NULL, NULL, 'N', NULL, 'VARCHAR2(80 BYTE)');
  c('ROOT_ACTIVITY_VERSION', 'NUMBER', 22, 22, '', NULL, NULL, 'N', NULL, 'NUMBER');
  c('OWNER_ROLE', 'VARCHAR2', 320, 320, 'B', NULL, NULL, 'Y', NULL, 'VARCHAR2(320 BYTE)');
  c('PARENT_ITEM_TYPE', 'VARCHAR2', 8, 8, 'B', NULL, NULL, 'Y', NULL, 'VARCHAR2(8 BYTE)');
  c('PARENT_ITEM_KEY', 'VARCHAR2', 240, 240, 'B', NULL, NULL, 'Y', NULL, 'VARCHAR2(240 BYTE)');
  c('PARENT_CONTEXT', 'VARCHAR2', 2000, 2000, 'B', NULL, NULL, 'Y', NULL, 'VARCHAR2(2000 BYTE)');
  c('BEGIN_DATE', 'DATE', 7, 7, '', NULL, NULL, 'N', NULL, 'DATE');
  c('END_DATE', 'DATE', 7, 7, '', NULL, NULL, 'Y', NULL, 'DATE');
  c('USER_KEY', 'VARCHAR2', 240, 240, 'B', NULL, NULL, 'Y', NULL, 'VARCHAR2(240 BYTE)');
  c('NAME', 'VARCHAR2', 8, 8, 'B', NULL, NULL, 'N', NULL, 'VARCHAR2(8 BYTE)');
  c('DISPLAY_NAME', 'VARCHAR2', 80, 80, 'B', NULL, NULL, 'N', NULL, 'VARCHAR2(80 BYTE)');
  c('ROLE_NAME', 'VARCHAR2', 4000, 4000, 'B', NULL, NULL, 'Y', NULL, 'VARCHAR2(4000 BYTE)');
  c('STATUS_CODE', 'VARCHAR2', 4000, 4000, 'B', NULL, NULL, 'Y', NULL, 'VARCHAR2(4000 BYTE)');
  c('ROLE_EMAIL', 'VARCHAR2', 4000, 4000, 'B', NULL, NULL, 'Y', NULL, 'VARCHAR2(4000 BYTE)');
  c('LIST_ID', 'NUMBER', 22, 22, '', NULL, NULL, 'Y', NULL, 'NUMBER');
  c('CREATION_DATE', 'DATE', 7, 7, '', NULL, NULL, 'Y', NULL, 'DATE');
  c('CREATED_BY', 'NUMBER', 22, 22, '', NULL, NULL, 'Y', NULL, 'NUMBER');
  c('LAST_UPDATE_DATE', 'DATE', 7, 7, '', NULL, NULL, 'Y', NULL, 'DATE');
  c('LAST_UPDATED_BY', 'NUMBER', 22, 22, '', NULL, NULL, 'Y', NULL, 'NUMBER');
  SELECT COUNT(*) INTO k FROM dba_tables WHERE owner = 'XXCENHID' AND table_name = 'XXCENHID_NOTIFICATIONS_LIST';
  IF k = 0 THEN
    o('PLAN', 'xxcenhid_notifications_list_table.sql', 'create table ' || tgt);
    RETURN;
  END IF;
  BEGIN
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || tgt || ' WHERE ROWNUM = 1' INTO k;
    has_rows := k > 0;
  EXCEPTION WHEN OTHERS THEN has_rows := TRUE;
  END;
  FOR i IN 1 .. src.COUNT LOOP
    DECLARE
      t r; found BOOLEAN := FALSE; narrow BOOLEAN := FALSE; wider BOOLEAN := FALSE; s r := src(i);
    BEGIN
      FOR x IN (SELECT data_type, data_length, char_length, char_used, data_precision, data_scale, nullable,
                       data_default FROM dba_tab_columns
                 WHERE owner = 'XXCENHID' AND table_name = 'XXCENHID_NOTIFICATIONS_LIST' AND column_name = s.n) LOOP
        found := TRUE; t.t := x.data_type; t.l := x.data_length; t.cl := x.char_length;
        t.cu := x.char_used; t.p := x.data_precision; t.s := x.data_scale; t.nl := x.nullable;
        t.d := SUBSTR(x.data_default, 1, 4000);
      END LOOP;
      IF NOT found THEN
        IF s.nl = 'N' AND s.d IS NULL AND has_rows THEN
          fail('new NOT NULL column without a default', s.n || ': the table has rows',
               'add it nullable with a default, fill it, then make it NOT NULL in a Manual step');
        ELSE
          ddl('ALTER TABLE ' || tgt || ' ADD ("' || s.n || '" ' || s.spec
              || CASE WHEN s.d IS NOT NULL THEN ' DEFAULT ' || s.d END
              || CASE WHEN s.nl = 'N' THEN ' NOT NULL' END || ')');
        END IF;
      ELSIF t.t <> s.t THEN
        fail('data type change', s.n || ': ' || t.t || ' on the target, ' || s.t || ' in the bundle',
             'migrate it in a Manual step (add a new column, copy the data, then drop the old one)');
      ELSE
        IF s.t IN ('VARCHAR2', 'CHAR', 'NVARCHAR2', 'NCHAR') THEN
          IF s.cl < t.cl THEN narrow := TRUE;
          ELSIF s.cl > t.cl OR NVL(s.cu, '-') <> NVL(t.cu, '-') THEN wider := TRUE; END IF;
        ELSIF s.t = 'RAW' THEN
          IF s.l < t.l THEN narrow := TRUE; ELSIF s.l > t.l THEN wider := TRUE; END IF;
        ELSIF s.t IN ('NUMBER', 'FLOAT') THEN
          IF t.p IS NULL AND t.s IS NULL THEN
            narrow := s.p IS NOT NULL OR s.s IS NOT NULL;
          ELSIF s.p IS NULL AND s.s IS NULL THEN wider := TRUE;
          ELSIF NVL(s.s, 0) < NVL(t.s, 0) OR NVL(s.p, 38) - NVL(s.s, 0) < NVL(t.p, 38) - NVL(t.s, 0) THEN
            narrow := TRUE;
          ELSIF NVL(s.p, 38) <> NVL(t.p, 38) OR NVL(s.s, 0) <> NVL(t.s, 0) THEN wider := TRUE;
          END IF;
        END IF;
        IF narrow THEN
          fail('column made smaller', s.n || ': ' || s.spec || ' in the bundle is smaller than the target''s',
               'check the data fits, then -- ALTER TABLE ' || tgt || ' MODIFY ("' || s.n || '" ' || s.spec
               || ') in a Manual step');
        ELSIF wider THEN
          ddl('ALTER TABLE ' || tgt || ' MODIFY ("' || s.n || '" ' || s.spec || ')');
        END IF;
        IF NVL(norm(s.d), '~') <> NVL(norm(t.d), '~') THEN
          ddl('ALTER TABLE ' || tgt || ' MODIFY ("' || s.n || '" DEFAULT ' || NVL(s.d, 'NULL') || ')');
        END IF;
        IF s.nl = 'N' AND t.nl = 'Y' THEN
          IF has_nulls(s.n) THEN
            fail('NOT NULL on a column with nulls', s.n || ' has null values on the target',
                 'fill the nulls in a Manual step first');
          ELSE
            ddl('ALTER TABLE ' || tgt || ' MODIFY ("' || s.n || '" NOT NULL)');
          END IF;
        ELSIF s.nl = 'Y' AND t.nl = 'N' THEN
          ddl('ALTER TABLE ' || tgt || ' MODIFY ("' || s.n || '" NULL)');
        END IF;
      END IF;
    END;
  END LOOP;
  FOR x IN (SELECT column_name FROM dba_tab_columns WHERE owner = 'XXCENHID' AND table_name = 'XXCENHID_NOTIFICATIONS_LIST'
              AND column_name NOT LIKE '%#%' AND column_name NOT IN ('ITEM_TYPE', 'ITEM_KEY', 'ROOT_ACTIVITY', 'PROCESS_NAME', 'ROOT_ACTIVITY_VERSION', 'OWNER_ROLE', 'PARENT_ITEM_TYPE', 'PARENT_ITEM_KEY', 'PARENT_CONTEXT', 'BEGIN_DATE', 'END_DATE', 'USER_KEY', 'NAME', 'DISPLAY_NAME', 'ROLE_NAME', 'STATUS_CODE', 'ROLE_EMAIL', 'LIST_ID', 'CREATION_DATE', 'CREATED_BY', 'LAST_UPDATE_DATE', 'LAST_UPDATED_BY')) LOOP
    fail('column only on the target', x.column_name || ' is not in the bundle (its data would be lost)',
         'add it back on the source, or -- ALTER TABLE ' || tgt || ' DROP COLUMN "' || x.column_name
         || '" in a Manual step if it really goes');
  END LOOP;
  IF fails > 0 THEN
    RETURN;
  END IF;
  IF todo.COUNT = 0 THEN
    o('SKIP', 'xxcenhid_notifications_list_table.sql', 'the target table already matches');
    RETURN;
  END IF;
  FOR i IN 1 .. todo.COUNT LOOP
    o('PLAN', 'xxcenhid_notifications_list_table.sql', todo(i));
  END LOOP;
END;
/

DECLARE
  k NUMBER;
  h NUMBER; bad NUMBER;
  PROCEDURE o(k VARCHAR2, f VARCHAR2, a VARCHAR2 := NULL, b VARCHAR2 := NULL, c VARCHAR2 := NULL) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('@@' || k || '|' || f || '|' || REPLACE(REPLACE(a, CHR(10), ' '), '|', '/') || '|'
                         || REPLACE(REPLACE(b, CHR(10), ' '), '|', '/') || '|' || REPLACE(REPLACE(c, CHR(10), ' '), '|', '/'));
  END;
BEGIN
  SELECT COUNT(*), SUM(ORA_HASH(s.line || ':' || RTRIM(s.text, ' ' || CHR(9) || CHR(10) || CHR(13)))) INTO k, h FROM dba_source s WHERE s.owner = 'APPS' AND s.name = 'XXCENHID_APPROVE_PKG' AND s.type = 'PACKAGE' AND s.line > 1;
  SELECT COUNT(*) INTO bad FROM dba_objects WHERE owner = 'APPS' AND object_name = 'XXCENHID_APPROVE_PKG' AND object_type = 'PACKAGE' AND status <> 'VALID';
  IF k = 24 AND h = 57012725973 AND bad = 0 THEN o('SKIP', 'xxcenhid_approve_pkg.pks', 'the target has the same source and it is valid');
  ELSE o('PLAN', 'xxcenhid_approve_pkg.pks', CASE WHEN k = 0 THEN 'create' ELSE 'replace (source differs or invalid)' END || ' package APPS.XXCENHID_APPROVE_PKG'); END IF;
EXCEPTION WHEN OTHERS THEN
  o('FAIL', 'xxcenhid_approve_pkg.pks', 'the check could not run', SQLERRM, 'APPS needs SELECT on the DBA_ views; fix the error and validate again');
END;
/

DECLARE
  k NUMBER;
  PROCEDURE o(k VARCHAR2, f VARCHAR2, a VARCHAR2 := NULL, b VARCHAR2 := NULL, c VARCHAR2 := NULL) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('@@' || k || '|' || f || '|' || REPLACE(REPLACE(a, CHR(10), ' '), '|', '/') || '|'
                         || REPLACE(REPLACE(b, CHR(10), ' '), '|', '/') || '|' || REPLACE(REPLACE(c, CHR(10), ' '), '|', '/'));
  END;
BEGIN
  SELECT COUNT(*) INTO k FROM dual WHERE EXISTS (SELECT 1 FROM dba_synonyms WHERE owner = 'APPS' AND synonym_name = 'XXCENHID_NOTFNS_LIST_LINE_SEQ' AND table_owner = 'XXCENHID' AND table_name IN ('XXCENHID_NOTFNS_LIST_LINE_SEQ', 'XXCENHID_NOTFNS_LIST_LINE_SEQ#'));
  IF k > 0 THEN o('SKIP', 'xxcenhid_notfns_list_line_seq_synonyms.sql', 'every synonym is already there'); END IF;
EXCEPTION WHEN OTHERS THEN
  o('FAIL', 'xxcenhid_notfns_list_line_seq_synonyms.sql', 'the check could not run', SQLERRM, 'APPS needs SELECT on the DBA_ views; fix the error and validate again');
END;
/

DECLARE
  k NUMBER;
  PROCEDURE o(k VARCHAR2, f VARCHAR2, a VARCHAR2 := NULL, b VARCHAR2 := NULL, c VARCHAR2 := NULL) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('@@' || k || '|' || f || '|' || REPLACE(REPLACE(a, CHR(10), ' '), '|', '/') || '|'
                         || REPLACE(REPLACE(b, CHR(10), ' '), '|', '/') || '|' || REPLACE(REPLACE(c, CHR(10), ' '), '|', '/'));
  END;
BEGIN
  SELECT COUNT(*) INTO k FROM dual WHERE EXISTS (SELECT 1 FROM dba_synonyms WHERE owner = 'APPS' AND synonym_name = 'XXCENHID_NOTFNS_LIST_SEQ' AND table_owner = 'XXCENHID' AND table_name IN ('XXCENHID_NOTFNS_LIST_SEQ', 'XXCENHID_NOTFNS_LIST_SEQ#'));
  IF k > 0 THEN o('SKIP', 'xxcenhid_notfns_list_seq_synonyms.sql', 'every synonym is already there'); END IF;
EXCEPTION WHEN OTHERS THEN
  o('FAIL', 'xxcenhid_notfns_list_seq_synonyms.sql', 'the check could not run', SQLERRM, 'APPS needs SELECT on the DBA_ views; fix the error and validate again');
END;
/

DECLARE
  k NUMBER;
  PROCEDURE o(k VARCHAR2, f VARCHAR2, a VARCHAR2 := NULL, b VARCHAR2 := NULL, c VARCHAR2 := NULL) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('@@' || k || '|' || f || '|' || REPLACE(REPLACE(a, CHR(10), ' '), '|', '/') || '|'
                         || REPLACE(REPLACE(b, CHR(10), ' '), '|', '/') || '|' || REPLACE(REPLACE(c, CHR(10), ' '), '|', '/'));
  END;
BEGIN
  SELECT COUNT(*) INTO k FROM dba_editioning_views WHERE owner = 'XXCENHID' AND table_name = 'XXCENHID_NOTFNS_LIST_LINES';
  IF k > 0 THEN o('SKIPIF', 'xxcenhid_notfns_list_lines_ev.sql', 'xxcenhid_notfns_list_lines_table.sql'); END IF;
EXCEPTION WHEN OTHERS THEN
  o('FAIL', 'xxcenhid_notfns_list_lines_ev.sql', 'the check could not run', SQLERRM, 'APPS needs SELECT on the DBA_ views; fix the error and validate again');
END;
/

DECLARE
  k NUMBER;
  PROCEDURE o(k VARCHAR2, f VARCHAR2, a VARCHAR2 := NULL, b VARCHAR2 := NULL, c VARCHAR2 := NULL) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('@@' || k || '|' || f || '|' || REPLACE(REPLACE(a, CHR(10), ' '), '|', '/') || '|'
                         || REPLACE(REPLACE(b, CHR(10), ' '), '|', '/') || '|' || REPLACE(REPLACE(c, CHR(10), ' '), '|', '/'));
  END;
BEGIN
  SELECT COUNT(*) INTO k FROM dba_editioning_views WHERE owner = 'XXCENHID' AND table_name = 'XXCENHID_NOTIFICATIONS_LIST';
  IF k > 0 THEN o('SKIPIF', 'xxcenhid_notifications_list_ev.sql', 'xxcenhid_notifications_list_table.sql'); END IF;
EXCEPTION WHEN OTHERS THEN
  o('FAIL', 'xxcenhid_notifications_list_ev.sql', 'the check could not run', SQLERRM, 'APPS needs SELECT on the DBA_ views; fix the error and validate again');
END;
/

DECLARE
  k NUMBER;
  h NUMBER; bad NUMBER;
  PROCEDURE o(k VARCHAR2, f VARCHAR2, a VARCHAR2 := NULL, b VARCHAR2 := NULL, c VARCHAR2 := NULL) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('@@' || k || '|' || f || '|' || REPLACE(REPLACE(a, CHR(10), ' '), '|', '/') || '|'
                         || REPLACE(REPLACE(b, CHR(10), ' '), '|', '/') || '|' || REPLACE(REPLACE(c, CHR(10), ' '), '|', '/'));
  END;
BEGIN
  SELECT COUNT(*), SUM(ORA_HASH(s.line || ':' || RTRIM(s.text, ' ' || CHR(9) || CHR(10) || CHR(13)))) INTO k, h FROM dba_source s WHERE s.owner = 'APPS' AND s.name = 'XXCENHID_APPROVE_PKG' AND s.type = 'PACKAGE BODY' AND s.line > 1;
  SELECT COUNT(*) INTO bad FROM dba_objects WHERE owner = 'APPS' AND object_name = 'XXCENHID_APPROVE_PKG' AND object_type = 'PACKAGE BODY' AND status <> 'VALID';
  IF k = 405 AND h = 878531427931 AND bad = 0 THEN o('SKIP', 'xxcenhid_approve_pkg.pkb', 'the target has the same source and it is valid');
  ELSE o('PLAN', 'xxcenhid_approve_pkg.pkb', CASE WHEN k = 0 THEN 'create' ELSE 'replace (source differs or invalid)' END || ' package body APPS.XXCENHID_APPROVE_PKG'); END IF;
EXCEPTION WHEN OTHERS THEN
  o('FAIL', 'xxcenhid_approve_pkg.pkb', 'the check could not run', SQLERRM, 'APPS needs SELECT on the DBA_ views; fix the error and validate again');
END;
/
