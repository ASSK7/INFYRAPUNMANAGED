CLASS zcl_students_api_clas DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES : tt_create_student TYPE TABLE FOR CREATE zi_student_u,
            tt_mapped_early   TYPE RESPONSE FOR MAPPED EARLY zi_student_u,
            tt_response_early TYPE RESPONSE FOR FAILED EARLY zi_student_u,
            tt_reported_early TYPE RESPONSE FOR REPORTED EARLY zi_student_u.

    CLASS-METHODS : get_instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_students_api_clas.

    "method for creating ID in early numbering for UNMANAGED SCENARIO
    METHODS : create_student_early_numbering  IMPORTING entities TYPE tt_create_student
                                              CHANGING  mapped   TYPE tt_mapped_early
                                                        failed   TYPE  tt_response_early
                                                        reported TYPE  tt_reported_early.


  PROTECTED SECTION.

    CLASS-DATA : mo_instance TYPE REF TO zcl_students_api_clas,
                 gt_students TYPE STANDARD TABLE OF zstudents_u,
                 gt_course   TYPE STANDARD TABLE OF ztab_course_u,
                 gs_mapped   TYPE tt_mapped_early.

  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_students_api_clas IMPLEMENTATION.
  METHOD get_instance.
    mo_instance = ro_instance = COND #( WHEN mo_instance IS BOUND
                                       THEN mo_instance
                                       ELSE NEW #(  ) ).
  ENDMETHOD.

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

ENDCLASS.
