*&---------------------------------------------------------------------*
*& Report z10w_alv001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z10w_alv001.

TABLES:     scarr, spfli, sflight, sbook.                "Database tables

TYPE-POOLS: slis.                                 "ALV Declarations

*Data Declaration
*----------------
TYPES: BEGIN OF ts_table,
   carrid   TYPE scarr-carrid,
   carrname TYPE scarr-carrname,
   connid   TYPE spfli-connid,
   cityfrom TYPE spfli-cityfrom,
   cityto   TYPE spfli-cityto,
   fldate   TYPE sflight-fldate,
   bookid   TYPE sbook-bookid,
 END OF ts_table.

DATA: gt_table TYPE STANDARD TABLE OF ts_table.


*ALV data declarations
DATA: fieldcatalog TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      gd_tab_group TYPE slis_t_sp_group_alv,
      gd_layout    TYPE slis_layout_alv,
      gd_repid     LIKE sy-repid.


DATA : t TYPE slis_t_sp_group_alv .

SELECTION-SCREEN BEGIN OF BLOCK part1 WITH FRAME TITLE text-001.
SELECT-OPTIONS s_carrid   FOR scarr-carrid.
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
  fieldcatalog-seltext_m   = '항공사 코드'.
  fieldcatalog-col_pos     = 1.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR fieldcatalog.

  fieldcatalog-fieldname   = 'CARRNAME'.
  fieldcatalog-seltext_m   = '항공사 이름'.
  fieldcatalog-col_pos     = 2.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR fieldcatalog.

  fieldcatalog-fieldname   = 'CONNID'.
  fieldcatalog-seltext_m   = '비행기 번호'.
  fieldcatalog-col_pos     = 4.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR fieldcatalog.

  fieldcatalog-fieldname   = 'CITYFROM'.
  fieldcatalog-seltext_m   = '출발지'.
  fieldcatalog-col_pos     = 5.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR fieldcatalog.

  fieldcatalog-fieldname   = 'CITYTO'.
  fieldcatalog-seltext_m   = '도착지'.
  fieldcatalog-col_pos     = 6.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR fieldcatalog.

  fieldcatalog-fieldname   = 'FLDATE'.
  fieldcatalog-seltext_m   = '비행 날짜'.
  fieldcatalog-col_pos     = 7.
  fieldcatalog-datatype    = 'DATS'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR fieldcatalog.

  fieldcatalog-fieldname   = 'BOOKID'.
  fieldcatalog-seltext_m   = '예약 번호'.
  fieldcatalog-col_pos     = 8.
  fieldcatalog-datatype    = 'CHAR'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR fieldcatalog.

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
      t_outtab           = gt_table
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
*    SELECT a~carrid, a~carrname, b~connid, b~cityfrom, b~cityto
*    FROM scarr AS a
*    INNER JOIN spfli AS b
*    ON a~carrid = b~carrid
*    WHERE a~carrid IN @s_carrid
*    INTO TABLE @gt_table.

*    SELECT a~carrid, a~carrname, b~connid, b~cityfrom, b~cityto
*    FROM scarr AS a
*    LEFT OUTER JOIN spfli AS b
*    ON a~carrid = b~carrid
*    WHERE a~carrid IN @s_carrid
*    INTO TABLE @gt_table.

*    SELECT a~carrid, a~carrname, b~connid, b~cityfrom, b~cityto
*    FROM scarr AS a
*    RIGHT OUTEr JOIN spfli AS b
*    ON a~carrid = b~carrid
*    WHERE a~carrid IN @s_carrid
*    INTO TABLE @gt_table.

*    SELECT a~carrid, a~carrname, b~connid, b~cityfrom, b~cityto
*    FROM scarr AS a
*    CROSS JOIN spfli AS b
*    WHERE a~carrid IN @s_carrid
*    INTO TABLE @gt_table.

*    SELECT a~carrid, a~carrname, b~connid, b~cityfrom, b~cityto, c~fldate
*    FROM scarr AS a
*    INNER JOIN spfli AS b
*    ON a~carrid = b~carrid
*    INNER JOIN sflight AS c
*    ON a~carrid = c~carrid AND b~connid = c~connid
*    WHERE a~carrid IN @s_carrid
*    INTO TABLE @gt_table.

*    SELECT a~carrid, a~carrname, b~connid, b~cityfrom, b~cityto, c~fldate
*    FROM scarr AS a
*    LEFT JOIN spfli AS b
*    ON a~carrid = b~carrid
*    LEFt JOIN sflight AS c
*    ON a~carrid = c~carrid AND b~connid = c~connid
*    WHERE a~carrid IN @s_carrid
*    INTO TABLE @gt_table.

    SELECT a~carrid, a~carrname, b~connid, b~cityfrom, b~cityto, c~fldate, d~bookid
    FROM scarr AS a
    JOIN spfli AS b
    ON a~carrid = b~carrid
    JOIN sflight AS c
    ON a~carrid = c~carrid AND b~connid = c~connid
    JOIN sbook AS d
    ON c~carrid = d~carrid AND c~connid = d~connid AND c~fldate = d~fldate
    WHERE a~carrid IN @s_carrid
    INTO TABLE @gt_table.
ENDFORM.                    " DATA_RETRIEVAL
