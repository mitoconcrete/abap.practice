*&---------------------------------------------------------------------*
*& Report Z4W_ALV001
*&---------------------------------------------------------------------*
*& SPFLI 테이블 ALV 출력 프로그램
*&---------------------------------------------------------------------*
REPORT Z4W_ALV001.

TABLES:     spfli.

TYPE-POOLS: slis.

*Data Declaration
*----------------
TYPES: BEGIN OF type_spfli,
         carrid   TYPE spfli-carrid,
         connid   TYPE spfli-connid,
         fltime   TYPE spfli-fltime,
         deptime  TYPE spfli-deptime,
         arrtime  TYPE spfli-arrtime,
         distance TYPE spfli-distance,
         distid   TYPE spfli-distid,
       END OF type_spfli.

DATA: table_spfli TYPE TABLE OF type_spfli INITIAL SIZE 0.

*ALV data declarations
DATA: fieldcatalog   TYPE slis_fieldcat_alv,
      fieldcatalogs  TYPE slis_t_fieldcat_alv,
      grid_tab_group TYPE slis_t_sp_group_alv,
      grid_layout    TYPE slis_layout_alv,
      grid_repid     LIKE sy-repid.


DATA : t TYPE slis_t_sp_group_alv .
************************************************************************
*Start-of-selection.
START-OF-SELECTION.

  PERFORM data_retrieval.
  PERFORM create_fieldcatalog.
  PERFORM create_layout.
  PERFORM display_alv_report.


*&---------------------------------------------------------------------*
*&      Form  DATA_RETRIEVAL
*&---------------------------------------------------------------------*
*&      SPFLI 테이블에서 데이터 조회
*&---------------------------------------------------------------------*
FORM data_retrieval.

  SELECT carrid connid fltime deptime arrtime distance distid
   UP TO 10 ROWS
    FROM spfli
    INTO TABLE table_spfli.

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
  fieldcatalog-outputlen   = 10.
  APPEND fieldcatalog TO fieldcatalogs.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'CONNID'.
  fieldcatalog-seltext_m   = 'Flight Connection Number'.
  fieldcatalog-col_pos     = 1.
  APPEND fieldcatalog TO fieldcatalogs.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'FLTIME'.
  fieldcatalog-seltext_m   = 'Flight Time'.
  fieldcatalog-col_pos     = 2.
  APPEND fieldcatalog TO fieldcatalogs.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'DEPTIME'.
  fieldcatalog-seltext_m   = 'Departure Time'.
  fieldcatalog-col_pos     = 3.
  APPEND fieldcatalog TO fieldcatalogs.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'ARRTIME'.
  fieldcatalog-seltext_m   = 'Arrival Time'.
  fieldcatalog-col_pos     = 4.
  APPEND fieldcatalog TO fieldcatalogs.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'DISTANCE'.
  fieldcatalog-seltext_m   = 'Distance'.
  fieldcatalog-col_pos     = 5.
  APPEND fieldcatalog TO fieldcatalogs.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'DISTID'.
  fieldcatalog-seltext_m   = 'Distance Unit'.
  fieldcatalog-col_pos     = 6.
  APPEND fieldcatalog TO fieldcatalogs.
  CLEAR  fieldcatalog.

ENDFORM.                    " CREATE_FIELDCATALOG


*&---------------------------------------------------------------------*
*&      Form  CREATE_LAYOUT
*&---------------------------------------------------------------------*
*&      ALV 레이아웃 설정
*&---------------------------------------------------------------------*
FORM create_layout.

  grid_layout-no_input          = 'X'.
  grid_layout-colwidth_optimize = 'X'.
  grid_layout-zebra = 'X'.
*  gd_layout-info_fieldname =      'LINE_COLOR'.
*  gd_layout-def_status = 'A'.

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
      i_save             = 'X'
    TABLES
      t_outtab           = table_spfli
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
  ENDIF.


ENDFORM.                    " DISPLAY_ALV_REPORT
