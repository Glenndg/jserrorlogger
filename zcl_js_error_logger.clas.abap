CLASS zcl_js_error_logger DEFINITION
  PUBLIC
  ABSTRACT
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS save_session
      IMPORTING
        !iv_service_name     TYPE string
        !is_session          TYPE zbc_js_app_session_gw
      RETURNING
        VALUE(rv_session_id) TYPE zjs_el_session_id .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS mc_app_table TYPE string VALUE 'ZBC_JS_APP' ##NO_TEXT.
    CONSTANTS mc_session_table TYPE string VALUE 'ZBC_JS_APP_SESS' ##NO_TEXT.
    CONSTANTS mc_error_table TYPE string VALUE 'ZBC_JS_APP_ERROR' ##NO_TEXT.
ENDCLASS.



CLASS ZCL_JS_ERROR_LOGGER IMPLEMENTATION.


  METHOD save_session.
*$--------------------------------------------------------------------- *
*$  Glenn De Groote   20/04/2017    glenn.degroote@flexso.com
*$--------------------------------------------------------------------- *

* --- Internal tables ------------------------------------------------- *

    DATA: lt_error_db TYPE STANDARD TABLE OF zbc_js_app_error.

* --- Structures ------------------------------------------------------ *

    DATA: ls_session_db TYPE zbc_js_app_sess.

* --- Variables ------------------------------------------------------- *

    DATA: lv_app_id        TYPE zjs_el_app_id,
          lv_session_id    TYPE zjs_el_session_id,
          lv_new_session   TYPE abap_bool,
          lv_has_errors_db TYPE abap_bool.

* --- Start processing ------------------------------------------------ *

* ~ Create GUID for Session

    TRY.

        IF is_session-session_id IS INITIAL.
          lv_session_id  = cl_system_uuid=>create_uuid_c32_static( ).
          lv_new_session = abap_true.
        ELSE.
          lv_session_id  = is_session-session_id.
          lv_new_session = abap_false.
        ENDIF.

      CATCH cx_uuid_error.

        " If the GUID can't be generated, don't save the errors

        CLEAR rv_session_id.
        RETURN.

    ENDTRY.

* ~ Get Application ID mapped to Service Name

    SELECT SINGLE
      app_id
    FROM
      (mc_app_table)
    INTO
      lv_app_id
    WHERE
      service_name EQ iv_service_name.

* ~ Create / update Session

    ls_session_db-app_id       = lv_app_id.
    ls_session_db-device       = is_session-device.
    ls_session_db-session_date = is_session-session_date.
    ls_session_db-session_id   = lv_session_id.
    ls_session_db-session_time = is_session-session_time.
    ls_session_db-session_user = sy-uname.

    " Determine if errors exist

    IF lv_new_session EQ abap_true.

      IF lines( is_session-errors ) GT 0.
        ls_session_db-has_errors = abap_true.
      ELSE.
        ls_session_db-has_errors = abap_false.
      ENDIF.

    ELSE.

      IF lines( is_session-errors ) EQ 0.

        SELECT SINGLE
          has_errors
        FROM
          (mc_session_table)
        INTO
          lv_has_errors_db
        WHERE
          session_id EQ is_session-session_id.

        IF sy-subrc <> 0.
          CLEAR rv_session_id.
          RETURN.
        ENDIF.

        ls_session_db-has_errors = lv_has_errors_db.

      ELSE.

        IF lines( is_session-errors ) GT 0.
          ls_session_db-has_errors = abap_true.
        ELSE.
          ls_session_db-has_errors = abap_false.
        ENDIF.

      ENDIF.

    ENDIF.

    MODIFY (mc_session_table) FROM ls_session_db.

    IF sy-subrc <> 0.
      CLEAR rv_session_id.
      RETURN.
    ENDIF.

* ~ Create / update Errors for current Session

    lt_error_db = VALUE #(
      FOR ls_error IN is_session-errors (
        session_id = lv_session_id
        timestamp  = ls_error-timestamp
        error_date = ls_error-error_date
        error_time = ls_error-error_time
        line       = ls_error-line
        location   = ls_error-location
        message    = ls_error-message
      )
    ).

    MODIFY (mc_error_table) FROM TABLE lt_error_db.

    IF sy-subrc <> 0.
      CLEAR rv_session_id.
      RETURN.
    ENDIF.

* ~ Return the Session ID

    rv_session_id = lv_session_id.

  ENDMETHOD.
ENDCLASS.
