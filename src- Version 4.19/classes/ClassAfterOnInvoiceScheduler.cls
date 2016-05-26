public with sharing class ClassAfterOnInvoiceScheduler {
    /*
        Modified By     : Aish :4-4-2014  :INVOICEIT-301
        Comments        : If the Invoice scheduler record is deleted we need to abort the job in the backend
    */
    public void handleAfterOnInvoiceScheduler(map<id,Invoice_RunScheduler__c> newMap,map<id,Invoice_RunScheduler__c> oldMap) {
        for(Invoice_RunScheduler__c scheduler : oldMap.Values()) { 
            if(scheduler.JobId__c != null) { 
                System.abortJob(scheduler.JobId__c); 
            }
        }
    }
}