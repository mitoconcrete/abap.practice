*&---------------------------------------------------------------------*
*& Report z11w_99_02
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z11w_99_02.

DATA : BEGIN OF ITAB OCCURS 0,
  NUM1 TYPE I,
  NUM2 TYPE I,
  NUM3 TYPE I,
END OF ITAB.

DO 10 TIMES.
  ITAB-NUM1 = SY-INDEX.
  DO 10 TIMES.
    ITAB-NUM2 = SY-INDEX.
    ITAB-NUM3 = ITAB-NUM1 * ITAB-NUM2.
    APPEND ITAB.
  ENDDO.

ENDDO.

LOOP AT ITAB.
  WRITE: / ITAB-NUM1, '*', ITAB-NUM2, '=', ITAB-NUM3.
ENDLOOP.
