trigger TriggerOnInvoiceLine on Invoice_Lines__c (after update) {
    ClassAfterOnInvoiceLine classAfterOnInvoiceLine = new ClassAfterOnInvoiceLine();
    if(Trigger.isAfter) {
        if(!classAfterOnInvoiceLine.getInvoiceLineAfterProcessingComplete()) {
          classAfterOnInvoiceLine.setInvoiceLineAfterProcessingComplete();
          classAfterOnInvoiceLine.handleAfterOnInvoiceLine(Trigger.newMap, Trigger.oldMap);
        }
    }
}