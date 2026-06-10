*&---------------------------------------------------------------------*
*& Include          Z15W_EX_ASSIGNMENT_001_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SET_FUNCTION_KEY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_function_key .
*SMPL
  G_FUNCTION_KEY-ICON_ID   = ICON_XLS.
  G_FUNCTION_KEY-ICON_TEXT = 'SAMPLE다운'.
  G_FUNCTION_KEY-TEXT      = 'SAMPLE다운'.
  SSCRFIELDS-FUNCTXT_01    = G_FUNCTION_KEY.

  CLEAR G_FUNCTION_KEY.

  G_FUNCTION_KEY-ICON_ID   = ICON_CREATE_NOTE.
  G_FUNCTION_KEY-ICON_TEXT = '노트생성'.
  G_FUNCTION_KEY-TEXT      = '노트를 생성합니다.'.
  SSCRFIELDS-FUNCTXT_03    = G_FUNCTION_KEY.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ACT_FUNCTION_KEY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM act_function_key .
  CASE SSCRFIELDS-UCOMM.
    WHEN 'FC01'.
      PERFORM EXCEL_DOWN_SMPL.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_FILE_PATH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_file_path .
* 선택된 파일의 주소를 P_FILE 입력칸에 할당
* METHOD 사용
  DATA : LT_FILE TYPE FILETABLE,
         LS_FILE TYPE FILE_TABLE,
         LV_RC   TYPE I.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
    CHANGING
      FILE_TABLE = LT_FILE
      RC         = LV_RC.

  READ TABLE LT_FILE INTO LS_FILE INDEX 1.
  IF SY-SUBRC = 0.
    P_FILE = LS_FILE.
  ENDIF.

* FUNCTION 사용시: CALL FUNCTION 'F4_FILENAME'
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_BEFORE_PROCESS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_before_process .
* 파일 주소 확인
  IF P_FILE = 'C:\'.
    MESSAGE '경로를 입력하세요' TYPE 'I'.
    LEAVE LIST-PROCESSING.
  ELSE.

    DATA : LEN TYPE I.
    DATA : F_LEN TYPE I.
    DATA : E_LEN TYPE I.

    LEN = STRLEN( P_FILE ).
    IF LEN < 9.
      MESSAGE '경로를 입력하세요' TYPE 'I'.
      LEAVE LIST-PROCESSING.
    ELSE.
      E_LEN = 5.
      F_LEN = LEN - E_LEN.
      IF P_FILE+F_LEN(E_LEN) = '.XLSX' OR P_FILE+F_LEN(E_LEN) = '.xlsx'.

      ELSE.
        MESSAGE '경로를 입력하세요' TYPE 'I'.
        LEAVE LIST-PROCESSING.
      ENDIF.
    ENDIF.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPLOAD_FROM_EXCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM upload_from_excel .
  DATA : lv_filename      TYPE string,
         lt_records       TYPE solix_tab,
         lv_headerxstring TYPE xstring,
         lv_filelength    TYPE i.

  lv_filename = p_file.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = lv_filename
      filetype                = 'BIN'
    IMPORTING
      filelength              = lv_filelength
      header                  = lv_headerxstring
    TABLES
      data_tab                = lt_records
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.

  "convert binary data to xstring
  "if you are using cl_fdt_xl_spreadsheet in odata then skips this step
  "as excel file will already be in xstring
  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
    EXPORTING
      input_length = lv_filelength
    IMPORTING
      buffer       = lv_headerxstring
    TABLES
      binary_tab   = lt_records
    EXCEPTIONS
      failed       = 1
      OTHERS       = 2.

  IF sy-subrc <> 0.
    "Implement suitable error handling here
  ENDIF.

  DATA : lo_excel_ref TYPE REF TO cl_fdt_xl_spreadsheet .

  TRY .
      lo_excel_ref = NEW cl_fdt_xl_spreadsheet(
                              document_name = lv_filename
                              xdocument     = lv_headerxstring ) .
    CATCH cx_fdt_excel_core.
      "Implement suitable error handling here
  ENDTRY .

  "Get List of Worksheets
  lo_excel_ref->if_fdt_doc_spreadsheet~get_worksheet_names(
    IMPORTING
      worksheet_names = DATA(lt_worksheets) ).

  IF NOT lt_worksheets IS INITIAL.
    READ TABLE lt_worksheets INTO DATA(lv_woksheetname) INDEX 1.

    DATA(lo_data_ref) = lo_excel_ref->if_fdt_doc_spreadsheet~get_itab_from_worksheet(
                                             lv_woksheetname ).
    "now you have excel work sheet data in dyanmic internal table
    ASSIGN lo_data_ref->* TO <gt_data>.
  ENDIF.          .

  DATA : lv_numberofcolumns   TYPE i,
         lv_date_string       TYPE string,
         lv_target_date_field TYPE datum.


  FIELD-SYMBOLS : <ls_data>  TYPE any,
                  <lv_field> TYPE any.

  FIELD-SYMBOLS : <ex_field> TYPE any.

  "you could find out number of columns dynamically from table <gt_data>

  SELECT COUNT( DISTINCT FIELDNAME ) FROM DD03L WHERE TABNAME = 'ZSPFLI' INTO @lv_numberofcolumns.


  LOOP AT <gt_data> ASSIGNING <ls_data> FROM 2 .


*    "processing columns
    DO lv_numberofcolumns TIMES.
      ASSIGN COMPONENT sy-index OF STRUCTURE <ls_data> TO <lv_field> .
      ASSIGN COMPONENT sy-index OF STRUCTURE gs_EXCEL TO <ex_field> .
      <ex_field> = <lv_field>.

    ENDDO .
    APPEND gs_EXCEL TO gt_EXCEL.
    CLEAR gs_EXCEL.
*    NEW-LINE .
  ENDLOOP .
ENDFORM.

*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .
* 필요 데이터 취합
  PERFORM GET_NEEDED_DATA.
* 업로드 조건에 따라 ALV 출력 데이터 취합
  PERFORM GET_ZSC_DATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCEL_DOWN_SMPL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM excel_down_smpl .
* 다운로드 양식 선택
  DATA: FNAME TYPE WWWDATATAB-OBJID.
  FNAME = 'ZSPFLI_EXCEL01'.
* 파일 경로 조회
  PERFORM SET_DIRECTORY.

* 엑셀 다운
  PERFORM DOWNLOAD_EXCEL_SMPL USING FNAME.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DIRECTORY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_KEY_OBJID
*&---------------------------------------------------------------------*
FORM set_directory.
  CLEAR GV_INITIAL_DIR.
  CREATE OBJECT OBJFILE.

  IF GV_DIRECTORY IS NOT INITIAL.
    GV_INITIAL_DIR = GV_INITIAL_DIR.
  ENDIF.

  OBJFILE->DIRECTORY_BROWSE( EXPORTING  INITIAL_FOLDER = GV_INITIAL_DIR
                             CHANGING   SELECTED_FOLDER = GV_INITIAL_DIR
                             EXCEPTIONS CNTL_ERROR      = 1
                                        ERROR_NO_GUI    = 2
                                        NOT_SUPPORTED_BY_GUI = 3 ).
  IF SY-SUBRC = 0.
*    GV_FILE = GV_DIRECTORY && '\' && LS_KEY-OBJID && '.xlsx'.
     GV_DIRECTORY = GV_INITIAL_DIR.
  ELSE.
    MESSAGE '파일경로에러' TYPE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DOWNLOAD_EXCEL_SMPL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_KEY_OBJID
*&---------------------------------------------------------------------*
*FORM download_excel_smpl  USING    p_ls_key_objid.
** OLE OBJECT 생성 & 실행
*  CREATE OBJECT GO_APPLICATION 'Excel.Application'.
*
** 화면 DISPLAY 설정 (1을 설정하면 DISPLAY)
*  SET PROPERTY OF GO_APPLICATION 'Visible' = 1.
*
** WORKBOOK 및 WORKBOOK 설정 & OPEN
*  CALL METHOD OF GO_APPLICATION 'Workbooks' = GO_WBOOK.
*  CALL METHOD OF GO_WBOOK 'Add'.
*
** 최초 실행 SHEET는 첫번째
*  CALL METHOD OF GO_APPLICATION 'Worksheets' = GO_SHEET
*    EXPORTING
*      #1 = 1.
*  CALL METHOD OF GO_SHEET 'Activate'.
*  SET PROPERTY OF GO_SHEET 'Name' = 'ZSCARR'.
*  GET PROPERTY OF GO_APPLICATION 'ActiveWorkbook' = GO_WBOOK.
*
*
** 데이터 입력
*  PERFORM FILL_CELL USING GO_APPLICATION 01: 01 'MANDT',
*                                             02 'CARRID',
*                                             03 'CARRNAME',
*                                             04 'CURRCODE',
*                                             05 'URL'.
*
** 파일명 설정
*  CONCATENATE GV_DIRECTORY '/' P_LS_KEY_OBJID '.xlsx' INTO GV_PATH.
*
** 실행 파일 저장
*  CALL METHOD OF GO_WBOOK 'SaveAs' EXPORTING #1 = GV_PATH.
*
*
*  IF SY-SUBRC = 0.
*    MESSAGE '엑셀정상다운' TYPE 'S'.
*  ELSE.
*    MESSAGE '엑셀다운에러' TYPE 'S'.
*  ENDIF.
*ENDFORM.
FORM download_excel_smpl USING p_fname.

  DATA: lo_excel      TYPE REF TO zcl_excel,
        lo_worksheet  TYPE REF TO zcl_excel_worksheet,
        lo_worksheet2 TYPE REF TO zcl_excel_worksheet,
        lo_writer     TYPE REF TO zif_excel_writer,
        lo_style_hdr  TYPE REF TO zcl_excel_style,
        lo_style_data TYPE REF TO zcl_excel_style,
        lv_xstring    TYPE xstring,
        lv_size       TYPE i,
        lt_binary     TYPE solix_tab,
        lv_filename   TYPE string,
        lv_path       TYPE string,
        lv_fullpath   TYPE string,
        lv_action     TYPE i,
        lv_tabname    TYPE tabname VALUE 'ZSPFLI',
        lv_title      TYPE c LENGTH 31,
        lv_title2     TYPE c LENGTH 31.

  " ★ DD03L + DD03T 조인으로 필드 메타데이터 취득
  DATA: BEGIN OF ls_field,
          fieldname TYPE dd03l-fieldname,
          position  TYPE dd03l-position,
          ddtext    TYPE dd03t-ddtext,
        END OF ls_field.
  DATA lt_fields LIKE TABLE OF ls_field.

  SELECT d~fieldname d~position t~ddtext
    INTO TABLE lt_fields
    FROM dd03l AS d
    LEFT OUTER JOIN dd03t AS t
      ON  t~tabname    = d~tabname
      AND t~fieldname  = d~fieldname
      AND t~as4local   = d~as4local
      AND t~ddlanguage = sy-langu
   WHERE d~tabname    = lv_tabname
     AND d~as4local   = 'A'
     AND d~fieldname NOT LIKE '.%'
   ORDER BY d~position.

  " ★ RTTI 로 동적 내부 테이블 생성
  DATA: lo_structdescr TYPE REF TO cl_abap_structdescr,
        lo_tabledescr  TYPE REF TO cl_abap_tabledescr,
        lt_data        TYPE REF TO data.

  lo_structdescr ?= cl_abap_typedescr=>describe_by_name( lv_tabname ).
  lo_tabledescr   = cl_abap_tabledescr=>create( lo_structdescr ).
  CREATE DATA lt_data TYPE HANDLE lo_tabledescr.

  FIELD-SYMBOLS: <lt_dyn_tab> TYPE STANDARD TABLE,
                 <ls_dyn_wa>  TYPE ANY,
                 <lv_field>   TYPE ANY.

  ASSIGN lt_data->* TO <lt_dyn_tab>.

  " ★ 동적 SELECT
  SELECT * FROM (lv_tabname) INTO TABLE <lt_dyn_tab>.

TRY.
    CREATE OBJECT lo_excel.
    lo_worksheet = lo_excel->get_active_worksheet( ).

    " ✅ 에러1 수정: tabname → c LENGTH 31 변환 후 전달
    lv_title = lv_tabname.
    lo_worksheet->set_title( ip_title = lv_title ).

    " === 헤더 스타일 ===
    lo_style_hdr = lo_excel->add_new_style( ).
    lo_style_hdr->fill->filltype        = zcl_excel_style_fill=>c_fill_solid.
    lo_style_hdr->fill->fgcolor-rgb     = 'FFFFFF00'.
    lo_style_hdr->alignment->horizontal = zcl_excel_style_alignment=>c_horizontal_center.
    lo_style_hdr->alignment->vertical   = zcl_excel_style_alignment=>c_vertical_center.
    PERFORM set_border USING lo_style_hdr->borders.

    " === 데이터 스타일 ===
    lo_style_data = lo_excel->add_new_style( ).
    lo_style_data->alignment->horizontal = zcl_excel_style_alignment=>c_horizontal_center.
    lo_style_data->alignment->vertical   = zcl_excel_style_alignment=>c_vertical_center.
    PERFORM set_border USING lo_style_data->borders.

    " ★ === 헤더 입력 (DD03T ddtext 우선, 없으면 fieldname fallback) ===
    DATA: lv_col_idx TYPE i VALUE 1.

    LOOP AT lt_fields INTO ls_field.
      DATA(lv_header) = COND string(
                          WHEN ls_field-ddtext IS NOT INITIAL
                          THEN ls_field-ddtext
                          ELSE ls_field-fieldname ).
      PERFORM fill_cell USING lo_worksheet 1 lv_col_idx lv_header lo_style_hdr.
      lv_col_idx = lv_col_idx + 1.
    ENDLOOP.

    " ★ === 데이터 입력 ===
    DATA: lv_row   TYPE i VALUE 2,
          lv_value TYPE string.

    LOOP AT <lt_dyn_tab> ASSIGNING <ls_dyn_wa>.
      lv_col_idx = 1.
      LOOP AT lt_fields INTO ls_field.
        ASSIGN COMPONENT ls_field-fieldname OF STRUCTURE <ls_dyn_wa> TO <lv_field>.
        IF sy-subrc = 0.
          lv_value = <lv_field>.
          PERFORM fill_cell USING lo_worksheet lv_row lv_col_idx lv_value lo_style_data.
        ENDIF.
        lv_col_idx = lv_col_idx + 1.
      ENDLOOP.
      lv_row = lv_row + 1.
    ENDLOOP.

    " ★ === 컬럼 너비 자동 계산 ===
    DATA: lt_widths TYPE TABLE OF i WITH DEFAULT KEY,
          lv_w      TYPE i,
          lv_max_w  TYPE i.

    " 헤더(ddtext or fieldname) 길이로 초기화
    LOOP AT lt_fields INTO ls_field.
      DATA(lv_hdr_len) = COND i(
                           WHEN ls_field-ddtext IS NOT INITIAL
                           THEN strlen( ls_field-ddtext )
                           ELSE strlen( ls_field-fieldname ) ).
      APPEND lv_hdr_len TO lt_widths.
    ENDLOOP.

    " 데이터 순회하며 최대 길이 갱신
    LOOP AT <lt_dyn_tab> ASSIGNING <ls_dyn_wa>.
      lv_col_idx = 1.
      LOOP AT lt_fields INTO ls_field.
        ASSIGN COMPONENT ls_field-fieldname OF STRUCTURE <ls_dyn_wa> TO <lv_field>.
        IF sy-subrc = 0.
          lv_value = <lv_field>.
          READ TABLE lt_widths INDEX lv_col_idx INTO lv_w.
          lv_max_w = strlen( lv_value ).
          IF lv_max_w > lv_w.
            MODIFY lt_widths INDEX lv_col_idx FROM lv_max_w.
          ENDIF.
        ENDIF.
        lv_col_idx = lv_col_idx + 1.
      ENDLOOP.
    ENDLOOP.

    " 너비 적용
    lv_col_idx = 1.
    LOOP AT lt_widths INTO lv_w.
      DATA: lv_col_alpha TYPE string.
      PERFORM col_num_to_alpha USING lv_col_idx CHANGING lv_col_alpha.
      lo_worksheet->get_column( ip_column = lv_col_alpha )->set_width( ip_width = lv_w + 2 ).
      lv_col_idx = lv_col_idx + 1.
    ENDLOOP.

    " === 두 번째 시트 ===
    lo_worksheet2 = lo_excel->add_new_worksheet( ).

    " ✅ 에러1 수정: 2번째 시트 타이틀도 동일하게 처리
    lv_title2 = lv_tabname && '2'.
    lo_worksheet2->set_title( ip_title = lv_title2 ).

    CREATE OBJECT lo_writer TYPE zcl_excel_writer_2007.
    lv_xstring = lo_writer->write_file( lo_excel ).

  CATCH zcx_excel INTO DATA(lo_excel_err).
    MESSAGE e398(00) WITH '엑셀 생성 실패:' lo_excel_err->get_text( ) '' ''.
    RETURN.
  ENDTRY.

  " xstring → solix_tab 변환
  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING  buffer        = lv_xstring
    IMPORTING  output_length = lv_size
    TABLES     binary_tab    = lt_binary.

  " 저장 다이얼로그
  cl_gui_frontend_services=>file_save_dialog(
    EXPORTING
      window_title         = '엑셀 다운로드'
      default_extension    = 'xlsx'
      default_file_name    = |{ p_fname }.xlsx|
      file_filter          = |Excel Files (*.xlsx)\|*.xlsx\|All Files (*.*)\|*.*|
    CHANGING
      filename             = lv_filename
      path                 = lv_path
      fullpath             = lv_fullpath
      user_action          = lv_action
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4 ).

  IF sy-subrc <> 0 OR lv_action <> cl_gui_frontend_services=>action_ok.
    RETURN.
  ENDIF.

  gv_path = lv_fullpath.

  " 파일 다운로드
  cl_gui_frontend_services=>gui_download(
    EXPORTING
      bin_filesize     = lv_size
      filename         = lv_fullpath
      filetype         = 'BIN'
    CHANGING
      data_tab         = lt_binary
    EXCEPTIONS
      file_write_error = 1
      no_authority     = 5
      access_denied    = 15
      file_not_found   = 19
      OTHERS           = 99 ).

  IF sy-subrc = 0.
    MESSAGE s398(00) WITH '엑셀이 정상 다운로드되었습니다' '' '' ''.
  ELSE.
    MESSAGE e398(00) WITH '엑셀 다운로드 실패' '' '' ''.
  ENDIF.

ENDFORM.


" ======================================================================
" 보더 4면 공통 설정
" ======================================================================
FORM set_border USING io_borders TYPE REF TO zcl_excel_style_borders.
  IF io_borders IS NOT BOUND. CREATE OBJECT io_borders. ENDIF.
  IF io_borders->left  IS NOT BOUND. CREATE OBJECT io_borders->left.  ENDIF.
  IF io_borders->right IS NOT BOUND. CREATE OBJECT io_borders->right. ENDIF.
  IF io_borders->top   IS NOT BOUND. CREATE OBJECT io_borders->top.   ENDIF.
  IF io_borders->down  IS NOT BOUND. CREATE OBJECT io_borders->down.  ENDIF.
  io_borders->left->border_style  = zcl_excel_style_border=>c_border_thin.
  io_borders->right->border_style = zcl_excel_style_border=>c_border_thin.
  io_borders->top->border_style   = zcl_excel_style_border=>c_border_thin.
  io_borders->down->border_style  = zcl_excel_style_border=>c_border_thin.
ENDFORM.


" ======================================================================
" ✅ 에러2 수정: 컬럼 번호 → 엑셀 알파벳 변환 (오프셋 방식)
" ======================================================================
FORM col_num_to_alpha USING    iv_num   TYPE i
                      CHANGING cv_alpha TYPE string.
  DATA: lv_q     TYPE i,
        lv_r     TYPE i,
        lv_c     TYPE c LENGTH 1,
        lv_alpha TYPE c LENGTH 26 VALUE 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
  cv_alpha = ''.
  lv_q = iv_num.
  WHILE lv_q > 0.
    lv_r = ( lv_q - 1 ) MOD 26.
    lv_c = lv_alpha+lv_r(1).    " ✅ 오프셋으로 알파벳 직접 추출
    cv_alpha = lv_c && cv_alpha.
    lv_q = ( lv_q - 1 ) DIV 26.
  ENDWHILE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FILL_CELL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_APPLICATION
*&      --> P_01
*&      --> P_01
*&      --> P_
*&---------------------------------------------------------------------*
*FORM FILL_CELL  USING    PV_APPLICATION
*                         PV_ROW
*                         PV_COL
*                         PV_VALUE.
*
*  DATA: LV_ECELL TYPE OLE2_OBJECT.
*
*  CALL METHOD OF PV_APPLICATION 'Cells' = LV_ECELL
*    EXPORTING
*      #1 = PV_ROW
*      #2 = PV_COL.
*
*  SET PROPERTY OF LV_ECELL 'Value' = PV_VALUE.
*ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_NEEDED_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_needed_data .
* 입력 데이터 점검을 위해 사용할 DB 데이터
  SELECT *
    FROM ZSPFLI
    INTO CORRESPONDING FIELDS OF TABLE GT_TABLE.
    SORT GT_TABLE BY CARRID CONNID.

  IF r2 = 'X'.
    it_cp[] = GT_TABLE[].
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ZSC_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_zsc_data .


  DATA: GT_SCURX TYPE TABLE OF SCURX,
        GS_SCURX TYPE          SCURX.


  SELECT * FROM SCURX INTO TABLE GT_SCURX.

  LOOP AT GT_EXCEL INTO GS_EXCEL.
    MOVE-CORRESPONDING GS_EXCEL TO GS_ZSC.

    IF GS_ZSC-CARRID IS INITIAL OR GS_ZSC-CONNID IS INITIAL.
      GS_ZSC-ZSTATUS = ICON_LED_RED.
      GS_ZSC-ZRESULT = GS_ZSC-ZRESULT && '[키값이 없습니다.]'.
    ELSE.
      SORT GT_TABLE BY CARRID CONNID.
      READ TABLE GT_TABLE INTO GS_TABLE
                           WITH KEY CARRID = GS_ZSC-CARRID
                                    CONNID = GS_ZSC-CONNID
                           BINARY SEARCH.
      IF SY-SUBRC = 0.
        GS_ZSC-ZSTATUS = ICON_LED_RED.
        GS_ZSC-ZRESULT = GS_ZSC-ZRESULT && '[키값이 이미 들어있습니다.]'.
      ENDIF.
    ENDIF.

    IF GS_ZSC-ZRESULT IS INITIAL.
      GS_ZSC-ZSTATUS = ICON_LED_YELLOW.
    ENDIF.
    APPEND GS_ZSC TO GT_ZSC.
    CLEAR: GS_EXCEL, GS_ZSC.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_OBJECT_INSTANCE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_object_instance .
  CREATE OBJECT GO_DOCKING
    EXPORTING
      SIDE         = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_LEFT
      EXTENSION    = 3000.

  CREATE OBJECT GO_GRID
    EXPORTING
      I_PARENT     = GO_DOCKING.

*CREATE OBJECT GO_CUSTOM
*  EXPORTING
*   CONTAINER_NAME = 'CON1'.
*
*CREATE OBJECT GO_GRID
*  EXPORTING
*    I_PARENT = GO_CUSTOM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FILDCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fildcat .
  DEFINE _FCAT.
    CLEAR: GS_FCAT.
    GS_FCAT-FIELDNAME = &1.
    GS_FCAT-COLTEXT   = &2.
    GS_FCAT-KEY       = &3.
    GS_FCAT-EDIT       = &4.
    GS_FCAT-OUTPUTLEN  = &5.
    GS_FCAT-LOWERCASE  = &6.
    APPEND GS_FCAT TO GT_FCAT.
  END-OF-DEFINITION.

  CLEAR: GT_FCAT.

  TYPES : BEGIN OF T_DD03L,
    FIELDNAME TYPE DD03L-FIELDNAME,
    POSITION TYPE DD03L-POSITION,
    KEYFLAG TYPE DD03L-KEYFLAG,
    LENG TYPE DD03L-LENG,
  END OF T_DD03L.
  DATA : FTAB TYPE TABLE OF T_DD03L.
  DATA : S_FTAB TYPE T_DD03L.

  SELECT FIELDNAME POSITION KEYFLAG LENG
    FROM DD03L
    INTO TABLE FTAB
    WHERE TABNAME = 'ZSPFLI'.

  SORT FTAB BY POSITION.

  DATA : POS TYPE I.
  DATA : FNAM TYPE LVC_S_FCAT-FIELDNAME.
  DATA : CTXT TYPE LVC_S_FCAT-COLTEXT.
  DATA : KEY  TYPE LVC_S_FCAT-KEY.
  DATA : EDIT TYPE LVC_S_FCAT-EDIT.
  DATA : LENG TYPE LVC_S_FCAT-OUTPUTLEN.
  DATA : LOW  TYPE LVC_S_FCAT-LOWERCASE.

  IF r1 = 'X'.
    _FCAT: 'ZSTATUS' '상태' 'X' '' '3' ''.
     LOOP AT FTAB INTO S_FTAB.
        FNAM = S_FTAB-FIELDNAME.
        LENG = S_FTAB-LENG.
        KEY =  S_FTAB-KEYFLAG.
        CASE sy-tabix.
          WHEN 1.
            CTXT = '클라이언트'.
          WHEN 2.
            CTXT = '항공사코드'.
          WHEN 3.
            CTXT = '비행스케줄번호'.
          WHEN 4.
            CTXT = '출발나라코드'.
          WHEN 5.
            CTXT = '출발도시'.
          WHEN 6.
            CTXT = '출발공항'.
          WHEN 7.
            CTXT = '도착나라코드'.
          WHEN 8.
            CTXT = '도착도시'.
          WHEN 9.
            CTXT = '도착공항'.
          WHEN 10.
            CTXT = '비행시간'.
          WHEN 11.
            CTXT = '출발시간'.
          WHEN 12.
            CTXT = '도착시간'.
          WHEN 13.
            CTXT = '거리'.
          WHEN 14.
            CTXT = '거리단위'.
          WHEN 15.
            CTXT = '비행타입'.
          WHEN 16.
            CTXT = '비행일수'.
        ENDCASE.
        _FCAT: FNAM CTXT KEY '' LENG ''.
     ENDLOOP.


   _FCAT: 'ZRESULT' '비고' '' '' '50' ''.
  ELSEIF r2 = 'X'.
     LOOP AT FTAB INTO S_FTAB.
       CLEAR : FNAM, LENG, KEY, EDIT, LOW.
        FNAM = S_FTAB-FIELDNAME.
        LENG = S_FTAB-LENG.
        KEY =  S_FTAB-KEYFLAG.
        IF KEY IS INITIAL.
          EDIT = 'X'.
        ENDIF.
        CASE sy-tabix.
          WHEN 1.
            CTXT = '클라이언트'.
          WHEN 2.
            CTXT = '항공사코드'.
          WHEN 3.
            CTXT = '비행스케줄번호'.
          WHEN 4.
            CTXT = '출발나라코드'.
          WHEN 5.
            CTXT = '출발도시'.
          WHEN 6.
            CTXT = '출발공항'.
          WHEN 7.
            CTXT = '도착나라코드'.
          WHEN 8.
            CTXT = '도착도시'.
          WHEN 9.
            CTXT = '도착공항'.
          WHEN 10.
            CTXT = '비행시간'.
          WHEN 11.
            CTXT = '출발시간'.
          WHEN 12.
            CTXT = '도착시간'.
          WHEN 13.
            CTXT = '거리'.
          WHEN 14.
            CTXT = '거리단위'.
          WHEN 15.
            CTXT = '비행타입'.
          WHEN 16.
            CTXT = '비행일수'.
        ENDCASE.
        _FCAT: FNAM CTXT KEY EDIT LENG LOW.
     ENDLOOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout .
  GS_LAYOUT-ZEBRA = 'X'.
  GS_LAYOUT-CWIDTH_OPT = 'A'.
  GS_LAYOUT-SEL_MODE   = 'D'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_alv_0100 .

IF r1 ='X'.
 CALL METHOD GO_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT                     = GS_LAYOUT
    CHANGING
      IT_OUTTAB                     = GT_ZSC
      IT_FIELDCATALOG               = GT_FCAT
          .
 ELSEIF r2 ='X'.
*   !!! IMPORTANT !!!
*   We register the ENTER event so the manual changes
*   are propagated back to GT_DATA
* go_grid->register_edit_event( i_event_id = cl_gui_alv_grid=>mc_evt_enter ).

 CALL METHOD GO_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT                     = GS_LAYOUT
    CHANGING
      IT_OUTTAB                     = GT_TABLE
      IT_FIELDCATALOG               = GT_FCAT.

  CALL METHOD go_grid->set_ready_for_input
          EXPORTING
            i_ready_for_input = 0.
 ENDIF.
* 이거 안써주면 더블클릭 안먹힘!!!
CREATE OBJECT g_event_receiver.
SET HANDLER g_event_receiver->handle_double_click FOR GO_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_data .
CALL METHOD GO_GRID->REFRESH_TABLE_DISPLAY.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_ZSC_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_zsc_data .
    LOOP AT GT_ZSC ASSIGNING FIELD-SYMBOL(<FS_ZSC>).
      PERFORM SAVE_ZSC_FINAL CHANGING <FS_ZSC>.
    ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_ZSC_FINAL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_ZSC>
*&---------------------------------------------------------------------*
FORM save_zsc_final CHANGING GS_ZSC LIKE GS_ZSC.
IF GS_ZSC-ZSTATUS = ICON_LED_YELLOW.
     MOVE-CORRESPONDING GS_ZSC TO GS_TABLE.
     GS_TABLE-MANDT = SY-MANDT.
     INSERT INTO ZSPFLI VALUES GS_TABLE.

     IF SY-SUBRC = 0.
         GS_ZSC-ZSTATUS = ICON_LED_GREEN.
         GS_ZSC-ZRESULT = '저장 성공'.
       COMMIT WORK AND WAIT.
*       MESSAGE S006.
     ELSEIF SY-SUBRC <> 0.
         GS_ZSC-ZSTATUS = ICON_LED_RED.
         GS_ZSC-ZRESULT = '저장 실패'.
*       MESSAGE E007.
     ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DEL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM del_data .
* 입력 데이터 점검을 위해 사용할 DB 데이터
  SELECT *
    FROM ZSPFLI
    INTO CORRESPONDING FIELDS OF TABLE GT_TABLE.

  IF GT_TABLE IS NOT INITIAL.
    DELETE FROM ZSPFLI.
    IF SY-SUBRC = 0.
     MESSAGE '정상적으로 테이블 데이터가 전체 삭제되었습니다.' TYPE 'S'.
    ELSE.
      MESSAGE '데이터 삭제중에 문제가 생겼습니다.' TYPE 'E'.
    ENDIF.
  ELSE.
    MESSAGE '삭제할 데이터가 없습니다.' TYPE 'I'.
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_MODIFY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_modify .
  DATA: l_valid(1) TYPE c.
  CALL METHOD go_grid->check_changed_data
          IMPORTING
            e_valid = l_valid.

  IF l_valid = 'X'.
  DATA : p_confirm TYPE c.
  DATA : p_button TYPE c.
*      IF togl = 'X'.
       IF go_grid->is_ready_for_input( ) = 1.
        p_button = 'S'.
        IF it_cp[] NE gt_table[].
          PERFORM popup_confirm USING p_button CHANGING p_confirm.
          IF p_confirm = '1'.
            PERFORM f_save_data.
            PERFORM GET_NEEDED_DATA.
            PERFORM refresh_data.
*            p_selfield-refresh = 'X'.
*            p_selfield-row_stable = 'X'.
*            p_selfield-col_stable = 'X'.
          ELSE.
            LEAVE SCREEN.
          ENDIF.
        ELSE.
          MESSAGE '변경할 데이터가 없습니다.' TYPE 'I'.
        ENDIF.
      ELSE.
        MESSAGE '조회모드입니다.' TYPE 'I'.
      ENDIF.

   ELSE.
      MESSAGE '변경할 수 없는 상태입니다.' TYPE 'I'.
   ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SAVE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_save_data .
  DATA: wa_cp   TYPE zspfli,
        wa_tmp  TYPE zspfli.

  LOOP AT gt_table INTO gs_table.
    READ TABLE it_cp INTO wa_cp INDEX sy-tabix.
    IF wa_cp NE gs_table.

      MOVE-CORRESPONDING gs_table TO wa_tmp.

      MODIFY zspfli FROM wa_tmp.
      IF sy-subrc = 0.
       APPEND gs_table TO it_changes.
      ELSE.
        MESSAGE '테이블 저장 중 에러가 발생했습니다.' TYPE 'I'.
        LEAVE SCREEN.
      ENDIF.
    ENDIF.

    CLEAR wa_cp.
  ENDLOOP.
*MESSAGE '데이터가 정상적으로 저장되었습니다.' TYPE 'S'.
  DESCRIBE TABLE it_changes LINES DATA(lines).
  MESSAGE lines && '건의 데이터가 저장되었습니다.' TYPE 'S'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form POPUP_CONFIRM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_BUTTON
*&      <-- P_CONFIRM
*&---------------------------------------------------------------------*
FORM popup_confirm USING p_button CHANGING p_confirm.     "POPUP 함수
  DATA: text_q  TYPE string,
        text_b1 TYPE string.
  IF p_button = 'S'.
    text_q = '변경된 데이터가 있습니다.저장하시겠습니까?'.
    text_b1 = '저장'.
  ELSEIF p_button = 'D'.
    text_q = '정말 삭제하시겠습니까?'.
    text_b1 = '삭제'.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'POPUP'
      text_question         = text_q
      text_button_1         = text_b1
      icon_button_1         = 'ICON_CHECKED'
      text_button_2         = '취소'
      icon_button_2         = 'ICON_INCOMPLETE'
      default_button        = '1'
      display_cancel_button = space
    IMPORTING
      answer                = p_confirm. "1:Continew / 2:Cancel
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FILL_CELL
*&---------------------------------------------------------------------*
*& abap2xlsx용 셀 입력 헬퍼
*&---------------------------------------------------------------------*
*&      --> P_WORKSHEET  대상 워크시트
*&      --> P_ROW        행 번호 (1부터 시작)
*&      --> P_COL        컬럼 번호 (1=A, 2=B, ...)
*&      --> P_VALUE      입력 값
*&      --> P_STYLE      스타일 객체 (없으면 빈 참조)
*&---------------------------------------------------------------------*
FORM fill_cell USING p_worksheet TYPE REF TO zcl_excel_worksheet
                     p_row       TYPE i
                     p_col       TYPE i
                     p_value     TYPE any
                     p_style     TYPE REF TO zcl_excel_style.

  DATA: lv_col_letter TYPE string.

  TRY.
      " 컬럼 번호 → 문자 변환 (1 → 'A', 2 → 'B', ...)
      lv_col_letter = zcl_excel_common=>convert_column2alpha( ip_column = p_col ).

      " 스타일 유무에 따라 분기
      IF p_style IS BOUND.
        p_worksheet->set_cell( ip_column = lv_col_letter
                               ip_row    = p_row
                               ip_value  = p_value
                               ip_style  = p_style ).
      ELSE.
        p_worksheet->set_cell( ip_column = lv_col_letter
                               ip_row    = p_row
                               ip_value  = p_value ).
      ENDIF.

    CATCH zcx_excel.
      " 무시 또는 로깅
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form COLUMN_WIDTH
*&---------------------------------------------------------------------*
*& abap2xlsx용 컬럼 너비 설정 헬퍼
*&---------------------------------------------------------------------*
*&      --> P_WORKSHEET  대상 워크시트
*&      --> P_COLUMN     컬럼 번호 (1, 2, 3, ...)
*&      --> P_WIDTH      너비
*&---------------------------------------------------------------------*
FORM column_width USING p_worksheet TYPE REF TO zcl_excel_worksheet
                        p_column    TYPE i
                        p_width     TYPE i.

  DATA: lv_col_letter TYPE string.

  TRY.
      " 컬럼 번호 → 문자 변환
      lv_col_letter = zcl_excel_common=>convert_column2alpha( ip_column = p_column ).

      " 너비 설정
      p_worksheet->get_column( ip_column = lv_col_letter )->set_width( ip_width = p_width ).

    CATCH zcx_excel.
      " 무시 또는 로깅
  ENDTRY.

ENDFORM.
*** INCLUDE Z22W_EX_ZSTRVELAG_001_F01
*** INCLUDE Z22W_EX_ZSTRVELAG_001_F01
