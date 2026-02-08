*&---------------------------------------------------------------------*
*& Report z9w_join001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z9w_join001.

TYPES: BEGIN OF wa,
            carrid TYPE scarr-carrid,
            carrname TYPE scarr-carrname,
            connid TYPE spfli-connid,
            cityfrom TYPE spfli-cityfrom,
            cityto TYPE spfli-cityto,
       END OF wa.

DATA: itab TYPE TABLE OF wa.


*SELECT a~carrid,
*       a~carrname,
*       b~connid,
*       b~cityfrom,
*       b~cityto
*  FROM scarr AS a
*  INNER JOIN spfli AS b
*  ON a~carrid = b~carrid
*  INTO TABLE @itab.


*SELECT a~carrid,
*       a~carrname,
*       b~connid,
*       b~cityfrom,
*       b~cityto
*  FROM scarr AS a
*  LEFT OUTER JOIN spfli AS b
*  ON a~carrid = b~carrid
*  INTO TABLE @itab.

SELECT a~carrid,
       a~carrname,
       b~connid,
       b~cityfrom,
       b~cityto
  FROM scarr AS a
  RIGHT OUTER JOIN spfli AS b
  ON a~carrid = b~carrid
  INTO TABLE @itab.

cl_demo_output=>display( itab ).
