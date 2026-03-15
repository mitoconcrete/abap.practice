*&---------------------------------------------------------------------*
*& Report z12w_move_001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z12w_move_001.

TYPES:
  BEGIN OF flight,
    carrid TYPE spfli-carrid,
    connid   TYPE spfli-connid,
    cityfrom TYPE spfli-cityfrom,
    cityto   TYPE spfli-cityto,
  END OF flight.
DATA
  flights TYPE SORTED TABLE OF flight WITH UNIQUE KEY carrid connid.

SELECT *
       FROM spfli
       INTO TABLE @DATA(spfli_tab).

MOVE-CORRESPONDING spfli_tab TO flights.

cl_demo_output=>display( flights ).
