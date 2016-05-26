/*
		* This scheduler class is created for InvoiceIt batch jobs object, 
		* This is used for invoking batches one after one and maintains records in BatchJobs object
		* For More Information refer this Ticket : INVOICEIT-399
		*/
		global with sharing class RunSchedulerBatchJobs implements Schedulable {
		     global void execute(SchedulableContext context) {
		        string query = 'SELECT Account__c, CurrencyL__c, CurrencyL__r.Name, Todays_MRR__c, Todays_MRR_With_Tax__c FROM Job__c '; 
		        BatchForCalculatingMRR batch = new BatchForCalculatingMRR(query,true);
		        ID batchprocessid = Database.executeBatch(batch, 10);
		     }
		}