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
  IF P_FILE EQ SPACE OR P_FILE = 'C:\'.
    MESSAGE '경로를 입력하세요' TYPE 'I'.
    LEAVE LIST-PROCESSING.
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

  "you could find out number of columns dynamically from table <gt_data>
  lv_numberofcolumns = 5 .

  LOOP AT <gt_data> ASSIGNING <ls_data> FROM 2 .


*    "processing columns
    DO lv_numberofcolumns TIMES.
      ASSIGN COMPONENT sy-index OF STRUCTURE <ls_data> TO <lv_field> .
      IF sy-subrc = 0 .
        CASE sy-index .
          when 1 .
            gs_EXCEL-MANDT = <lv_field>.
          when 2 .
            gs_EXCEL-CARRID = <lv_field>.
          when 3 .
            gs_EXCEL-CARRNAME = <lv_field>.
          when 4 .
            gs_EXCEL-CURRCODE = <lv_field>.
          when 5 .
            gs_EXCEL-URL = <lv_field>.

*          WHEN 10 .
*            lv_date_string = <lv_field> .
*            PERFORM date_convert USING lv_date_string CHANGING lv_target_date_field .
*            WRITE lv_target_date_field .
          WHEN OTHERS.
*            WRITE : <lv_field> .
        ENDCASE .

      ENDIF.
    ENDDO .
    APPEND gs_EXCEL TO gt_EXCEL.
    CLEAR gs_EXCEL.
*    NEW-LINE .
  ENDLOOP .


** TAB으로 구분된 내용을 잘라서 ITAB에 APPEND 한다.
*  LOOP AT lt_intern.
*    SPLIT lt_intern
*    AT cl_abap_char_utilities=>horizontal_tab
*    INTO gs_EXCEL-CARRID gs_EXCEL-CARRNAME gs_EXCEL-CURRCODE gs_EXCEL-URL.
*    gs_EXCEL-MANDT = '001'.
*    APPEND gs_EXCEL TO gt_EXCEL.
*    CLEAR gs_EXCEL.
*  ENDLOOP.
*
**HEADER LINE 삭제
*  IF gt_excel IS NOT INITIAL.
*    DELETE gt_excel INDEX 1. "상단에 적힌 필드명을 삭제시켜줌
*  ELSE.
*    MESSAGE '데이터가 존재하지 않습니다' TYPE 'E'.
*  ENDIF.

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
*    LS_KEY-OBJID = 'ZTEST14_EXCEL01'.
*    LS_KEY-RELID = 'MI'.
*
  DATA: FNAME TYPE WWWDATATAB-OBJID.
  FNAME = 'ZTEST14_EXCEL01'.
* 파일 경로 조회
*  PERFORM SET_DIRECTORY USING LS_KEY-OBJID.
  PERFORM SET_DIRECTORY.

* 엑셀 다운
*  PERFORM DOWNLOAD_EXCEL_SMPL USING LS_KEY-OBJID.
  PERFORM DOWNLOAD_EXCEL_SMPL USING FNAME.
*
*  IF SY-SUBRC = 0.
*    MESSAGE '엑셀정상다운' TYPE 'S'.
*  ELSE.
*    MESSAGE '엑셀다운에러' TYPE 'S'.
*  ENDIF.
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

  DATA: lo_excel       TYPE REF TO zcl_excel,
        lo_worksheet   TYPE REF TO zcl_excel_worksheet,
        lo_worksheet2  TYPE REF TO zcl_excel_worksheet,
        lo_writer      TYPE REF TO zif_excel_writer,
        lo_style_hdr   TYPE REF TO zcl_excel_style,
        lo_style_none  TYPE REF TO zcl_excel_style,
        lv_xstring     TYPE xstring,
        lv_size        TYPE i,
        lt_binary      TYPE solix_tab,
        lv_filename    TYPE string,
        lv_path        TYPE string,
        lv_fullpath    TYPE string,
        lv_action      TYPE i,
        lt_scarr       TYPE TABLE OF scarr.

TRY.
    SELECT * FROM scarr INTO TABLE lt_scarr.

    CREATE OBJECT lo_excel.
    lo_worksheet = lo_excel->get_active_worksheet( ).
    lo_worksheet->set_title( ip_title = 'ZSCARR' ).

    " === 헤더 스타일 ===
    lo_style_hdr = lo_excel->add_new_style( ).
    lo_style_hdr->fill->filltype        = zcl_excel_style_fill=>c_fill_solid.
    lo_style_hdr->fill->fgcolor-rgb     = 'FFFFFF00'.
    lo_style_hdr->alignment->horizontal = zcl_excel_style_alignment=>c_horizontal_center.
    lo_style_hdr->alignment->vertical   = zcl_excel_style_alignment=>c_vertical_center.

    " ★ borders 자체 인스턴스화 (혹시 모를 경우 대비)
    IF lo_style_hdr->borders IS NOT BOUND.
      CREATE OBJECT lo_style_hdr->borders.
    ENDIF.

    " ★ 4면 객체 명시적 생성 후 스타일 설정
    IF lo_style_hdr->borders->left IS NOT BOUND.
      CREATE OBJECT lo_style_hdr->borders->left.
    ENDIF.
    lo_style_hdr->borders->left->border_style = zcl_excel_style_border=>c_border_thin.

    IF lo_style_hdr->borders->right IS NOT BOUND.
      CREATE OBJECT lo_style_hdr->borders->right.
    ENDIF.
    lo_style_hdr->borders->right->border_style = zcl_excel_style_border=>c_border_thin.

    IF lo_style_hdr->borders->top IS NOT BOUND.
      CREATE OBJECT lo_style_hdr->borders->top.
    ENDIF.
    lo_style_hdr->borders->top->border_style = zcl_excel_style_border=>c_border_thin.

    IF lo_style_hdr->borders->down IS NOT BOUND.
      CREATE OBJECT lo_style_hdr->borders->down.
    ENDIF.
    lo_style_hdr->borders->down->border_style = zcl_excel_style_border=>c_border_thin.

    " === 데이터 스타일 ===
    DATA: lo_style_data TYPE REF TO zcl_excel_style.
    lo_style_data = lo_excel->add_new_style( ).

    IF lo_style_data->borders IS NOT BOUND.
      CREATE OBJECT lo_style_data->borders.
    ENDIF.

    IF lo_style_data->borders->left IS NOT BOUND.
      CREATE OBJECT lo_style_data->borders->left.
    ENDIF.
    lo_style_data->borders->left->border_style = zcl_excel_style_border=>c_border_thin.

    IF lo_style_data->borders->right IS NOT BOUND.
      CREATE OBJECT lo_style_data->borders->right.
    ENDIF.
    lo_style_data->borders->right->border_style = zcl_excel_style_border=>c_border_thin.

    IF lo_style_data->borders->top IS NOT BOUND.
      CREATE OBJECT lo_style_data->borders->top.
    ENDIF.
    lo_style_data->borders->top->border_style = zcl_excel_style_border=>c_border_thin.

    IF lo_style_data->borders->down IS NOT BOUND.
      CREATE OBJECT lo_style_data->borders->down.
    ENDIF.
    lo_style_data->borders->down->border_style = zcl_excel_style_border=>c_border_thin.

    " === 헤더 입력 ===
    PERFORM fill_cell USING lo_worksheet 1: 1 'MANDT'    lo_style_hdr,
                                            2 'CARRID'   lo_style_hdr,
                                            3 'CARRNAME' lo_style_hdr,
                                            4 'CURRCODE' lo_style_hdr,
                                            5 'URL'      lo_style_hdr.

    " === 데이터 입력 ===
    DATA: lv_row TYPE i VALUE 2.
    FIELD-SYMBOLS: <fs_scarr> LIKE LINE OF lt_scarr.

    LOOP AT lt_scarr ASSIGNING <fs_scarr>.
      PERFORM fill_cell USING lo_worksheet lv_row: 1 <fs_scarr>-mandt    lo_style_data,
                                                   2 <fs_scarr>-carrid   lo_style_data,
                                                   3 <fs_scarr>-carrname lo_style_data,
                                                   4 <fs_scarr>-currcode lo_style_data,
                                                   5 <fs_scarr>-url      lo_style_data.
      lv_row = lv_row + 1.
    ENDLOOP.

    " === 컬럼 너비 ===
    PERFORM column_width USING lo_worksheet 1 10.
    PERFORM column_width USING lo_worksheet 2 10.
    PERFORM column_width USING lo_worksheet 3 20.
    PERFORM column_width USING lo_worksheet 4 10.
    PERFORM column_width USING lo_worksheet 5 40.

    " === 두 번째 시트 ===
    lo_worksheet2 = lo_excel->add_new_worksheet( ).
    lo_worksheet2->set_title( ip_title = 'ZSCARR2' ).

    CREATE OBJECT lo_writer TYPE zcl_excel_writer_2007.
    lv_xstring = lo_writer->write_file( lo_excel ).

  CATCH zcx_excel INTO DATA(lo_excel_err).
    MESSAGE e398(00) WITH '엑셀 생성 실패:' lo_excel_err->get_text( ) '' ''.
    RETURN.
ENDTRY.

  " 9. xstring → solix_tab 변환
  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer        = lv_xstring
    IMPORTING
      output_length = lv_size
    TABLES
      binary_tab    = lt_binary.

  " 10. 저장 다이얼로그 (OS 독립)
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

  " 사용자가 취소했거나 에러 발생 시 종료
  IF sy-subrc <> 0
     OR lv_action <> cl_gui_frontend_services=>action_ok.
    RETURN.
  ENDIF.

  gv_path = lv_fullpath.

  " 11. 파일 다운로드
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

  " 12. 결과 메시지
  IF sy-subrc = 0.
    MESSAGE s398(00) WITH '엑셀이 정상 다운로드되었습니다' '' '' ''.
  ELSE.
    MESSAGE e398(00) WITH '엑셀 다운로드 실패' '' '' ''.
  ENDIF.

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
    FROM ZSCARR
    INTO CORRESPONDING FIELDS OF TABLE GT_ZSCARR.
    SORT GT_ZSCARR BY CARRID.

  IF r2 = 'X'.
    it_zscarrcp[] = GT_ZSCARR[].
  ENDIF.
*  IF GT_ZSCARR IS NOT INITIAL.
*    DELETE FROM ZSCARR.
*  ENDIF.
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

*  LOOP AT GT_EXCEL INTO GS_EXCEL.
*    MOVE-CORRESPONDING GS_EXCEL TO GS_ZSC.
*
*    IF GS_ZSC-CARRID IS INITIAL.
*      GS_ZSC-ZSTATUS = ICON_LED_RED.
*      GS_ZSC-ZRESULT = '키값이 없습니다'.
*    ELSE.
*      SORT GT_ZSCARR BY CARRID.
*      READ TABLE GT_ZSCARR INTO GS_ZSCARR
*                           WITH KEY CARRID = GS_ZSC-CARRID
*                           BINARY SEARCH.
*      IF SY-SUBRC = 0.
*         GS_ZSC-ZSTATUS = ICON_LED_RED.
*         GS_ZSC-ZRESULT = '중복된 키가 있습니다.'.
*      ENDIF.
*
*
*    ENDIF.
*
*    IF GS_ZSC-ZRESULT IS INITIAL.
*      GS_ZSC-ZSTATUS = ICON_LED_YELLOW.
*    ENDIF.
*    APPEND GS_ZSC TO GT_ZSC.
*    CLEAR: GS_EXCEL, GS_ZSC.
*  ENDLOOP.


  DATA: GT_SCURX TYPE TABLE OF SCURX,
        GS_SCURX TYPE          SCURX.


  SELECT * FROM SCURX INTO TABLE GT_SCURX.

  LOOP AT GT_EXCEL INTO GS_EXCEL.
    MOVE-CORRESPONDING GS_EXCEL TO GS_ZSC.

IF GS_ZSC-CARRID IS INITIAL.
      GS_ZSC-ZSTATUS = ICON_LED_RED.
      GS_ZSC-ZRESULT = GS_ZSC-ZRESULT && '[CARRID 키값이 없습니다.]'.
ELSE.
      SORT GT_ZSCARR BY CARRID.
      READ TABLE GT_ZSCARR INTO GS_ZSCARR
                           WITH KEY CARRID = GS_ZSC-CARRID
                           BINARY SEARCH.
      IF SY-SUBRC = 0.
         GS_ZSC-ZSTATUS = ICON_LED_RED.
         GS_ZSC-ZRESULT = GS_ZSC-ZRESULT && '[CARRID 키값이 이미 들어있습니다.]'.
      ENDIF.

ENDIF.

IF GS_ZSC-CURRCODE IS INITIAL.
      GS_ZSC-ZSTATUS = ICON_LED_RED.
      GS_ZSC-ZRESULT = GS_ZSC-ZRESULT && '[CURRCODE 값이 없습니다.]'.
ELSE.
      READ TABLE GT_SCURX INTO GS_SCURX
                           WITH KEY CURRKEY = GS_ZSC-CURRCODE.
      IF SY-SUBRC <> 0.
         GS_ZSC-ZSTATUS = ICON_LED_RED.
         GS_ZSC-ZRESULT = GS_ZSC-ZRESULT && '[CURRCODE에 없는 통화키를 입력했습니다.]'.
      ENDIF.
ENDIF.


*    IF GS_ZSC-CARRID IS INITIAL.
*      GS_ZSC-ZSTATUS = ICON_LED_RED.
*      GS_ZSC-ZRESULT = GS_ZSC-ZRESULT && '[CARRID 키값이 없습니다.]'.
*
*    ELSEIF GS_ZSC-CURRCODE IS INITIAL.
*      GS_ZSC-ZSTATUS = ICON_LED_RED.
*      GS_ZSC-ZRESULT = GS_ZSC-ZRESULT && '[CURRCODE 값이 없습니다.]'.
*    ELSE.
*      READ TABLE GT_SCURX INTO GS_SCURX
*                           WITH KEY CURRKEY = GS_ZSC-CURRCODE.
*      IF SY-SUBRC <> 0.
*         GS_ZSC-ZSTATUS = ICON_LED_RED.
*         GS_ZSC-ZRESULT = GS_ZSC-ZRESULT && '[CURRCODE에 없는 통화키를 입력했습니다.]'.
*      ENDIF.
*
*      SORT GT_ZSCARR BY CARRID.
*      READ TABLE GT_ZSCARR INTO GS_ZSCARR
*                           WITH KEY CARRID = GS_ZSC-CARRID
*                           BINARY SEARCH.
*      IF SY-SUBRC = 0.
*         GS_ZSC-ZSTATUS = ICON_LED_RED.
*         GS_ZSC-ZRESULT = GS_ZSC-ZRESULT && '[CARRID 키값이 이미 들어있습니다.]'.
*      ENDIF.
*
*    ENDIF.

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
*  CREATE OBJECT GO_DOCKING
*    EXPORTING
*      SIDE         = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_LEFT
*      EXTENSION    = 3000.
*
*  CREATE OBJECT GO_GRID
*    EXPORTING
*      I_PARENT     = GO_DOCKING.

CREATE OBJECT GO_CUSTOM
  EXPORTING
   CONTAINER_NAME = 'CON1'.

CREATE OBJECT GO_GRID
  EXPORTING
    I_PARENT = GO_CUSTOM.

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
IF r1 = 'X'.
    _FCAT: 'ZSTATUS' '상태' 'X' '' '3' '',
           'MANDT' '클라이언트' 'X' '' '5' '',
           'CARRID' '아이디' 'X' '' '5' '',
           'CARRNAME' '이름' '' '' '20' '',
           'CURRCODE' '통화' '' '' '5' '',
           'URL' '사이트' '' '' '30' '',
           'ZRESULT' '비고' '' '' '50' ''.
ELSEIF r2 = 'X'.
    _FCAT: 'MANDT' '클라이언트' 'X' '' '5' '',
           'CARRID' '아이디' 'X' '' '5' '',
           'CARRNAME' '이름' '' 'X' '20' 'X',
           'CURRCODE' '통화' '' 'X' '5' '',
           'URL' '사이트' '' 'X' '255' 'X'.
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
      IT_OUTTAB                     = GT_ZSCARR
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


*    LOOP AT GT_ZSC INTO GS_ZSC.
*     IF GS_ZSC-ZSTATUS = ICON_LED_YELLOW.
*     MOVE-CORRESPONDING GS_ZSC TO GS_ZSCARR.
*     GS_ZSCARR-MANDT = SY-MANDT.
*     INSERT INTO ZSCARR VALUES GS_ZSCARR.
*
*     IF SY-SUBRC = 0.
*         GS_ZSC-ZSTATUS = ICON_LED_GREEN.
*         GS_ZSC-ZRESULT = '저장 성공'.
*       COMMIT WORK AND WAIT.
*       MESSAGE S006.
*     ELSEIF SY-SUBRC <> 0.
*       MESSAGE E007.
*     ENDIF.
*  ENDIF.
*    ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_ZSC_FINAL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_ZSC>
*&---------------------------------------------------------------------*
FORM save_zsc_final  CHANGING GS_ZSC LIKE GS_ZSC.
IF GS_ZSC-ZSTATUS = ICON_LED_YELLOW.
     MOVE-CORRESPONDING GS_ZSC TO GS_ZSCARR.
     GS_ZSCARR-MANDT = SY-MANDT.
     INSERT INTO ZSCARR VALUES GS_ZSCARR.

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
    FROM ZSCARR
    INTO CORRESPONDING FIELDS OF TABLE GT_ZSCARR.


  IF GT_ZSCARR IS NOT INITIAL.
    DELETE FROM ZSCARR.
    IF SY-SUBRC = 0.
     MESSAGE '정상적으로 ZSCARR테이블 데이터가 전체 삭제되었습니다.' TYPE 'S'.
    ELSE.
      MESSAGE '데이터 삭제중에 문제가 생겼습니다.' TYPE 'E'.
    ENDIF.
  ELSE.
*     MESSAGE '데이터 삭제중에 문제가 생겼습니다.' TYPE 'E'.
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
*
*        IF go_grid->is_ready_for_input( ) = 0.
*        CALL METHOD go_grid->set_ready_for_input
*          EXPORTING
*            i_ready_for_input = 1.
*
*      ELSE.
*        CALL METHOD go_grid->check_changed_data
*          IMPORTING
*            e_valid = l_valid.
*        IF l_valid = 'X'.
*          CALL METHOD go_grid->set_ready_for_input
*            EXPORTING
*              i_ready_for_input = 0.
*
*        ENDIF.
*      ENDIF.
*
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
        IF it_zscarrcp[] NE gt_zscarr[].
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
  DATA: wa_zscarrcp   TYPE zscarr,
        wa_zscarr_tmp TYPE zscarr.

  DATA: it_changes TYPE TABLE OF zscarr WITH HEADER LINE.
  CLEAR it_changes[].

  READ TABLE gt_zscarr into gs_zscarr WITH KEY carrname = ''.
  IF sy-subrc = '0'.
    MESSAGE '입력하지 않은 값이 있습니다.' TYPE 'I'.
    LEAVE SCREEN.
  ENDIF.

  READ TABLE gt_zscarr into gs_zscarr WITH KEY currcode = ''.
  IF sy-subrc = '0'.
    MESSAGE '입력하지 않은 값이 있습니다.' TYPE 'I'.
    LEAVE SCREEN.
  ENDIF.

  READ TABLE gt_zscarr into gs_zscarr WITH KEY url = ''.
  IF sy-subrc = '0'.
    MESSAGE '입력하지 않은 값이 있습니다.' TYPE 'I'.
    LEAVE SCREEN.
  ENDIF.

  DATA : it_scurx TYPE TABLE OF scurx.
  DATA : wa_scurx TYPE  scurx.
  SELECT * FROM scurx INTO TABLE it_scurx.
  LOOP AT gt_zscarr INTO gs_zscarr.
    READ TABLE it_scurx INTO wa_scurx WITH KEY currkey = gs_zscarr-currcode.
    IF sy-subrc <> 0.
      MESSAGE 'CURRCODE에 들어있지 않은 값을 넣었습니다' TYPE 'I'.
      LEAVE SCREEN.
    ENDIF.
  ENDLOOP.

  LOOP AT gt_zscarr INTO gs_zscarr.
    READ TABLE it_zscarrcp INTO wa_zscarrcp INDEX sy-tabix.
    IF wa_zscarrcp NE gs_zscarr.

      MOVE-CORRESPONDING gs_zscarr TO wa_zscarr_tmp.

      MODIFY zscarr FROM wa_zscarr_tmp.
      IF sy-subrc = 0.
       APPEND gs_zscarr TO it_changes.
      ELSE.
        MESSAGE '테이블 저장 중 에러가 발생했습니다.' TYPE 'I'.
        LEAVE SCREEN.
      ENDIF.
    ENDIF.

    CLEAR wa_zscarrcp.
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
