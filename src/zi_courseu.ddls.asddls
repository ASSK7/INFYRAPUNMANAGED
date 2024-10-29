@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_COURSEU as select from ztab_course_u
association to parent ZI_STUDENT_U as _student on _student.Studentid = $projection.Studentid
{
    key studentid as Studentid,
    key course as Course,
    key semester as Semester,
    semresult as Semresult,
    _student
}
