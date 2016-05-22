trigger TriggerOnInvoiceScheduler on Invoice_RunScheduler__c (after delete) {
    /*
        Modified By     : Aish, 4-4-2014, INVOICEIT-301
        Comments        : If the Invoice scheduler record is deleted we need to abort the job in the backend
    */
    ClassAfterOnInvoiceScheduler classAfterOnInvoiceScheduler = new ClassAfterOnInvoiceScheduler(); 
    classAfterOnInvoiceScheduler.handleAfterOnInvoiceScheduler(trigger.newMap,trigger.oldMap);
}