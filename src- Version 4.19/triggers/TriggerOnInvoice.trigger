trigger TriggerOnInvoice on Invoice__c (after update, before delete) {
    ClassAfterOnInvoice classAfterOnInvoice = new ClassAfterOnInvoice();
    if(Trigger.isAfter) {
        if(!classAfterOnInvoice.getInvoiceAfterProcessingComplete()) {
          classAfterOnInvoice.setInvoiceAfterProcessingComplete();
          classAfterOnInvoice.handleAfterOnInvoice(Trigger.newMap, Trigger.oldMap);
        }
    } else {
        classAfterOnInvoice.handleBeforeOnInvoice(Trigger.old);
    }
    
    /*
        Modified By     : Rama Krishna
        created date    : 11 june 2013
        Modified Date   : 19 june 2013
        JIRA Task       : INVOICEIT-130
        Comments        : whenever invoice status changed from Draft to posted, 
                         if invoice Account have any paymnets,Allowing Unallocated Payments to be automatically allocated to future invoices. 
    */ 
    boolean isAutomaticAllocatePayment = Configuration__c.getValues('AUTOMATIC_ALLOCATEDTOFUTURE_INVOICES').Boolean_Value__c;
    
    if(isAutomaticAllocatePayment != null && isAutomaticAllocatePayment){
        if(Trigger.isAfter) {
            classAfterOnInvoice.handleAfterOnInvoiceAutomaticAllocation(Trigger.newMap, Trigger.oldMap);
        }
    }
}