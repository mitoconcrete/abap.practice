*&---------------------------------------------------------------------*
*& Report Z6W_SEL_EX003
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z6W_SEL_EX003.

SELECTION-SCREEN BEGIN OF BLOCK part5 WITH FRAME TITLE text-005.
PARAMETERS p_carrid TYPE spfli-carrid
                    AS LISTBOX VISIBLE LENGTH 20
                    DEFAULT 'LH'.
SELECTION-SCREEN END OF BLOCK part5.

SELECTION-SCREEN BEGIN OF BLOCK part6 WITH FRAME TITLE text-006.
PARAMETERS :  P01 TYPE spfli-mandt,
              P02 TYPE spfli-carrid,
              P03 TYPE spfli-connid,
              P04 TYPE spfli-countryfr,
              P05 TYPE spfli-cityfrom,
              P06 TYPE spfli-airpfrom,
              P07 TYPE spfli-countryto,
              P08 TYPE spfli-cityto,
              P09 TYPE spfli-airpto,
              P10 TYPE spfli-fltime,
              P11 TYPE spfli-deptime,
              P12 TYPE spfli-arrtime,
              P13 TYPE spfli-distance,
              P14 TYPE spfli-distid,
              P15 TYPE spfli-fltype,
              P16 TYPE spfli-period.
SELECTION-SCREEN END OF BLOCK part6.

SELECTION-SCREEN BEGIN OF BLOCK part7 WITH FRAME TITLE text-007.
PARAMETERS :  LP01 TYPE spfli-mandt AS LISTBOX VISIBLE LENGTH 20,
              LP02 TYPE spfli-carrid AS LISTBOX VISIBLE LENGTH 20,
              LP03 TYPE spfli-connid AS LISTBOX VISIBLE LENGTH 20,
              LP04 TYPE spfli-countryfr AS LISTBOX VISIBLE LENGTH 20,
              LP05 TYPE spfli-cityfrom AS LISTBOX VISIBLE LENGTH 20,
              LP06 TYPE spfli-airpfrom AS LISTBOX VISIBLE LENGTH 20,
              LP07 TYPE spfli-countryto AS LISTBOX VISIBLE LENGTH 20,
              LP08 TYPE spfli-cityto AS LISTBOX VISIBLE LENGTH 20,
              LP09 TYPE spfli-airpto AS LISTBOX VISIBLE LENGTH 20,
              LP10 TYPE spfli-fltime AS LISTBOX VISIBLE LENGTH 20,
              LP11 TYPE spfli-deptime AS LISTBOX VISIBLE LENGTH 20,
              LP12 TYPE spfli-arrtime AS LISTBOX VISIBLE LENGTH 20,
              LP13 TYPE spfli-distance AS LISTBOX VISIBLE LENGTH 20,
              LP14 TYPE spfli-distid AS LISTBOX VISIBLE LENGTH 20,
              LP15 TYPE spfli-fltype AS LISTBOX VISIBLE LENGTH 20,
              LP16 TYPE spfli-period AS LISTBOX VISIBLE LENGTH 20.
SELECTION-SCREEN END OF BLOCK part7.

SELECTION-SCREEN BEGIN OF BLOCK part8 WITH FRAME TITLE text-008.
PARAMETERS :  SP01 TYPE zscarr-mandt,
              SP02 TYPE zscarr-carrid,
              SP03 TYPE zscarr-carrname,
              SP04 TYPE zscarr-currcode,
              SP05 TYPE zscarr-url.
SELECTION-SCREEN END OF BLOCK part8.


START-OF-SELECTION.
  WRITE: p_carrid.
