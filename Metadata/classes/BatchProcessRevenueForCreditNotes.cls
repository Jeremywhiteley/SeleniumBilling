/*
      this class to used process the revenue transaction for the invoice lines
    */

    global with sharing class BatchProcessRevenueForCreditNotes implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts{

        global list<id> listOfCreditNoteIds = new list<id>();
        global Batch_Jobs__c batchJobsObj;
        global String errorLog = '';
        list<id> listOfCreditLineIds = new list<id>();
        
        global BatchProcessRevenueForCreditNotes(list<Id> creditNoteIds) {
            this.listOfCreditNoteIds = creditNoteIds;
        }
        
        global Database.QueryLocator start(Database.BatchableContext BC){
           batchJobsObj = new Batch_Jobs__c(name = DateTime.now().format('yyyy-MM-dd'),Start_Date_and_Time__c = system.now(),Status__c = 'Started',Type__c = 'Batch Process Revenue For CreditNotes');
           insert batchJobsObj;
            
           if(listOfCreditNoteIds != null){ 
                return Database.getQueryLocator([select Name from Credit_Line__c where Credit_Note__c IN: listOfCreditNoteIds AND Credit_Note__r.Credit_Note_Status__c =: CommonUtilClass.STATUS_POSTED]);  
            } else {
                return Database.getQueryLocator([select Name from Credit_Line__c where Revenue_Recognition_Status__c =: CommonUtilClass.STATUS_QUEUED AND Credit_Note__r.Credit_Note_Status__c =: CommonUtilClass.STATUS_POSTED]);
            }
        }
        
         global void execute(Database.BatchableContext BC, list<Credit_Line__c> listOfCreditLines) {
           try {
            // add the all ids to list to process revenue after completion of this batch
            Set<Id> setOfRecordIds = (new Map<Id,Credit_Line__c>(listOfCreditLines)).keySet();
            listOfCreditLineIds = new list<id>();
            listOfCreditLineIds.addall(setOfRecordIds);
            // call the method to create revenue transactions
            RevenueTransactionsForCreditUtilClass.createRevenueTransactionForCreditLine(listOfCreditLineIds);
           
           }catch(Exception ex) {
            errorLog += system.Label.ExceptionMessage + ex.getTypeName() + ':'+ex.getMessage() + ':'  + ex.getLineNumber() + ':' + ex.getStackTraceString() + '\n';
           } 
         }
         
         global void finish(Database.BatchableContext BC) {
            
            batchJobsObj.Completed_Date_and_Time__c = system.now();
            batchJobsObj.Status__c = CommonUtilClass.STATUS_COMPLETED;
            if(errorLog != ''){
                batchJobsObj.Status__c = CommonUtilClass.STATUS_COMPLETED_WITH_ERRORS;
                // the maximum size of Long Text Area is 32768. If error log is more than this then create the attachment with error log 
                if(errorLog.Length() < 32768) {
                    batchJobsObj.Exception_Log__c = errorLog; 
                } else {
                    Attachment attachment = new Attachment(Body = Blob.valueOf(errorLog), Name = 'ErrorLog.txt', ParentId = batchJobsObj.Id );
                    insert attachment;  
                    batchJobsObj.Exception_Log__c = 'Error log is attached as an attachment, you can find the attachment in releated list';
                }
            }
            update batchJobsObj;       
         }
         
    }