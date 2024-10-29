@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_STUDENT_U as select from zstudents_u
association to ZI_GENDERU as _gender on _gender.Value = $projection.Gender
composition[0..*] of ZI_COURSEU as _course
{
    
    key studentid as Studentid,
    studentname as Studentname,
    studentclass as Studentclass,
    studentage as Studentage,
    studentsection as Studentsection,
    schoolname as Schoolname,
    status as Status,
    gender as Gender,
    lastchangedat as Lastchangedat,
    fee as Fee,
    
    //    Associations
    _gender,
    _gender.Description as GenderDesc,
    //Composition
    _course
}
