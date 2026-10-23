DECLARE
   l_sql VARCHAR2(4000);
BEGIN
   l_sql := 'SELECT *'
      || ' FROM scott.emp'
      || ' WHERE 1=2';
   DBMS_SQL.PARSE(l_sql);   
EXCEPTION
   WHEN OTHERS THEN
      RAISE;
END;

SELECT *
FROM (
SELECT * 
FROM scott.emp
)

WITH 
(
SELECT *
FROM FND_LOOKUP_VALUES
WHERE 1=2
) x
SELECT * FROM x

SELECT * FROM (
  WITH my_cte AS (
    SELECT * FROM FND_LOOKUP_VALUES
  )
  SELECT * FROM my_cte
)


SELECT /*+ WITH_PLSQL */ POS__ FROM (
WITH FUNCTION pos__ RETURN NUMBER IS
  c INTEGER := DBMS_SQL.OPEN_CURSOR;
  p NUMBER := -1;
BEGIN
  BEGIN DBMS_SQL.PARSE(c, q'~SELECT * FROM scott.emp~', DBMS_SQL.NATIVE);
  EXCEPTION WHEN OTHERS THEN p := DBMS_SQL.LAST_ERROR_POSITION; END;
  DBMS_SQL.CLOSE_CURSOR(c);
  RETURN p;
END;
SELECT pos__() AS POS__ FROM DUAL
)


SELECT *
FROM fnd_lookup_values x,
      scott.emp y
 WHERE x.lookup_type = y.empno
 
 
SELECT DBMS_SQLTUNE.REPORT_SQL_MONITOR('select * from fnd_lookup_values where rownum<10') FROM DUAL

SELECT DBMS_SQLTUNE.REPORT_SQL_MONITOR(
         sql_id       => select * from fnd_lookup_values where rownum<10,
         type         => 'XML',
         report_level => 'ALL'
       ) AS sql_monitor_report
FROM DUAL

SELECT /*+ gather_plan_statistics */ /* SDTUNE_001 */ * FROM fnd_lookup_values

SELECT sql_id, child_number FROM gv$sql WHERE sql_text LIKE '%SDTUNE_001%' AND sql_text NOT LIKE '%v$sql%'


SELECT DBMS_SQLTUNE.REPORT_SQL_MONITOR(
         sql_id       => '12345',
         type         => 'XML',
         report_level => 'ALL'
       ) AS sql_monitor_report
FROM DUAL

SELECT * FROM fnd_lookup_values WHERE ROWNUM<10

SELECT dbms_sqltune.report_sql_monitor(type => 'html') FROM DUAL


SELECT distinct s.sql_text, m.sql_id, m.cpu_time
FROM v$sql_monitor m INNER JOIN v$sql s ON s.sql_id=m.sql_id 
ORDER BY m.cpu_time

SELECT dbms_sql_monitor.begin_operation(dbop_name => 'sales_job1') FROM DUAL
SELECT * FROM fnd_lookup_values WHERE ROWNUM<10
SELECT dbms_sql_monitor.end_operation(dbop_name => 'sales_job1', dbop_eid => 78) FROM DUAL

SELECT dbms_sql_monitor.report_sql_monitor(dbop_name =>'sales_job1') FROM dual;

dbms_sql_monitor.report_sql_monitor()

SELECT username, elapsed_time, plsql_exec_time, sql_text, cpu_time,
rm_last_action, rm_last_action_reason, rm_last_action_time, rm_consumer_group
FROM v$sql_monitor WHERE username is not null;


EXPLAIN PLAN SET STATEMENT_ID = 'dm_plan_FSCM_Que_261012_020536' FOR 
SELECT DBMS_XMLGEN.GETXMLTYPE('select * from fnd_lookup_values') AS RESULT 
FROM DUAL 


SELECT * FROM user_objects
WHERE object_name LIKE 'DBMS_SQL_MONITOR'

SELECT sql_id, 
       sql_text, 
       status, 
       dbop_name
FROM fusion.perf_sql_monitor
WHERE dbop_name = 'sales_job1' 
   OR sql_text LIKE '%sales_job1%'
   
   perf_