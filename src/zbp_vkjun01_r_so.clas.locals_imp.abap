CLASS lhc_zvkjun01_i_soit DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    " Validation method triggered ON SAVE for the SO Item entity
    " Checks amount-related rules before persisting data
    METHODS validateamount FOR VALIDATE ON SAVE
      IMPORTING keys FOR zvkjun01_i_soit~validateamount.

ENDCLASS.

CLASS lhc_zvkjun01_i_soit IMPLEMENTATION.

  METHOD validateamount.

    " Step 1: Read the parent Sales Order Header entity
    " using the keys passed from the item level
    " This gives us access to header-level fields for cross-validation
    READ ENTITIES OF zvkjun01_r_so IN LOCAL MODE
        ENTITY zvkjun01_r_so
        ALL FIELDS
        WITH VALUE #(
                        " Map each item key to its parent header key (Soid)
                        FOR ls_key IN keys
                            ( %key-Soid = ls_key-soid )

                    )
        RESULT DATA(li_result_header)   " Header records returned
        FAILED DATA(li_failed_header).  " Failed keys collected here

    " Step 2: Read the SO Item entity directly
    " using the same keys passed into this validation method
    READ ENTITIES OF zvkjun01_r_so IN LOCAL MODE
        ENTITY zvkjun01_i_soit
        ALL FIELDS
        WITH CORRESPONDING #( keys )    " Keys passed as-is from the trigger
        RESULT DATA(li_result_item)     " Item records returned
        FAILED li_failed_header.        " Reusing same failed container

  ENDMETHOD.

ENDCLASS.

" ============================================================
" Behavior Handler for the Root Entity: zvkjun01_r_so
" Handles: Authorization, Validations, Determinations,
"          Instance Features, and Custom Actions
" ============================================================
CLASS lhc_ZVKJUN01_R_SO DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    " Called to check instance-level authorization for each key
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zvkjun01_r_so RESULT result.

    " Called to check global (entity-level) authorization
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zvkjun01_r_so RESULT result.

    " Validation: Ensures SalesTimestamp corresponds to today's date
    " Triggered ON SAVE
    METHODS validateCreatedOn FOR VALIDATE ON SAVE
      IMPORTING keys FOR zvkjun01_r_so~validateCreatedOn.

    " Determination: Calculates and sets ApprovalTimestamp ON SAVE
    " Sets approval date as SalesDate + 2 days
    METHODS determineapprovalT FOR DETERMINE ON SAVE
      IMPORTING keys FOR zvkjun01_r_so~determineapprovalT.

    " Determination: Calculates and sets ApprovalTimestamp ON MODIFY
    " Sets approval date as SalesDate + 8 days (draft/modify scenario)
    METHODS determineapprovalTMM FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zvkjun01_r_so~determineapprovalTMM.

    " Controls field/action availability based on instance data
    " Disables 'updateaction' if ApprovalTimestamp is already set
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zvkjun01_r_so RESULT result.

    " Custom action: Manually sets ApprovalTimestamp to current
    " system date and time when triggered by the user
    METHODS updateaction FOR MODIFY
      IMPORTING keys FOR ACTION zvkjun01_r_so~updateaction RESULT result.

ENDCLASS.

CLASS lhc_ZVKJUN01_R_SO IMPLEMENTATION.

  " No custom instance authorization logic needed currently
  METHOD get_instance_authorizations.
  ENDMETHOD.

  " No custom global authorization logic needed currently
  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD validateCreatedOn.

    " Read child items via association \_Item
    " to ensure item data is available if needed for cross-checks
    READ ENTITIES OF zvkjun01_r_so IN LOCAL MODE
    ENTITY zvkjun01_r_so BY \_Item
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result_item).

    " Read the SalesTimestamp field from the header entity
    " for each key passed into this validation
    READ ENTITIES OF zvkjun01_r_so IN LOCAL MODE
    ENTITY zvkjun01_r_so
    FIELDS ( SalesTimestamp )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    " Local variables for timestamp conversion
    DATA: lv_date     TYPE d,
          lv_time     TYPE t,
          lv_timezone TYPE sy-zonlo.

    LOOP AT lt_result INTO DATA(ls_result).

      " Use current user's timezone for conversion
      lv_timezone = sy-zonlo.

      " Convert the UTC SalesTimestamp into local date and time
      CONVERT TIME STAMP ls_result-SalesTimestamp TIME ZONE lv_timezone
        INTO DATE lv_date TIME lv_time.

      " Check: Sales date must not be in the past
      " If it is earlier than today, raise an error message
      IF lv_date LT sy-datum.

        APPEND VALUE #(
                        %key = ls_result-%key
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Sales Date is not Todays Date'
                               )
                      ) TO reported-zvkjun01_r_so.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD determineapprovalT.

    " Local variables for timestamp decomposition and reconstruction
    DATA: lv_date     TYPE d,
          lv_time     TYPE t,
          lv_timezone TYPE sy-zonlo.

    " Read all fields of the Sales Order header for each triggered key
    READ ENTITIES OF zvkjun01_r_so IN LOCAL MODE
    ENTITY zvkjun01_r_so
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(li_result).

    LOOP AT li_result INTO DATA(ls_result).

      " Use current user's timezone for conversion
      lv_timezone = sy-zonlo.

      " Convert SalesTimestamp to local date/time
      CONVERT TIME STAMP ls_result-SalesTimestamp TIME ZONE lv_timezone
        INTO DATE lv_date TIME lv_time.

      " Add 2 days to the sales date to compute the approval deadline
      lv_date = lv_date + 2.

      " Convert the new approval date back to a UTC timestamp
      Convert DATE lv_date time sy-timlo InTO TIME STAMP DATA(lv_timestamp)
        tiME ZONE sy-zonlo.

      " Write the computed ApprovalTimestamp back to the entity
      MODIFY ENTITIES OF zvkjun01_r_so IN LOCAL MODE
        ENTITY zvkjun01_r_so
        UPDATE FIELDS ( ApprovalTimestamp )
        WITH VALUE #(
                        ( %key = ls_result-%key ApprovalTimestamp = lv_timestamp )

                    )
       FaiLED DATA(li_failed)
       Reported Data(li_reported)
       mapped Data(li_mapped).

    ENDLOOP.
  ENDMETHOD.

  METHOD determineapprovalTMM.

    " Local variables for timestamp decomposition and reconstruction
    DATA: lv_date     TYPE d,
          lv_time     TYPE t,
          lv_timezone TYPE sy-zonlo.

    " Read all fields of the Sales Order header for each triggered key
    READ ENTITIES OF zvkjun01_r_so IN LOCAL MODE
    ENTITY zvkjun01_r_so
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(li_result).

    LOOP AT li_result INTO DATA(ls_result).

      " Use current user's timezone for conversion
      lv_timezone = sy-zonlo.

      " Convert SalesTimestamp to local date/time
      CONVERT TIME STAMP ls_result-SalesTimestamp TIME ZONE lv_timezone
        INTO DATE lv_date TIME lv_time.

      " Add 8 days to the sales date — longer window for modify scenario
      lv_date = lv_date + 8.

      " Convert the updated date back to a UTC timestamp
      CONVERT DATE lv_date TIME sy-timlo INTO TIME STAMP DATA(lv_timestamp)
        TIME ZONE sy-zonlo.

      " Write the computed ApprovalTimestamp back using %tky (transactional key)
      " %tky is preferred in ON MODIFY determinations as it includes draft keys
      MODIFY ENTITIES OF zvkjun01_r_so IN LOCAL MODE
        ENTITY zvkjun01_r_so
        UPDATE FIELDS ( ApprovalTimestamp )
        WITH VALUE #(
                        ( %tky = ls_result-%tky ApprovalTimestamp = lv_timestamp )

                    )
       FAILED DATA(li_failed)
       REPORTED DATA(li_reported)
       MAPPED DATA(li_mapped).
    ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_features.

    " Read the ApprovalTimestamp for each key to determine action availability
    READ ENTITIES OF zvkjun01_r_so IN LOCAL MODE
        ENTITY zvkjun01_r_so
        FIELDS (  ApprovalTimestamp )
        WITH CORRESPONDING #( Keys )
        RESULT DATA(li_read).

    " Build the result table controlling action visibility per instance
    result = VALUE #( FOR ls_read IN li_read

                        " If ApprovalTimestamp is initial (not yet set):
                        "   → Enable the 'updateaction' button
                        " If ApprovalTimestamp is already filled:
                        "   → Disable the 'updateaction' button (prevent re-approval)
                        LET ApprovalTimestamp = COND #(
                                                        WHEN ls_read-ApprovalTimestamp IS INITIAL
                                                            THEN if_abap_behv=>fc-o-enabled

                                                             ELSE if_abap_behv=>fc-o-disabled
                                                      )

                            IN (  %key = ls_read-%key %action-updateaction = approvaltimestamp )

                    ).

  ENDMETHOD.

  METHOD updateaction.

    " Local variable to hold the current timestamp
    DATA: lv_date     TYPE d,
          lv_time     TYPE t,
          lv_timezone TYPE sy-zonlo.

    " Build a timestamp from the current system date and time
    CONVERT DATE sy-datum TIME sy-timlo INTO TIME STAMP DATA(lv_timestamp)
      TIME ZONE sy-zonlo.

    " Set ApprovalTimestamp to NOW for all keys passed to this action
    MODIFY ENTITIES OF zvkjun01_r_so IN LOCAL MODE
        ENTITY zvkjun01_r_so
        UPDATE FIELDS ( ApprovalTimestamp )
        WITH VALUE #( FOR ls_key IN Keys
                        ( %key = ls_key-%key ApprovalTimestamp = lv_timestamp )
                    ).

    " Re-read the updated records to populate the action result
    " The result is returned to the caller (e.g. Fiori UI) as action output
    READ ENTITIES OF zvkjun01_r_so IN LOCAL MODE
        ENTITY zvkjun01_r_so
        ALL FIELDS
        WITH CORRESPONDING #( Keys )
        RESULT DATA(li_read).

        " Map each read result into the action result structure
        " %param holds the full entity record as the action return value
        result = VALUE #( FOR ls_read IN li_read
                            (  %key = ls_read-%key %param = ls_read  )

                        ).

  ENDMETHOD.

ENDCLASS.
