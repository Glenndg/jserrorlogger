CLASS zcl_zjs_error_logger_dpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_zjs_error_logger_dpc
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS /iwbep/if_mgw_appl_srv_runtime~create_deep_entity
         REDEFINITION .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ZJS_ERROR_LOGGER_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_deep_entity.
*$--------------------------------------------------------------------- *
*$  Glenn De Groote   20/04/2017    glenn.degroote@flexso.com
*$--------------------------------------------------------------------- *

* --- Structures ------------------------------------------------------ *

    DATA: ls_session TYPE zcl_zjs_error_logger_mpc=>ts_session.

* --- Variables  ------------------------------------------------------ *

    DATA: lv_session_id TYPE zjs_el_session_id.

* --- Start processing ------------------------------------------------ *

    CASE iv_entity_name.

      WHEN 'Session'. " May vary on the setup of your SEGW project

* ~ Read incomming data from data provider object
*   Import to understand that this contains both session information and
*   the errors

        io_data_provider->read_entry_data(
          IMPORTING
            es_data = ls_session
        ).

* ~ Save the session and its errors to the database

        lv_session_id = zcl_js_error_logger=>save_session(
          EXPORTING
            iv_service_name = mr_service_document_name->*     " Service Name
            is_session      = ls_session    " JS E.L.: Application Error GateWay
        ).

* ~ Make sure to return the session id so it the session can be updated

        ls_session-session_id = lv_session_id.

        copy_data_to_ref(
          EXPORTING
            is_data = ls_session
          CHANGING
            cr_data = er_deep_entity
        ).

      WHEN OTHERS.

        CALL METHOD super->/iwbep/if_mgw_appl_srv_runtime~create_deep_entity
          EXPORTING
            iv_entity_name          = iv_entity_name
            iv_entity_set_name      = iv_entity_set_name
            iv_source_name          = iv_source_name
            io_data_provider        = io_data_provider
            it_key_tab              = it_key_tab
            it_navigation_path      = it_navigation_path
            io_expand               = io_expand
            io_tech_request_context = io_tech_request_context
          IMPORTING
            er_deep_entity          = er_deep_entity.

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
