CLASS lcl_buffer DEFINITION CREATE PRIVATE.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_buffer,
             flag    TYPE c LENGTH 1,
             lv_data TYPE zcit_dm_t22ad124,
           END OF ty_buffer.
    CLASS-DATA mt_buffer TYPE STANDARD TABLE OF ty_buffer WITH EMPTY KEY.
    CLASS-METHODS get_instance RETURNING VALUE(ro_instance) TYPE REF TO lcl_buffer.
    METHODS add_to_buffer IMPORTING iv_flag TYPE c is_doc TYPE zcit_dm_t22ad124.
  PRIVATE SECTION.
    CLASS-DATA go_instance TYPE REF TO lcl_buffer.
ENDCLASS.

CLASS lcl_buffer IMPLEMENTATION.
  METHOD get_instance.
    IF go_instance IS NOT BOUND.
      go_instance = NEW #( ).
    ENDIF.
    ro_instance = go_instance.
  ENDMETHOD.
  METHOD add_to_buffer.
    INSERT VALUE ty_buffer( flag = iv_flag lv_data = is_doc ) INTO TABLE mt_buffer.
  ENDMETHOD.
ENDCLASS.

CLASS lhc_Document DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Document RESULT result.
    METHODS create FOR MODIFY IMPORTING entities FOR CREATE Document.
    METHODS update FOR MODIFY IMPORTING entities FOR UPDATE Document.
    METHODS delete FOR MODIFY IMPORTING keys FOR DELETE Document.
    METHODS read   FOR READ   IMPORTING keys FOR READ Document RESULT result.
    METHODS lock   FOR LOCK   IMPORTING keys FOR LOCK Document.
ENDCLASS.

CLASS lhc_Document IMPLEMENTATION.
  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.
    DATA(lo_buffer) = lcl_buffer=>get_instance( ).
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      DATA ls_doc TYPE zcit_dm_t22ad124.

      " Manual Mapping to resolve the error
      ls_doc-doc_id       = <ls_entity>-DocumentID.
      ls_doc-doc_title    = <ls_entity>-Title.
      ls_doc-doc_type     = <ls_entity>-DocType.
      ls_doc-doc_status   = <ls_entity>-Status.
      ls_doc-priority     = <ls_entity>-Priority.
      ls_doc-storage_cost = <ls_entity>-StorageCost.
      ls_doc-currency     = <ls_entity>-Currency.

      " Advanced Logic: Auto-fill metadata
      ls_doc-created_by = sy-uname.
      GET TIME STAMP FIELD ls_doc-created_at.

      lo_buffer->add_to_buffer( iv_flag = 'C' is_doc = ls_doc ).

      INSERT VALUE #( %cid = <ls_entity>-%cid DocumentID = ls_doc-doc_id )
             INTO TABLE mapped-document.
    ENDLOOP.
  ENDMETHOD.

  METHOD update. " Implementation similar to reference PDF [cite: 227]
  ENDMETHOD.

  METHOD delete. " Implementation similar to reference PDF [cite: 248]
  ENDMETHOD.

  METHOD read.
    SELECT * FROM zcit_dm_t22ad124 FOR ALL ENTRIES IN @keys
      WHERE doc_id = @keys-DocumentID INTO CORRESPONDING FIELDS OF TABLE @result.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.
ENDCLASS.

CLASS lsc_ZCIT_DM_I22AD124 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save REDEFINITION.
    METHODS finalize REDEFINITION.
    METHODS check_before_save REDEFINITION.

    METHODS cleanup REDEFINITION.
ENDCLASS.

CLASS lsc_ZCIT_DM_I22AD124 IMPLEMENTATION.
  METHOD save.
    LOOP AT lcl_buffer=>mt_buffer ASSIGNING FIELD-SYMBOL(<ls_buf>).
      CASE <ls_buf>-flag.
        WHEN 'C'. INSERT zcit_dm_t22ad124 FROM @<ls_buf>-lv_data.
        WHEN 'U'. UPDATE zcit_dm_t22ad124 FROM @<ls_buf>-lv_data.
        WHEN 'D'. DELETE FROM zcit_dm_t22ad124 WHERE doc_id = @<ls_buf>-lv_data-doc_id.
      ENDCASE.
    ENDLOOP.
    CLEAR lcl_buffer=>mt_buffer.
  ENDMETHOD.
  METHOD finalize. ENDMETHOD.
  METHOD check_before_save. ENDMETHOD.

  METHOD cleanup. ENDMETHOD.
ENDCLASS.
