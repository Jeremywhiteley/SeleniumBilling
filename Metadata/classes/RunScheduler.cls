global class RunScheduler implements Schedulable {

        global void execute(SchedulableContext context) {
            //The context.getTriggerId returns the 18 char salesforce id
            //We have stored the 15 char id in Invoice_RunScheduler__c object
            //Truncate the last 3 characters and use them in the query

            String cronId = context.getTriggerId();
            
            if(cronId.Length() == 18) {
                cronId = cronId.substring(0,cronId.length()-3);
            } 
            
            Invoice_RunScheduler__c invoiceRunScheduler = [SELECT Type__c, Target_Date__c, Start_Date__c, Name, 
                                                           Minutes__c, JobId__c, IsDeleted, Invoice_Date__c, 
                                                           Id, Hours__c, Frequency__c ,Invoice_Day_of_week__c,
                                                           Invoice_Day_Of_Month__c,Target_Day_of_week__c,
                                                           Target_Day_Of_Month__c,Invoice_Currency__c,
                                                           Automatically_Post_Invoices__c, Invoice_Batch__c
                                                           FROM Invoice_RunScheduler__c 
                                                           WHERE JobId__c = : cronId];
            
            Date invoiceDate, targetDate;
            Date todaysDate = system.today();        
            String sInvoiceRunSchedulerType = invoiceRunScheduler.Type__c;

            if(sInvoiceRunSchedulerType == System.Label.OptionOnce) {
                invoiceDate = invoiceRunScheduler.Invoice_Date__c;
                targetDate = invoiceRunScheduler.Target_Date__c;
            } else if(sInvoiceRunSchedulerType == System.Label.OptionDaily) {
                invoiceDate = system.today();
                targetDate = system.today();
            } else if(sInvoiceRunSchedulerType == System.Label.OptionWeekly) {
                //assume the scheduler starts on monday and runs every monday
                Integer invoice_dayofweek = Integer.ValueOf(invoiceRunScheduler.Invoice_Day_of_week__c);//tuesday
                Integer target_dayofweek = Integer.ValueOf(invoiceRunScheduler.Target_Day_of_week__c);//saturday

                //what is the day of the week of system.today() = 2
                Date weekStart = todaysDate.toStartofWeek();
                Integer dayOfWeek = weekStart.daysBetween(todaysDate);
                dayOfWeek = dayOfWeek + 2;

                invoiceDate = todaysDate.addDays(invoice_dayofweek - dayOfWeek); //add 1 day so invoice day is on tuesday
                targetDate = todaysDate.addDays(target_dayofweek - dayOfWeek); //add 5 days so invoice day is on saturday
            } else if(sInvoiceRunSchedulerType == System.Label.OptionMonthly) {
                Integer invoice_dayofmonth = Integer.ValueOf(invoiceRunScheduler.Invoice_Day_Of_Month__c);
                Integer target_dayofmonth = Integer.ValueOf(invoiceRunScheduler.Target_Day_Of_Month__c);

                //Check if these days are greater than the last day of the running month. If yes reset these days to last day of the month
                //If the invoice_dayofmonth is 31 and the scheduler is running on 29th, the value will be reset to 29
                Integer daysInMonth = date.daysInMonth(todaysDate.year(), todaysDate.month());
                if(invoice_dayofmonth > daysInMonth) {
                    invoice_dayofmonth = daysInMonth;
                }
                if(target_dayofmonth > daysInMonth) {
                    target_dayofmonth = daysInMonth;
                }

                invoiceDate = date.newinstance(todaysDate.year(), todaysDate.month(), invoice_dayofmonth);
                targetDate = date.newinstance(todaysDate.year(), todaysDate.month(), target_dayofmonth);
            }

            String orderStatusForInvoicing = (Configuration__c.getValues('ORDER_STATUS_FOR_INVOICING').String_Value__c);
            String groupBy = (Configuration__c.getValues('INVOICE_GROUP_CRITERIA').String_Value__c);
            
            /*//Lets the customer decide what would be the batch size for processing invoices
            
           */
            
            // Ref : INVOICEIT-252, Modified by : Laxman Rao M
            // Previously we were giving the option for the customer to decide what is the size of batch
            // but now we are processing only one Order at a time, if their is any exception we will rollback the all the dml operations like roll back Invoice Lines, Invoice, Order charges, Usage Charges etc
            Integer batchSize = 1;
            
            String query;

            String targetDateString = targetDate.year() + '-';
            if(targetDate.month() < 10) {
                targetDateString += '0' + targetDate.month() + '-'; 
            } else {
                targetDateString += targetDate.month() + '-';
            }
            if(targetDate.day() < 10) {
                targetDateString += '0' + targetDate.day();
            } else {
                targetDateString += targetDate.day();
            }

            //Depending upon the grouping parameter pass the accountids or the jobids
            if(groupBy == CommonUtilClass.INVOICING_GROUP_BY_ACCOUNT) 
            {
                query = 'SELECT Account__c, Partner__c, Payment_Plan__c, Billing_Contact__r.AccountId, Id FROM Job__c'; 
            } else {
                query = 'SELECT Id,Payment_Plan__c FROM Job__c'; 
            }

            query +=    ' WHERE Account__c != null' +
                        ' AND Is_Billing_Master_Order__c = false' +
                        ' AND Service_Activation_Date__c <= '+ targetDateString +
                        ' AND(Charges_without_a_Charge_Date__c > 0' +  
                        ' OR Minimum_Next_Charge_Date_For_Product__c <= '+ targetDateString+')'; 
                        
            //If the order's status field for invoicing is mentioned then use that in the where clause 
            if(orderStatusForInvoicing != null && orderStatusForInvoicing.trim().length() > 0) {
                query += ' AND Status__c = \'' + orderStatusForInvoicing + '\'';
            }
            
            query += ' AND CurrencyL__c = \'' + invoiceRunScheduler.Invoice_Currency__c + '\'';
            
            //Added by dhanalakshmi for INVOICEIT-615 to filter the invoices based on invoice batch type
            if(invoiceRunScheduler.Invoice_Batch__c != null){
               query += ' AND Invoice_Batch__c = \'' + invoiceRunScheduler.Invoice_Batch__c+ '\''; 
            }else{
                 query += ' AND Invoice_Batch__c = ' + invoiceRunScheduler.Invoice_Batch__c+ ''; 
            }
            

            BatchInvoiceGeneration1 batch = new BatchInvoiceGeneration1(query, 
                                                                        groupBy, 
                                                                        invoicedate, 
                                                                        targetdate,
                                                                        invoiceRunScheduler.Invoice_Currency__c,
                                                                        invoiceRunScheduler.Name,
                                                                        invoiceRunScheduler.Id);
                                                                        
            ID batchprocessid = Database.executeBatch(batch,batchSize);
            
        } 
        
    }