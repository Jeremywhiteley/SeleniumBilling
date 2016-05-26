global class BatchChargePaymentPlanInstallmentProcess implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {
        
    String query;
    global String errorLog = '';
    global Batch_Jobs__c batchJobsObj;
    global list<Payment_Plan_Installment__c> listOfPaymentInstalmentsToUpdate;
    global Decimal nofOfDaysBetweenRetries;
    global Decimal noOfMaxRetries;
    global Decimal noOfMaxDaysBetweenRetries;
    global list<Payment__c> listOfPayments;
    global date processDate;
    Public Payment_Run__c paymentRun;
    Public Static Payment_Run__c paymentRunRef;
    Public Payment_Scheduler__c paymentScheduler;
    Public Static Payment_Scheduler__c paymentSchedulerRef;
    Public integer noOfInvoicesProcessed = 0;
    Public integer noOfSuccesfullTransaction = 0;
    Public integer noOfFailedTransaction = 0;
    Public decimal totalTransactionsValue = 0.0; 
    
    global BatchChargePaymentPlanInstallmentProcess(date processDate) {
         this.processDate = processDate;
         listOfPayments = new list<Payment__c>();
         listOfPaymentInstalmentsToUpdate = new list<Payment_Plan_Installment__c>();
         noOfMaxRetries = Configuration__c.getValues('PAYMENT_NO_OF_RETRIES').Number_Value__c;
         noOfMaxDaysBetweenRetries = Configuration__c.getValues('PAYMENT_NO_OF_DAYS_BETWEEN_RETRIES').Number_Value__c;
         nofOfDaysBetweenRetries = 0;
         //Added by Siri:INVOICEIT-661:06-01-2016
         paymentRun = new Payment_Run__c();
         paymentRun = paymentRunRef;
         paymentScheduler = new Payment_Scheduler__c();
         paymentScheduler = paymentSchedulerRef;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        batchJobsObj = new Batch_Jobs__c(name = DateTime.now().format('yyyy-MM-dd'),Start_Date_and_Time__c = system.now(),Status__c = 'Started',Type__c = 'BatchCharge PaymentPlanInstallment Process');
        insert batchJobsObj;
        if(noOfMaxRetries == null){
          noOfMaxRetries = 0; 
        }
        //Below query-modified by Dev M: INVOICEIT-661
        list<String> listofPaymentOptions = paymentScheduler.Payment_Options__c.split(';');
        return Database.getQueryLocator([SELECT Name,Description__c, Last_Processing_Date__c,
                                       Order__c,Payment_Date__c,Account__c,Account__r.Gateway__c,
                                       Payment_Method__c,Invoice__c,Payment__c,Invoice__r.CurrencyL__c,
                                       Payment_Amount__c,Payment_Type__c,Order__r.Account__c,No_of_tries__c,
                                       Payment_Method__r.Card_Expiration_Month__c,Payment_Method__r.Card_Expiration_Year__c,Payment_Method__r.Payment_Method__c,
                                       Payment_Method__r.Card_Type__c,Payment_Method__r.Card_Number__c,Transaction__c
                                       FROM Payment_Plan_Installment__c
                                       Where Invoice__c != null AND Payment_Date__c <=: processDate
                                       AND Payment_Method__c != null
                                       AND ( Payment__c = null 
                                        OR Payment_Status__c != 'Completed' )
                                       AND Invoice__r.Invoice_Status__c = 'Posted'
                                       AND No_of_tries__c < :noOfMaxRetries
                                       
                                       
                                       ]);
                                    
    }

    //Please mention batch size always 1, 
    global void execute(Database.BatchableContext BC, List<Payment_Plan_Installment__c> scope) {
        for(Payment_Plan_Installment__c paymentPlanInstalments : scope){
          //Added by Siri: INVOICEIT-661
          ++noOfInvoicesProcessed;
          PaymentSiteOperation.GenericPaymentResult result; 
          Payment_Plan_Installment__c paymentPlanInstalment;
          Decimal noOfTries = 0;
          Date lastProcessingDate = paymentPlanInstalments.Last_Processing_Date__c;
          if(paymentPlanInstalments.Last_Processing_Date__c != null){
            nofOfDaysBetweenRetries = lastProcessingDate.daysBetween(date.today());
          }
          if(paymentPlanInstalments.No_of_tries__c != null){
            noOfTries = paymentPlanInstalments.No_of_tries__c;
          }
          if(noOfMaxDaysBetweenRetries == null){
            noOfMaxDaysBetweenRetries = 0;
          }
          //Added by Dev M: INVOICEIT-661
          Boolean transactionfailed = false;
          try{
              Payment__c paymentObj;
              
              if(nofOfDaysBetweenRetries >= noOfMaxDaysBetweenRetries || lastProcessingDate == null){
                result = PaymentOperations.authorizeAndChargePaymentPlanInstalments(paymentPlanInstalments.Invoice__c, paymentPlanInstalments.Payment_Method__c, paymentPlanInstalments.Payment_Amount__c);
                if(result != null && result.transactionObj != null ) {
                  Transaction__c transactionToInsert = result.transactionObj;
                  if(transactionToInsert.Payment_Method__c == null){
                      transactionToInsert.Payment_Method__c = paymentPlanInstalments.Payment_Method__c;
                  }
                  //Added by JOSHITHA 02-12-2015: INVOICEIT-650
                  if(transactionToInsert.Payment_Plan_Installment__c == null){
                      transactionToInsert.Payment_Plan_Installment__c = paymentPlanInstalments.Id;
                  }
                  //Added by Dev M: INVOICEIT-661
                  transactionToInsert.Payment_Run__c = paymentRun.Id;
                  insert transactionToInsert;
                  paymentPlanInstalments.Transaction__c = transactionToInsert.Id;

                  if(result.transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                    //Added by Siri INVOICEIT-661 06-01-16
                    ++noOfSuccesfullTransaction;
                    totalTransactionsValue = totalTransactionsValue + result.transactionObj.Amount__c;

                    paymentObj = new Payment__c(Account__c = paymentPlanInstalments.Account__c, 
                                              Amount__c = result.transactionObj.Amount__c, 
                                              Status__c = CommonUtilClass.STATUS_COMPLETED, 
                                              Payment_Type__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD,
                                              Payment_Date__c = system.today(),
                                              Transaction__c = transactionToInsert.Id,
                                              Currency__c = paymentPlanInstalments.Invoice__r.CurrencyL__c
                                              );
                    
                   
                    if(paymentPlanInstalments.Invoice__c != null) {
                        
                        Invoice__c invoice = [SELECT Invoice_Status__c, Unpaid_Amount__c FROM Invoice__c WHERE Id =: paymentPlanInstalments.Invoice__c];
                        

                        if(invoice.Invoice_Status__c == CommonUtilClass.STATUS_POSTED)
                          paymentObj.Invoice__c = paymentPlanInstalments.Invoice__c;


                        insert paymentObj;
                        // if the unpaid amount is less then allocate total amount less what ever is pending
                        
                        if(invoice.Invoice_Status__c == CommonUtilClass.STATUS_POSTED && invoice.Unpaid_Amount__c > 0) {
                           Payment_Allocation__c paymentAllocation;
                          if(paymentObj.Amount__c <= invoice.Unpaid_Amount__c) {
                             paymentAllocation = new Payment_Allocation__c(Payment__c = paymentObj.Id,
                                                                            Amount__c = paymentObj.Amount__c,
                                                                            Invoice__c = paymentPlanInstalments.Invoice__c,
                                                                            Status__c = CommonUtilClass.STATUS_COMPLETED);   
                            } else {
                             paymentAllocation = new Payment_Allocation__c(Payment__c = paymentObj.Id,
                                                                            Amount__c = invoice.Unpaid_Amount__c,
                                                                            Invoice__c = paymentPlanInstalments.Invoice__c,
                                                                            Status__c = CommonUtilClass.STATUS_COMPLETED); 
                            }
                            insert paymentAllocation;
                          }
                    } else {
                      insert paymentObj;
                    }

                  }else{
                      //Added by Siri: INVOICEIT-661 
                      if(!transactionfailed) {
                        ++noOfFailedTransaction;
                        transactionfailed = true;
                      }
                      CommonUtilClass.createFailedtransactionForPaymentPlan(paymentPlanInstalments, paymentRun.Id, result.message);
                  }
                  paymentPlanInstalments.Last_Processing_Date__c = system.today();
                  paymentPlanInstalments.No_of_tries__c = ++noOfTries;
                  if(paymentObj != null){
                    paymentPlanInstalments.Payment__c = paymentObj.Id;
                  }
                  

                  update paymentPlanInstalments;
                }else{
                  //Else block-added by Siri: INVOICEIT-661
                  if(!transactionfailed) {
                    ++noOfFailedTransaction;
                    transactionfailed = true;
                  }
                  CommonUtilClass.createFailedtransactionForPaymentPlan(paymentPlanInstalments, paymentRun.Id, result.message);
                  errorLog += result.message+ '\n';
                  errorLog += ' PaymentPlanInstalment Id : ' + paymentPlanInstalments.Id + '\n';
                  errorLog += ' PaymentPlanInstalment Name : ' + paymentPlanInstalments.Name + '\n';
                }
              }
            }catch(Exception ex){
              //Added by Siri related to INVOICEIT-661
              if(!transactionfailed) {
                  ++noOfFailedTransaction;
                  transactionfailed = true;
                }
              CommonUtilClass.createFailedtransactionForPaymentPlan(paymentPlanInstalments, paymentRun.Id, ex.getTypeName() + ':' + ex.getMessage() + ':'  + ex.getLineNumber());
              errorLog +=  ex.getTypeName() + ':' + ex.getMessage() + ':'  + ex.getLineNumber() + ':' + ex.getStackTraceString() + '\n';
              errorLog += ' PaymentPlanInstalment Id : ' + paymentPlanInstalments.Id + '\n';
              errorLog += ' PaymentPlanInstalment Name : ' + paymentPlanInstalments.Name + '\n';
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        batchJobsObj.Completed_Date_and_Time__c = system.now();
        batchJobsObj.Status__c = CommonUtilClass.STATUS_COMPLETED;
        if(errorLog != '') {
          //Added by Dev M :INVOICEIT-661
          paymentRun.Status__c = CommonUtilClass.STATUS_COMPLETED_WITH_ERRORS; 
          paymentRun.Exception_Log__c = errorLog;

          batchJobsObj.Status__c = CommonUtilClass.STATUS_COMPLETED_WITH_ERRORS;
          // the maximum size of Long Text Area is 32768. If error log is more than this then create the attachment with error log 
          if(errorLog.Length() < 32768) {
              batchJobsObj.Exception_Log__c = errorLog; 
          } else {
              Attachment attachment = new Attachment(Body = Blob.valueOf(errorLog), Name = 'ErrorLog.txt', ParentId = batchJobsObj.Id );
              insert attachment;  
              batchJobsObj.Exception_Log__c = 'Error log is attached as an attachment, you can find the attachment in releated list';
          }
        }else{
            paymentRun.Status__c = CommonUtilClass.STATUS_COMPLETED; 
        }
        //Below added by Siri :INVOICEIT-661
        paymentRun.Completed_Time__c = system.now();
        paymentRun.Invoices_Processed__c = paymentRun.Invoices_Processed__c + noOfInvoicesProcessed;
        paymentRun.Successful_Transactions__c = paymentRun.Successful_Transactions__c + noOfSuccesfullTransaction;
        paymentRun.Failed_Transactions__c = paymentRun.Failed_Transactions__c + noOfFailedTransaction;
        paymentRun.Total_Payment_Value__c = paymentRun.Total_Payment_Value__c + totalTransactionsValue;

        upsert paymentRun;
        update batchJobsObj;
    }    
  }