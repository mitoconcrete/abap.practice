*&---------------------------------------------------------------------*
*& Report Z7W_SEL_EX001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z7W_SEL_EX001.

TABLES: spfli.

SELECTION-SCREEN BEGIN OF BLOCK part1 WITH FRAME TITLE text-001.
SELECT-OPTIONS s_carrid FOR spfli-carrid.
SELECTION-SCREEN END OF BLOCK part1.

START-OF-SELECTION.
  WRITE: '셀렉트 옵션'.
