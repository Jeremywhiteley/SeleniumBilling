global with sharing class RunSchedulerMrr implements Schedulable {
	     global void execute(SchedulableContext context) {
	        string query = 'SELECT Account__c, CurrencyL__c, CurrencyL__r.Name, Todays_MRR__c, Todays_MRR_With_Tax__c FROM Job__c '; 
	        BatchForCalculatingMRR batch = new BatchForCalculatingMRR(query);
	        ID batchprocessid = Database.executeBatch(batch, 10);
	     }
	}