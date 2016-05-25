public with sharing class ClassForPostingInvoices {
   public Invoice_Run__c runObj {get;set;}
   public ClassForPostingInvoices(ApexPages.StandardController stdController) {
      runObj = (Invoice_Run__c )stdController.getrecord();
      runObj = [SELECT Id,Name FROM Invoice_Run__c  WHERE ID =:runObj.Id ];
   }
   
   
   public pagereference isExecuteBatch(){
     string sQuery = 'SELECT Name,Tax_Engine__c,Account__c,Order__c,Exception_Log__c,Tax_Calculation_Status__c FROM Invoice__c where Invoice_Run_Created_By__c =\'' +runObj.Id+ '\' And Invoice_Status__c = \'Draft\'';
     BatchForPostingInvoices  b = new BatchForPostingInvoices(sQuery );
     database.executebatch(b,1);
     Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, system.Label.Batch_Job_Started));
     return null;
   
   }
}