global class BatchForPostingInvoices implements Database.Batchable<sObject>,database.stateful,Database.AllowsCallouts{
     global string sQuery;
     global string InvoiceStatus = 'Draft';
     global Batch_Jobs__c batchJob;
     global string errorLog = null;
     global static boolean isExecuteAvaTax = true;
     global BatchForPostingInvoices(string query){
        this.sQuery = query;
         batchJob = new Batch_Jobs__c(Name = 'BatchInvoiceStatusUpdate- ' + system.today(), Type__c = 'BatchInvoiceStatusUpdate', Start_Date_and_Time__c = system.now(), Status__c = 'Processing');
         insert batchJob;  
      }
     global Database.querylocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(sQuery);
      } 
      global void execute(Database.BatchableContext BC, List<Invoice__c> scope){
           try {
               isExecuteAvaTax = false;
               list<Invoice__c> listOfInvoice = new  list<Invoice__c>();
               Invoice__c invToUpdate;
               list<Invoice_Lines__c> listOfInvoiceLinesToUpdate = new list<Invoice_Lines__c>();
               for(Invoice__c inv : scope) {
                   if(inv.Tax_Engine__c == System.Label.Avalara) {
                         ClassforCalculatingAvaTax.calculateTaxInvoice(inv.Account__c,inv.Order__c,inv.id);
                       }
                       else{
                          invToUpdate = new Invoice__c(id = inv.id,Invoice_Status__c = 'Posted');
                          listOfInvoice.add(invToUpdate);
                   }
                   
               }
               update listOfInvoice;
           } catch(exception ex) {
              errorLog += '\n' + 'An exception has occured, exception type is ' + ex.getTypeName() + ':'+ex.getMessage() + ':' + ex.getLineNumber() + ':' + ex.getStackTraceString() + '\n';
          }    
     }
      global void finish(Database.BatchableContext BC){
          batchJob.Completed_Date_and_Time__c = system.now();
          if(errorLog == null) {
              batchJob.Status__c = 'Completed';
          } else {
              batchJob.Status__c = 'Completed with Errors';
              
              if(errorLog.Length() < 32768) {
                  batchJob.Exception_Log__c = errorLog; 
              } 
          }
          update batchJob;
      }
  }