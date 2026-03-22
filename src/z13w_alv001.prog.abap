*&---------------------------------------------------------------------*
*& Report z13w_alv001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z13w_alv001.

TABLES:     sbook.

TYPE-POOLS: slis.                                 "ALV Declarations

*Data Declaration
*----------------
TYPES: BEGIN OF t_sbook,
  carrid     TYPE sbook-carrid,
  connid     TYPE sbook-connid,
*  luggweight TYPE sbook-luggweight,
  luggweight TYPE P DECIMALS 4,
  wunit      TYPE sbook-wunit,
  loccuram   TYPE sbook-loccuram,
  loccurkey  TYPE sbook-loccurkey,
 END OF t_sbook.


DATA: it_sbook TYPE SORTED TABLE OF t_sbook WITH NON-UNIQUE KEY carrid connid,
*DATA: it_sbook TYPE STANDARD TABLE OF t_sbook,
      wa_sbook TYPE t_sbook.
DATA: it_collect TYPE STANDARD TABLE OF t_sbook,
      it_collect2 TYPE STANDARD TABLE OF t_sbook,
      wa_collect TYPE t_sbook.

TYPES: BEGIN OF t_move,
  carrid     TYPE sbook-carrid,
  connid     TYPE sbook-connid,
*  luggweight TYPE sbook-luggweight,
  luggweight TYPE P DECIMALS 4,
  wunit      TYPE sbook-wunit,
  loccuram   TYPE sbook-loccuram,
  loccurkey  TYPE sbook-loccurkey,
  carrname   TYPE scarr-carrname,
  cityfrom   TYPE spfli-cityfrom,
  cityto     TYPE spfli-cityto,
 END OF t_move.

 DATA: it_move TYPE STANDARD TABLE OF t_move,
       wa_move TYPE t_move.

TYPES: BEGIN OF t_scarr,
  carrid     TYPE scarr-carrid,
  carrname   TYPE scarr-carrname,
 END OF t_scarr.

 DATA: it_scarr TYPE STANDARD TABLE OF t_scarr,
       wa_scarr TYPE t_scarr.

TYPES: BEGIN OF t_spfli,
  carrid     TYPE spfli-carrid,
  connid     TYPE spfli-connid,
  cityfrom   TYPE spfli-cityfrom,
  cityto     TYPE spfli-cityto,
 END OF t_spfli.

 DATA: it_spfli TYPE STANDARD TABLE OF t_spfli,
       wa_spfli TYPE t_spfli.

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

  fieldcatalog-fieldname   = 'CARRID'.
  fieldcatalog-seltext_m   = '항공사코드'.
  fieldcatalog-col_pos     = 0.
  fieldcatalog-outputlen   = 10.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'CONNID'.
  fieldcatalog-seltext_m   = '비행 번호'.
  fieldcatalog-col_pos     = 1.
  fieldcatalog-lzero       = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'LUGGWEIGHT'.
  fieldcatalog-seltext_m   = '수화물 무게'.
  fieldcatalog-col_pos     = 2.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'WUNIT'.
  fieldcatalog-seltext_m   = '무게단위'.
  fieldcatalog-col_pos     = 3.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'LOCCURAM'.
  fieldcatalog-seltext_m   = '금액'.
  fieldcatalog-col_pos     = 4.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'LOCCURKEY'.
  fieldcatalog-seltext_m   = '통화단위'.
  fieldcatalog-col_pos     = 5.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'CARRNAME'.
  fieldcatalog-seltext_m   = '항공사이름'.
  fieldcatalog-col_pos     = 6.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'CITYFROM'.
  fieldcatalog-seltext_m   = '출발도시'.
  fieldcatalog-col_pos     = 7.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'CITYTO'.
  fieldcatalog-seltext_m   = '도착도시'.
  fieldcatalog-col_pos     = 8.
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
      t_outtab           = it_move
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

SELECT carrid connid luggweight wunit loccuram loccurkey
  FROM sbook
  INTO TABLE it_sbook
  WHERE carrid IN s_carrid.
*  ORDER BY carrid connid.

*SORT it_sbook BY carrid connid.
*SORT it_sbook BY carrid ASCENDING connid DESCENDING.

LOOP AT it_sbook INTO wa_sbook.
  COLLECT wa_sbook INTO it_collect.
ENDLOOP.

SELECT carrid carrname
FROM scarr INTO TABLE it_scarr
WHERE carrid IN s_carrid.

SELECT carrid connid cityfrom cityto
FROM spfli INTO TABLE it_spfli
WHERE carrid IN s_carrid.

LOOP AT it_collect INTO wa_collect.
    CLEAR : wa_move, wa_scarr, wa_spfli.
    MOVE-CORRESPONDING wa_collect TO wa_move.

    READ TABLE it_scarr INTO wa_scarr
    WITH KEY carrid = wa_move-carrid.
    IF sy-subrc = 0.
      wa_move-carrname = wa_scarr-carrname.
    ENDIF.

    READ TABLE it_spfli INTO wa_spfli
    WITH KEY carrid = wa_move-carrid
             connid = wa_move-connid.
    IF sy-subrc = 0.
      wa_move-cityfrom = wa_spfli-cityfrom.
      wa_move-cityto = wa_spfli-cityto.
    ENDIF.

    APPEND wa_move TO it_move.
ENDLOOP.



*LOOP AT it_sbook INTO wa_sbook.
*  AT END OF carrid.
*    SUM.
*    APPEND wa_sbook TO it_collect2.
*  ENDAT.
*  AT END OF connid.
*    SUM.
*    APPEND wa_sbook TO it_collect.
*  ENDAT.
*ENDLOOP.




ENDFORM.                    " DATA_RETRIEVAL
