@EndUserText.label: 'Abastract entity using for action'
@Metadata.allowExtensions: true
define abstract entity ZA_STUDENT
//  with parameters parameter_name : parameter_type
{
    @UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: Status' )  //this annotation gives the selected record value of table in the popup in action
    status         : abap.char(15);
    
}
