*&---------------------------------------------------------------------*
*& Report z10w_join001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z10w_join001.

TYPES: BEGIN OF wa,
         carrid   TYPE scarr-carrid,
         carrname TYPE scarr-carrname,
         connid   TYPE spfli-connid,
         cityfrom TYPE spfli-cityfrom,
         cityto   TYPE spfli-cityto,
         fldate   TYPE sflight-fldate,
         bookid   TYPE sbook-bookid,
       END OF wa.

DATA itab TYPE TABLE OF wa.

*SELECT c~carrid c~carrname p~connid p~cityfrom p~cityto
*  FROM scarr AS c
*  INNER JOIN spfli AS p
*  ON c~carrid = p~carrid
*  INTO TABLE itab.

*SELECT c~carrid c~carrname p~connid p~cityfrom p~cityto
*  FROM scarr AS c
*  LEFT OUTER JOIN spfli AS p
*  ON c~carrid = p~carrid
*  INTO TABLE itab.

*SELECT c~carrid, c~carrname, p~connid, p~cityfrom, p~cityto
*  FROM scarr AS c
*  RIGHT OUTER JOIN spfli AS p
*  ON c~carrid = p~carrid
*  INTO TABLE @itab.

*SELECT c~carrid, c~carrname, p~connid, p~cityfrom, p~cityto
*  FROM scarr AS c
*  CROSS JOIN spfli AS p
*  INTO TABLE @itab.

* 94 rows
*SELECT c~carrid, c~carrname, p~connid, p~cityfrom, p~cityto, f~fldate
*  FROM scarr AS c
*    INNER JOIN spfli AS p
*    ON c~carrid = p~carrid
*    INNER JOIN sflight AS f
*    ON p~carrid = f~carrid
*    AND p~connid = f~connid
*  INTO TABLE @itab.

* 94 rows
*SELECT c~carrid, c~carrname, p~connid, p~cityfrom, p~cityto, f~fldate
*  FROM scarr AS c
*    LEFT OUTER JOIN spfli AS p
*    ON c~carrid = p~carrid
*    INNER JOIN sflight AS f
*    ON p~carrid = f~carrid
*    AND p~connid = f~connid
*  INTO TABLE @itab.

* 105 rows, left outer join + left outer join => new open sql syntax
*SELECT c~carrid, c~carrname, p~connid, p~cityfrom, p~cityto, f~fldate
*  FROM scarr AS c
*    LEFT OUTER JOIN spfli AS p
*    ON c~carrid = p~carrid
*    LEFT OUTER  JOIN sflight AS f
*    ON p~carrid = f~carrid
*    AND p~connid = f~connid
*  INTO TABLE @itab.

* 12,417 rows, inner join + inner join + inner join
*SELECT c~carrid, c~carrname, p~connid, p~cityfrom, p~cityto, f~fldate, b~bookid
*  FROM scarr AS c
*    INNER JOIN spfli AS p
*    ON c~carrid = p~carrid
*    INNER JOIN sflight AS f
*    ON p~carrid = f~carrid
*    AND p~connid = f~connid
*    INNER JOIN sbook AS b
*    ON f~carrid = b~carrid
*    AND f~connid = b~connid
*    AND f~fldate = b~fldate
*  INTO TABLE @itab.

* 12,417 rows, left outer join + left outer join + left outer join => new open sql syntax
SELECT c~carrid, c~carrname, p~connid, p~cityfrom, p~cityto, f~fldate, b~bookid
  FROM scarr AS c
    LEFT OUTER JOIN spfli AS p
    ON c~carrid = p~carrid
    LEFT OUTER JOIN sflight AS f
    ON p~carrid = f~carrid
    AND p~connid = f~connid
    LEFT OUTER JOIN sbook AS b
    ON f~carrid = b~carrid
    AND f~connid = b~connid
    AND f~fldate = b~fldate
  INTO TABLE @itab.

cl_demo_output=>display( itab ).
