*&---------------------------------------------------------------------*
*& Report z11w_if001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z11w_if001.

Data Title_1(20) TYPE C.
     Title_1 = 'Tutorials'.

DATA Title_2(20) TYPE C.
     Title_2 = 'Tutorials'.

IF Title_1 = 'Tutorials'.
   write 'This is IF Statement'.
ELSE.
   write 'This is ELSE Statement'.
ENDIF.

IF Title_2 = 'Tutorials'.
   write 'This is IF2 Statement'.
ELSE.
   write 'This is ELSE2 Statement'.
ENDIF.
