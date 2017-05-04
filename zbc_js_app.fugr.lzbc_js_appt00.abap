*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 20.04.2017 at 09:57:11
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZBC_JS_APP......................................*
DATA:  BEGIN OF STATUS_ZBC_JS_APP                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBC_JS_APP                    .
CONTROLS: TCTRL_ZBC_JS_APP
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZBC_JS_APP                    .
TABLES: ZBC_JS_APP                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
