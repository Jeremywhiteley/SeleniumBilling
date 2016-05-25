global with sharing class BatchCancelInvoices implements Database.Batchable<sObject>, Database.Stateful{
    global String query;
    global set<id> setOfInvoicesId = new set<id>();

    global BatchCancelInvoices(set<id> setOfInvoicesId){
      this.setOfInvoicesId = setOfInvoicesId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        query = 'SELECT Name FROM Invoice__c WHERE ID IN: setOfInvoicesId';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,list<Invoice__c> scope){
    try{
        ControllerCancelInvoice.isButtonClicked = true; 
        Invoice__c inv = new Invoice__c(id=scope[0].id,Invoice_Status__c ='Cancelled');
        update inv;
    }catch(Exception ex){
    }
    }    
    global void finish(Database.BatchableContext BC){
    }
}