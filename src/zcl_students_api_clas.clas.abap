CLASS zcl_students_api_clas DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES : tt_create_student  TYPE TABLE FOR CREATE zi_student_u,
            tt_mapped_early    TYPE RESPONSE FOR MAPPED EARLY zi_student_u,
            tt_response_early  TYPE RESPONSE FOR FAILED EARLY zi_student_u,
            tt_reported_early  TYPE RESPONSE FOR REPORTED EARLY zi_student_u,
            tt_save_reported   TYPE RESPONSE FOR REPORTED LATE zi_student_u,

            "read
            tt_read_keys       TYPE TABLE FOR READ IMPORT zi_student_u,
            tt_read_result     TYPE TABLE FOR READ RESULT zi_student_u,

            "update
            tt_update_entities TYPE TABLE FOR UPDATE zi_student_u,

            "cba
            tt_create_course   TYPE TABLE FOR CREATE zi_student_u\\student\_course,

            "delete
            tt_delete_student  TYPE TABLE FOR DELETE zi_student_u\\student.


    CLASS-METHODS : get_instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_students_api_clas.

    "method for creating ID in early numbering for UNMANAGED SCENARIO
    METHODS : create_student_early_numbering  IMPORTING entities TYPE tt_create_student
                                              CHANGING  mapped   TYPE tt_mapped_early
                                                        failed   TYPE  tt_response_early
                                                        reported TYPE  tt_reported_early.

    "Method for CREATE
    METHODS : create_student  IMPORTING entities TYPE tt_create_student "table for create zi_student_u
                              CHANGING  mapped   TYPE tt_mapped_early " response for mapped early zi_student_u
                                        failed   TYPE tt_response_early " response for failed early zi_student_u
                                        reported TYPE tt_reported_early ." response for reported early zi_student_u

    METHODS : save_student CHANGING reported TYPE tt_save_reported.

    METHODS : read_student IMPORTING keys     TYPE tt_read_keys "keys  type table for read import zi_student_u\\student  [ derived type... ]
                           CHANGING  result   TYPE tt_read_result  "type table for read result zi_student_u\\student  [ derived type... ]
                                     failed   TYPE tt_response_early "response for failed early zi_student_u  [ derived type... ]
                                     reported TYPE tt_reported_early. "response for reported early zi_student_u


    METHODS : update_student  IMPORTING entities TYPE tt_update_entities   "type table for update zi_student_u\\student  [ derived type... ]
                              CHANGING  mapped   TYPE tt_mapped_early  "response for mapped early zi_student_u  [ derived type... ]
                                        failed   TYPE tt_response_early "response for failed early zi_student_u  [ derived type... ]
                                        reported TYPE tt_reported_early. "response for reported early zi_student_u


    "CREATE BY ASSOCIATION
    METHODS : cba_course_earlynumbering  IMPORTING entities TYPE tt_create_course "table for create zi_student_u\\student\_course  [ derived type... ]
                                         CHANGING  mapped   TYPE tt_mapped_early "response for mapped early zi_student_u  [ derived type... ]
                                                   failed   TYPE tt_response_early " response for failed early zi_student_u  [ derived type... ]
                                                   reported TYPE tt_reported_early. "response for reported early zi_student_u

    METHODS : cba_create_courese  IMPORTING entities_cba TYPE tt_create_course "table for create zi_student_u\\student\_course  [ derived type... ]
                                  CHANGING  mapped       TYPE tt_mapped_early "response for mapped early zi_student_u  [ derived type... ]
                                            failed       TYPE tt_response_early "response for failed early zi_student_u  [ derived type... ]
                                            reported     TYPE tt_reported_early. "response for reported early zi_student_u

    METHODS : delete_student IMPORTING keys     TYPE tt_delete_student "table for delete zi_student_u\\student  [ derived type... ]
                             CHANGING  mapped   TYPE tt_mapped_early "response for mapped early zi_student_u  [ derived type... ]
                                       failed   TYPE tt_response_early "response for failed early zi_student_u  [ derived type... ]
                                       reported TYPE tt_reported_early. " response for reported early zi_student_u


  PROTECTED SECTION.

    CLASS-DATA : mo_instance    TYPE REF TO zcl_students_api_clas,
                 gt_students    TYPE STANDARD TABLE OF zstudents_u,
                 gt_course      TYPE STANDARD TABLE OF ztab_course_u,
                 gs_mapped      TYPE tt_mapped_early,
                 gt_so_students TYPE RANGE OF zstudents_u-studentid.

  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_students_api_clas IMPLEMENTATION.


  METHOD create_student_early_numbering.
    DATA(ls_mapped) = gs_mapped.

    "Creating UUID
    DATA(lv_new_id) = cl_uuid_factory=>create_system_uuid(  )->create_uuid_x16(  ).

    "Buffer table update
    READ TABLE gt_students ASSIGNING FIELD-SYMBOL(<lfs_student>) INDEX 1.

    IF <lfs_student> IS ASSIGNED.
      <lfs_student>-studentid = lv_new_id.
      UNASSIGN <lfs_student>.
    ENDIF.

    mapped-student = VALUE #(
        FOR ls_entity IN entities WHERE ( Studentid IS INITIAL )
        (
            %cid = ls_entity-%cid
            %is_draft = ls_entity-%is_draft
            Studentid = lv_new_id
         )
    ).

  ENDMETHOD.


  METHOD get_instance.
    mo_instance = ro_instance = COND #( WHEN mo_instance IS BOUND
                                       THEN mo_instance
                                       ELSE NEW #(  ) ).
  ENDMETHOD.

  METHOD create_student.
    gt_students = CORRESPONDING #( entities MAPPING FROM ENTITY ).


**********************     OLD SYNTAX        ************************

*    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_entity>).
*
*        IF gt_students[] IS NOT INITIAL.
*
**           gt_students[ 1 ]-studentid =  1.
*
*            mapped-student = VALUE #( (
*                %cid = <fs_entity>-%cid
*                %is_draft = <fs_entity>-%is_draft
*                %key  = <fs_entity>-%key
*             ) ).
*
*        ENDIF.
*
*    ENDLOOP.

**********************     NEW SYNTAX        *************************

    mapped = VALUE #(
        student = VALUE #(
            FOR ls_entity IN entities (
                %cid = ls_entity-%cid
                    %is_draft = ls_entity-%is_draft
                    %key  = ls_entity-%key
             )
         )
     ).


  ENDMETHOD.

  METHOD save_student.

    IF gt_students[] IS NOT INITIAL.  "for parent creation
      MODIFY zstudents_u FROM TABLE @gt_students.
    ENDIF.

    IF gt_course[] IS NOT INITIAL.  "for child creation
      MODIFY ztab_course_u FROM TABLE @gt_course.
    ENDIF.

    IF gt_so_students[] IS NOT INITIAL. "for delete
      DELETE FROM zstudents_u WHERE studentid IN @gt_so_students.
    ENDIF.

  ENDMETHOD.

  METHOD read_student.

    IF keys IS NOT INITIAL.

      DATA(lv_studentid) = keys[ 1 ]-studentid.

      SELECT * FROM zstudents_u "table name
      WHERE studentid = @lv_studentid INTO TABLE @DATA(lt_temp).

      result = CORRESPONDING #( lt_temp MAPPING TO ENTITY ).

    ENDIF.

  ENDMETHOD.

  METHOD update_student.

    "Declaring the Internal table of DB Table and Control Structure
    DATA : lt_student    TYPE STANDARD TABLE OF zstudents_u, "internal table of actual db table type
           lt_cx_student TYPE STANDARD TABLE OF zstr_students. "internal table of  control structure

    lt_student = CORRESPONDING #( entities MAPPING FROM ENTITY ). "reading the data coming from UI
    lt_cx_student = CORRESPONDING #( entities MAPPING FROM ENTITY USING CONTROL ).  "readig control structure data to identify which fields are changed on UI

    IF lt_student IS NOT INITIAL.

      SELECT * FROM zstudents_u
      FOR ALL ENTRIES IN @lt_student
      WHERE studentid = @lt_student-studentid
      INTO TABLE @DATA(lt_student_old).

    ENDIF.

    gt_students = VALUE #(

        FOR x = 1 WHILE x <= lines( lt_student )

        LET
            ls_control_flag = VALUE #( lt_cx_student[ x ] OPTIONAL )
            ls_student_data = VALUE #( lt_student[ x ] OPTIONAL )    "data fetched from UI
            ls_student_data_old = VALUE #( lt_student_old[ studentid = lt_student[ x ]-studentid ] OPTIONAL ) "data fetched from DB table

        IN
        (
            studentid = ls_student_data-studentid
            fee       = COND #( WHEN ls_control_flag-fee IS NOT INITIAL THEN ls_student_data-fee ELSE ls_student_data_old-fee )
            gender       = COND #( WHEN ls_control_flag-gender IS NOT INITIAL THEN ls_student_data-gender ELSE ls_student_data_old-gender )
            genderdesc       = COND #( WHEN ls_control_flag-genderdesc IS NOT INITIAL THEN ls_student_data-genderdesc ELSE ls_student_data_old-genderdesc )
            lastchangedat       = COND #( WHEN ls_control_flag-lastchangedat IS NOT INITIAL THEN ls_student_data-lastchangedat ELSE ls_student_data_old-lastchangedat )
            schoolname       = COND #( WHEN ls_control_flag-schoolname IS NOT INITIAL THEN ls_student_data-schoolname ELSE ls_student_data_old-schoolname )
            status       = COND #( WHEN ls_control_flag-status IS NOT INITIAL THEN ls_student_data-status ELSE ls_student_data_old-status )
            studentage       = COND #( WHEN ls_control_flag-studentage IS NOT INITIAL THEN ls_student_data-studentage ELSE ls_student_data_old-studentage )
            studentsection       = COND #( WHEN ls_control_flag-studentsection IS NOT INITIAL THEN ls_student_data-studentsection ELSE ls_student_data_old-studentsection )
            studentname       = COND #( WHEN ls_control_flag-studentname IS NOT INITIAL THEN ls_student_data-studentname ELSE ls_student_data_old-studentname )
            studentclass       = COND #( WHEN ls_control_flag-studentclass IS NOT INITIAL THEN ls_student_data-studentclass ELSE ls_student_data_old-studentclass )

         )

         "after this gt_students table will be saved in save sequence as the modify statement written in the save sequence.



     ).

  ENDMETHOD.

  METHOD cba_course_earlynumbering.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_entity>).

      LOOP AT <fs_entity>-%target ASSIGNING FIELD-SYMBOL(<fs_course>).
        mapped-course = VALUE #( (
            %cid = <fs_course>-%cid
            %is_draft = <fs_course>-%is_draft
            %key = <fs_course>-%key

         ) ) .
      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

  METHOD cba_create_courese.
    gt_course = VALUE #(

        FOR ls_cba_entities IN entities_cba
            FOR ls_course_cba IN ls_cba_entities-%target
                LET
                    ls_course = CORRESPONDING ztab_course_u(    "ztab_course_u is table name
                        ls_course_cba MAPPING FROM ENTITY
                     )
                IN
                (
                    ls_course
                 )
     ).

    mapped = VALUE #(
        course = VALUE #(
            FOR i = 1 WHILE i <= lines( entities_cba )
                LET lt_courses = VALUE #( entities_cba[ i ]-%target OPTIONAL )
            IN
                FOR j = 1 WHILE j <= lines( lt_courses )
                LET ls_courses = VALUE #( lt_courses[ j  ] OPTIONAL )
                IN
                (
                    %cid = ls_courses-%cid
                    %is_draft = ls_courses-%is_draft
                    %key = ls_courses-%key

                 )
         )

     ).
  ENDMETHOD.

  METHOD delete_student.
    DATA : lt_students TYPE STANDARD TABLE OF zstudents_u.
    lt_students = CORRESPONDING #( keys MAPPING FROM ENTITY ).

    gt_so_students = VALUE #(

            FOR ls_student IN lt_students
            (
            sign = 'I'
            option = 'EQ'
            low = ls_student-studentid
            )
     ) .


  ENDMETHOD.

ENDCLASS.
