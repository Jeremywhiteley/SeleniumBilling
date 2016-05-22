public with sharing class InvoiceClass {
    public Invoice__c invoice;
    public list<Invoice_Lines__c> invoiceLines = new list<Invoice_Lines__c>();
}