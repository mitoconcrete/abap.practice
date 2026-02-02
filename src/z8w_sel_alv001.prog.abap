*&---------------------------------------------------------------------*
*& Report z8w_sel_alv001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z8w_sel_alv001.

TABLES:     SCARR.


TYPE-POOLS: slis.                                 "ALV Declarations

*Data Declaration
*----------------
TYPES: BEGIN OF t_scarr,
  carrid TYPE scarr-carrid,
  carrname TYPE scarr-carrname,
  currcode TYPE scarr-currcode,
  url TYPE scarr-url,
   "Used to store row color attributes
 END OF t_scarr.

DATA: it_scarr TYPE STANDARD TABLE OF t_scarr INITIAL SIZE 0,
      wa_scarr TYPE t_scarr.

*ALV data declarations
DATA: fieldcatalog TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      gd_tab_group TYPE slis_t_sp_group_alv,
      gd_layout    TYPE slis_layout_alv,
      gd_repid     LIKE sy-repid.


*DATA : t TYPE slis_t_sp_group_alv .


SELECTION-SCREEN BEGIN OF BLOCK part1 WITH FRAME TITLE text-001.
SELECT-OPTIONS s_carrid FOR scarr-carrid  .
SELECTION-SCREEN SKIP.
SELECT-OPTIONS s_cname FOR scarr-carrname  .
SELECT-OPTIONS s_ccode FOR scarr-currcode  .
SELECT-OPTIONS s_url FOR scarr-url  .
SELECTION-SCREEN SKIP.
PARAMETERS NUM TYPE I DEFAULT 10.
*SELECT-OPTIONS s_carrn FOR scarr-carrname.
*SELECT-OPTIONS s_currcd FOR scarr-currcode .
*PARAMETERS p_carrid TYPE scarr-carrid OBLIGATORY DEFAULT 'AA'.
SELECTION-SCREEN END OF BLOCK part1.


INITIALIZATION.

**p_carrid = 'AA'.
*
**

*  s_carrid-SIGN   = 'I'.
*  s_carrid-OPTION   = 'BT'.
*  s_carrid-LOW     = 'AA'.
*  s_carrid-HIGH   = 'AZ'.
*  APPEND s_carrid TO s_carrid.
*  CLEAR  s_carrid.
*
*  s_carrid-SIGN   = 'I'.
*  s_carrid-OPTION   = 'EQ'.
*  s_carrid-LOW     = 'AB'.
**  s_carrid-HIGH   = 'AZ'.
*  APPEND s_carrid TO s_carrid.
*  CLEAR  s_carrid.
*
*  s_carrid-SIGN   = 'I'.
*  s_carrid-OPTION   = 'EQ'.
*  s_carrid-LOW     = 'AC'.
**  s_carrid-HIGH   = 'AZ'.
*  APPEND s_carrid TO s_carrid.
*  CLEAR  s_carrid.
*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_cname-low.
* s_cname-low = 'American Airlines'.

  TYPES : BEGIN OF abc,
    carrname type scarr-carrname,
  END of abc.

  DATA: IT_F4HELP3 TYPE TABLE OF abc.

  SELECT CARRNAME FROM SCARR
  INTO TABLE IT_F4HELP3.

    DATA: IT_RETURN_TAB TYPE ddshretval OCCURS 0 WITH HEADER LINE .

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD         = 'CARRNAME'
      VALUE_ORG        = 'S'
      DYNPROFIELD      = 's_cname-low'
      DYNPPROG         = SY-REPID
      DYNPNR           = SY-DYNNR
      CALLBACK_FORM    = 'CALL_BACK2'
      CALLBACK_PROGRAM = SY-REPID
    TABLES
      VALUE_TAB        = IT_F4HELP3
      RETURN_TAB       = IT_RETURN_TAB
    EXCEPTIONS
      PARAMETER_ERROR  = 1
      NO_VALUES_FOUND  = 2
      OTHERS           = 3.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_cname-high.
*  s_cname-high = 'American Airlines'.

  TYPES : BEGIN OF abc,
    carrname type scarr-carrname,
  END of abc.

  DATA: IT_F4HELP3 TYPE TABLE OF abc.

  SELECT CARRNAME FROM SCARR
  INTO TABLE IT_F4HELP3.

    DATA: IT_RETURN_TAB TYPE ddshretval OCCURS 0 WITH HEADER LINE .

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD         = 'CARRNAME'
      VALUE_ORG        = 'S'
      DYNPROFIELD      = 's_cname-high'
      DYNPPROG         = SY-REPID
      DYNPNR           = SY-DYNNR
      CALLBACK_FORM    = 'CALL_BACK2'
      CALLBACK_PROGRAM = SY-REPID
    TABLES
      VALUE_TAB        = IT_F4HELP3
      RETURN_TAB       = IT_RETURN_TAB
    EXCEPTIONS
      PARAMETER_ERROR  = 1
      NO_VALUES_FOUND  = 2
      OTHERS           = 3.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_url-low.

  TYPES : BEGIN OF abc,
    url type scarr-url,
  END of abc.

  DATA: IT_F4HELP3 TYPE TABLE OF abc.

  SELECT URL FROM SCARR
  INTO TABLE IT_F4HELP3.

    DATA: IT_RETURN_TAB TYPE ddshretval OCCURS 0 WITH HEADER LINE .

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD         = 'CARRNAME'
      VALUE_ORG        = 'S'
      DYNPROFIELD      = 's_url-low'
      DYNPPROG         = SY-REPID
      DYNPNR           = SY-DYNNR
      CALLBACK_FORM    = 'CALL_BACK2'
      CALLBACK_PROGRAM = SY-REPID
    TABLES
      VALUE_TAB        = IT_F4HELP3
      RETURN_TAB       = IT_RETURN_TAB
    EXCEPTIONS
      PARAMETER_ERROR  = 1
      NO_VALUES_FOUND  = 2
      OTHERS           = 3.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_url-high.
*  s_cname-high = 'American Airlines'.


  TYPES : BEGIN OF abc,
    url type scarr-url,
  END of abc.

  DATA: IT_F4HELP3 TYPE TABLE OF abc.

  SELECT URL FROM SCARR
  INTO TABLE IT_F4HELP3.

    DATA: IT_RETURN_TAB TYPE ddshretval OCCURS 0 WITH HEADER LINE .

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD         = 'URL'
      VALUE_ORG        = 'S'
      DYNPROFIELD      = 's_url-high'
      DYNPPROG         = SY-REPID
      DYNPNR           = SY-DYNNR
      CALLBACK_FORM    = 'CALL_BACK2'
      CALLBACK_PROGRAM = SY-REPID
    TABLES
      VALUE_TAB        = IT_F4HELP3
      RETURN_TAB       = IT_RETURN_TAB
    EXCEPTIONS
      PARAMETER_ERROR  = 1
      NO_VALUES_FOUND  = 2
      OTHERS           = 3.



*&---------------------------------------------------------------------*
*&      Form  call_back2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RECORD_TAB   text
*      -->SHLP_TOP     text
*      -->CALLCONTROL  text
*----------------------------------------------------------------------*
FORM CALL_BACK2 TABLES RECORD_TAB STRUCTURE SEAHLPRES
               CHANGING SHLP_TOP TYPE SHLP_DESCR
                     CALLCONTROL LIKE DDSHF4CTRL.

  SHLP_TOP-INTDESCR-DIALOGTYPE = 'A'.   "A 100개 이상이면 다이알로그 조회, D 즉시조회,  C 다이알로그 조회

ENDFORM.                    "call_back

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

  fieldcatalog-fieldname   = 'CARRID'.
  fieldcatalog-seltext_m   = 'Airline Code(CARRID)'.
  fieldcatalog-col_pos     = 0.
  fieldcatalog-outputlen   = 10.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'CARRNAME'.
  fieldcatalog-seltext_l   = 'Airline name(CARRNAME)'.
  fieldcatalog-col_pos     = 1.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'CURRCODE'.
  fieldcatalog-seltext_l   = 'Local currency of airline(CURRCODE)'.
  fieldcatalog-col_pos     = 2.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'URL'.
  fieldcatalog-seltext_m   = 'Airline URL(URL)'.
  fieldcatalog-col_pos     = 3.
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
      t_outtab           = it_scarr
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
*       Retrieve data form EKPO table and populate itab it_ekko
*----------------------------------------------------------------------*
FORM data_retrieval.
*  DATA: ld_color(1) TYPE c.

  SELECT carrid carrname currcode url
   UP TO NUM ROWS
    FROM scarr
    INTO TABLE it_scarr
*    WHERE carrid = p_carrid.
    WHERE carrid IN s_carrid
      AND carrname IN s_cname
      AND currcode IN s_ccode
      AND url IN s_url.
*    AND currcode IN s_currcd.

ENDFORM.                    " DATA_RETRIEVAL
