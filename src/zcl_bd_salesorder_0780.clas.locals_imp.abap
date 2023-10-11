CLASS lcl_buffer DEFINITION.

  PUBLIC SECTION.

    CONSTANTS: created TYPE c LENGTH 1 VALUE 'C',
               updated TYPE c LENGTH 1 VALUE 'U',
               deleted TYPE c LENGTH 1 VALUE 'D'.

    TYPES: BEGIN OF ty_buffer_hdr.
             INCLUDE TYPE zheader_0780 AS data.
    TYPES:   flag TYPE c LENGTH 1,
           END OF ty_buffer_hdr.

    TYPES: BEGIN OF ty_buffer_itm.
             INCLUDE TYPE zitems_0780 AS data.
    TYPES:   flag TYPE c LENGTH 1,
           END OF ty_buffer_itm.

    TYPES: tt_header TYPE SORTED TABLE OF ty_buffer_hdr WITH UNIQUE KEY ordernumber.
    TYPES: tt_items  TYPE SORTED TABLE OF ty_buffer_itm WITH UNIQUE KEY ordernumber positionnumber.

    CLASS-DATA mt_buffer_hdr TYPE tt_header.
    CLASS-DATA mt_buffer_itm TYPE tt_items.

ENDCLASS.


CLASS lhc_SalesOrder DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS create_header FOR MODIFY IMPORTING entities FOR CREATE Header.
    METHODS update_header FOR MODIFY IMPORTING entities FOR UPDATE Header.
    METHODS delete_header FOR MODIFY IMPORTING entities FOR DELETE Header.

*    methods LOCK_HEADER for lock importing KEYS for lock ServOrd.
    METHODS read_header FOR READ IMPORTING keys FOR READ Header RESULT result.

    METHODS create_item FOR MODIFY IMPORTING entities FOR CREATE Items.
    METHODS update_item FOR MODIFY IMPORTING entities FOR UPDATE Items.
    METHODS delete_item FOR MODIFY IMPORTING entities FOR DELETE Items.

*    methods LOCK_ITEM for lock importing KEYS for lock ServItem.
    METHODS read_item FOR READ IMPORTING keys FOR READ Items RESULT result.
    METHODS rba_Header FOR READ
      IMPORTING keys_rba FOR READ Items\_Header FULL result_requested RESULT result LINK association_links.

    METHODS rba_Items FOR READ
      IMPORTING keys_rba FOR READ Header\_Items FULL result_requested RESULT result LINK association_links.

    METHODS cba_Items FOR MODIFY
      IMPORTING entities_cba FOR CREATE Header\_Items.

ENDCLASS.

CLASS lhc_SalesOrder IMPLEMENTATION.

  METHOD create_header.

    SELECT MAX( ordernumber ) FROM zheader_0780
    INTO @DATA(lv_max_ordernumber).

    lv_max_ordernumber = lv_max_ordernumber + 1.

    GET TIME STAMP FIELD DATA(lv_time_stamp).

    LOOP AT entities INTO DATA(ls_entities).

      ls_entities-%data-ordernumber = lv_max_ordernumber.

      INSERT VALUE #( flag = lcl_buffer=>created
                      data = CORRESPONDING #( ls_entities-%data ) ) INTO TABLE  lcl_buffer=>mt_buffer_hdr.

      IF NOT ls_entities-%cid IS INITIAL.
        INSERT VALUE #( %cid = ls_entities-%cid
                        ordernumber = ls_entities-Ordernumber ) INTO TABLE mapped-header.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD delete_header.

    LOOP AT entities INTO DATA(ls_entities).

      DATA(lv_ordernumber) = ls_entities-ordernumber.

      INSERT VALUE #( flag = lcl_buffer=>deleted
                      data = CORRESPONDING #( ls_entities ) ) INTO TABLE  lcl_buffer=>mt_buffer_hdr.

    ENDLOOP.

    SELECT * FROM zitems_0780
    WHERE ordernumber EQ @lv_ordernumber
    INTO TABLE @DATA(lt_items) .
    IF sy-subrc EQ 0.

      LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<lfs_item>).

        INSERT VALUE #( flag = lcl_buffer=>deleted
                        data = CORRESPONDING #( <lfs_item> ) ) INTO TABLE  lcl_buffer=>mt_buffer_itm.

      ENDLOOP.

    ENDIF.

  ENDMETHOD.

  METHOD delete_item.

    LOOP AT entities INTO DATA(ls_entities).

      INSERT VALUE #( flag = lcl_buffer=>deleted
                      data = CORRESPONDING #( ls_entities ) ) INTO TABLE  lcl_buffer=>mt_buffer_itm.

    ENDLOOP.

  ENDMETHOD.

  METHOD create_item.

    SELECT MAX( ordernumber ) FROM zheader_0780
    INTO @DATA(lv_max_ordernumber).

    lv_max_ordernumber = lv_max_ordernumber + 1.

    GET TIME STAMP FIELD DATA(lv_time_stamp).

    LOOP AT entities INTO DATA(ls_entities).

      ls_entities-%data-ordernumber = lv_max_ordernumber.

      INSERT VALUE #( flag = lcl_buffer=>created
                      data = CORRESPONDING #( ls_entities-%data ) ) INTO TABLE  lcl_buffer=>mt_buffer_hdr.

      IF NOT ls_entities-%cid IS INITIAL.
        INSERT VALUE #( %cid = ls_entities-%cid
                        ordernumber = ls_entities-Ordernumber
                        positionnumber = ls_entities-Positionnumber ) INTO TABLE mapped-items.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD update_header.

    DATA: ls_components TYPE abap_compdescr.
    DATA: lo_strucdescr TYPE REF TO cl_abap_structdescr.

    LOOP AT entities INTO DATA(ls_entities).

      SELECT SINGLE * FROM zheader_0780
      WHERE ordernumber EQ @ls_entities-Ordernumber
      INTO @DATA(ls_header).
      IF sy-subrc EQ 0.

        lo_strucdescr ?= cl_abap_typedescr=>describe_by_data( ls_entities-%control ).

        LOOP AT lo_strucdescr->components INTO ls_components.

          ASSIGN COMPONENT ls_components-name OF STRUCTURE ls_entities-%control TO FIELD-SYMBOL(<lfs_fctrl>).
          IF sy-subrc <> 0.
            EXIT.
          ENDIF.

          IF <lfs_fctrl> EQ cl_abap_behv=>flag_changed.

            ASSIGN COMPONENT ls_components-name OF STRUCTURE ls_entities TO FIELD-SYMBOL(<lfs_fin>).
            IF sy-subrc EQ 0.

              ASSIGN COMPONENT ls_components-name OF STRUCTURE ls_header TO FIELD-SYMBOL(<lfs_fout>).
              IF sy-subrc EQ 0.
                <lfs_fout> = <lfs_fin>.
              ENDIF.

            ENDIF.

          ENDIF.

        ENDLOOP.

      ENDIF.

      INSERT VALUE #( flag = lcl_buffer=>updated
                      data = CORRESPONDING #( ls_header ) ) INTO TABLE  lcl_buffer=>mt_buffer_hdr.

    ENDLOOP.

  ENDMETHOD.

  METHOD update_item.

    DATA: ls_components TYPE abap_compdescr.
    DATA: lo_strucdescr TYPE REF TO cl_abap_structdescr.

    LOOP AT entities INTO DATA(ls_entities).

      SELECT SINGLE * FROM zitems_0780
      WHERE ordernumber EQ @ls_entities-Ordernumber
      AND   positionnumber EQ @ls_entities-Positionnumber
      INTO @DATA(ls_item).
      IF sy-subrc EQ 0.

        lo_strucdescr ?= cl_abap_typedescr=>describe_by_data( ls_entities-%control ).

        LOOP AT lo_strucdescr->components INTO ls_components.

          ASSIGN COMPONENT ls_components-name OF STRUCTURE ls_entities-%control TO FIELD-SYMBOL(<lfs_fctrl>).
          IF sy-subrc <> 0.
            EXIT.
          ENDIF.

          IF <lfs_fctrl> EQ cl_abap_behv=>flag_changed.

            ASSIGN COMPONENT ls_components-name OF STRUCTURE ls_entities TO FIELD-SYMBOL(<lfs_fin>).
            IF sy-subrc EQ 0.

              ASSIGN COMPONENT ls_components-name OF STRUCTURE ls_item TO FIELD-SYMBOL(<lfs_fout>).
              IF sy-subrc EQ 0.
                <lfs_fout> = <lfs_fin>.
              ENDIF.

            ENDIF.

          ENDIF.

        ENDLOOP.

      ENDIF.

      INSERT VALUE #( flag = lcl_buffer=>updated
                      data = CORRESPONDING #( ls_item ) ) INTO TABLE  lcl_buffer=>mt_buffer_itm.

    ENDLOOP.

*    LOOP AT entities INTO DATA(ls_entities).
*
*      INSERT VALUE #( flag = lcl_buffer=>updated
*                      data = CORRESPONDING #( ls_entities-%data ) ) INTO TABLE  lcl_buffer=>mt_buffer_itm.
*
*    ENDLOOP.

  ENDMETHOD.

  METHOD cba_Items.

    DATA(lv_count) = 0.
    LOOP AT entities_cba INTO DATA(LS_entities).

      SELECT
      Ordernumber,
      positionnumber
      FROM zitems_0780
      WHERE ordernumber EQ @ls_entities-Ordernumber
      INTO TABLE @DATA(lt_items).
      IF sy-subrc EQ 0.
        lv_count = lines( lt_items ).
      ENDIF.

      lv_count = lv_count + 1.
      LOOP AT LS_entities-%target INTO DATA(ls_target).

        ls_target-Ordernumber = LS_entities-Ordernumber.
        ls_target-Positionnumber = lv_count.

        INSERT VALUE #( flag = lcl_buffer=>created
                        data = CORRESPONDING #( ls_target ) ) INTO TABLE  lcl_buffer=>mt_buffer_itm.

        IF NOT ls_target-%cid IS INITIAL.
          INSERT VALUE #( %cid = ls_target-%cid
                          ordernumber = ls_target-Ordernumber ) INTO TABLE mapped-items.
        ENDIF.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

  METHOD read_header.
  ENDMETHOD.

  METHOD read_item.
  ENDMETHOD.

  METHOD rba_Header.
  ENDMETHOD.

  METHOD rba_Items.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_Z_I_HEADER_0780 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

*    METHODS SAVE_MODIFIED REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_Z_I_HEADER_0780 IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.

    DATA: lt_data_created  TYPE STANDARD TABLE OF zheader_0780.
    DATA: lt_data_updated  TYPE STANDARD TABLE OF zheader_0780.
    DATA: lt_data_deleted  TYPE STANDARD TABLE OF zheader_0780.
    DATA: lt_items_created TYPE STANDARD TABLE OF zitems_0780.
    DATA: lt_items_updated TYPE STANDARD TABLE OF zitems_0780.
    DATA: lt_items_deleted TYPE STANDARD TABLE OF zitems_0780.

    lt_data_created = VALUE #( FOR <row> IN lcl_buffer=>mt_buffer_hdr
                                WHERE ( flag EQ lcl_buffer=>created ) ( <row>-data )  ).
    IF lt_data_created IS NOT INITIAL.
      INSERT zheader_0780 FROM TABLE @lt_data_created.
    ENDIF.

    lt_data_updated = VALUE #( FOR <row> IN lcl_buffer=>mt_buffer_hdr
                                WHERE ( flag EQ lcl_buffer=>updated ) ( <row>-data )  ).
    IF lt_data_updated IS NOT INITIAL.
      UPDATE zheader_0780 FROM TABLE @lt_data_updated.
    ENDIF.

    lt_data_deleted = VALUE #( FOR <row> IN lcl_buffer=>mt_buffer_hdr
                                WHERE ( flag EQ lcl_buffer=>deleted ) ( <row>-data )  ).
    IF lt_data_deleted IS NOT INITIAL.
      DELETE zheader_0780 FROM TABLE @lt_data_deleted.
      IF sy-subrc EQ 0.

        lt_items_deleted = VALUE #( FOR <row2> IN lcl_buffer=>mt_buffer_itm
                                    WHERE ( flag EQ lcl_buffer=>deleted ) ( <row2>-data )  ).
        IF lt_items_deleted IS NOT INITIAL.
          DELETE zitems_0780 FROM TABLE @lt_items_deleted.
        ENDIF.

      ENDIF.

    ENDIF.

    lt_items_created = VALUE #( FOR <row2> IN lcl_buffer=>mt_buffer_itm
                                WHERE ( flag EQ lcl_buffer=>created ) ( <row2>-data )  ).
    IF lt_items_created IS NOT INITIAL.
      INSERT zitems_0780 FROM TABLE @lt_items_created.
    ENDIF.

    lt_items_deleted = VALUE #( FOR <row2> IN lcl_buffer=>mt_buffer_itm
                                WHERE ( flag EQ lcl_buffer=>deleted ) ( <row2>-data )  ).
    IF lt_items_deleted IS NOT INITIAL.
      DELETE zitems_0780 FROM TABLE @lt_items_deleted.
    ENDIF.

    lt_items_updated = VALUE #( FOR <row2> IN lcl_buffer=>mt_buffer_itm
                                WHERE ( flag EQ lcl_buffer=>updated ) ( <row2>-data )  ).
    IF lt_items_updated IS NOT INITIAL.
      UPDATE zitems_0780 FROM TABLE @lt_items_updated.
    ENDIF.

    CLEAR: lcl_buffer=>mt_buffer_hdr, lcl_buffer=>mt_buffer_itm.

  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

*  METHOD SAVE_MODIFIED.
*
*  ENDMETHOD.

ENDCLASS.
