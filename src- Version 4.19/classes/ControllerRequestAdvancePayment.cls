public with sharing class ControllerRequestAdvancePayment {
    
    public Account account{get;set;} 
    public list<Contact> listOfContacts{get;set;}
    RequestAdvancePayment requestAdvancePayment;
    public list<RequestAdvancePayment> listOfRequestAdvancePayment{get;set;}
    public boolean isContactSelected{get;set;}
    
    public ControllerRequestAdvancePayment(ApexPages.StandardController controller) {
        account = (Account)controller.getRecord();
        isContactSelected=false;
        listOfRequestAdvancePayment = new list<RequestAdvancePayment>();
        string sQuery ='SELECT ' + CommonUtilClass.getObjectFields('Contact')
                                 + ' FROM Contact '
                                 + ' WHERE AccountId  =' + '\''+ account.Id + '\'' + ' ';                
                
        sQuery = String.escapeSingleQuotes(sQuery);
        sQuery = sQuery.replace('\\','');
        listOfContacts = Database.query(sQuery);
        if(listOfContacts.size() == 0) {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There are no contacts to send email for the request advance credit card payment'));
            //Added by Shruthi related to INVOICEIT-200
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.Label.NoContactsToSendEmail));
            isContactSelected = true;
        } else {
            //if(Configuration__c.getValues('FORCE.COM_SITE_URL').String_Value__c != null){
                for(Contact contact : listOfContacts){
                    // if contact email is not present
                    if(contact.Email != null){
                        requestAdvancePayment = new RequestAdvancePayment();
                        requestAdvancePayment.isChecked = false;
                        requestAdvancePayment.contact = contact;
                        listOfRequestAdvancePayment.add(requestAdvancePayment);
                    }else {
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No email IDs are present in the contacts'));
                        //Added by Shruthi related to INVOICEIT-200
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.Label.NoEmailIdPresentInContactList));
                        isContactSelected = true;
                    }
                 }
            //}else{
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please configure the Force.Com site URL in the Invoice IT Setup'));
                //isContactSelected = true;
            //}
        }   
    }
    
     public PageReference sendEmailForRequestPayment(){
        if(account.Advance_Requested_Amount__c <= 0){
             //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please enter amount more than zero')); 
             //Added by Shruthi related to INVOICEIT-200
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, system.Label.EnterAmountGreaterThanZero));           
             return null;
        }
        
        for(RequestAdvancePayment requestAdvancePayment : listOfRequestAdvancePayment){
                if(requestAdvancePayment.isChecked){
                        isContactSelected = true;
                }
        }
        /*
         Modified By     : Sagarika Rout
                Modified Date   : 25-09-2013
                JIRA Task       : INVOICEIT-240
                Comments        : emailtemplate for advance payment, 
                                    we have created new email template :Advance_Payment .
        */
         if(!isContactSelected){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, system.Label.SelectContactToSendEmail));
         } else {
                list<EmailTemplate> listOfEmailTemplate = [select id from EmailTemplate where DeveloperName='Advance_Payment'];
                if(account.Advance_Requested_Amount__c != null){
                    account.Advance_Request_Status__c = 'Requested';
                    update account;
                }
                for(RequestAdvancePayment requestAdvancePayment : listOfRequestAdvancePayment){
                        if(requestAdvancePayment.isChecked){
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                        /*Setting user email in to address
                        String[] toAddresses = new String[] {requestAdvancePayment.Contact.Email} ;
                        Assign the addresses for the To and CC lists to the mail object
                            mail.setSubject('Advance Payment Request');
                            mail.setToAddresses(toAddresses);
                            string sForce_ComSiteURL = Configuration__c.getValues('FORCE.COM_SITE_URL').String_Value__c+'/?id='+requestAdvancePayment.Contact.accountId;
                            Organization orgDetails = [SELECT Id,Name, LanguageLocaleKey FROM Organization WHERE Id = :UserInfo.getOrganizationId()];
                            mail.setPlainTextBody('M/s  ' +orgDetails.Name + ' has requested for an advance payment of USD '+ account.Advance_Requested_Amount__c
                                                    + '\n' 
                                                    + '\n'
                                                    + 'Please use following URL to process your credit card payment :- '
                                                    + '\n'
                                                    + '\n'
                                                    +sForce_ComSiteURL
                                                    + '\n'
                                                    + '\n'
                                                    + '- Team Accounts');*/
                              
                              if(!listOfEmailTemplate.isEmpty()){
                                    mail.setTemplateId(listOfEmailTemplate[0].id );
                                    mail.setTargetObjectId(requestAdvancePayment.Contact.ID);    
                                    if(!Test.isRunningTest()) {
                                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });   
                                    }               
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, system.Label.EmailSentSuccessfully));
                              }else {
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.Label.InvalidEmailTemplate));
                              }                      
                                
                        }
                }
                
                
         }
        return null;
     }
  
  public class RequestAdvancePayment {
        public boolean isChecked {get;set;}
        public Contact contact {get;set;}
    }
}