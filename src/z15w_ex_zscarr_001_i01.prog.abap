*&---------------------------------------------------------------------*
*& Include          Z15W_EX_ZSCARR_001_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SAVE_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE save_data INPUT.
  CASE ok_code.
    WHEN 'SAVE'.
      IF r1 = 'X'.
        PERFORM save_zsc_data.
      ELSEIF r2 = 'X'.
        PERFORM save_modify.
      ENDIF.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EDIT_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE edit_data INPUT.
  DATA: l_valid(1) TYPE c.

  CASE ok_code.
    WHEN 'EDIT'.
      IF go_grid->is_ready_for_input( ) = 0.
        CALL METHOD go_grid->set_ready_for_input
          EXPORTING
            i_ready_for_input = 1.

      ELSE.
        CALL METHOD go_grid->check_changed_data
          IMPORTING
            e_valid = l_valid.
        IF l_valid = 'X'.
          CALL METHOD go_grid->set_ready_for_input
            EXPORTING
              i_ready_for_input = 0.

        ENDIF.
      ENDIF.
  ENDCASE.
ENDMODULE.
