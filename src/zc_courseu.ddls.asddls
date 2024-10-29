@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection CDS View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_COURSEU as projection on ZI_COURSEU
{
    key Studentid,
    key Course,
    key Semester,
    Semresult,
    /* Associations */
    _student : redirected to parent ZC_STUDENT
}
