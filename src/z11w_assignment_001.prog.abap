*&---------------------------------------------------------------------*
*& Report z11w_assignment_001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z11w_assignment_001.

TABLES:     sflight.                "Database tables

TYPE-POOLS: slis.                                 "ALV Declarations

*Data Declaration
*----------------
TYPES: BEGIN OF it_sflight,
           carrid       TYPE sflight-carrid,
           connid       TYPE sflight-connid,
           price        TYPE sflight-price,
           currency     TYPE sflight-currency,
           seatmax      TYPE sflight-seatsmax,
       END OF it_sflight.

DATA: gt_sflight TYPE STANDARD TABLE OF it_sflight.
DATA: wa_sflight TYPE it_sflight.
DATA: gt_collect TYPE STANDARD TABLE OF it_sflight.

*ALV data declarations
DATA: fieldcatalog TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      gd_tab_group TYPE slis_t_sp_group_alv,
      gd_layout    TYPE slis_layout_alv,
      gd_repid     LIKE sy-repid.


DATA : t TYPE slis_t_sp_group_alv .

SELECTION-SCREEN BEGIN OF BLOCK part1 WITH FRAME TITLE text-001.
SELECT-OPTIONS s_carrid   FOR sflight-carrid.
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

  fieldcatalog-fieldname = 'PRICE'.
  fieldcatalog-seltext_m = 'Price'.
  fieldcatalog-col_pos = 3.
  APPEND fieldcatalog.

  fieldcatalog-fieldname = 'CURRENCY'.
  fieldcatalog-seltext_m = 'Currency'.
  fieldcatalog-col_pos = 4.
  APPEND fieldcatalog.

  fieldcatalog-fieldname = 'SEATMAX'.
  fieldcatalog-seltext_m = 'Max Seats'.
  fieldcatalog-col_pos = 5.
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
      t_outtab           = gt_collect
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
    SELECT carrid, connid, price, currency, seatsmax
    FROM sflight
    WHERE carrid IN @s_carrid
    INTO TABLE @gt_sflight.

    LOOP AT gt_sflight INTO wa_sflight.
        COLLECT wa_sflight INTO gt_collect.
    ENDLOOP.
ENDFORM.                    " DATA_RETRIEVAL
