public with sharing class ControllerInvoiceRun {

        public Invoice_Run__c invoiceRun {set;get;}
        public boolean bDisplayNoteMessage {set;get;}
        
        public ControllerInvoiceRun(ApexPages.StandardController stdController) {
            invoiceRun = (Invoice_Run__c) stdController.getRecord();
        }
        
        public PageReference emailAllInvoicesForInvoiceRun() {
            try{
                String s = System.Label.Email_Success_All_Users;
                BatchForEmailingInvoices  batchEmailInvoices = new BatchForEmailingInvoices(invoiceRun.Id); 
                Id processedId = database.executebatch(batchEmailInvoices,1);
                bDisplayNoteMessage = true;
                
                Apexpages.Message message = new Apexpages.Message(ApexPages.Severity.INFO,s);
                Apexpages.addMessage(message);
            }
            catch(Exception ex) {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber());
                Apexpages.addMessage(errorMessage);
            }
            return null;
        }
        
        public PageReference backToInvoiceRun() {
            return new PageReference('/' + invoiceRun.Id);
        }
    }