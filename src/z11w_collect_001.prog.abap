*&---------------------------------------------------------------------*
*& Report z11w_collect_001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z11w_collect_001.

* internal table Structure creation
TYPES: BEGIN OF t_product,
       pid(10)     TYPE C,
       pname(40)   TYPE C,
       pamount(10) TYPE P,
       END OF t_product.

* Data & internal table declaration
DATA: wa TYPE t_product,
      it TYPE TABLE OF t_product.

* inserting data to the internal table of INDEX 1
wa-pid     = 'IFB1'.
wa-pname   = 'IFB WASHING MACHINE'.
wa-pamount = 31000.
COLLECT wa INTO it.

* inserting data to the internal table of INDEX 1
wa-pid     = 'IFB1'.
wa-pname   = 'IFB WASHING MACHINE'.
wa-pamount = 30000.
COLLECT wa INTO it.

* inserting data to the internal table of INDEX 2
wa-pid     = 'IFB2'.
wa-pname   = 'IFB SPLIT AC'.
wa-pamount = 38000.
COLLECT wa INTO it.

* inserting data to the internal table of INDEX 2
wa-pid     = 'IFB2'.
wa-pname   = 'IFB SPLIT AC'.
wa-pamount = 32000.
COLLECT wa INTO it.

* Reading internal table for all the records
LOOP AT it INTO wa.
  IF sy-subrc = 0.
    WRITE :/ wa-pid, wa-pname, wa-pamount.
  ELSE.
    WRITE 'No Record Found'.
  ENDIF.
ENDLOOP.
