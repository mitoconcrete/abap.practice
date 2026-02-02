*&---------------------------------------------------------------------*
*& Report z7w_sel_alv002
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z7w_sel_alv002.

TABLES:     sflight.

TYPE-POOLS: slis.                                 "ALV Declarations

*Data Declaration
*----------------
TYPES: BEGIN OF t_sflight,
  carrid   TYPE sflight-carrid,
  connid   TYPE sflight-connid,
  fldate   TYPE sflight-fldate,
  price    TYPE sflight-price,
  currency TYPE sflight-currency,
  planetype TYPE sflight-planetype,
  seatsmax TYPE sflight-seatsmax,
 END OF t_sflight.

DATA: it_sflight TYPE STANDARD TABLE OF t_sflight INITIAL SIZE 0,
      wa_sflight TYPE t_sflight.

*ALV data declarations
DATA: fieldcatalog TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      gd_tab_group TYPE slis_t_sp_group_alv,
      gd_layout    TYPE slis_layout_alv,
      gd_repid     LIKE sy-repid.


DATA : t TYPE slis_t_sp_group_alv .
************************************************************************
*Start-of-selection.

SELECTION-SCREEN BEGIN OF BLOCK part2 WITH FRAME TITLE text-001.
SELECT-OPTIONS s_carrid FOR sflight-carrid OBLIGATORY.
SELECT-OPTIONS s_connid FOR sflight-connid.
SELECT-OPTIONS s_fldate FOR sflight-fldate.
SELECTION-SCREEN SKIP.
SELECT-OPTIONS s_price FOR sflight-price.
SELECT-OPTIONS s_curr FOR sflight-currency.
SELECT-OPTIONS s_ptype FOR sflight-planetype.
SELECT-OPTIONS s_seats FOR sflight-seatsmax.
SELECTION-SCREEN SKIP.
PARAMETERS num TYPE i DEFAULT 100.
SELECTION-SCREEN END OF BLOCK part2.

INITIALIZATION.
   s_carrid-SIGN = 'I'.
   s_carrid-OPTION = 'EQ'.
   s_carrid-LOW = 'AA'.
   s_carrid-HIGH = ''.
   APPEND s_carrid.
   CLEAR s_carrid.

   s_carrid-SIGN = 'I'.
   s_carrid-OPTION = 'BT'.
   s_carrid-LOW = 'AB'.
   s_carrid-HIGH = 'ZZ'.
   APPEND s_carrid.
   CLEAR s_carrid.

   s_carrid-SIGN = 'E'.
   s_carrid-OPTION = 'EQ'.
   s_carrid-LOW = 'AB'.
   s_carrid-HIGH = ''.
   APPEND s_carrid.
   CLEAR s_carrid.

   s_carrid-SIGN = 'E'.
   s_carrid-OPTION = 'BT'.
   s_carrid-LOW = 'AC'.
   s_carrid-HIGH = 'AF'.
   APPEND s_carrid.
   CLEAR s_carrid.


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

  fieldcatalog-fieldname   = 'CARRID'.
  fieldcatalog-seltext_m   = 'Airline Code'.
  fieldcatalog-col_pos     = 1.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'CONNID'.
  fieldcatalog-seltext_m   = 'Flight Connection'.
  fieldcatalog-col_pos     = 2.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'FLDATE'.
  fieldcatalog-seltext_m   = 'Flight Date'.
  fieldcatalog-col_pos     = 3.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'PRICE'.
  fieldcatalog-seltext_m   = 'Price'.
  fieldcatalog-col_pos     = 4.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'CURRENCY'.
  fieldcatalog-seltext_m   = 'Currency'.
  fieldcatalog-col_pos     = 5.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'PLANETYPE'.
  fieldcatalog-seltext_m   = 'Plane Type'.
  fieldcatalog-col_pos     = 6.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'SEATSMAX'.
  fieldcatalog-seltext_m   = 'Maximum Seats'.
  fieldcatalog-col_pos     = 7.
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
*  gd_layout-info_fieldname =      'LINE_COLOR'.
*  gd_layout-def_status = 'A'.

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
      t_outtab           = it_sflight
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDFORM.                    " DISPLAY_ALV_REPORT


*&---------------------------------------------------------------------*
*&      Form  DATA_RETRIEVAL
*&---------------------------------------------------------------------*

FORM data_retrieval.
  SELECT carrid connid fldate price currency planetype seatsmax
    UP TO num ROWS
    FROM sflight
    INTO TABLE it_sflight
    WHERE carrid IN s_carrid
    AND connid IN s_connid
    AND fldate IN s_fldate
    AND price IN s_price
    AND currency IN s_curr
    AND planetype IN s_ptype
    AND seatsmax IN s_seats.
ENDFORM.                    " DATA_RETRIEVAL

*Text Elements Definition
*---------------------------------------
* TEXT-001: Selection Screen Title
* TEXT-002: Airline Code (CARRID)
* TEXT-003: Flight Connection (CONNID)
* TEXT-004: Flight Date (FLDATE)
* TEXT-005: Price (PRICE)
* TEXT-006: Currency (CURRENCY)
* TEXT-007: Plane Type (PLANETYPE)
* TEXT-008: Maximum Seats (SEATSMAX)
* TEXT-009: Maximum No. of Hits (NUM)
