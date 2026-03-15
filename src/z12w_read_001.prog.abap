*&---------------------------------------------------------------------*
*& Report z12w_read_001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z12w_read_001.

PARAMETERS: carrid TYPE sflight-carrid DEFAULT 'AA',
            connid TYPE sflight-connid DEFAULT '0017',
            fldate TYPE sflight-fldate DEFAULT '20180528'.


DATA sflight_tab TYPE SORTED TABLE OF sflight
                 WITH UNIQUE KEY carrid connid fldate.

SELECT *
       FROM sflight
       WHERE carrid = @carrid AND
             connid = @connid
       INTO TABLE @sflight_tab.

IF sy-subrc = 0.
  READ TABLE sflight_tab
       WITH TABLE KEY carrid = carrid
                      connid = connid
                      fldate = fldate
       INTO DATA(sflight_wa).
  IF sy-subrc = 0.
    sflight_wa-price = sflight_wa-price * '0.9'.
    MODIFY sflight_tab FROM sflight_wa INDEX sy-tabix.
  ENDIF.
ENDIF.

cl_demo_output=>display( sflight_tab ).
