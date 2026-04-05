*&---------------------------------------------------------------------*
*& Include          Z15W_EX_ZSCARR_001_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SET_FUNCTION_KEY
*&---------------------------------------------------------------------*
FORM set_function_key .
*SMPL
  G_FUNCTION_KEY-ICON_ID   = ICON_XLS.
  G_FUNCTION_KEY-ICON_TEXT = 'SAMPLE다운'.
  G_FUNCTION_KEY-TEXT      = 'SAMPLE다운'.
  SSCRFIELDS-FUNCTXT_01    = G_FUNCTION_KEY.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ACT_FUNCTION_KEY
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
  ENDIF.

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
          WHEN 1 .
            gs_EXCEL-MANDT = <lv_field>.
          WHEN 2 .
            gs_EXCEL-CARRID = <lv_field>.
          WHEN 3 .
            gs_EXCEL-CARRNAME = <lv_field>.
          WHEN 4 .
            gs_EXCEL-CURRCODE = <lv_field>.
          WHEN 5 .
            gs_EXCEL-URL = <lv_field>.
          WHEN OTHERS.
        ENDCASE .
      ENDIF.
    ENDDO .
    APPEND gs_EXCEL TO gt_EXCEL.
    CLEAR gs_EXCEL.
  ENDLOOP .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
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
*& OS 무관 엑셀 샘플 다운로드 (XML Spreadsheet 2003)
*&---------------------------------------------------------------------*
FORM excel_down_smpl .
  DATA: lv_filename TYPE string,
        lv_path     TYPE string,
        lv_fullpath TYPE string,
        lv_action   TYPE i.

* 파일 저장 다이얼로그 (OS 무관)
  cl_gui_frontend_services=>file_save_dialog(
    EXPORTING
      default_extension = 'xml'
      default_file_name = 'ZTEST14_EXCEL01'
      file_filter       = 'Excel XML (*.xml)|*.xml|All Files (*.*)|*.*'
    CHANGING
      filename    = lv_filename
      path        = lv_path
      fullpath    = lv_fullpath
      user_action = lv_action ).

  IF lv_action <> cl_gui_frontend_services=>action_ok.
    MESSAGE '다운로드가 취소되었습니다.' TYPE 'S'.
    RETURN.
  ENDIF.

* XML Spreadsheet 생성 & 다운로드
  PERFORM download_excel_xml USING lv_fullpath.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DOWNLOAD_EXCEL_XML
*&---------------------------------------------------------------------*
*& XML Spreadsheet 2003 포맷으로 샘플 양식 생성 후 다운로드
*& (OLE 미사용 - Windows/Mac/Linux 모두 동작)
*&---------------------------------------------------------------------*
FORM download_excel_xml USING pv_fullpath TYPE string.
  DATA: lt_xml  TYPE TABLE OF string.

* XML Spreadsheet 2003 헤더
  APPEND '<?xml version="1.0" encoding="UTF-8"?>'                             TO lt_xml.
  APPEND '<?mso-application progid="Excel.Sheet"?>'                            TO lt_xml.
  APPEND '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"'      TO lt_xml.
  APPEND ' xmlns:o="urn:schemas-microsoft-com:office:office"'                  TO lt_xml.
  APPEND ' xmlns:x="urn:schemas-microsoft-com:office:excel"'                   TO lt_xml.
  APPEND ' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">'           TO lt_xml.

* 스타일 정의 (헤더 볼드 + 배경색)
  APPEND '<Styles>'                                                            TO lt_xml.
  APPEND '<Style ss:ID="Default" ss:Name="Normal">'                            TO lt_xml.
  APPEND '  <Alignment ss:Vertical="Center"/>'                                 TO lt_xml.
  APPEND '</Style>'                                                            TO lt_xml.
  APPEND '<Style ss:ID="Header">'                                              TO lt_xml.
  APPEND '  <Font ss:Bold="1"/>'                                               TO lt_xml.
  APPEND '  <Interior ss:Color="#D9E1F2" ss:Pattern="Solid"/>'                 TO lt_xml.
  APPEND '  <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>'          TO lt_xml.
  APPEND '  <Borders>'                                                         TO lt_xml.
  APPEND '    <Border ss:Position="Bottom" ss:LineStyle="Continuous"'           TO lt_xml.
  APPEND '            ss:Weight="1"/>'                                         TO lt_xml.
  APPEND '  </Borders>'                                                        TO lt_xml.
  APPEND '</Style>'                                                            TO lt_xml.
  APPEND '</Styles>'                                                           TO lt_xml.

* 워크시트 시작
  APPEND '<Worksheet ss:Name="ZSCARR">'                                        TO lt_xml.
  APPEND '<Table>'                                                             TO lt_xml.

* 컬럼 너비 설정
  APPEND '<Column ss:Width="60"/>'                                             TO lt_xml.
  APPEND '<Column ss:Width="60"/>'                                             TO lt_xml.
  APPEND '<Column ss:Width="150"/>'                                            TO lt_xml.
  APPEND '<Column ss:Width="80"/>'                                             TO lt_xml.
  APPEND '<Column ss:Width="250"/>'                                            TO lt_xml.

* 헤더 행
  APPEND '<Row ss:StyleID="Header">'                                           TO lt_xml.
  APPEND '  <Cell><Data ss:Type="String">MANDT</Data></Cell>'                  TO lt_xml.
  APPEND '  <Cell><Data ss:Type="String">CARRID</Data></Cell>'                 TO lt_xml.
  APPEND '  <Cell><Data ss:Type="String">CARRNAME</Data></Cell>'               TO lt_xml.
  APPEND '  <Cell><Data ss:Type="String">CURRCODE</Data></Cell>'               TO lt_xml.
  APPEND '  <Cell><Data ss:Type="String">URL</Data></Cell>'                    TO lt_xml.
  APPEND '</Row>'                                                              TO lt_xml.

* 닫기
  APPEND '</Table>'                                                            TO lt_xml.
  APPEND '<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">'   TO lt_xml.
  APPEND '  <FreezePanes/>'                                                    TO lt_xml.
  APPEND '  <FrozenNoSplit/>'                                                  TO lt_xml.
  APPEND '  <SplitHorizontal>1</SplitHorizontal>'                             TO lt_xml.
  APPEND '  <TopRowBottomPane>1</TopRowBottomPane>'                            TO lt_xml.
  APPEND '</WorksheetOptions>'                                                 TO lt_xml.
  APPEND '</Worksheet>'                                                        TO lt_xml.
  APPEND '</Workbook>'                                                         TO lt_xml.

* 파일 다운로드 (GUI_DOWNLOAD - OS 무관)
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename              = pv_fullpath
      filetype              = 'ASC'
      write_field_separator = space
    TABLES
      data_tab              = lt_xml
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

  IF sy-subrc = 0.
    MESSAGE '엑셀정상다운' TYPE 'S'.
  ELSE.
    MESSAGE '엑셀다운에러' TYPE 'S'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_NEEDED_DATA
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
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ZSC_DATA
*&---------------------------------------------------------------------*
FORM get_zsc_data .

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
FORM create_object_instance .

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
FORM set_layout .
  GS_LAYOUT-ZEBRA = 'X'.
  GS_LAYOUT-CWIDTH_OPT = 'A'.
  GS_LAYOUT-SEL_MODE   = 'D'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV_0100
*&---------------------------------------------------------------------*
FORM display_alv_0100 .

  IF r1 ='X'.
    CALL METHOD GO_GRID->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_LAYOUT                     = GS_LAYOUT
      CHANGING
        IT_OUTTAB                     = GT_ZSC
        IT_FIELDCATALOG               = GT_FCAT.

  ELSEIF r2 ='X'.
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
FORM refresh_data .
  CALL METHOD GO_GRID->REFRESH_TABLE_DISPLAY.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_ZSC_DATA
*&---------------------------------------------------------------------*
FORM save_zsc_data .
  LOOP AT GT_ZSC ASSIGNING FIELD-SYMBOL(<FS_ZSC>).
    PERFORM SAVE_ZSC_FINAL CHANGING <FS_ZSC>.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_ZSC_FINAL
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
    ELSEIF SY-SUBRC <> 0.
      GS_ZSC-ZSTATUS = ICON_LED_RED.
      GS_ZSC-ZRESULT = '저장 실패'.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DEL_DATA
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
    MESSAGE '삭제할 데이터가 없습니다.' TYPE 'I'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_MODIFY
*&---------------------------------------------------------------------*
FORM save_modify .
  DATA: l_valid(1) TYPE c.
  CALL METHOD go_grid->check_changed_data
    IMPORTING
      e_valid = l_valid.

  IF l_valid = 'X'.
    DATA : p_confirm TYPE c.
    DATA : p_button TYPE c.
    IF go_grid->is_ready_for_input( ) = 1.
      p_button = 'S'.
      IF it_zscarrcp[] NE gt_zscarr[].
        PERFORM popup_confirm USING p_button CHANGING p_confirm.
        IF p_confirm = '1'.
          PERFORM f_save_data.
          PERFORM GET_NEEDED_DATA.
          PERFORM refresh_data.
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
FORM f_save_data .
  DATA: wa_zscarrcp   TYPE zscarr,
        wa_zscarr_tmp TYPE zscarr.

  DATA: it_changes TYPE TABLE OF zscarr WITH HEADER LINE.
  CLEAR it_changes[].

  READ TABLE gt_zscarr INTO gs_zscarr WITH KEY carrname = ''.
  IF sy-subrc = '0'.
    MESSAGE '입력하지 않은 값이 있습니다.' TYPE 'I'.
    LEAVE SCREEN.
  ENDIF.

  READ TABLE gt_zscarr INTO gs_zscarr WITH KEY currcode = ''.
  IF sy-subrc = '0'.
    MESSAGE '입력하지 않은 값이 있습니다.' TYPE 'I'.
    LEAVE SCREEN.
  ENDIF.

  READ TABLE gt_zscarr INTO gs_zscarr WITH KEY url = ''.
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

  DESCRIBE TABLE it_changes LINES DATA(lines).
  MESSAGE lines && '건의 데이터가 저장되었습니다.' TYPE 'S'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form POPUP_CONFIRM
*&---------------------------------------------------------------------*
FORM popup_confirm USING p_button CHANGING p_confirm.
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
