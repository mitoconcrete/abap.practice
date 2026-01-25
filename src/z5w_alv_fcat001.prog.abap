*&---------------------------------------------------------------------*
*& Report Z5W_ALV_FCAT001
*&---------------------------------------------------------------------*
*& Subtotal 기능이 있는 ALV 출력 프로그램
*&---------------------------------------------------------------------*
REPORT Z5W_ALV_FCAT001.

TABLES:     sflight.

TYPE-POOLS: slis.                                 "ALV Declarations

*Data Declaration
*----------------
TYPES: BEGIN OF t_sflight,
  carrid    TYPE sflight-carrid,
  connid   TYPE sflight-connid,
  seatsmax TYPE sflight-seatsmax,
 END OF t_sflight.

DATA: it_sflight TYPE STANDARD TABLE OF t_sflight.

*ALV data declarations
DATA: fieldcatalog TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      gd_layout    TYPE slis_layout_alv,
      gd_repid     LIKE sy-repid.

DATA: it_sortinfo TYPE slis_t_sortinfo_alv WITH HEADER LINE.

************************************************************************
*Start-of-selection.
START-OF-SELECTION.

  PERFORM data_retrieval.
  PERFORM build_fieldcatalog.
  PERFORM build_layout.
  PERFORM build_sortinfo.
  PERFORM display_alv_report.


*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
*       Build Fieldcatalog for ALV Report
*----------------------------------------------------------------------*
FORM build_fieldcatalog.

  fieldcatalog-fieldname   = 'CARRID'.
  fieldcatalog-seltext_m   = '항공사 코드'.
  fieldcatalog-col_pos     = 0.
  fieldcatalog-key         = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'CONNID'.
  fieldcatalog-seltext_m   = '항공편 번호'.
  fieldcatalog-col_pos     = 1.
  fieldcatalog-key         = 'X'.
  fieldcatalog-lzero       = 'X'.
  fieldcatalog-just        = 'L'.
  fieldcatalog-hotspot     = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'SEATSMAX'.
  fieldcatalog-seltext_m   = '좌석 수'.
  fieldcatalog-col_pos     = 2.
  fieldcatalog-emphasize   = 'C310'.
  fieldcatalog-do_sum      = 'X'.
"   fieldcatalog-edit        = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

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
  gd_layout-totals_before_items = 'X'.

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
      it_fieldcat        = fieldcatalogs[]
      it_sort            = it_sortinfo[]
      i_save             = 'X'
    TABLES
      t_outtab           = it_sflight
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
  ENDIF.


ENDFORM.                    " DISPLAY_ALV_REPORT


*&---------------------------------------------------------------------*
*&      Form  DATA_RETRIEVAL
*&---------------------------------------------------------------------*
*       Retrieve data form SFLIGHT table and populate itab it_sflight
*----------------------------------------------------------------------*
FORM data_retrieval.
  DATA: ld_color(1) TYPE c.

  SELECT carrid connid seatsmax
    FROM sflight
    INTO TABLE it_sflight.

ENDFORM.                    " DATA_RETRIEVAL

*&---------------------------------------------------------------------*
*&      Form  BUILD_SORTINFO
*&---------------------------------------------------------------------*
*       Build sortinfo for ALV Report
*----------------------------------------------------------------------*
FORM build_sortinfo.
  it_sortinfo-spos        = 1.
  it_sortinfo-fieldname   = 'CARRID'.
  it_sortinfo-up          = 'X'.  "오름차순
  APPEND it_sortinfo TO it_sortinfo.
  CLEAR  it_sortinfo.

  it_sortinfo-spos        = 2.
  it_sortinfo-fieldname   = 'CONNID'.
  it_sortinfo-down        = 'X'.  "내림차순
  APPEND it_sortinfo TO it_sortinfo.
  CLEAR  it_sortinfo.
ENDFORM.                    " BUILD_SORTINFO