@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection CDS View for ROOTV'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

define root view entity ZC_STUDENT as projection on ZI_STUDENT_U
{
    key Studentid,
    Studentname,
    Studentclass,
    Studentage,
    Studentsection,
    Schoolname,
    Status,
    Gender,
    Lastchangedat,
    Fee,
    GenderDesc,
    /* Associations */
    _course : redirected to composition child ZC_COURSEU,
    _gender
}
