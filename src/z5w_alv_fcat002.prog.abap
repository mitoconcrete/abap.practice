*&---------------------------------------------------------------------*
*& Report Z5W_ALV_FCAT002
*&---------------------------------------------------------------------*
*& SFLIGHT 테이블 ALV 출력 프로그램 (KEY, SUBTOTAL, HOTSPOT, EMPHASIZE)
*&---------------------------------------------------------------------*
REPORT Z5W_ALV_FCAT002.

TABLES:     sflight.

TYPE-POOLS: slis.

*Data Declaration
*----------------
TYPES: BEGIN OF type_sflight,
         carrid    TYPE sflight-carrid,
         connid    TYPE sflight-connid,
         fldate    TYPE sflight-fldate,
         price     TYPE sflight-price,
         currency  TYPE sflight-currency,
         planetype TYPE sflight-planetype,
         seatsmax  TYPE sflight-seatsmax,
       END OF type_sflight.

DATA: table_sflight TYPE TABLE OF type_sflight INITIAL SIZE 0.

*ALV data declarations
DATA: fieldcatalog   TYPE slis_fieldcat_alv,
      fieldcatalogs  TYPE slis_t_fieldcat_alv,
      sortinfo       TYPE slis_sortinfo_alv,
      sortinfos      TYPE slis_t_sortinfo_alv,
      grid_layout    TYPE slis_layout_alv,
      grid_repid     LIKE sy-repid.
      

************************************************************************
*Start-of-selection.
START-OF-SELECTION.

  PERFORM data_retrieval.
  PERFORM create_fieldcatalog.
  PERFORM create_sortinfo.
  PERFORM create_layout.
  PERFORM display_alv_report.


*&---------------------------------------------------------------------*
*&      Form  DATA_RETRIEVAL
*&---------------------------------------------------------------------*
*&      SFLIGHT 테이블에서 데이터 조회
*&---------------------------------------------------------------------*
FORM data_retrieval.

  SELECT carrid connid fldate price currency planetype seatsmax
    FROM sflight
    INTO TABLE table_sflight.

ENDFORM.                    " DATA_RETRIEVAL



*&---------------------------------------------------------------------*
*&      Form  CREATE_FIELDCATALOG
*&---------------------------------------------------------------------*
*&      ALV 필드 카탈로그 생성
*&---------------------------------------------------------------------*
FORM create_fieldcatalog.

  fieldcatalog-fieldname   = 'CARRID'.
  fieldcatalog-seltext_m   = 'Airline Code'.
  fieldcatalog-col_pos     = 0.
  fieldcatalog-key         = 'X'.
  APPEND fieldcatalog TO fieldcatalogs.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'CONNID'.
  fieldcatalog-seltext_m   = 'Flight Connection Number'.
  fieldcatalog-col_pos     = 1.
  fieldcatalog-key         = 'X'.
  fieldcatalog-lzero       = 'X'.
  fieldcatalog-hotspot     = 'X'.
  APPEND fieldcatalog TO fieldcatalogs.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'FLDATE'.
  fieldcatalog-seltext_m   = 'Flight Date'.
  fieldcatalog-col_pos     = 2.
  fieldcatalog-key         = 'X'.
  APPEND fieldcatalog TO fieldcatalogs.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'PRICE'.
  fieldcatalog-seltext_m   = 'Airfare'.
  fieldcatalog-col_pos     = 3.
  fieldcatalog-do_sum      = 'X'.
  APPEND fieldcatalog TO fieldcatalogs.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'CURRENCY'.
  fieldcatalog-seltext_m   = 'Currency'.
  fieldcatalog-col_pos     = 4.
  fieldcatalog-emphasize   = 'X'.
  APPEND fieldcatalog TO fieldcatalogs.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'PLANETYPE'.
  fieldcatalog-seltext_m   = 'Aircraft Type'.
  fieldcatalog-col_pos     = 5.
  fieldcatalog-emphasize   = 'C310'.
  APPEND fieldcatalog TO fieldcatalogs.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'SEATSMAX'.
  fieldcatalog-seltext_m   = 'Maximum Seats'.
  fieldcatalog-col_pos     = 6.
  fieldcatalog-do_sum      = 'X'.
  APPEND fieldcatalog TO fieldcatalogs.
  CLEAR  fieldcatalog.

ENDFORM.                    " CREATE_FIELDCATALOG


*&---------------------------------------------------------------------*
*&      Form  CREATE_SORTINFO
*&---------------------------------------------------------------------*
*&      정렬 및 서브토탈 설정
*&---------------------------------------------------------------------*
FORM create_sortinfo.

  sortinfo-fieldname = 'CARRID'.
  sortinfo-spos      = 1.
  sortinfo-up        = 'X'.
  sortinfo-subtot    = 'X'.
  APPEND sortinfo TO sortinfos.
  CLEAR  sortinfo.

  sortinfo-fieldname = 'CONNID'.
  sortinfo-spos      = 2.
  sortinfo-down      = 'X'.
  sortinfo-subtot    = 'X'.
  APPEND sortinfo TO sortinfos.
  CLEAR  sortinfo.

ENDFORM.                    " CREATE_SORTINFO


*&---------------------------------------------------------------------*
*&      Form  CREATE_LAYOUT
*&---------------------------------------------------------------------*
*&      ALV 레이아웃 설정
*&---------------------------------------------------------------------*
FORM create_layout.

  grid_layout-no_input          = 'X'.
  grid_layout-colwidth_optimize = 'X'.
  grid_layout-zebra             = 'X'.
  grid_layout-totals_before_items = 'X'.

ENDFORM.                    " CREATE_LAYOUT


*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV_REPORT
*&---------------------------------------------------------------------*
*&      ALV 그리드 출력
*&---------------------------------------------------------------------*
FORM display_alv_report.
  grid_repid = sy-repid.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = grid_repid
      is_layout          = grid_layout
      it_fieldcat        = fieldcatalogs[]
      it_sort            = sortinfos[]
      i_save             = 'X'
    TABLES
      t_outtab           = table_sflight
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
  ENDIF.

ENDFORM.                    " DISPLAY_ALV_REPORT
