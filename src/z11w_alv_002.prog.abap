*&---------------------------------------------------------------------*
*& Report z11w_alv_002
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z11w_alv_002.

TABLES:     sbook.                "Database tables

TYPE-POOLS: slis.                                 "ALV Declarations

*Data Declaration
*----------------
TYPES: BEGIN OF it_sbook,
           carrid       TYPE sbook-carrid,
           connid       TYPE sbook-connid,
           luggweight   TYPE sbook-luggweight,
           wunit        TYPE sbook-wunit,
           loccuram     TYPE sbook-loccuram,
           loccurkey    TYPE sbook-loccurkey,
       END OF it_sbook.

DATA: it_sbook TYPE STANDARD TABLE OF it_sbook.
DATA: wa_sbook TYPE it_sbook.
DATA: it_collect TYPE STANDARD TABLE OF it_sbook.

*ALV data declarations
DATA: fieldcatalog TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      gd_tab_group TYPE slis_t_sp_group_alv,
      gd_layout    TYPE slis_layout_alv,
      gd_repid     LIKE sy-repid.


DATA : t TYPE slis_t_sp_group_alv .

SELECTION-SCREEN BEGIN OF BLOCK part1 WITH FRAME TITLE text-001.
SELECT-OPTIONS s_carrid   FOR sbook-carrid.
SELECTION-SCREEN END OF BLOCK part1.


************************************************************************
*Start-of-selection.
START-OF-SELECTION.

  PERFORM data_retrieval.
  PERFORM build_fieldcatalog.
  PERFORM build_layout.
  PERFORM display_alv_report.


*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
*       Build Fieldcatalog for ALV Report
*----------------------------------------------------------------------*
FORM build_fieldcatalog.

  fieldcatalog-fieldname = 'CARRID'.
  fieldcatalog-seltext_m = 'Airline Code'.
  fieldcatalog-col_pos = 1.
  APPEND fieldcatalog.

  fieldcatalog-fieldname = 'CONNID'.
  fieldcatalog-seltext_m = 'Flight Number'.
  fieldcatalog-col_pos = 2.
  APPEND fieldcatalog.

  fieldcatalog-fieldname = 'LUGGWEIGHT'.
  fieldcatalog-seltext_m = 'Luggage Weight'.
  fieldcatalog-col_pos = 3.
  APPEND fieldcatalog.

  fieldcatalog-fieldname = 'WUNIT'.
  fieldcatalog-seltext_m = 'Weight Unit'.
  fieldcatalog-col_pos = 4.
  APPEND fieldcatalog.

  fieldcatalog-fieldname = 'LOCCURAM'.
  fieldcatalog-seltext_m = 'Local Currency Amount'.
  fieldcatalog-col_pos = 5.
  APPEND fieldcatalog.

  fieldcatalog-fieldname = 'LOCCURKEY'.
  fieldcatalog-seltext_m = 'Local Currency Key'.
  fieldcatalog-col_pos = 6.
  APPEND fieldcatalog.

ENDFORM.                    " BUILD_FIELDCATALOG


*&---------------------------------------------------------------------*
*&      Form  BUILD_LAYOUT
*&---------------------------------------------------------------------*
*       Build layout for ALV grid report
*----------------------------------------------------------------------*
FORM build_layout.

  gd_layout-no_input          = 'X'.
  gd_layout-colwidth_optimize = 'X'.
  gd_layout-zebra = 'X'.

ENDFORM.                    " BUILD_LAYOUT


*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV_REPORT
*&---------------------------------------------------------------------*
*       Display report using ALV grid
*----------------------------------------------------------------------*
FORM display_alv_report.
  gd_repid = sy-repid.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = gd_repid
      is_layout          = gd_layout
      it_fieldcat        = fieldcatalog[]
      i_save             = 'X'
    TABLES
      t_outtab           = it_collect
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
  ENDIF.
ENDFORM.                    " DISPLAY_ALV_REPORT


*&---------------------------------------------------------------------*
*&      Form  DATA_RETRIEVAL
*&---------------------------------------------------------------------*
FORM data_retrieval.
    SELECT carrid, connid, luggweight, wunit, loccuram, loccurkey
    FROM sbook
    WHERE carrid IN @s_carrid
    INTO TABLE @it_sbook.

    LOOP AT it_sbook INTO wa_sbook.
        COLLECT wa_sbook INTO it_collect.
    ENDLOOP.
ENDFORM.                    " DATA_RETRIEVAL
