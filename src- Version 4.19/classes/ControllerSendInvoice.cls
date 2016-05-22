public with sharing class ControllerSendInvoice {

        public Invoice__c invoice {set;get;}
        public boolean bDisplayNoteMessage {set;get;}
        
        public ControllerSendInvoice(ApexPages.StandardController stdController) {
            invoice = (Invoice__c) stdController.getRecord();
            this.invoice = [select id,Email_Sent__c from Invoice__c where id =:invoice.id];
        }
        
        public PageReference emailInvoice() {
            try{
                String s ='';
                if(!invoice.Email_Sent__c) {
                    String sMessage = ClassWebServiceEmailing.sendInvoice(invoice.Id);
                    bDisplayNoteMessage = true;
                    if(sMessage.Contains('Exception') || sMessage.Contains('Error')) {
                        s = sMessage ; 
                    }
                    else {
                        invoice.Email_Sent__c = true;
                        update invoice;
                        s = System.Label.LabelEmailSent;
                    }       
                }
                else {
                      s = System.Label.Email_is_already_sent;
                }
                
                Apexpages.Message message = new Apexpages.Message(ApexPages.Severity.INFO,s);
                Apexpages.addMessage(message);
            }
            catch(Exception ex) {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber());
                Apexpages.addMessage(errorMessage);
            }
            return null;
        }
        
        public PageReference backToInvoice() {
            return new PageReference('/' + invoice.Id);
        }

    }