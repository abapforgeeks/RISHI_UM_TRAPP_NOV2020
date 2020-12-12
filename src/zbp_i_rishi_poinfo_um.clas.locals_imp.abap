CLASS lhc_buffer DEFINITION.
  PUBLIC SECTION.
    CLASS-DATA:
      mt_create_podoc TYPE TABLE OF zrishi_podata,
      mt_update_podoc TYPE TABLE OF zrishi_podata,
      mt_update_poitm TYPE TABLE OF zrishi_poitmdata.
ENDCLASS.
CLASS lhc_PurchaseInfo DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS create FOR MODIFY
      IMPORTING it_purchasedocs FOR CREATE PurchaseInfo.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE PurchaseInfo.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE PurchaseInfo.

    METHODS read FOR READ
      IMPORTING keys FOR READ PurchaseInfo RESULT result.

    METHODS rba_Items FOR READ
      IMPORTING keys_rba FOR READ PurchaseInfo\_Items FULL result_requested RESULT result LINK association_links.

    METHODS cba_Items FOR MODIFY
      IMPORTING entities_cba FOR CREATE PurchaseInfo\_Items.

ENDCLASS.

CLASS lhc_PurchaseInfo IMPLEMENTATION.

  METHOD create.
    DATA: ls_purchase_doc TYPE zrishi_podata.

    SELECT MAX( po_doc ) FROM zrishi_podata INTO @DATA(lv_po_doc).

    LOOP AT it_purchasedocs ASSIGNING FIELD-SYMBOL(<lfs_po_doc>).
      MOVE-CORRESPONDING <lfs_po_doc> TO ls_purchase_doc.
*      lv_po_doc = lv_po_doc + 1.
      lv_po_doc += 1.
      ls_purchase_doc-po_doc = condense( lv_po_doc ).
      GET TIME STAMP FIELD DATA(lv_create_change_time).
      ls_purchase_doc-created_on = lv_create_change_time.
      ls_purchase_doc-createby = sy-uname.
      APPEND ls_purchase_doc TO lhc_buffer=>mt_create_podoc.
      IF ls_purchase_doc-po_doc IS INITIAL.

        "raise message by appending values to reported.
      ENDIF.
      APPEND VALUE #( %cid = <lfs_po_doc>-%cid  po_doc = ls_purchase_doc-po_doc ) TO mapped-purchaseinfo.
    ENDLOOP.


  ENDMETHOD.


  METHOD update.

    DATA: ls_po_updatex TYPE zrishi_if_global_types=>ts_po_control.
    DATA: lt_po_updatex TYPE TABLE OF zrishi_if_global_types=>ts_po_control.
    DATA: lt_po_current TYPE TABLE OF zrishi_podata,
          ls_po_current TYPE zrishi_podata.


    DATA(lv_test) = abap_true.
    "step 1: find out fields which are modified.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_po_data>).
      ls_po_updatex-po_doc = <lfs_po_data>-po_doc.
      ls_po_updatex-po_description = xsdbool( <lfs_po_data>-%control-po_description = cl_abap_behv=>flag_changed  ).
      ls_po_updatex-popriority = xsdbool( <lfs_po_data>-%control-popriority = cl_abap_behv=>flag_changed ).
      ls_po_updatex-postatus   = xsdbool( <lfs_po_data>-%control-postatus = cl_abap_behv=>flag_changed ).
      ls_po_updatex-curkey   = xsdbool( <lfs_po_data>-%control-curkey = cl_abap_behv=>flag_changed ).
      ls_po_updatex-compcode   = xsdbool( <lfs_po_data>-%control-compcode = cl_abap_behv=>flag_changed ).
      APPEND ls_po_updatex TO lt_po_updatex.
      MOVE-CORRESPONDING <lfs_po_data> TO ls_po_current.
      APPEND ls_po_current TO lt_po_current.
      APPEND VALUE #( %cid = <lfs_po_data>-%cid_ref po_doc = <lfs_po_data>-po_doc ) TO mapped-purchaseinfo.

    ENDLOOP.

    "fetch exsiting PO entreis (to modify the updated fields).
    IF lt_po_current IS NOT INITIAL.
      SELECT * FROM zrishi_podata
      FOR ALL ENTRIES IN  @lt_po_current
      WHERE po_doc EQ @lt_po_current-po_doc
      INTO TABLE @DATA(lt_po_db).
      IF sy-subrc NE 0.
        RETURN.
      ENDIF.

    ENDIF.
    DATA: lv_index TYPE i.
    LOOP AT lt_po_current ASSIGNING FIELD-SYMBOL(<lfs_po_current>).

      "check if the current po exist in db.
      READ TABLE lt_po_db ASSIGNING FIELD-SYMBOL(<lfs_po_db>) WITH KEY po_doc = <lfs_po_current>-po_doc.
      IF sy-subrc EQ 0.
        lv_index = 3.
        GET TIME STAMP FIELD DATA(lv_changedon).
        <lfs_po_db>-changed_on = lv_changedon.
      ENDIF.
      DO.
        "PO exits, now check to be updated fields in the current po.
        READ TABLE lt_po_updatex INTO DATA(ls_po_udatedx) WITH KEY po_doc = <lfs_po_current>-po_doc.
        ASSIGN COMPONENT lv_index OF STRUCTURE Ls_po_updatex TO FIELD-SYMBOL(<lfs_flag>).
        IF sy-subrc NE 0.
          EXIT.
        ENDIF.

        IF <lfs_flag> = abap_true.

          ASSIGN COMPONENT lv_index OF STRUCTURE <lfs_po_current> TO FIELD-SYMBOL(<lfs_current_value>).
          ASSIGN COMPONENT lv_index OF STRUCTURE <lfs_po_db> TO FIELD-SYMBOL(<lfs_db_value>).
          <lfs_db_value> = <lfs_current_value>.

        ENDIF.
        lv_index += 1.
      ENDDO.




    ENDLOOP.
    lhc_buffer=>mt_update_podoc = lt_po_db.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
    DATA(lv_podoc) = keys[ 1 ]-po_doc.
    SELECT * FROM zrishi_podata WHERE po_doc EQ @lv_podoc
    INTO TABLE @DATA(lt_latest_podata).
    MOVE-CORRESPONDING lt_latest_podata TO result.

  ENDMETHOD.

  METHOD rba_Items.
  ENDMETHOD.

  METHOD cba_Items.
    DATA(lv_test) = abap_true.
    DATA: lt_po_items TYPE TABLE OF zrishi_poitmdata,
          ls_po_items TYPE zrishi_poitmdata.
    DATA(lv_podoc) = entities_cba[ 1 ]-po_doc.


    SELECT MAX( po_item ) FROM zrishi_poitmdata
     WHERE po_document EQ @lv_podoc
     INTO @DATA(lv_poitem) .

    LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<lfs_cba>).

      LOOP AT <lfs_cba>-%target ASSIGNING FIELD-SYMBOL(<lfs_items>).

        MOVE-CORRESPONDING <lfs_items> TO ls_po_items.
        ls_po_items-po_document = <lfs_cba>-po_doc.
        lv_poitem += 10.
        ls_po_items-po_item = lv_poitem.
        APPEND ls_po_items TO lt_po_items.
        APPEND VALUE #( %cid = <lfs_cba>-%cid_ref  po_doc =  ls_po_items-po_document
                        ) TO mapped-purchaseinfo.
        APPEND VALUE #( %cid = <lfs_items>-%cid  po_document =  ls_po_items-po_document po_item = lv_poitem ) TO mapped-purchaseitems.


      ENDLOOP.
      lhc_buffer=>mt_update_poitm = lt_po_items.





    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_PurchaseItems DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE PurchaseItems.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE PurchaseItems.

    METHODS read FOR READ
      IMPORTING keys FOR READ PurchaseItems RESULT result.

ENDCLASS.

CLASS lhc_PurchaseItems IMPLEMENTATION.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_RISHI_POINFO_UM DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_RISHI_POINFO_UM IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    IF lhc_buffer=>mt_create_podoc IS NOT INITIAL OR lhc_buffer=>mt_update_poitm IS NOT INITIAL.
      CALL FUNCTION 'ZRISHI_CREATE_PO'
        EXPORTING
          it_purchase_create = lhc_buffer=>mt_create_podoc
          it_purchase_items  = lhc_buffer=>mt_update_poitm.
    ENDIF.

    IF lhc_buffer=>mt_update_podoc IS NOT INITIAL.

      CALL FUNCTION 'ZRISHI_UPDATE_PO'
        EXPORTING
          it_update_po = lhc_buffer=>mt_update_podoc.
      .
    ENDIF.

  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

ENDCLASS.
