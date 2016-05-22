global with sharing class  BatchInvoiceGeneration implements Database.Batchable<Job__c>, Database.Stateful{
        global Integer noOfAccountsProcessed = 0;
        global Integer noOfJobsProcessed = 0;
        global Integer noOfInvoicesGenerated = 0;
        global Integer noOfCreditNotesGenerated = 0;
        global Double totalInvoiceValue = 0;
        global Invoice_Run__c invoiceRun;
        global Integer noOfDaysToDueDate = 0;
        global Iterable<Job__c> start(Database.BatchableContext BC){
            return new ClassIterateJob();
        }
        global void execute(Database.BatchableContext BC, list<Job__c> scope){
        }
        global void finish(Database.BatchableContext BC){
        }
    }