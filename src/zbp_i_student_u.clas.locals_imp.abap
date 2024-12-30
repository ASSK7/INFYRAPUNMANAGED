CLASS lhc_Student DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Student RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Student RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE Student.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Student.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE Student.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE Student.

    METHODS read FOR READ
      IMPORTING keys FOR READ Student RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK Student.

    METHODS rba_Course FOR READ  "rba - read by association
      IMPORTING keys_rba FOR READ Student\_Course FULL result_requested RESULT result LINK association_links.

    METHODS cba_Course FOR MODIFY  "cba - create by association
      IMPORTING entities_cba FOR CREATE Student\_Course.
    METHODS validatefields FOR VALIDATE ON SAVE
      IMPORTING keys FOR Student~validatefields.
    METHODS updateSectionBasedOnClass FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Student~updateSectionBasedOnClass.

    METHODS updateSchoolBasedOnSection FOR DETERMINE ON SAVE
      IMPORTING keys FOR Student~updateSchoolBasedOnSection.
    METHODS updateStudentStatus FOR MODIFY
      IMPORTING keys FOR ACTION Student~updateStudentStatus RESULT result.

    METHODS earlynumbering_cba_Course FOR NUMBERING
      IMPORTING entities FOR CREATE Student\_Course.

ENDCLASS.

CLASS lhc_Student IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.

    zcl_students_api_clas=>get_instance(  )->create_student(
      EXPORTING
        entities = entities
      CHANGING
        mapped   = mapped
        failed   = failed
        reported = reported
    ).

  ENDMETHOD.

  METHOD earlynumbering_create.

    zcl_students_api_clas=>get_instance(  )->create_student_early_numbering(
      EXPORTING
        entities = entities
      CHANGING
        mapped   = mapped
        failed   = failed
        reported = reported
    ).

  ENDMETHOD.

  METHOD update.

    zcl_students_api_clas=>get_instance(  )->update_student(
      EXPORTING
        entities = entities
      CHANGING
        mapped   = mapped
        failed   = failed
        reported = reported
    ).

  ENDMETHOD.

  METHOD delete.
    zcl_students_api_clas=>get_instance(  )->delete_student(
      EXPORTING
        keys     = keys
      CHANGING
        mapped   = mapped
        failed   = failed
        reported = reported
    ).
  ENDMETHOD.

  METHOD read.

    zcl_students_api_clas=>get_instance(  )->read_student(
      EXPORTING
        keys     = keys
      CHANGING
        result   = result
        failed   = failed
        reported = reported
    ).

  ENDMETHOD.

  METHOD lock.
    " 1. First lock object should be create by right clicking on data dictionary in package, give the primary table name to which we want to create lock
    " 2. Select lock mode and activate

    TRY.
        "getting the instance of the lock object which was created by us
        DATA(lo_lockObj) = cl_abap_lock_object_factory=>get_instance( iv_name = 'EZCUSTOM_LOCK' ).  "EZCUSTOM_LOCK is lock object name

      CATCH cx_abap_lock_failure INTO DATA(lo_exception).
        RAISE SHORTDUMP lo_exception.
    ENDTRY.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_key>).

      TRY.
          lo_lockobj->enqueue(
*          it_table_mode =
            it_parameter  = VALUE #( ( name = 'STUDENTID' value = REF #( <fs_key>-Studentid ) ) )
*          _scope        =
*          _wait         =
          ).
        CATCH cx_abap_foreign_lock INTO DATA(foreign_lock).

          APPEND VALUE #(
             studentid = keys[ 1 ]-Studentid
             %msg = new_message_with_text(
                  severity = if_abap_behv_message=>severity-error
                  text = 'Record is locked by ' && foreign_lock->user_name
               )
           ) TO reported-student.

          APPEND VALUE #(
            studentid = keys[ 1 ]-Studentid
          ) TO failed-student.

        CATCH cx_abap_lock_failure INTO DATA(lock_failure).
          RAISE SHORTDUMP lock_failure.

      ENDTRY.

    ENDLOOP.


  ENDMETHOD.

  METHOD rba_Course.
  ENDMETHOD.

  METHOD cba_Course. "method for create by association to create child entities

    zcl_students_api_clas=>get_instance(  )->cba_create_courese(
      EXPORTING
        entities_cba = entities_cba
      CHANGING
        mapped       = mapped
        failed       = failed
        reported     = reported
    ).

  ENDMETHOD.

  METHOD earlynumbering_cba_Course.

    zcl_students_api_clas=>get_instance(  )->cba_course_earlynumbering(
      EXPORTING
        entities = entities
      CHANGING
        mapped   = mapped
        failed   = failed
        reported = reported
    ).
  ENDMETHOD.

  METHOD validatefields.

    "reading the data based on keys
    READ ENTITIES OF zi_student_u "ENTITY NAME
    IN LOCAL MODE
    ENTITY Student
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT  DATA(lt_results)
    FAILED DATA(lt_failed)
    REPORTED DATA(lt_reported).

    "As for create/update, we are reading one records so READ Table syntax with index used below
    READ TABLE lt_results ASSIGNING FIELD-SYMBOL(<fs_result>) INDEX 1.

    IF <fs_result> IS ASSIGNED.
      IF <fs_result>-Studentname IS INITIAL OR <fs_result>-Studentage IS INITIAL.
        APPEND VALUE #( %tky = <fs_result>-%tky ) TO failed-student.
        "below syntax also be used
        "failed-student = VALUE #( ( %tky = <fs_result>-%tky ) ).

        "below code is to remove duplicate messages
        reported-student = VALUE #(
            ( %tky = <fs_result>-%tky  %state_area = 'VALIDATE_NAME' )
            ( %tky = <fs_result>-%tky  %state_area = 'VALIDATE_AGE' )
         ).



        IF <fs_result>-Studentname IS INITIAL.
          reported-student =  VALUE #( (   %tky = <fs_result>-%tky
                          %element-studentname = if_abap_behv=>mk-on
*                    %state_area = 'VALIDATE_NAME'   "we can give any state area name here
                          %msg = new_message(
                                   id       = 'SY'
                                   number   = '002'
                                   severity = if_abap_behv_message=>severity-error
                                   v1       = 'First Name should not be empty!') ) ).
        ENDIF.

        IF <fs_result>-Studentage IS INITIAL.
          reported-student =  VALUE #( BASE reported-student ( %tky = <fs_result>-%tky   "BASE reported-student -> get all the messages instead of last appended message
                      %element-studentage = if_abap_behv=>mk-on
*                    %state_area = 'VALIDATE_AGE'
                      %msg = new_message(
                               id       = 'SY'
                               number   = '002'
                               severity = if_abap_behv_message=>severity-error
                               v1       = 'Age should not be empty!') ) ).
        ENDIF.

      ENDIF.

    ENDIF.




  ENDMETHOD.

  METHOD updateSectionBasedOnClass.

    "reading the entity
    READ ENTITIES OF zi_student_u
    IN LOCAL MODE
    ENTITY Student
    FIELDS ( Studentclass )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_student).

    "updating the value based on student class field
    READ TABLE lt_student ASSIGNING FIELD-SYMBOL(<fs_student>) INDEX 1. "as getting only one record in table, I'm using read table. we can use loop also.
    TRANSLATE <fs_student>-Studentclass TO UPPER CASE.

    IF <fs_student>-Studentclass EQ 'INTERMEDIATE'.

      MODIFY ENTITIES OF zi_student_u
      IN LOCAL MODE
      ENTITY Student
      UPDATE FIELDS ( Studentsection )
      WITH VALUE #( ( %tky = <fs_student>-%tky  Studentsection = 1 ) ) .


    ELSEIF <fs_student>-Studentclass EQ 'DIPLAMO'.
      MODIFY ENTITIES OF zi_student_u
      IN LOCAL MODE
      ENTITY Student
      UPDATE FIELDS ( Studentsection )
      WITH VALUE #( ( %tky = <fs_student>-%tky  Studentsection = 4 ) ) .
    ENDIF.

  ENDMETHOD.

  METHOD updateSchoolBasedOnSection.

    "reading the entity
    READ ENTITIES OF zi_student_u
    IN LOCAL MODE
    ENTITY Student
    FIELDS ( Studentsection )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_student).

    "updating the value based on student class field
    READ TABLE lt_student ASSIGNING FIELD-SYMBOL(<fs_student>) INDEX 1. "as getting only one record in table, I'm using read table. we can use loop also.
    TRANSLATE <fs_student>-Studentclass TO UPPER CASE.

    IF <fs_student>-Studentsection EQ 1.

      MODIFY ENTITIES OF zi_student_u
      IN LOCAL MODE
      ENTITY Student
      UPDATE FIELDS ( Schoolname )
      WITH VALUE #( ( %tky = <fs_student>-%tky  Schoolname = 'LPU' ) ) .


    ELSEIF <fs_student>-Studentclass EQ 'DIPLAMO'.
      MODIFY ENTITIES OF zi_student_u
      IN LOCAL MODE
      ENTITY Student
      UPDATE FIELDS ( Schoolname )
      WITH VALUE #( ( %tky = <fs_student>-%tky  Schoolname = 'KLU' ) ) .
    ENDIF.

  ENDMETHOD.

  METHOD updateStudentStatus.

*    READ ENTITIES OF zi_student_u
*    IN LOCAL MODE
*    ENTITY Student
*    FIELDS ( Status )
*    WITH CORRESPONDING #( keys )
*    RESULT DATA(lt_students).

    DATA(lv_status) = keys[ 1 ]-%param-status.

    MODIFY ENTITIES OF zi_student_u
    IN LOCAL MODE
    ENTITY Student
    UPDATE FIELDS ( Status )
    WITH VALUE #( ( Studentid = keys[ 1 ]-Studentid  Status = keys[ 1 ]-%param-status ) ).

    READ ENTITIES OF zi_student_u
    IN LOCAL MODE
    ENTITY Student
    FIELDS ( Status )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_students).

    result = VALUE #( FOR <fs_stud> IN lt_students (
        %tky = <fs_stud>-%tky
        %param = <fs_stud>
    )
     ).

  ENDMETHOD.

ENDCLASS.

CLASS lhc_Course DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE Course.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE Course.

    METHODS read FOR READ
      IMPORTING keys FOR READ Course RESULT result.

    METHODS rba_Student FOR READ
      IMPORTING keys_rba FOR READ Course\_Student FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_Course IMPLEMENTATION.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_Student.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_STUDENT_U DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_STUDENT_U IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
    "if failed has any entry, then cleanup_finalize method will be called automatically

    DATA gt_students_tmp TYPE STANDARD TABLE OF zstudents_u.

    gt_students_tmp = zcl_students_api_clas=>gt_students.

    IF gt_students_tmp IS NOT INITIAL.

      LOOP AT gt_students_tmp ASSIGNING FIELD-SYMBOL(<ls_student>).

        IF <ls_student>-studentage > 21.
          APPEND VALUE #( studentid = <ls_student>-studentid ) TO failed-student.
          APPEND VALUE #( studentid = <ls_student>-studentid
                          %msg      = new_message_with_text(
                                          severity = if_abap_behv_message=>severity-error
                                          text     = 'Student age should not be greater than 21' )

          ) TO reported-student.
        ENDIF.
      ENDLOOP.

    ENDIF.

  ENDMETHOD.

  METHOD save.

    zcl_students_api_clas=>get_instance(  )->save_student(
      CHANGING
        reported = reported
    ).


  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
