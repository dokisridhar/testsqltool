CREATE OR REPLACE PACKAGE BODY APPS.XXCENHID_APPROVE_PKG AS
-------------------------------------------------------------------------------
-- company              : Centroid - HID Global
-- module               : HID Approve
-- file name            : XXCENHID_APPROVE_PKG.pls
-- location             : $XXCUST_TOP/sql
-- clearcase location   : $XXCUST_TOP/sql
-- cr / ticket          :
-- description          : This plsql block is used for Integration of EBS with
--                      : HID Approve Application for approvals
-------------------------------------------------------------------------------
-- ver  | date       | name          | description
-------------------------------------------------------------------------------
-- 1.0  | 25/Mar/2018 | Sridhar Doki    | initial release
-------------------------------------------------------------------------------
   PROCEDURE debug_log(P_MESSAGE IN VARCHAR2) IS
   BEGIN
      INSERT INTO xxcenhid_debug(correlation_id,response_mesg_txt,creation_date,created_by)
      VALUES ('DEBUGLOG',P_MESSAGE,SYSDATE,fnd_global.user_id);
      IF Nvl(fnd_global.conc_request_id,0) > 0 THEN
            fnd_file.put_line(fnd_file.Log,p_message);
      ELSE
         BEGIN
            dbms_output.put_line(SubStr(p_message,1,250));
         EXCEPTION
            WHEN OTHERS THEN
               Dbms_Output.DISABLE;
               Dbms_Output.ENABLE(100000);
               dbms_output.put_line(SubStr(p_message,1,250));
         END;
      END IF;
   END debug_log;

   --This is a scheduled procedure to insert eligible records for processing by HID Approve
   PROCEDURE insert_eligible_records(errbuff OUT VARCHAR2,
                                     retcode OUT NUMBER) IS
      l_notifications_list       xxcenhid_notifications_list%ROWTYPE;
      l_Reqid                    NUMBER;
      --TYPE l_notifications_list_tbl_typ IS TABLE OF xxcenhid_notifications_list%ROWTYPE INDEX BY BINARY_INTEGER;
      --l_notifications_list_tbl   l_notifications_list_tbl_typ;
      --l_notfns_lines_list        xxcenhid_notfns_list_lines%ROWTYPE;
      TYPE l_notfns_lines_list_tbl_typ IS TABLE OF xxcenhid_notfns_list_lines%ROWTYPE INDEX BY BINARY_INTEGER;
      l_notfns_lines_list_tbl    l_notfns_lines_list_tbl_typ;
      l_list_id                  NUMBER;
      l_list_line_id             NUMBER;
      CURSOR l_monitor_wf_cur IS
      SELECT *
      FROM
      (SELECT WorkflowItemEO.ITEM_TYPE,
         WorkflowItemEO.ITEM_KEY,
         WorkflowItemEO.ROOT_ACTIVITY,
         ActivityEO.DISPLAY_NAME PROCESS_NAME,
         WorkflowItemEO.ROOT_ACTIVITY_VERSION,
         WorkflowItemEO.OWNER_ROLE,
         WorkflowItemEO.PARENT_ITEM_TYPE,
         WorkflowItemEO.PARENT_ITEM_KEY,
         WorkflowItemEO.PARENT_CONTEXT,
         WorkflowItemEO.BEGIN_DATE,
         WorkflowItemEO.END_DATE,
         WorkflowItemEO.USER_KEY,
         WorkflowItemTypeEO.NAME,
         WorkflowItemTypeEO.DISPLAY_NAME,
         wf_directory.getroledisplayname2(WorkflowItemEO.OWNER_ROLE)                                                                                                             AS ROLE_NAME,
         wf_fwkmon.getitemstatus(WorkflowItemEO.ITEM_TYPE, WorkflowItemEO.ITEM_KEY, WorkflowItemEO.END_DATE, WorkflowItemEO.ROOT_ACTIVITY, WorkflowItemEO.ROOT_ACTIVITY_VERSION) AS STATUS_CODE,
         wf_fwkmon.getroleemailaddress(WorkflowItemEO.OWNER_ROLE)                                                                                                                AS ROLE_EMAIL
      FROM WF_ITEMS WorkflowItemEO,
         WF_ITEM_TYPES_VL WorkflowItemTypeEO,
         WF_ACTIVITIES_VL ActivityEO
      WHERE WorkflowItemEO.ITEM_TYPE = WorkflowItemTypeEO.NAME
      AND ActivityEO.ITEM_TYPE       = WorkflowItemEO.ITEM_TYPE
      AND ActivityEO.NAME            = WorkflowItemEO.ROOT_ACTIVITY
      AND ActivityEO.VERSION         = WorkflowItemEO.ROOT_ACTIVITY_VERSION
      ) QRSLT
      WHERE (QRSLT.ITEM_TYPE IN  (SELECT lookup_code
                                    FROM fnd_lookup_values
                                    WHERE lookup_type='XXCENHID_ELIGIBLE_ITEM_TYPES'
                                      AND LANGUAGE = UserEnv('LANG')
                                      AND enabled_flag = 'Y'
                                      AND SYSDATE BETWEEN Nvl(start_date_active,SYSDATE-1) AND Nvl(end_date_active,SYSDATE+1))
        AND QRSLT.STATUS_CODE='ACTIVE'
        AND QRSLT.BEGIN_DATE > to_date('01-MAR-2018','DD-MON-YYYY') )
        AND EXISTS (SELECT 'x'
                     FROM wf_item_activity_statuses wias,
                        wf_process_activities wpa,
                        wf_activities_vl wa,
                        wf_activities_vl wa2,
                        wf_items wi,
                        wf_lookups wl,
                        wf_lookups wl2
                     WHERE wias.item_type       = wi.item_type
                     AND wias.item_key          = wi.item_key
                     AND wias.process_activity  = wpa.instance_id
                     AND wpa.activity_name      = wa.name
                     AND wpa.activity_item_type = wa.item_type
                     AND wi.begin_date BETWEEN wa.begin_date AND NVL(wa.end_date, wi.begin_date)
                     AND wpa.process_name      = wa2.name
                     AND wpa.process_item_type = wa2.item_type
                     AND wpa.process_version   = wa2.version
                     AND wias.activity_status  = wl.lookup_code
                     AND wl.lookup_type        = 'WFENG_STATUS'
                     AND wa.type               = wl2.lookup_code
                     AND wl2.lookup_type       = 'WFENG_ACTIVITY_TYPE'
                     AND wias.item_type        = QRSLT.item_type
                     AND wias.item_key         = QRSLT.item_key
                     AND wias.activity_status  = 'NOTIFIED'
                     AND wias.notification_id IS NOT NULL
                     AND wa.type               = 'NOTICE'
                     )
      ORDER BY BEGIN_DATE DESC;

      CURSOR l_wf_activities_cur(p_item_type IN VARCHAR2,
                                 p_item_key  IN VARCHAR2) IS
      SELECT wias.process_activity                        AS PROCESS_ACTIVITY,
            wias.activity_status                                AS ACTIVITY_STATUS,
            wa.type                                             AS ACTIVITY_TYPE,
            wa.display_name                                     AS ACTIVITY_DISPLAY_NAME,
            wa2.display_name                                    AS PARENT_ACTIVITY_DISPLAY,
            wpa.activity_name                                   AS ACTIVITY_NAME,
            wpa.process_name                                    AS PARENT_ACTIVITY,
            wias.item_type                                      AS ITEM_TYPE,
            wias.item_key                                       AS ITEM_KEY,
            wi.user_key                                         AS USER_KEY,
            wias.notification_id                                AS NOTIFICATION_ID,
            wias.assigned_user                                  AS ASSIGNED_USER,
            wf_notification.getsubject(wias.notification_id)    AS SUBJECT,
            wf_fwkmon.getroleemailaddress(wias.assigned_user)   AS ROLE_EMAIL_ADDRESS,
            wf_directory.getroledisplayname(wias.assigned_user) AS ROLE_DISPLAY_NAME,
            wl.meaning                                          AS ACTIVITY_STATUS_DISPLAY,
            wl2.meaning                                         AS ACTIVITY_TYPE_DISPLAY
         FROM wf_item_activity_statuses wias,
            wf_process_activities wpa,
            wf_activities_vl wa,
            wf_activities_vl wa2,
            wf_items wi,
            wf_lookups wl,
            wf_lookups wl2
         WHERE wias.item_type       = wi.item_type
         AND wias.item_key          = wi.item_key
         AND wias.process_activity  = wpa.instance_id
         AND wpa.activity_name      = wa.name
         AND wpa.activity_item_type = wa.item_type
         AND wi.begin_date BETWEEN wa.begin_date AND NVL(wa.end_date, wi.begin_date)
         AND wpa.process_name      = wa2.name
         AND wpa.process_item_type = wa2.item_type
         AND wpa.process_version   = wa2.version
         AND wias.activity_status  = wl.lookup_code
         AND wl.lookup_type        = 'WFENG_STATUS'
         AND wa.type               = wl2.lookup_code
         AND wl2.lookup_type       = 'WFENG_ACTIVITY_TYPE'
         AND wias.item_type        = p_item_type
         AND wias.item_key         = p_item_key
         AND wias.activity_status  = 'NOTIFIED'
         AND wias.notification_id IS NOT NULL
         AND wa.type               = 'NOTICE';
   BEGIN
      FOR l_monitor_rec IN l_monitor_wf_cur
      LOOP
         BEGIN
            SELECT list_id
            INTO l_list_id
            FROM xxcenhid_notifications_list
            WHERE item_type = l_monitor_rec.item_type
               AND item_key  = l_monitor_rec.item_key;
         EXCEPTION
            WHEN OTHERS THEN
               l_list_id := NULL;
         END;
         IF l_list_id IS NULL THEN
            l_notifications_list.list_id    := xxcenhid_notfns_list_seq.NEXTVAL;
            l_list_id := l_notifications_list.list_id;
            l_notifications_list.item_type      := l_monitor_rec.item_type;
            l_notifications_list.item_key       := l_monitor_rec.item_key;
            l_notifications_list.root_activity  := l_monitor_rec.root_activity;
            l_notifications_list.process_name   := l_monitor_rec.process_name;
            l_notifications_list.root_activity_version   := l_monitor_rec.root_activity_version;
            l_notifications_list.owner_role        := l_monitor_rec.owner_role;
            l_notifications_list.parent_item_type  := l_monitor_rec.parent_item_type;
            l_notifications_list.parent_item_key   := l_monitor_rec.parent_item_key;
            l_notifications_list.parent_context    := l_monitor_rec.parent_context;
            l_notifications_list.begin_date        := l_monitor_rec.begin_date;
            l_notifications_list.end_date          := l_monitor_rec.end_date;
            l_notifications_list.user_key          := l_monitor_rec.user_key;
            l_notifications_list.name              := l_monitor_rec.name;
            l_notifications_list.display_name      := l_monitor_rec.display_name;
            l_notifications_list.role_name         := l_monitor_rec.role_name;
            l_notifications_list.status_code       := l_monitor_rec.status_code;
            l_notifications_list.role_email        := l_monitor_rec.role_email;
            l_notifications_list.creation_date     := SYSDATE;
            l_notifications_list.created_by        := fnd_global.user_id;
            l_notifications_list.last_update_date  := SYSDATE;
            l_notifications_list.last_updated_by   := fnd_global.user_id;
            INSERT INTO xxcenhid_notifications_list VALUES l_notifications_list;
         END IF;

         l_notfns_lines_list_tbl.DELETE;
         FOR l_wf_activities_rec IN l_wf_activities_cur(p_item_type => l_monitor_rec.item_type,
                                                        p_item_key  => l_monitor_rec.item_key)
         LOOP
            BEGIN
               SELECT list_line_id
                 INTO l_list_line_id
                 FROM xxcenhid_notfns_list_lines
                WHERE nid     = l_wf_activities_rec.notification_id
                  AND list_id = l_list_id;
            EXCEPTION
               WHEN OTHERS THEN
                  l_list_line_id := NULL;
            END;
            IF l_list_line_id IS NULL THEN
               l_notfns_lines_list_tbl(l_notfns_lines_list_tbl.Count + 1).list_id          := l_list_id;
               l_notfns_lines_list_tbl(l_notfns_lines_list_tbl.Count).list_line_id         := XXCENHID_NOTFNS_LIST_LINE_SEQ.nextval;
               l_notfns_lines_list_tbl(l_notfns_lines_list_tbl.Count).correlation_id       := l_monitor_rec.item_type||'_'||l_monitor_rec.item_key||'_'||l_wf_activities_rec.notification_id||'_'||XXCENHID_NOTFNS_LIST_LINE_SEQ.CURRVAL;
               l_notfns_lines_list_tbl(l_notfns_lines_list_tbl.count).process_activity     := l_wf_activities_rec.process_activity;
               l_notfns_lines_list_tbl(l_notfns_lines_list_tbl.count).activity_status      := l_wf_activities_rec.activity_status;
               l_notfns_lines_list_tbl(l_notfns_lines_list_tbl.count).activity_type        := l_wf_activities_rec.activity_type;
               l_notfns_lines_list_tbl(l_notfns_lines_list_tbl.count).activity_display_name:= l_wf_activities_rec.activity_display_name;
               l_notfns_lines_list_tbl(l_notfns_lines_list_tbl.count).parent_activity_display  := l_wf_activities_rec.parent_activity_display;
               l_notfns_lines_list_tbl(l_notfns_lines_list_tbl.count).activity_name        := l_wf_activities_rec.activity_name;
               l_notfns_lines_list_tbl(l_notfns_lines_list_tbl.count).parent_activity      := l_wf_activities_rec.parent_activity;
               l_notfns_lines_list_tbl(l_notfns_lines_list_tbl.count).nid                  := l_wf_activities_rec.notification_id;
               l_notfns_lines_list_tbl(l_notfns_lines_list_tbl.count).assigned_user        := l_wf_activities_rec.assigned_user;
               --l_notfns_lines_list_tbl(l_notfns_lines_list_tbl.count).hid_appr_mapped_user        := 'scott.morrell';
               l_notfns_lines_list_tbl(l_notfns_lines_list_tbl.count).notification_subject := l_wf_activities_rec.subject;
               l_notfns_lines_list_tbl(l_notfns_lines_list_tbl.count).role_email_address   := l_wf_activities_rec.role_email_address;
               l_notfns_lines_list_tbl(l_notfns_lines_list_tbl.count).role_display_name    := l_wf_activities_rec.role_display_name;
               l_notfns_lines_list_tbl(l_notfns_lines_list_tbl.count).creation_date        := SYSDATE;
               l_notfns_lines_list_tbl(l_notfns_lines_list_tbl.count).created_by           := fnd_global.user_id;
               l_notfns_lines_list_tbl(l_notfns_lines_list_tbl.count).last_update_date     := SYSDATE;
               l_notfns_lines_list_tbl(l_notfns_lines_list_tbl.count).last_updated_by      := fnd_global.user_id;
            END IF;
         END LOOP;
         IF l_notfns_lines_list_tbl.Count > 0 THEN
            FORALL l_ntfn_rec_idx IN l_notfns_lines_list_tbl.FIRST..l_notfns_lines_list_tbl.LAST
               INSERT INTO XXCENHID_NOTFNS_LIST_LINES VALUES l_notfns_lines_list_tbl(l_ntfn_rec_idx);
         END IF;
         COMMIT;
      END LOOP;
      COMMIT;
      /*
      l_Reqid := Fnd_Request.Submit_Request('XXCENHID',
                                         'XXCENHID_PROCESS_PENDING_WF',
                                         'XXCENHID Process Pending Workflow Records',
                                         NULL,
                                         FALSE);
      debug_log('Submitted request with id ' || l_reqid);
      COMMIT;
      */
   EXCEPTION
      WHEN OTHERS THEN
         debug_log(Dbms_Utility.format_error_backtrace);
   END insert_eligible_records;

   --procedure to approve or reject workflow notification
   PROCEDURE wf_approve_reject(pAction          IN VARCHAR2, --APPROVE/REJECT
                               pComments        IN VARCHAR2, -- User Comments -- Optional
                               pNotification_id IN NUMBER,   -- Notification ID
                               pStatus         OUT VARCHAR2,
                               pMessage        OUT VARCHAR2 ) IS
      l_user_name VARCHAR2(250);
   BEGIN
      BEGIN
         SELECT recipient_role
         INTO l_user_name
         FROM wf_notifications
         WHERE notification_id = pNotification_id;
      EXCEPTION
         WHEN OTHERS THEN
            l_user_name := NULL;
      END;
      debug_log('l_user_name ' ||l_user_name);
      wf_notification.SETATTRTEXT(pNotification_id,'RESULT',pAction);
      wf_notification.Respond(pNotification_id, pComments, l_user_name, pAction);
      pStatus  := 'S';
      pMessage := 'Successfully '||initcap(pAction);
      debug_log('Workflow updated successfully');
      --COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         pStatus  := 'E';
         pMessage := 'Unexpected error while Approve/Reject the notification: '||SQLERRM;
         debug_log('Error while updating Workflow');
         debug_log(Dbms_Utility.format_error_backtrace);
   END wf_approve_reject;

   PROCEDURE update_wf(p_correlationId     IN VARCHAR2,
                       p_Action            IN VARCHAR2
                       ) IS
      l_count        NUMBER;
      l_wf_status    VARCHAR2(30);
      lx_message     VARCHAR2(4000);
      lx_status      VARCHAR2(300);
      PRAGMA autonomous_transaction;
   BEGIN
      debug_log('Updating workflow now');
      debug_log('p_correlationId '||p_correlationId);
      debug_log('p_Action '||p_Action);

      IF instr(p_action,'clientapprovalstatus=accept') > 0 THEN
         l_wf_status := 'APPROVE';
      ELSIF instr(p_action,'clientapprovalstatus=deny') > 0 THEN
         l_wf_status := 'REJECT';
      ELSE
         l_wf_status := 'UNKNOWN';
      END IF;
      debug_log('l_wf_status ' ||l_wf_status);

      FOR l_lines_rec IN (SELECT h.item_type,
                                 h.item_key,
                                 l.nid,
                                 l.list_line_id,
                                 l.process_activity
                             FROM xxcenhid_notifications_list h,
                                  xxcenhid_notfns_list_lines l
                            WHERE h.list_id           = l.list_id
                              AND l.activity_status   = 'NOTIFIED'
                              AND l.activity_type     = 'NOTICE'
                              AND Nvl(l.hid_appr_notfn_sent,'N') = ('Y')
                              AND l.correlation_id = p_correlationid)
      LOOP
         --debug_log('updating workflow for item type, item key and nid ' + l_lines_rec.item_type + ',' + l_lines_rec.item_key + ',' + l_lines_rec.nid);
         SELECT Count(1)
           INTO l_count
           FROM wf_item_activity_statuses wias,
               wf_process_activities wpa,
               wf_activities_vl wa,
               wf_activities_vl wa2,
               wf_items wi,
               wf_lookups wl,
               wf_lookups wl2
         WHERE wias.item_type       = wi.item_type
          AND wias.item_key          = wi.item_key
          AND wias.process_activity  = wpa.instance_id
          AND wpa.activity_name      = wa.name
          AND wpa.activity_item_type = wa.item_type
          AND wi.begin_date BETWEEN wa.begin_date AND NVL(wa.end_date, wi.begin_date)
          AND wpa.process_name      = wa2.name
          AND wpa.process_item_type = wa2.item_type
          AND wpa.process_version   = wa2.version
          AND wias.activity_status  = wl.lookup_code
          AND wl.lookup_type        = 'WFENG_STATUS'
          AND wa.type               = wl2.lookup_code
          AND wl2.lookup_type       = 'WFENG_ACTIVITY_TYPE'
          AND wias.item_type        = l_lines_rec.item_type
          AND wias.item_key         = l_lines_rec.item_key
          AND wias.activity_status  = 'NOTIFIED'
          AND wias.notification_id IS NOT NULL
          AND wa.type               = 'NOTICE'
          AND wias.notification_id = l_lines_rec.nid;


         IF l_count = 0 THEN
            debug_log('Current status of workflow is not notified');
            UPDATE xxcenhid_notfns_list_lines
               SET last_updated_by           = fnd_global.user_id,
                   last_update_date          = SYSDATE,
                   hid_appr_notfn_response   = p_action,
                   hid_appr_process_status   = 'STANDARD_APPROVAL',
                   error_message             = 'Notification is approved in EBS. No action taken from HID Approve'
             WHERE list_line_id = l_lines_rec.list_line_id;
         ELSE
            IF l_wf_status = 'UNKNOWN' THEN
               debug_log('HID Approve status is unknown');
               UPDATE xxcenhid_notfns_list_lines
                  SET last_updated_by           = fnd_global.user_id,
                     last_update_date          = SYSDATE,
                     hid_appr_notfn_response   = p_action,
                     hid_appr_process_status   = 'UNKNOWN_STATUS_FROM_HID',
                     error_message             = 'Unknown Status from HID'
               WHERE list_line_id = l_lines_rec.list_line_id;
            ELSE
               debug_log('Updating workflow now with HID status');

               wf_approve_reject(pAction        => l_wf_status, --APPROVE/REJECT
                               pComments        => NULL,
                               pNotification_id => l_lines_rec.nid,
                               pStatus          => lx_status,
                               pMessage         => lx_message);

               IF lx_status = 'S' THEN
                  UPDATE xxcenhid_notfns_list_lines
                     SET last_updated_by          = fnd_global.user_id,
                        last_update_date          = SYSDATE,
                        hid_appr_notfn_response   = p_action,
                        hid_appr_process_status   = 'HID_APPROVE_'||Upper(l_wf_status)
                  WHERE list_line_id = l_lines_rec.list_line_id;
               ELSE
                  UPDATE xxcenhid_notfns_list_lines
                     SET last_updated_by           = fnd_global.user_id,
                        last_update_date          = SYSDATE,
                        hid_appr_notfn_response   = p_action,
                        hid_appr_process_status   = 'HID_APPROVE_ERROR',
                        error_message             = lx_message
                  WHERE list_line_id = l_lines_rec.list_line_id;
               END IF;
            END IF;
         END IF;

       END LOOP;
       COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         debug_log(Dbms_Utility.format_error_backtrace);
         ROLLBACK;
   END update_wf;

END XXCENHID_APPROVE_PKG;
/
