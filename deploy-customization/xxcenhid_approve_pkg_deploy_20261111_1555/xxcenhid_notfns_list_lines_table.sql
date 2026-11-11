SET SERVEROUTPUT ON SIZE UNLIMITED
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
  SELECT COUNT(*) INTO k FROM all_tables WHERE owner = 'XXCENHID' AND table_name = 'XXCENHID_NOTFNS_LIST_LINES';
  IF k = 0 THEN
    EXECUTE IMMEDIATE 'CREATE TABLE "XXCENHID"."XXCENHID_NOTFNS_LIST_LINES" ' || CHR(10) || '   (	"LIST_LINE_ID" NUMBER, ' || CHR(10) || '	"PROCESS_ACTIVITY" NUMBER, ' || CHR(10) || '	"ACTIVITY_STATUS" VARCHAR2(50), ' || CHR(10) || '	"ACTIVITY_TYPE" VARCHAR2(50), ' || CHR(10) || '	"ACTIVITY_DISPLAY_NAME" VARCHAR2(240), ' || CHR(10) || '	"PARENT_ACTIVITY_DISPLAY" VARCHAR2(240), ' || CHR(10) || '	"ACTIVITY_NAME" VARCHAR2(240), ' || CHR(10) || '	"PARENT_ACTIVITY" VARCHAR2(240), ' || CHR(10) || '	"NID" NUMBER, ' || CHR(10) || '	"ASSIGNED_USER" VARCHAR2(300), ' || CHR(10) || '	"NOTIFICATION_SUBJECT" VARCHAR2(2000), ' || CHR(10) || '	"ROLE_EMAIL_ADDRESS" VARCHAR2(300), ' || CHR(10) || '	"ROLE_DISPLAY_NAME" VARCHAR2(300), ' || CHR(10) || '	"HID_APPR_MAPPED_USER" VARCHAR2(300), ' || CHR(10) || '	"HID_APPR_NOTFN_SENT" VARCHAR2(30), ' || CHR(10) || '	"HID_APPR_NOTFN_RESPONSE" VARCHAR2(4000), ' || CHR(10) || '	"HID_APPR_PROCESS_STATUS" VARCHAR2(30), ' || CHR(10) || '	"ERROR_MESSAGE" VARCHAR2(4000), ' || CHR(10) || '	"CREATION_DATE" DATE, ' || CHR(10) || '	"CREATED_BY" NUMBER, ' || CHR(10) || '	"LAST_UPDATE_DATE" DATE, ' || CHR(10) || '	"LAST_UPDATED_BY" NUMBER, ' || CHR(10) || '	"LIST_ID" NUMBER, ' || CHR(10) || '	"CORRELATION_ID" VARCHAR2(500)' || CHR(10) || '   )';
    DBMS_OUTPUT.PUT_LINE('created ' || tgt);
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
                       data_default FROM all_tab_columns
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
  FOR x IN (SELECT column_name FROM all_tab_columns WHERE owner = 'XXCENHID' AND table_name = 'XXCENHID_NOTFNS_LIST_LINES'
              AND column_name NOT LIKE '%#%' AND column_name NOT IN ('LIST_LINE_ID', 'PROCESS_ACTIVITY', 'ACTIVITY_STATUS', 'ACTIVITY_TYPE', 'ACTIVITY_DISPLAY_NAME', 'PARENT_ACTIVITY_DISPLAY', 'ACTIVITY_NAME', 'PARENT_ACTIVITY', 'NID', 'ASSIGNED_USER', 'NOTIFICATION_SUBJECT', 'ROLE_EMAIL_ADDRESS', 'ROLE_DISPLAY_NAME', 'HID_APPR_MAPPED_USER', 'HID_APPR_NOTFN_SENT', 'HID_APPR_NOTFN_RESPONSE', 'HID_APPR_PROCESS_STATUS', 'ERROR_MESSAGE', 'CREATION_DATE', 'CREATED_BY', 'LAST_UPDATE_DATE', 'LAST_UPDATED_BY', 'LIST_ID', 'CORRELATION_ID')) LOOP
    fail('column only on the target', x.column_name || ' is not in the bundle (its data would be lost)',
         'add it back on the source, or -- ALTER TABLE ' || tgt || ' DROP COLUMN "' || x.column_name
         || '" in a Manual step if it really goes');
  END LOOP;
  IF fails > 0 THEN
    RAISE_APPLICATION_ERROR(-20100, lbl || ': ' || fails || ' change(s) could lose data; nothing was changed. ./deploy.sh -v lists them');
  END IF;
  IF todo.COUNT = 0 THEN
    DBMS_OUTPUT.PUT_LINE(tgt || ' is unchanged');
    RETURN;
  END IF;
  FOR i IN 1 .. todo.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE(todo(i));
    EXECUTE IMMEDIATE todo(i);
  END LOOP;
END;
/
