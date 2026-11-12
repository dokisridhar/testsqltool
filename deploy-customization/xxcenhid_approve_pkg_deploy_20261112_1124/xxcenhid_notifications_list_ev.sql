DECLARE
  k NUMBER;
BEGIN
  SELECT COUNT(*) INTO k FROM dba_editioning_views WHERE owner = 'XXCENHID' AND table_name = 'XXCENHID_NOTIFICATIONS_LIST';
  IF k > 0 AND ad_zd.get_edition('PATCH') = SYS_CONTEXT('userenv', 'current_edition_name') THEN
    ad_zd_table.patch('XXCENHID', 'XXCENHID_NOTIFICATIONS_LIST');
  ELSE
    ad_zd_table.upgrade('XXCENHID', 'XXCENHID_NOTIFICATIONS_LIST');
  END IF;
END;
/
