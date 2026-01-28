*&---------------------------------------------------------------------*
*& Report Z6W_SEL_EX004
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z6W_SEL_EX004.

SELECTION-SCREEN BEGIN OF BLOCK part1 WITH FRAME TITLE text-001.
PARAMETERS :  SB01 TYPE sbook-mandt,
              SB02 TYPE sbook-carrid,
              SB03 TYPE sbook-connid,
              SB04 TYPE sbook-fldate,
              SB05 TYPE sbook-bookid,
              SB06 TYPE sbook-customid,
              SB07 TYPE sbook-custtype,
              SB08 TYPE sbook-smoker,
              SB09 TYPE sbook-luggweight,
              SB10 TYPE sbook-wunit,
              SB11 TYPE sbook-invoice,
              SB12 TYPE sbook-class,
              SB13 TYPE sbook-forcuram,
              SB14 TYPE sbook-forcurkey,
              SB15 TYPE sbook-loccuram,
              SB16 TYPE sbook-loccurkey,
              SB17 TYPE sbook-order_date,
              SB18 TYPE sbook-counter,
              SB19 TYPE sbook-agencynum,
              SB20 TYPE sbook-cancelled,
              SB21 TYPE sbook-reserved,
              SB22 TYPE sbook-passname,
              SB23 TYPE sbook-passform,
              SB24 TYPE sbook-passbirth.
SELECTION-SCREEN END OF BLOCK part1.

SELECTION-SCREEN BEGIN OF BLOCK part2 WITH FRAME TITLE text-002.
PARAMETERS :  SB25 TYPE sbook-mandt AS LISTBOX VISIBLE LENGTH 20,
              SB26 TYPE sbook-carrid AS LISTBOX VISIBLE LENGTH 20,
              SB27 TYPE sbook-connid AS LISTBOX VISIBLE LENGTH 20,
              SB28 TYPE sbook-fldate AS LISTBOX VISIBLE LENGTH 20,
              SB29 TYPE sbook-bookid AS LISTBOX VISIBLE LENGTH 20,
              SB30 TYPE sbook-customid AS LISTBOX VISIBLE LENGTH 20,
              SB31 TYPE sbook-custtype AS LISTBOX VISIBLE LENGTH 20,
              SB32 TYPE sbook-smoker AS LISTBOX VISIBLE LENGTH 20,
              SB33 TYPE sbook-luggweight AS LISTBOX VISIBLE LENGTH 20,
              SB34 TYPE sbook-wunit AS LISTBOX VISIBLE LENGTH 20,
              SB35 TYPE sbook-invoice AS LISTBOX VISIBLE LENGTH 20,
              SB36 TYPE sbook-class AS LISTBOX VISIBLE LENGTH 20,
              SB37 TYPE sbook-forcuram AS LISTBOX VISIBLE LENGTH 20,
              SB38 TYPE sbook-forcurkey AS LISTBOX VISIBLE LENGTH 20,
              SB39 TYPE sbook-loccuram AS LISTBOX VISIBLE LENGTH 20,
              SB40 TYPE sbook-loccurkey AS LISTBOX VISIBLE LENGTH 20,
              SB41 TYPE sbook-order_date AS LISTBOX VISIBLE LENGTH 20,
              SB42 TYPE sbook-counter AS LISTBOX VISIBLE LENGTH 20,
              SB43 TYPE sbook-agencynum AS LISTBOX VISIBLE LENGTH 20,
              SB44 TYPE sbook-cancelled AS LISTBOX VISIBLE LENGTH 20,
              SB45 TYPE sbook-reserved AS LISTBOX VISIBLE LENGTH 20,
              SB46 TYPE sbook-passname AS LISTBOX VISIBLE LENGTH 20,
              SB47 TYPE sbook-passform AS LISTBOX VISIBLE LENGTH 20,
              SB48 TYPE sbook-passbirth AS LISTBOX VISIBLE LENGTH 20.
SELECTION-SCREEN END OF BLOCK part2.
