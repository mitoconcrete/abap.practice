*&---------------------------------------------------------------------*
*& Report z8w_sel_alv002
*&---------------------------------------------------------------------*
REPORT z8w_sel_alv002.

TABLES: spfli.

TYPE-POOLS: slis.

*-------------------------
* Selection screen (simple)
*-------------------------
SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE text-001.
SELECT-OPTIONS s_carrid FOR spfli-carrid.
SELECT-OPTIONS s_connid FOR spfli-connid.
SELECTION-SCREEN SKIP.
SELECT-OPTIONS s_cfrom  FOR spfli-cityfrom.
SELECT-OPTIONS s_cto    FOR spfli-cityto.
SELECTION-SCREEN SKIP.
SELECT-OPTIONS s_period FOR spfli-period.
SELECTION-SCREEN SKIP.
PARAMETERS num TYPE i DEFAULT 100.
SELECTION-SCREEN END OF BLOCK blk1.


*-------------------------
* Custom help texts
*-------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_period-low.

  TYPES : BEGIN OF abc,
    period type spfli-period,
  END of abc.

  DATA: IT_F4HELP3 TYPE TABLE OF abc.

  SELECT PERIOD FROM SPFLI
  INTO TABLE IT_F4HELP3.

    DATA: IT_RETURN_TAB TYPE ddshretval OCCURS 0 WITH HEADER LINE .

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD         = 'PERIOD'
      VALUE_ORG        = 'S'
      DYNPROFIELD      = 's_period-low'
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

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_period-high.

  TYPES : BEGIN OF abc,
    period type spfli-period,
  END of abc.

  DATA: IT_F4HELP3 TYPE TABLE OF abc.

  SELECT PERIOD FROM SPFLI
  INTO TABLE IT_F4HELP3.

    DATA: IT_RETURN_TAB TYPE ddshretval OCCURS 0 WITH HEADER LINE .

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD         = 'PERIOD'
      VALUE_ORG        = 'S'
      DYNPROFIELD      = 's_period-high'
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

FORM CALL_BACK2 TABLES RECORD_TAB STRUCTURE SEAHLPRES
               CHANGING SHLP_TOP TYPE SHLP_DESCR
                     CALLCONTROL LIKE DDSHF4CTRL.

  SHLP_TOP-INTDESCR-DIALOGTYPE = 'A'.   "A 100개 이상이면 다이알로그 조회, D 즉시조회,  C 다이알로그 조회

ENDFORM.                    "call_back

*-------------------------
* Data declarations
*-------------------------
TYPES: BEGIN OF t_spfli,
         carrid   TYPE spfli-carrid,
         connid   TYPE spfli-connid,
         fltime   TYPE spfli-fltime,
         deptime  TYPE spfli-deptime,
         arrtime  TYPE spfli-arrtime,
         distance TYPE spfli-distance,
         distid   TYPE spfli-distid,
         cityfrom TYPE spfli-cityfrom,
         cityto   TYPE spfli-cityto,
         period   TYPE spfli-period,
       END OF t_spfli.

DATA: it_spfli TYPE STANDARD TABLE OF t_spfli INITIAL SIZE 0,
      wa_spfli TYPE t_spfli.

* ALV declarations (header-line style like example)
DATA: fieldcatalog TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      gd_tab_group TYPE slis_t_sp_group_alv,
      gd_layout    TYPE slis_layout_alv,
      gd_repid     LIKE sy-repid.


*----------------------------------------------------------------------*
* Start-of-selection
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM data_retrieval.
  PERFORM create_fieldcatalog.
  PERFORM create_layout.
  PERFORM display_alv_report.

*----------------------------------------------------------------------*
* Form DATA_RETRIEVAL
* Simple SELECT using select-options (IN s_xxx) and UP TO num ROWS
*----------------------------------------------------------------------*
FORM data_retrieval.
  SELECT carrid
         connid
         fltime
         deptime
         arrtime
         distance
         distid
         cityfrom
         cityto
         period
   UP TO NUM ROWS
    FROM spfli
    INTO TABLE it_spfli
    WHERE carrid IN s_carrid
        AND connid IN s_connid
        AND cityfrom IN s_cfrom
        AND cityto IN s_cto
        AND period IN s_period.
ENDFORM.

*----------------------------------------------------------------------*
* Form CREATE_FIELDCATALOG (header-line fieldcatalog usage)
*----------------------------------------------------------------------*
FORM create_fieldcatalog.

  fieldcatalog-fieldname   = 'CARRID'.
  fieldcatalog-seltext_m   = 'Airline Code'.
  fieldcatalog-col_pos     = 0.
  fieldcatalog-key         = 'X'.
  fieldcatalog-outputlen   = 10.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR fieldcatalog.

  fieldcatalog-fieldname   = 'CONNID'.
  fieldcatalog-seltext_m   = 'Flight Connection Number'.
  fieldcatalog-col_pos     = 1.
  fieldcatalog-key         = 'X'.
  fieldcatalog-lzero       = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR fieldcatalog.

  fieldcatalog-fieldname   = 'CITYFROM'.
  fieldcatalog-seltext_m   = 'From City'.
  fieldcatalog-col_pos     = 2.
  fieldcatalog-emphasize   = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR fieldcatalog.

  fieldcatalog-fieldname   = 'CITYTO'.
  fieldcatalog-seltext_m   = 'To City'.
  fieldcatalog-col_pos     = 3.
  fieldcatalog-emphasize   = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR fieldcatalog.

  fieldcatalog-fieldname   = 'FLTIME'.
  fieldcatalog-seltext_m   = 'Flight Time'.
  fieldcatalog-col_pos     = 4.
  fieldcatalog-edit_mask   = '__________'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR fieldcatalog.

  fieldcatalog-fieldname   = 'DISTANCE'.
  fieldcatalog-seltext_m   = 'Distance'.
  fieldcatalog-col_pos     = 5.
  fieldcatalog-decimals_out = 0.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR fieldcatalog.

  fieldcatalog-fieldname   = 'DISTID'.
  fieldcatalog-seltext_m   = 'Distance Unit'.
  fieldcatalog-col_pos     = 6.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR fieldcatalog.

  fieldcatalog-fieldname   = 'PERIOD'.
  fieldcatalog-seltext_m   = 'Period'.
  fieldcatalog-col_pos     = 7.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR fieldcatalog.

ENDFORM.

*----------------------------------------------------------------------*
* Form CREATE_LAYOUT
*----------------------------------------------------------------------*
FORM create_layout.
  gd_layout-no_input          = 'X'.
  gd_layout-colwidth_optimize = 'X'.
  gd_layout-zebra = 'X'.
ENDFORM.

*----------------------------------------------------------------------*
* Form DISPLAY_ALV_REPORT
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
      t_outtab           = it_spfli
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
  ENDIF.
ENDFORM.
*-------------------------
