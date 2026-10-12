select *
from oe_order_headers_all
where rownum < 10
AND orig_sys_document_ref=10
AND order_type_id =100;