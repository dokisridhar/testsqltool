DECLARE
  k NUMBER;
BEGIN
  SELECT COUNT(*) INTO k FROM dba_editioning_views WHERE owner = 'XXCENHID' AND table_name = 'XXCENHID_NOTFNS_LIST_LINES';
  IF k > 0 AND ad_zd.get_edition('PATCH') = SYS_CONTEXT('userenv', 'current_edition_name') THEN
    ad_zd_table.patch('XXCENHID', 'XXCENHID_NOTFNS_LIST_LINES');
  ELSE
    ad_zd_table.upgrade('XXCENHID', 'XXCENHID_NOTFNS_LIST_LINES');
  END IF;
END;
/
