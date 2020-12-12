INTERFACE zrishi_if_global_types
  PUBLIC .
  TYPES:
           tt_db_poinfo TYPE TABLE OF zrishi_podata,
           tt_db_update type table of zrishi_podata,
           tt_db_poitem TYPE TABLE of zrishi_poitmdata.
  TYPES: BEGIN OF lty_pox,
           client         TYPE mandt,
           po_doc         TYPE xsdboolean,
           po_description TYPE xsdboolean,
           postatus       TYPE xsdboolean,
           popriority     TYPE xsdboolean,
           compcode       TYPE xsdboolean,
           total_poprice  TYPE xsdboolean,
           curkey         TYPE xsdboolean,
           createby       TYPE xsdboolean,
           created_on     TYPE xsdboolean,
           changed_on     TYPE xsdboolean,
           final_change   TYPE xsdboolean,
         END OF lty_pox.
  TYPES: ts_po_control TYPE lty_pox,
         tt_po_control TYPE TABLE OF lty_pox.

ENDINTERFACE.
