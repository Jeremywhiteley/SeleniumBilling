global with sharing class BatchForEmailingInvoices implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
      global String query;
      global Id invoiceRunId;
      global String errorLog = '';
      
      global BatchForEmailingInvoices (Id invoiceRunId){
           //this.query = query;
           this.invoiceRunId= invoiceRunId;
          
       }
       
       global Database.QueryLocator start(Database.BatchableContext BC) {
           String query = 'SELECT Id,Name,Email_Sent__c FROM Invoice__c '
                          + 'WHERE Invoice_Run_Created_By__c =\''+ String.escapeSingleQuotes(invoiceRunId) + '\' '
                          + 'AND Email_Sent__c = false' ;
           return Database.getQueryLocator(query);
       }
       
        global void execute(Database.BatchableContext BC, list<sObject> scope) {
          for(sObject sObj : scope) {
              Invoice__c invoice = (Invoice__c) sObj;  
              try {
                  Messaging.reserveSingleEmailCapacity(1);
                  String sMessage = ClassWebServiceEmailing.sendInvoice(invoice.Id);
                  if(sMessage.Contains('Exception') || sMessage.Contains('Error')) {
                    errorLog = errorLog + sMessage;   
                    errorLog += ' Invoice Id : ' + invoice.Id + '\n';
                    errorLog += ' Invoice Name : ' + invoice.Name + '\n';
                  }
                  else {
                      invoice.Email_Sent__c = true;
                      update invoice;
                  }   
                 
              }
               catch(Exception ex) {
                  errorLog +=  ex.getTypeName() + ':' + ex.getMessage() + ':'  + ex.getLineNumber() + ':' + ex.getStackTraceString() + '\n';
                  errorLog += ' Invoice Id : ' + invoice.Id + '\n';
                  errorLog += ' Invoice Name : ' + invoice.Name + '\n';
               }  
          }
        }
        
        global void finish(Database.BatchableContext BC) {
            AsyncApexJob aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors 
                                FROM AsyncApexJob 
                                WHERE ID =: BC.getJobId()];
            
            list<Invoice_Run__c> listInvoiceRun = [Select id,Exception_Log__c  from Invoice_Run__c where id =:invoiceRunId];
            list<Invoice__c> listInvoices1 = [Select id,Name,Email_Sent__c  
                                             from Invoice__c 
                                             where Invoice_Run_Created_By__c =:invoiceRunId
                                             AND Email_Sent__c = false];
            if(errorLog != '' && errorLog.Length() > 0 && listInvoiceRun != null && !listInvoiceRun.isEmpty()) {
                if(errorLog.Length() < 32768) {
                     if(listInvoiceRun.get(0).Exception_Log__c != null) {
                        listInvoiceRun.get(0).Exception_Log__c = listInvoiceRun.get(0).Exception_Log__c + errorLog;           
                     }
                     else {
                        listInvoiceRun.get(0).Exception_Log__c = errorLog;    
                     }
                 } else {
                      Attachment attachment = new Attachment();
                      attachment.Body = Blob.valueOf(errorLog);
                      attachment.Name = 'ErrorLogForEmails.txt';
                      attachment.ParentId = invoiceRunId; 
                      insert attachment;  
                      
                      String errorStatement = '  Error log for Emails is attached as an attachment, you can find the attachment in related list';
                      if(listInvoiceRun.get(0).Exception_Log__c != null) {
                          listInvoiceRun.get(0).Exception_Log__c = listInvoiceRun.get(0).Exception_Log__c + errorStatement;           
                      }
                  }
               
              update listInvoiceRun;  
              
              String sUserId = Userinfo.getUserId();
              String sEmailId = Userinfo.getUserEmail();
              
              Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
              if(sEmailId != null) {
                  email.setSaveAsActivity(false);
                  email.setTargetObjectId(sUserId);
                  String subject='Error While sending Invoices';
                  String body='The invoices sent to the customers are not succesfully sent. Please check your Exception log'; 
                  email.setHtmlBody(body); 
                  email.setSubject(subject);
                  
                  // Sends the email
                  Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
              }
            }
            else if(aaj.TotalJobItems > 0 && (listInvoices1 == null || listInvoices1.isEmpty())){
                
                String sUserId = Userinfo.getUserId();
                String sEmailId = Userinfo.getUserEmail();
              
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                if(sEmailId != null) {
                   email.setSaveAsActivity(false);
                   email.setTargetObjectId(sUserId);
                   String subject='Invoices sent Successfully';
                   String body='The invoices sent to the customers are succesfully sent.'; 
                   email.setHtmlBody(body); 
                   email.setSubject(subject);
                  
                  // Sends the email
                   Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});  
               }  
              
            }
            else if(aaj.TotalJobItems == 0){
                String sUserId = Userinfo.getUserId();
                String sEmailId = Userinfo.getUserEmail();
              
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                if(sEmailId != null) {
                   email.setSaveAsActivity(false);
                   email.setTargetObjectId(sUserId);
                   String subject='No Invoices Sent';
                   String body='There are no invoices in the Queue to be sent to the customer.'; 
                   email.setHtmlBody(body); 
                   email.setSubject(subject);
                  
                  // Sends the email
                   Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});  
               }  
                  
              
            }
        }  

  }