*&---------------------------------------------------------------------*
*& Report Z3W_ALV001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z3W_ALV001.

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
         seatsocc  TYPE sflight-seatsocc,
       END OF type_sflight.

DATA: table_sflight TYPE TABLE OF type_sflight INITIAL SIZE 0.

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
FORM data_retrieval.
  DATA: ld_color(1) TYPE c.

  SELECT carrid connid fldate price currency planetype seatsmax seatsocc
   UP TO 10 ROWS
    FROM sflight
    INTO TABLE table_sflight.

ENDFORM.                    " DATA_RETRIEVAL



*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCATALOG
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

  fieldcatalog-fieldname   = 'FLDATE'.
  fieldcatalog-seltext_m   = 'Flight date'.
  fieldcatalog-col_pos     = 2.
  APPEND fieldcatalog TO fieldcatalogs.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'PRICE'.
  fieldcatalog-seltext_m   = 'Airfare'.
  fieldcatalog-col_pos     = 3.
  APPEND fieldcatalog TO fieldcatalogs.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'CURRENCY'.
  fieldcatalog-seltext_m   = 'Local currency of airline'.
  fieldcatalog-col_pos     = 4.
  APPEND fieldcatalog TO fieldcatalogs.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'PLANETYPE'.
  fieldcatalog-seltext_m   = 'Aircraft Type'.
  fieldcatalog-col_pos     = 5.
  APPEND fieldcatalog TO fieldcatalogs.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'SEATSMAX'.
  fieldcatalog-seltext_m   = 'Maximum capacity in economy class'.
  fieldcatalog-col_pos     = 6.
  APPEND fieldcatalog TO fieldcatalogs.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'SEATSOCC'.
  fieldcatalog-seltext_m   = 'Occupied seats in economy class'.
  fieldcatalog-col_pos     = 7.
  APPEND fieldcatalog TO fieldcatalogs.
  CLEAR  fieldcatalog.

ENDFORM.                    " BUILD_FIELDCATALOG


*&---------------------------------------------------------------------*
*&      Form  BUILD_LAYOUT
*&---------------------------------------------------------------------*

FORM create_layout.

  grid_layout-no_input          = 'X'.
  grid_layout-colwidth_optimize = 'X'.
  grid_layout-zebra = 'X'.
*  gd_layout-info_fieldname =      'LINE_COLOR'.
*  gd_layout-def_status = 'A'.

ENDFORM.                    " BUILD_LAYOUT


*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV_REPORT
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
      t_outtab           = table_sflight
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDFORM.                    " DISPLAY_ALV_REPORT
