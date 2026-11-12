CREATE OR REPLACE PACKAGE APPS.XXCENHID_APPROVE_PKG AUTHID CURRENT_USER AS
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

   --This is a scheduled procedure to insert eligible records for processing by HID Approve
   PROCEDURE insert_eligible_records(errbuff OUT VARCHAR2,
                                     retcode OUT NUMBER);

   --procedure to approve or reject workflow notification based on the HID Approve response
   PROCEDURE update_wf(p_correlationId     IN VARCHAR2,
                       p_Action            IN VARCHAR2
                       );
END XXCENHID_APPROVE_PKG;
/
