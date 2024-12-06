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
