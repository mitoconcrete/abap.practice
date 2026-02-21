*&---------------------------------------------------------------------*
*& Report z10w_assignment001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z10w_assignment001.

TABLES: sbook, scarr, scustom.

TYPE-POOLS: vrm, slis.

TYPES: BEGIN OF t_sbook,
         carrid     TYPE sbook-carrid,
         carrname   TYPE scarr-carrname,    " 항공사 이름 추가
         connid     TYPE sbook-connid,
         fldate     TYPE sbook-fldate,
         bookid     TYPE sbook-bookid,
         customid   TYPE sbook-customid,
         custname   TYPE scustom-name,      " 고객 이름 추가
         custtel    TYPE scustom-telephone, " 고객 전화번호 추가
         custtype   TYPE scustom-custtype,  " 고객 유형 추가
         loccuram   TYPE sbook-loccuram,
         loccurkey  TYPE sbook-loccurkey,
         order_date TYPE sbook-order_date,
         cancelled  TYPE sbook-cancelled,
       END OF t_sbook.

DATA: it_sbook       TYPE STANDARD TABLE OF t_sbook,
      LT_DROPLIST    TYPE VRM_VALUES,

      fieldcatalog   TYPE slis_fieldcat_alv,
      fieldcatalogs  TYPE slis_t_fieldcat_alv,
      grid_tab_group TYPE slis_t_sp_group_alv,
      grid_layout    TYPE slis_layout_alv,
      grid_repid     LIKE sy-repid.

DATA: gv_custid TYPE sbook-customid.
DATA: t TYPE slis_t_sp_group_alv.

************************************************************************
* 1. 선택 화면
*   - 검색 조건: 항공사(s_carrid), 노선(s_connid), 출발일(s_fldate)
*   - 고객 선택: s_custid (SELECT-OPTIONS)
*   - 라디오 버튼: r1 = 전체, r2 = 유효(취소되지 않음), r3 = 취소됨
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
    PARAMETERS: s_carrid TYPE sbook-carrid
                        AS LISTBOX VISIBLE LENGTH 20
                        OBLIGATORY DEFAULT 'AA'.
    PARAMETERS: s_connid TYPE sbook-connid
                        AS LISTBOX VISIBLE LENGTH 40
                        OBLIGATORY DEFAULT '0017'.
    PARAMETERS: s_fldate TYPE sbook-fldate OBLIGATORY DEFAULT '20171219'.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
    SELECT-OPTIONS s_custid FOR gv_custid.
    PARAMETERS: r1 RADIOBUTTON GROUP rb1 DEFAULT 'X' USER-COMMAND rad.
    PARAMETERS: r2 RADIOBUTTON GROUP rb1.
    PARAMETERS: r3 RADIOBUTTON GROUP rb1.
SELECTION-SCREEN END OF BLOCK b2.

************************************************************************
* 리스트박스 값 도움(value-help)
************************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_carrid.
  REFRESH LT_DROPLIST.

  SELECT
    sbook~carrid AS KEY,
    sbook~carrid && '(' && scarr~carrname  && ')' AS TEXT
    FROM sbook
    JOIN scarr ON sbook~carrid = scarr~carrid
    INTO TABLE @LT_DROPLIST.

  " KEY, TEXT 순으로 정렬하고 중복 제거
  SORT LT_DROPLIST BY KEY TEXT.
  DELETE ADJACENT DUPLICATES FROM LT_DROPLIST.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = 's_carrid'
      values = LT_DROPLIST.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_connid.
  REFRESH LT_DROPLIST.

  SELECT
    sbook~connid AS KEY,
    spfli~CITYFROM && '=>' && spfli~CITYTO AS TEXT
    FROM sbook
    JOIN spfli ON sbook~connid = spfli~connid
    INTO TABLE @LT_DROPLIST.

  SORT LT_DROPLIST BY KEY TEXT.
  DELETE ADJACENT DUPLICATES FROM LT_DROPLIST.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = 's_connid'
      values = LT_DROPLIST.

************************************************************************
* 2. 데이터 조회
*    - 선택 조건에 따라 SBOOK에서 조회
*    - 라디오 버튼에 따라 CANCELLED 플래그로 필터링
************************************************************************
FORM data_retrieval.
  DATA: lv_cancelled TYPE sbook-cancelled.

  SELECT b~carrid,
         c~carrname, " 항공사 이름 추가
         b~connid,
         b~fldate,
         b~bookid,
         b~customid,
         cu~name,
         cu~telephone,
         cu~custtype,
         b~loccuram,
         b~loccurkey,
         b~order_date,
         b~cancelled
    FROM sbook AS b
    JOIN scarr AS c
        ON b~carrid = c~carrid
    JOIN scustom AS cu
        ON b~customid = cu~id
    WHERE b~carrid = @s_carrid
      AND b~connid = @s_connid
      AND b~fldate = @s_fldate
      AND b~customid IN @s_custid
    INTO TABLE @it_sbook.

  lv_cancelled = 'X'.

  IF r2 = 'X'.
    " 취소되지 않은 예약만 유지
    DELETE it_sbook WHERE cancelled = lv_cancelled.
  ELSEIF r3 = 'X'.
    " 취소된 예약만 유지
    DELETE it_sbook WHERE cancelled <> lv_cancelled.
  ENDIF.
ENDFORM.

************************************************************************
* 3. ALV 필드 카탈로그 및 레이아웃
************************************************************************
FORM create_fieldcatalog.
  CLEAR fieldcatalog.
  fieldcatalog-fieldname = 'CARRID'.
  fieldcatalog-seltext_m = 'Airline Code'.
  fieldcatalog-key = 'X'.
  APPEND fieldcatalog TO fieldcatalogs.

  fieldcatalog-fieldname = 'CARRNAME'.
  fieldcatalog-seltext_m = 'Airline Name'.
  fieldcatalog-key = 'X'.
  APPEND fieldcatalog TO fieldcatalogs.

  CLEAR fieldcatalog.
  fieldcatalog-fieldname = 'CONNID'.
  fieldcatalog-seltext_m = 'No'.
  fieldcatalog-key = 'X'.
  APPEND fieldcatalog TO fieldcatalogs.

  CLEAR fieldcatalog.
  fieldcatalog-fieldname = 'FLDATE'.
  fieldcatalog-seltext_m = 'Flight Date'.
  fieldcatalog-key = 'X'.
  APPEND fieldcatalog TO fieldcatalogs.

  CLEAR fieldcatalog.
  fieldcatalog-fieldname = 'BOOKID'.
  fieldcatalog-seltext_m = 'Booking'.
  fieldcatalog-key = 'X'.
  APPEND fieldcatalog TO fieldcatalogs.

  CLEAR fieldcatalog.
  fieldcatalog-fieldname = 'CUSTOMID'.
  fieldcatalog-seltext_m = 'Cust No.'.
  fieldcatalog-lzero   = 'X'.
  fieldcatalog-hotspot = 'X'.
  APPEND fieldcatalog TO fieldcatalogs.

  CLEAR fieldcatalog.
  fieldcatalog-fieldname = 'CUSTNAME'.
  fieldcatalog-seltext_m = 'Customer Name'.
  APPEND fieldcatalog TO fieldcatalogs.

  CLEAR fieldcatalog.
  fieldcatalog-fieldname = 'CUSTTEL'.
  fieldcatalog-seltext_m = 'Telephone no.'.
  APPEND fieldcatalog TO fieldcatalogs.

  CLEAR fieldcatalog.
  fieldcatalog-fieldname = 'CUSTTYPE'.
  fieldcatalog-seltext_m = 'B/P cust.'.
  APPEND fieldcatalog TO fieldcatalogs.

  CLEAR fieldcatalog.
  fieldcatalog-fieldname = 'LOCCURAM'.
  fieldcatalog-seltext_m = 'Amount'.
  APPEND fieldcatalog TO fieldcatalogs.

  CLEAR fieldcatalog.
  fieldcatalog-fieldname = 'LOCCURKEY'.
  fieldcatalog-seltext_m = 'Curr.'.
  APPEND fieldcatalog TO fieldcatalogs.

  CLEAR fieldcatalog.
  fieldcatalog-fieldname = 'ORDER_DATE'.
  fieldcatalog-seltext_m = 'Booking Date'.
  APPEND fieldcatalog TO fieldcatalogs.

  CLEAR fieldcatalog.
  fieldcatalog-fieldname = 'CANCELLED'.
  fieldcatalog-seltext_m = 'Cancelled'.
  APPEND fieldcatalog TO fieldcatalogs.
ENDFORM.

FORM create_layout.
  grid_layout-zebra             = 'X'.
  grid_layout-colwidth_optimize = 'X'.
  grid_layout-no_input          = 'X'.
ENDFORM.

FORM display_alv_report.
  grid_repid = sy-repid.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = grid_repid
      is_layout          = grid_layout
      it_fieldcat        = fieldcatalogs[]
      i_save             = 'X'
    TABLES
      t_outtab           = it_sbook
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.

************************************************************************
* 4. 메인
************************************************************************
START-OF-SELECTION.
  PERFORM data_retrieval.
  PERFORM create_fieldcatalog.
  PERFORM create_layout.
  PERFORM display_alv_report.
