*&---------------------------------------------------------------------*
*& Include          Z15W_EX_ASSIGNMENT_001_C01
*&---------------------------------------------------------------------*

* CLASS *

CLASS lcl_event_receiver DEFINITION DEFERRED.
DATA: g_event_receiver TYPE REF TO lcl_event_receiver.

*--------------------------------------------------
* 클래스 선언
*-------------------------------------------------
CLASS lcl_event_receiver DEFINITION.
PUBLIC SECTION.
METHODS : handle_double_click
FOR EVENT double_click OF cl_gui_alv_grid
IMPORTING e_row
e_column.
ENDCLASS.
*--------------------------------------------
* 클래스 구현
*--------------------------------------------
CLASS lcl_event_receiver IMPLEMENTATION.
METHOD handle_double_click.


* 내가 선택하는 alv .... line

IF r1 ='X'.
  DATA: tmp_GT_ZSC LIKE LINE OF GT_ZSC.

  READ TABLE GT_ZSC INDEX e_row-index INTO tmp_GT_ZSC.
  tmp_GT_ZSC-carrname = 'ZSCARR'.
  set PARAMETER ID 'DTB' FIELD tmp_GT_ZSC-carrname.
ELSEIF r2 ='X'.
  DATA: tmp_GT_ZSCARR LIKE LINE OF GT_ZSCARR.

  READ TABLE GT_ZSCARR INDEX e_row-index INTO tmp_GT_ZSCARR.
*  tmp_GT_ZSCARR-carrname = 'ZSCARR'.
  set PARAMETER ID 'DTB' FIELD tmp_GT_ZSCARR-carrname.
ENDIF.


call TRANSACTION 'SE11' WITHOUT AUTHORITY-CHECK.


ENDMETHOD.
ENDCLASS.
