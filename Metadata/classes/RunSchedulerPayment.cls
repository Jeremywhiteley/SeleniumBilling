global with sharing class RunSchedulerPayment implements Schedulable {
        global void execute(SchedulableContext context) {
            String cronId = context.getTriggerId();
            
            if(cronId.Length() == 18) {
                cronId = cronId.substring(0,cronId.length()-3);
            } 
            
            Payment_Scheduler__c paymentScheduler = [SELECT Type__c, Name, Start_date_and_time__c, Currency__c, Payment_Options__c, Payment_Batch__c
                                                     FROM Payment_Scheduler__c 
                                                     WHERE JobId__c =: cronId];
            
            string todaysDate = '' + system.today();
            todaysDate = todaysDate.replace(' 00:00:00', '');

            //Added by Siri related to INVOICEIT-631 on 25-11-2015
            Decimal noOfMaximumRetries = Configuration__c.getValues('PAYMENT_NO_OF_RETRIES').Number_Value__c;
            if(noOfMaximumRetries == null){
              noOfMaximumRetries = 0; 
            }

            // modified by ram 27- 5-2013 jira-INVOICEIT-184, dded the where condition Invoice_State is not equals to proforma.

            // Added Order__r.Payment_Plan__c = null for INVOICEIT-630, by DL, we are not charging the payment plan invoices here AND condition added by Siri and "Last_Processing_Date__c, No_of_tries__c" fields in query for INVOICEIT-631 on 25-11-2015

            String query = 'SELECT Id, Name,Last_Processing_Date__c, No_of_tries__c From Invoice__c WHERE Invoice_Status__c = \'' + CommonUtilClass.STATUS_POSTED + '\''
                           + ' AND CurrencyL__c = \'' + paymentScheduler.Currency__c + '\''
                           + ' AND Invoice_State__c != \'' + CommonUtilClass.STATUS_PROFORMA + '\''
                           + ' AND Account__r.Payment_Method__c != null'
                           + ' AND Unpaid_Amount__c > 0 '
                           + ' AND Order__r.Payment_Plan__c = null '
                           + ' AND No_of_tries__c < '+noOfMaximumRetries;
            
            // modified by Laxman Rao M, jira-INVOICEIT-376, call the batch class only if the Payment_Options field is not null

            if(paymentScheduler.Payment_Options__c != null) {
                query = query + ' AND (';
                for(string option : paymentScheduler.Payment_Options__c.split(';') ) {
                    query = query + ' Account__r.Payment_Method__r.Payment_Method__c =\'' + option + '\' OR';
                }
                query = query.substring(0, query.length()-2);
                query = query + ' )';
                
                //Modified by Laxman 10 may 2013 Jira - INVOICEIT-171, If INVOICE_TO_BE_CHARGED_ON is due date then query by due date else if it is invoice date then query by inoice date

                string invoicedToBeChargedOn = Configuration__c.getValues('INVOICE_TO_BE_CHARGED_ON').String_Value__c;             
                if(invoicedToBeChargedOn != null && invoicedToBeChargedOn == CommonUtilClass.INVOICE_DATE) {
                    query += ' AND Invoice_Date__c <= ' + todaysDate;   
                }
                else if(invoicedToBeChargedOn != null && invoicedToBeChargedOn == CommonUtilClass.PREFERRED_PAYMENT_DATE){
                    query += ' AND Preferred_Payment_Date__c <= ' + todaysDate;
                }
                else {
                    query += ' AND Due_Date__c <= ' + todaysDate;
                }
                //Added by dhanalakshmi for INVOICEIT-612 to filter the invoices based on payment batch type
                if(paymentScheduler.Payment_Batch__c != null) {
                    query += ' AND Payment_Batch__c  = \'' + paymentScheduler.Payment_Batch__c + '\'';
                } else {
                    query += ' AND Payment_Batch__c  = ' + paymentScheduler.Payment_Batch__c + '';
                }          
        
                ID batchprocessid = Database.executeBatch(new BatchTransactions(query, paymentScheduler), 1);
            }
        }
    }