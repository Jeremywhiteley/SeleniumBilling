//This class to used process the revenue transaction for the invoice lines
    global with sharing class BatchProcessRevenueForInvoiceLines implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts{
        global list<id> listOfInvoiceLineIds = new list<id>();
        global Batch_Jobs__c batchJobsObj;
        global String errorLog = ''; 
        
        global BatchProcessRevenueForInvoiceLines(list<Id> invoiceLineIds) {
            this.listOfInvoiceLineIds = invoiceLineIds;
        }
        
        global Database.QueryLocator start(Database.BatchableContext BC){
           batchJobsObj = new Batch_Jobs__c(name = DateTime.now().format('yyyy-MM-dd'),Start_Date_and_Time__c = system.now(),Status__c = 'Started',Type__c = 'Batch Process For InvoiceLines');
           insert batchJobsObj;
           
           if(listOfInvoiceLineIds!= null){
                return Database.getQueryLocator([select Name from Invoice_Lines__c where Id in:listOfInvoiceLineIds AND Invoice__r.Invoice_Status__c = : CommonUtilClass.STATUS_POSTED ]);
          }else{
             return Database.getQueryLocator([select Name from Invoice_Lines__c where Revenue_Recognition_Status__c = : CommonUtilClass.STATUS_QUEUED AND Invoice__r.Invoice_Status__c = :CommonUtilClass.STATUS_POSTED]);  

           }   
        }
        
         global void execute(Database.BatchableContext BC, list<Invoice_Lines__c> listOfInvoiceLines) {
               try {
                // add the all ids to list to process revenue after completion of this batch
                list<id> listOfInvoiceLinesIds = new list<id>();
                 Map<Id,Invoice_Lines__c> mapinvoice =  new Map<Id,Invoice_Lines__c>(listOfInvoiceLines);
                Set<Id> setOfRecordIds = (mapinvoice).keySet();
                listOfInvoiceLinesIds.addall(setOfRecordIds);
                // call the method to create revenue transactions
                RevenueTransactionsForInvoiceUtilClass.processRevenueTransactionFromBatch(listOfInvoiceLinesIds);
            }catch(Exception ex) {
                errorLog += system.Label.ExceptionMessage + ex.getTypeName() + ':'+ex.getMessage() + ':'  + ex.getLineNumber() + ':' + ex.getStackTraceString() + '\n';
              } 
                
         }
         
         global void finish(Database.BatchableContext BC) {
            
            batchJobsObj.Completed_Date_and_Time__c = system.Now();
            batchJobsObj.Status__c = CommonUtilClass.STATUS_COMPLETED;
            if(errorLog != ''){
                              batchJobsObj.Status__c = CommonUtilClass.STATUS_COMPLETED_WITH_ERRORS;
     
                // the maximum size of Long Text Area is 32768. If error log is more than this then create the attachment with error log 
                if(errorLog.Length() < 32768) {
                    batchJobsObj.Exception_Log__c = errorLog; 
                } else {
     Attachment attachment = new Attachment(Body = Blob.valueOf(errorLog), Name = 'ErrorLog.txt', ParentId = batchJobsObj.Id );
                    batchJobsObj.Exception_Log__c = 'Error log is attached as an attachment, you can find the attachment in releated list';
                    insert attachment;
                }
            }
            update batchJobsObj;
            
            // Invoke credit lines batch   
            if(listOfInvoiceLineIds == null) { 
                BatchProcessRevenueForCreditNotes batch = new BatchProcessRevenueForCreditNotes(null);
                database.executebatch(batch,30); 
            }  
         }
         
    }