*&---------------------------------------------------------------------*
*& Report z9w_listbox001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z9w_listbox001.

TYPE-POOLS VRM.
DATA: LT_DROPLIST TYPE VRM_VALUES.


SELECTION-SCREEN BEGIN OF BLOCK part5 WITH FRAME TITLE text-005.
PARAMETERS p_carrid TYPE spfli-carrid
                    AS LISTBOX VISIBLE LENGTH 20
                    DEFAULT 'LH'.
PARAMETERS p_connid TYPE spfli-connid
                    AS LISTBOX VISIBLE LENGTH 60
                    DEFAULT '0017'.
PARAMETERS p_period TYPE spfli-period
                    AS LISTBOX VISIBLE LENGTH 60
                    DEFAULT '0'.
SELECTION-SCREEN END OF BLOCK part5.

PARAMETERS inter(10) TYPE C VISIBLE LENGTH 20.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_carrid.

REFRESH LT_DROPLIST.

SELECT
  CARRID AS KEY,
  CARRID && ' ' && CARRNAME AS TEXT
  FROM SCARR
  INTO TABLE @LT_DROPLIST.

SORT LT_DROPLIST BY KEY TEXT.

DELETE ADJACENT DUPLICATES FROM LT_DROPLIST.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id                    = 'p_carrid'
      values                = LT_DROPLIST.
*   EXCEPTIONS
*     ID_ILLEGAL_NAME       = 1
*     OTHERS                = 2
*            .
  IF sy-subrc = 0.
* Implement suitable error handling here
  ENDIF.

*inter = 10.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_period.

REFRESH LT_DROPLIST.

*SELECT
*  PERIOD AS KEY,
*  PERIOD AS TEXT
*  FROM SPFLI
*  INTO TABLE @LT_DROPLIST.

SELECT
  CAST( PERIOD AS CHAR ) AS KEY,
  CAST( PERIOD AS CHAR ) AS TEXT
  FROM SPFLI
  INTO TABLE @LT_DROPLIST.

SORT LT_DROPLIST BY KEY TEXT.

DELETE ADJACENT DUPLICATES FROM LT_DROPLIST.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id                    = 'p_period'
      values                = LT_DROPLIST.
*   EXCEPTIONS
*     ID_ILLEGAL_NAME       = 1
*     OTHERS                = 2
*            .
  IF sy-subrc = 0.
* Implement suitable error handling here
  ENDIF.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_connid.

REFRESH LT_DROPLIST.

SELECT
  CONNID AS KEY,
  CARRID && ' ' && CITYFROM && '=>' && CITYTO AS TEXT
*  CARRID && CAST( CONNID AS CHAR ) AS TEXT
*  CARRID && CONNID AS TEXT
  FROM SPFLI
  INTO TABLE @LT_DROPLIST.

SORT LT_DROPLIST BY KEY TEXT.

DELETE ADJACENT DUPLICATES FROM LT_DROPLIST.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id                    = 'p_connid'
      values                = LT_DROPLIST.
*   EXCEPTIONS
*     ID_ILLEGAL_NAME       = 1
*     OTHERS                = 2
*            .
  IF sy-subrc = 0.
* Implement suitable error handling here
  ENDIF.

  START-OF-SELECTION.

  inter = 10.
