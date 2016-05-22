/**
 *@purpose : Apex Controller is refferd in InvoiceITSetupController
 *@author  : Asish Kumar Behera
 *jira ticket : INVOICEIT-323
 **/
public with sharing class ClassMultipicklistForSetup {
    
    //variable Declaration
     public String pickListValue {get;set;}
     public String pickListLabel {get;set;}
     public boolean isSelected {get;set;}
}