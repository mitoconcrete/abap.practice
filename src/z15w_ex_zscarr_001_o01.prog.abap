*&---------------------------------------------------------------------*
*& Include          Z15W_EX_ZSCARR_001_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  DATA: TITLE TYPE STRING.
  REFRESH fcode.
  CLEAR wa_fcode.
  IF r1 = 'X'.

    wa_fcode = 'EDIT'.
    APPEND wa_fcode TO fcode.

    wa_fcode = 'DEL'.
    APPEND wa_fcode TO fcode.

    SET PF-STATUS '100' EXCLUDING fcode.
    TITLE = 'ZSCARR 업로드'.
  ELSEIF r2 = 'X'.

    SET PF-STATUS '100'.
    TITLE = 'ZSCARR 조회 및 편집'.
  ELSE.
  ENDIF.
  SET TITLEBAR '100' WITH TITLE.

* WITH GV_TITLE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_alv_0100 OUTPUT.
*  IF GO_DOCKING IS INITIAL.
  IF GO_CUSTOM IS INITIAL.
* OBJECT*INSTANCE 생성
    PERFORM create_object_instance.

* FIELD CATALOG
    PERFORM set_fildcat.

* LAYOUT
    PERFORM set_layout.

* DISPLAY ALV
    PERFORM display_alv_0100.

  ELSE.
    PERFORM refresh_data.
  ENDIF.
ENDMODULE.
