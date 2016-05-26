global with sharing class BatchTransactions implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
         
         global String query;
         global String errorLog = '';
         global Payment_Scheduler__c paymentScheduler;
         global Payment_Run__c paymentRun;   
         global integer noOfInvoicesProcessed = 0;
         global integer noOfSuccesfullTransaction = 0;
         global integer noOfFailedTransaction = 0;
         global Decimal noOfDaysBetweenRetries ;
         global list<Transaction__c> listOfTransactionsToUpdate;
         //Added by Siri:INVOICEIT-631:25-11-2015
         global list<Invoice__c> listOfInvoicesToUpdate = new list<Invoice__c>();
         global decimal totalTransactionsValue = 0.0;
           
         global BatchTransactions(String query, Payment_Scheduler__c paymentScheduler){
             this.query = query;
             this.paymentScheduler = paymentScheduler;
             listOfTransactionsToUpdate = new list<Transaction__c>();
             //Added by Siri:INVOICEIT-631:25-11-2015
             noOfDaysBetweenRetries = Configuration__c.getValues('PAYMENT_NO_OF_DAYS_BETWEEN_RETRIES').Number_Value__c;
             paymentRun = new Payment_Run__c(Payment_Scheduler__c = paymentScheduler.Id, Name = paymentScheduler.Name, 
                                             Status__c = CommonUtilClass.STATUS_PROCESSING, Start_Time__c = system.now());
         }
         
         global Database.QueryLocator start(Database.BatchableContext BC) {
            insert paymentRun;
            return Database.getQueryLocator(query);
         }
         
         global void execute(Database.BatchableContext BC, list<sObject> scope) {

            //Added by Siri: INVOICEIT-631:25-11-2015
            Date lastProcessingDate ;
            Decimal noOfDays = 0;
            Decimal noOfTries ;

            for(sObject sObj : scope) {
                 ++noOfInvoicesProcessed;
                 Invoice__c invoice = (Invoice__c) sObj;
                 // Added by Dev M: SUP-543
                 PaymentOperations.PaymentResult result;

                 //If conditions added by Siri: INVOICEIT-631: 25-11-2015
                 if(invoice.No_of_tries__c != null){
                    noOfTries = invoice.No_of_tries__c;
                 }
                 if(invoice.Last_Processing_Date__c != null){
                    lastProcessingDate = invoice.Last_Processing_Date__c;
                    noOfDays = lastProcessingDate.daysBetween(system.today());
                 }
                 if(noOfDaysBetweenRetries == null){
                    noOfDaysBetweenRetries = 0;
                 }

                 try {
                     //If condition added by Siri:INVOICEIT-631:25-11-2015
                     if( noOfDays >= noOfDaysBetweenRetries || lastProcessingDate == null){
                         result = PaymentOperations.authorizeAndCharge(invoice.Id, null, null);
                         if(result != null && result.transactionObj != null && result.transactionObj.Id != null) {
                            if(result.transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                                ++noOfSuccesfullTransaction;
                                totalTransactionsValue = totalTransactionsValue + result.transactionObj.Amount__c;
                                
                                // we are not passing payment run parameters to the gateway class, to avoid passing params to gateway class follow below ones
                                // in order to update the payment description for the relavant payment, therefore we are querying the payment to update 
                                // execution of batch size also 1, so that no problem of qurying , releated to ticket INVOICEIT-246
                                list<payment__c> lstPayment = [Select id from payment__c where Transaction__c =: result.transactionObj.Id LIMIT 1];
                                if(lstPayment.size() > 0){
                                    payment__c paymentToUpdateDescription = new payment__c(id = lstPayment[0].id, Payment_Description__c = 'Payment Scheduler: '+DateTime.now().format('MMM dd,YYYY')+  ' Run');
                                    update paymentToUpdateDescription;
                                }

                                
                             } else {
                                //it many be error or declined or held for review 
                                ++noOfFailedTransaction;
                                //Added by Siri: INVOICEIT-631: 25-11-2015
                                Invoice__c invoicesToUpdateFields = new Invoice__c( Id = invoice.id ,No_of_tries__c = ++noOfTries, Last_Processing_Date__c= system.today());
                                listOfInvoicesToUpdate.add(invoicesToUpdateFields);

                             }
                             result.transactionObj.Payment_Run__c = paymentRun.Id;
                             listOfTransactionsToUpdate.add(result.transactionObj);
                             
                         } else {
                            //it many be error or declined or held for review
                            ++noOfFailedTransaction;
                            errorLog += result.message+ '\n';
                            errorLog += ' Invoice Id : ' + invoice.Id + '\n';
                            errorLog += ' Invoice Name : ' + invoice.Name + '\n';
                            // Added by Dev M: SUP-543
                            CommonUtilClass.createFailedtransaction(invoice.Id, paymentRun.Id, result.message);

                            //Added by Siri:INVOICEIT-631:25-11-2015
                             Invoice__c invoicesToUpdateFields = new Invoice__c( Id = invoice.id ,No_of_tries__c = ++noOfTries, Last_Processing_Date__c= system.today());
                             listOfInvoicesToUpdate.add(invoicesToUpdateFields);
                         }
                         
                     }
                 }
                 catch(Exception ex) {
                    ++noOfFailedTransaction;
                    errorLog +=  ex.getTypeName() + ':' + ex.getMessage() + ':'  + ex.getLineNumber() + ':' + ex.getStackTraceString() + '\n';
                    errorLog += ' Invoice Id : ' + invoice.Id + '\n';
                    errorLog += ' Invoice Name : ' + invoice.Name + '\n';
                    // Added by Dev M: SUP-543
                    CommonUtilClass.createFailedtransaction(invoice.Id, paymentRun.Id, ex.getTypeName() + ':' + ex.getMessage() + ':'  + ex.getLineNumber());
                    
                    //Added by Siri:INVOICEIT-631: 25-11-2015
                    Invoice__c invoicesToUpdateFields = new Invoice__c( Id = invoice.id ,No_of_tries__c = ++noOfTries, Last_Processing_Date__c= system.today());
                    listOfInvoicesToUpdate.add(invoicesToUpdateFields);             
                 }
            }
         }
         
         global void finish(Database.BatchableContext BC) {
             
            if(errorLog == '') {
                paymentRun.Status__c = CommonUtilClass.STATUS_COMPLETED;    
            } else {
                paymentRun.Status__c = CommonUtilClass.STATUS_COMPLETED_WITH_ERRORS;
                paymentRun.Exception_Log__c = errorLog;
            }
            paymentRun.Completed_Time__c = system.now();
            paymentRun.Invoices_Processed__c = noOfInvoicesProcessed;
            paymentRun.Successful_Transactions__c = noOfSuccesfullTransaction;
            paymentRun.Failed_Transactions__c = noOfFailedTransaction;
            paymentRun.Total_Payment_Value__c = totalTransactionsValue;

            update paymentRun;
            
            if(!listOfTransactionsToUpdate.isEmpty()) {
                upsert listOfTransactionsToUpdate;
            }
            
            //Added by Siri:INVOICEIT-631:25-11-2015
            if(!listOfInvoicesToUpdate.isEmpty()){
                 Update listOfInvoicesToUpdate;
            }
        
            //Added by Siri:INVOICEIT-661
            BatchChargePaymentPlanInstallmentProcess.paymentRunRef = paymentRun;
            BatchChargePaymentPlanInstallmentProcess.paymentSchedulerRef = paymentScheduler;
            //Added by Lopa: INVOICEIT-644: 04-12-2015
            if(!Test.isRunningTest()){
                BatchChargePaymentPlanInstallmentProcess batchinstallmentObj = new BatchChargePaymentPlanInstallmentProcess(system.today());  
                Database.executeBatch(batchinstallmentObj,1);
            }

         }
    }