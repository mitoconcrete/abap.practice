*&---------------------------------------------------------------------*
*& Report Z5W_ALV_SUBTOT_TEXT001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z5W_ALV_SUBTOT_TEXT001.

TABLES:     sflight.

TYPE-POOLS: slis.                                 "ALV Declarations

*Data Declaration
*----------------
TYPES: BEGIN OF t_sf,
  carrid type sflight-carrid,
  carrid1 type sflight-carrid,
  connid type sflight-connid,
  price  type sflight-price,

 END OF t_sf.



DATA: it_sf TYPE STANDARD TABLE OF t_sf,
      wa_sf TYPE t_sf.

*ALV data declarations
DATA: fieldcatalog TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      gd_tab_group TYPE slis_t_sp_group_alv,
      gd_layout    TYPE slis_layout_alv,
      gd_repid     LIKE sy-repid.
DATA: it_sort      TYPE slis_t_sortinfo_alv WITH HEADER LINE.
*Alv Event
DATA: gt_events TYPE slis_t_event,
      ls_event TYPE slis_alv_event.


DATA : t TYPE slis_t_sp_group_alv .
************************************************************************
*Start-of-selection.
START-OF-SELECTION.

  PERFORM data_retrieval.
  PERFORM build_fieldcatalog.
  PERFORM build_layout.
  PERFORM build_sort.
  PERFORM alv_event_set.
  PERFORM display_alv_report.


*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
*       Build Fieldcatalog for ALV Report
*----------------------------------------------------------------------*
FORM build_fieldcatalog.



  fieldcatalog-fieldname   = 'CARRID'.
  fieldcatalog-seltext_m   = '항공사 코드'.
  fieldcatalog-col_pos     = 0.
  fieldcatalog-no_out      = 'X'.
*  fieldcatalog-tech        = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'CARRID1'.
  fieldcatalog-seltext_m   = '항공사 코드'.
  fieldcatalog-col_pos     = 0.
  fieldcatalog-key         = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'CONNID'.
  fieldcatalog-seltext_m   = '항공사 번호'.
  fieldcatalog-col_pos     = 1.
*  fieldcatalog-no_out      = 'X'.
*  fieldcatalog-tech        = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'PRICE'.
  fieldcatalog-seltext_m   = '금액'.
  fieldcatalog-col_pos     = 2.
  fieldcatalog-do_sum      = 'X'.
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
*  gd_layout-totals_before_items = 'X'.
*  gd_layout-totals_only = 'X'.
*  gd_layout-subtotals_text = '소계'.
*  gd_layout-totals_text       = '총계'.

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
      it_sort            = it_sort[]
      it_events              = gt_events[]
*      I_STRUCTURE_NAME      = 'SFLIGHT'
      i_save             = 'X'
    TABLES
      t_outtab           = it_sf
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
  DATA: ld_color(1) TYPE c.

SELECT * FROM SFLIGHT INTO CORRESPONDING FIELDS OF TABLE it_sf.

  LOOP AT it_sf INTO wa_sf.
    wa_sf-carrid1 = wa_sf-carrid.
    MODIFY it_sf FROM wa_sf.
  ENDLOOP.

ENDFORM.                    " DATA_RETRIEVAL
*&---------------------------------------------------------------------*
*& Form BUILD_SORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM build_sort .
  it_sort-spos      = '1'.
  it_sort-fieldname = 'CARRID'.
  it_sort-up        = 'X'.
  it_sort-subtot    = 'X'.
*  it_sort-expa      = 'X'.
  APPEND it_sort.

  it_sort-fieldname = 'CARRID1'.
  it_sort-up        = 'X'.
*  it_sort-expa      = 'X'.
  APPEND it_sort.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  alv_event_set
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM alv_event_set .
  CONSTANTS : c_formname_subtotal_text TYPE slis_formname VALUE
                                                      'SUBTOTAL_TEXT'.
*  DATA: l_s_event TYPE slis_alv_event.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type     = 4
    IMPORTING
      et_events       = gt_events
    EXCEPTIONS
      list_type_wrong = 0
      OTHERS          = 0.


  "* Subtotal
  READ TABLE gt_events  INTO ls_event
                    WITH KEY name = slis_ev_subtotal_text.
  IF sy-subrc = 0.
    MOVE c_formname_subtotal_text TO ls_event-form.
    MODIFY gt_events FROM ls_event INDEX sy-tabix.
  ENDIF.

ENDFORM.                    " alv_event_set

*&---------------------------------------------------------------------*
*&      Form  subtotal_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TOTAL        text
*      -->P_SUBTOT_TEXT  text
*----------------------------------------------------------------------*
FORM subtotal_text CHANGING
               p_total TYPE any
               p_subtot_text TYPE slis_subtot_text.
* Patient Level Text
*  IF p_subtot_text-criteria = 'CARRID'.
*    p_subtot_text-display_text_for_subtotal
*                 = 'Patient Total'(011).
*  ENDIF.

**  Material Group Text
*  IF p_subtot_text-criteria = 'WGBEZ'.
*    p_subtot_text-display_text_for_subtotal = 'Material Group Total'(012) .
*  ENDIF.

ENDFORM.                    "subtotal_text
