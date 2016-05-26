global with sharing class ClassWebServiceEmailing {

    WebService static string sendInvoice(Id invoiceId) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        try {
            Invoice__c invoice = [SELECT Billing_Contact__c,Billing_Contact__r.Email 
                                    FROM Invoice__c 
                                    WHERE Id =: invoiceId];        
            string sEmailAddresses = invoice.Billing_Contact__r.Email;
            string sEmailId = invoice.Billing_Contact__c;

            Map<String,Configuration__c> mapConfiguration = Configuration__c.getAll();
            string sTemplateEmailId;

            if(mapConfiguration.containsKey('INVOICE_EMAIL_TEMPLATE')) {
                sTemplateEmailId = mapConfiguration.get('INVOICE_EMAIL_TEMPLATE').String_Value__c;
            }

            if(sEmailAddresses != null) {
                email.setSaveAsActivity(true);
                email.setTargetObjectId(sEmailId);
                email.setTemplateId(sTemplateEmailId);
                email.setWhatId(invoiceId);
                
                // Sends the email
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                return System.Label.Email_Success + ' ' + sEmailAddresses;
            }  
            else {
                return System.Label.BillingContact_Invoice;
            }
        }
        catch(Exception ex) {
            return System.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber();
        }  
    }    

    WebService static string sendQuote(Id quoteId) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        try {           
            PageReference pdf = Page.sendQuote;
            pdf.getParameters().put('id',(String)quoteId);
            pdf.setRedirect(true);
            Blob b;
            if (!system.test.isRunningTest()){
                 b = pdf.getContent();
            }

            // Create the email attachment
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setBody(b);
            Quote__c quote = [SELECT Shipping_Contact__r.Email,Shipping_Contact__c,Valid_To__c,Name
                                FROM Quote__c 
                                WHERE Id =: quoteId];        
            
            efa.setFileName(quote.Name + '.pdf');

            if(!(quote.Valid_To__c < System.Today())) { 
                string sEmailAddresses = quote.Shipping_Contact__r.Email;
                string sEmailId = quote.Shipping_Contact__c;

                Map<String,Configuration__c> mapConfiguration = Configuration__c.getAll();
                string sTemplateEmailId = mapConfiguration.get('QUOTE_EMAIL_TEMPLATE').String_Value__c;

                if(sEmailAddresses != null){
                    email.setSaveAsActivity(true);
                    email.setTargetObjectId(sEmailId);
                    email.setTemplateId(sTemplateEmailId);
                    email.setWhatId(quoteId);

                    // Sets the paramaters of the email
                    email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                    // Sends the email
                    Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                    Quote__c quote1 = new Quote__c(Id = quoteId,Email_Sent__c = CommonUtilClass.STATUS_TRUE);
                    update quote1;
                    return System.Label.Email_Success + ' ' + sEmailAddresses;
                }  
                else {
                    return System.Label.ShippingContact_Quote;
                }
            }
            else {
                return System.Label.Quote_is_Expired;
            }
        }
        catch(Exception ex) {
            return System.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber();
        }  
    }

    webservice static string attachPdf(Id invoiceId,String invoiceName) {
        try {
            //create a attachment object and set the parameters
            Attachment attachment = new Attachment();
            attachment.OwnerId = UserInfo.getUserId();
            attachment.ParentId = invoiceId; // the record the file is attached to
            attachment.IsPrivate = true;
            attachment.Name = invoiceName + '-'+ System.today().format() + '.Pdf';
            
            //get the pdf content to be attached by passing the invoice id
            PageReference pdf = Page.viewinvoice;
            pdf.getParameters().put('id',(String)invoiceId);
            pdf.setRedirect(true);
            Blob b;
            if (!system.test.isRunningTest()){
                b = pdf.getContent();
            }
            
            attachment.body = b;       
            insert attachment;  

            return System.Label.AttachPDF_Invoice;
        }
        catch(Exception ex) {
            return System.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber();
        }
    }
    
    webservice static string attachPdfToOpportunity(Id OppId,String quoteName,Id quoteId) {
        try {
            //create a attachment object and set the parameters
            Attachment attachment = new Attachment();
            attachment.OwnerId = UserInfo.getUserId();
            attachment.ParentId = quoteId; // the record the file is attached to
            attachment.IsPrivate = true;
            attachment.Name = 'Quote' + '.Pdf';
            
            //get the pdf content to be attached by passing the invoice id
            PageReference pdf = Page.sendquote;
            pdf.getParameters().put('id',(String)quoteId);
            pdf.setRedirect(true);
            Blob b;
            if (!system.test.isRunningTest()){
                b = pdf.getContent();
            }
            
            attachment.body = b;       
            insert attachment;  
            return System.Label.AttachPDF_Quote;
        }
        catch(Exception ex) {
            return System.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber();
        }
    }
    
    webservice static string emailAllInvoicesForInvoiceRun(Id invoiceRunID) {
        try {
            list<Invoice__c> listOfInvoices = [SELECT Id,Email_Sent__c
                                               FROM Invoice__c
                                               WHERE Invoice_Run_Created_By__c =: invoiceRunID];
    
            list<Invoice__c> listOfInvoicesToUpdate = new list<Invoice__c>();
            
            for(Invoice__c invoice : listOfInvoices) {
                    Invoice__c invoiceToBeUpdated = new Invoice__c(Id = invoice.Id,
                                                        Email_Sent__c = CommonUtilClass.STATUS_TRUE);
                    listOfInvoicesToUpdate.add(invoiceToBeUpdated);
                }
                
            update  listOfInvoicesToUpdate; 
            
            return System.Label.Email_Success_All_Users;
        }
        catch(Exception ex) {
            return System.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber();
        }
    }
    
    webservice static string postAllInvoicesForInvoiceRun(Id invoiceRunID) {
        try {
            
            //Commented by Dev INVOICEIT-595
             /* list<Invoice__c> listOfInvoices = [SELECT Id,Email_Sent__c
                                               FROM Invoice__c
                                               WHERE Invoice_Run_Created_By__c =: invoiceRunID
                                               AND Invoice_Status__c =: CommonUtilClass.STATUS_DRAFT];
    
            if(listOfInvoices.size() > 0) {
                for(Invoice__c invoice : listOfInvoices) {
                    invoice.Invoice_Status__c = CommonUtilClass.STATUS_POSTED;
                }
                    
                update  listOfInvoices; 
            } else {
                return 'No invoice(s) are present with status draft';
            } */
            
            string sQuery = 'SELECT Name,Tax_Engine__c,Order__c,Account__c,Invoice_Date__c,Amount__c FROM Invoice__c where Invoice_Run_Created_By__c =\'' +invoiceRunID + '\' And Invoice_Status__c = \'Draft\'';
            BatchForPostingInvoices  b = new BatchForPostingInvoices(sQuery);
            database.executebatch(b,1);

            return 'Batch job has been started, the invoice will posted soon';
        }
        catch(Exception ex) {
            return System.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber();
        }
    }
}