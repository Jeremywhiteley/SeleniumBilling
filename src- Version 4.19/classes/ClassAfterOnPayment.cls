public with sharing class ClassAfterOnPayment {
        /** If AUTOMATE_PAYMENT_ALLOCATION boolean is true then the Payament Allocation is done for invoice*/
        public static boolean PAYMENT_AFTER_PROCESSING_COMPLETE = false;

        public void setPaymentsAfterProcessingComplete() {
            PAYMENT_AFTER_PROCESSING_COMPLETE = true;
        }

        public Boolean getPaymentsAfterProcessingComplete() {
            return PAYMENT_AFTER_PROCESSING_COMPLETE;
        }

        public void handleAfterOnPayments(map<Id,Payment__c> newMap, map<Id,Payment__c> oldMap)
        {
            list<Payment_Allocation__c> listOfPaymentAllocations = new list<Payment_Allocation__c>();
            decimal un_AllocatedAmount = 0;
            Payment_Allocation__c pAllocation;

            boolean isPaymentAutomated = Configuration__c.getValues('AUTOMATE_PAYMENT_ALLOCATION').Boolean_Value__c; 
            
            if(trigger.isInsert) {
                // Added by Shruthi for INVOICEIT-394,Payment allocation are automatically created when the invoice is populated on Payment
                for(Payment__c payment : newMap.values()) {
                    if(payment.Transaction__c == null && payment.Invoice__c != null &&  payment.status__c == 'Completed') {
                        pAllocation = new Payment_Allocation__c(Invoice__c = payment.Invoice__c, Amount__c = payment.Amount__c, Payment__c = payment.Id);
                        listOfPaymentAllocations.add(pAllocation);
                    }
                }
                            
                if(isPaymentAutomated) {
                    for(Payment__c payment : newMap.Values()) {
                        if(payment.Transaction__c == null && payment.Invoice__c == null &&  payment.status__c == 'Completed') {        
                            list<Invoice__c> listOfInvoices = ControllerAllocatePayments.getInvoicesForPayment(payment);
                            un_AllocatedAmount = payment.Amount__c;
                            
                            for(Invoice__c invoice : listOfInvoices) {
                                if(un_AllocatedAmount >= invoice.Unpaid_Amount__c) {
                                    pAllocation = new Payment_Allocation__c(Invoice__c = invoice.Id, Amount__c = invoice.Unpaid_Amount__c, Payment__c = payment.Id);
                                    un_AllocatedAmount = un_AllocatedAmount - invoice.Unpaid_Amount__c;
                                    listOfPaymentAllocations.add(pAllocation);
                                } else {
                                    // below if condition is added by ram to avoid 0$ allocation, jira tkt INVOICEIT-439, date : jan 21,2015
                                    if(un_AllocatedAmount <= 0){
                                        break;
                                    }
                                    pAllocation = new Payment_Allocation__c(Invoice__c = invoice.Id, Amount__c = un_AllocatedAmount, Payment__c = payment.Id);
                                    un_AllocatedAmount = 0;
                                    listOfPaymentAllocations.add(pAllocation);
                                    //once the un_AllocatedAmount is 0 break the loop
                                    break;
                                }
                            }
                        }
                    }
                } 
                
                if(!listOfPaymentAllocations.isEmpty()) {
                    insert listOfPaymentAllocations;
                }
                
            } else if(Trigger.isUpdate) {
                set<Id> setOfPaymentIdsOfInterest = new set<Id>();
                list<Payment_Allocation__c> listOfPAllocationToUpdate;
                list<Refund__c> listOfRefundsToInsert = new list<Refund__c>();
                list<Refund_Line__c> listOfRefundLinesToInsert = new list<Refund_Line__c>();

                for(Payment__c newPayment : newMap.Values()) {
                    Payment__c oldPayment = oldMap.get(newPayment.Id);
                    //Added by DL for Payment Refund INVOICEIT-683
                    Refund__c refund;
                    Refund_Line__c refundLine;
                    if(newPayment.Status__c == CommonUtilClass.STATUS_CANCELLED && newPayment.Status__c != oldPayment.Status__c
                       ) {
                        setOfPaymentIdsOfInterest.add(newPayment.Id);
                        if(newPayment.Amount__c != newPayment.Refunded_Amount__c) {
                            refund = new Refund__c(Account__c = newPayment.Account__c, Currency__c = newPayment.Currency__c);
                            refundLine = new Refund_Line__c(Payment__c = newPayment.Id,Status__c='Completed',Refund_Amount__c = newPayment.Amount__c - newPayment.Refunded_Amount__c);
                            listOfRefundsToInsert.add(refund);
                            listOfRefundLinesToInsert.add(refundLine);
                        }
                    }
                }
                //Added by DL for Payment Refund INVOICEIT-683, inserting refund and refund lines
                if(!listOfRefundsToInsert.isEmpty()){
                    insert listOfRefundsToInsert;
                    for(integer i=0; i<listOfRefundsToInsert.size(); i++) {
                        listOfRefundLinesToInsert[i].Refund__c = listOfRefundsToInsert[i].Id;
                    }
                    insert listOfRefundLinesToInsert;
                }

                if(setOfPaymentIdsOfInterest.size() > 0) {
                    // Dev M INVOICEIT-213 Previously there was not where clause in the status, I have added Status__c =: CommonUtilClass.STATUS_COMPLETED
                    listOfPAllocationToUpdate = [SELECT Invoice__c
                                                 FROM Payment_Allocation__c
                                                 WHERE Payment__c IN : setOfPaymentIdsOfInterest
                                                 AND Status__c =: CommonUtilClass.STATUS_COMPLETED];

                    for(Payment_Allocation__c payAllocation : listOfPAllocationToUpdate) {
                        payAllocation.Status__c = CommonUtilClass.STATUS_CANCELLED;
                    }       

                    update listOfPAllocationToUpdate;
                }
            }
        }

        public void handleBeforeOnPayments(list<Payment__c> newPayments)
        { 
            if(UserInfo.isMultiCurrencyOrganization()) {
                map<Id,Currency__c> mapId_Currency;
                set<Id> setCurrencyId = new set<Id>();
                map<string,decimal> map_Payment_ConversionRate = new map<string,decimal>();
                map<Id, string> map_CurrId_CurrIsoCode = new map<Id, string>();
                date startDate;
                date nextStartDate;
                string isoCode;
                string paymentIsoCode;
                boolean isAdvanceCurrEnabled = true;

                // adding the currency Ids.
                for(Payment__c payment : newPayments) {
                    setCurrencyId.add(payment.Currency__c);
                }

                //adding the all currency names to list.
                for(Currency__c currencyObj : [SELECT Name FROM Currency__c WHERE Id IN:setCurrencyId]) {
                    map_CurrId_CurrIsoCode.put(currencyObj.Id, currencyObj.Name);
                }
                
                // converting the all ListOfStings Into String format 
                string sCurrencyIds = CommonUtilClass.convertListOfStingsIntoString(map_CurrId_CurrIsoCode.values()); 
                string sQuery =   'SELECT ISOCode, ConversionRate, StartDate, NextStartDate FROM DatedConversionRate '
                                   + ' WHERE ISOCode IN (' + sCurrencyIds  + ')';
                                   
                //when creating a dynamic SOQL statement,to help prevent SOQL injection. 
                sQuery = String.escapeSingleQuotes(sQuery);
                sQuery = sQuery.replace('\\',''); 
                
                // querying the DatedConversionRate(Multi currencyObj).
                list<sobject> sobjectDatedConversionRates = Database.query(sQuery);
                
                //if advance currency is not enabled, then query from the CurrencyType
                if(sobjectDatedConversionRates.isEmpty()) {
                    sQuery = 'SELECT ConversionRate,DecimalPlaces,Id,IsActive,IsCorporate,IsoCode FROM CurrencyType WHERE IsActive = true AND ISOCode IN (' + sCurrencyIds + ')';
                    sQuery = String.escapeSingleQuotes(sQuery);
                    sQuery = sQuery.replace('\\',''); 
                    sobjectDatedConversionRates = Database.query(sQuery);
                    isAdvanceCurrEnabled = false;
                }
                if(isAdvanceCurrEnabled) {
                    for(Payment__c payment : newPayments) {
                        for(sobject sobjectExchangeRate : sobjectDatedConversionRates) {
                            startDate = (date) sobjectExchangeRate.get('StartDate');
                            nextStartDate = (date) sobjectExchangeRate.get('NextStartDate');
                            isoCode = (string) sobjectExchangeRate.get('ISOCode');
                            
                            if(map_CurrId_CurrIsoCode.containsKey(payment.Currency__c)) {
                                paymentIsoCode = map_CurrId_CurrIsoCode.get(payment.Currency__c);
                                if(isoCode == paymentIsoCode 
                                    && startDate != null
                                    && nextStartDate != null
                                    && startDate <= system.today()
                                    && nextStartDate > system.today()) 
                                {
                                    payment.Exchange_Rate_Applied__c = (decimal) sobjectExchangeRate.get('ConversionRate');
                                    // To populate currencyisocode in multi currency org,related to invoiceIT-464
                                    CommonUtilClass.populateCurrencyIsoCodeOnSobject(payment, paymentIsoCode);
                                    break;
                                }
                            }
                        }
                    }  
                } else {
                    for(Payment__c payment : newPayments) {
                        for(sobject sobjectExchangeRate : sobjectDatedConversionRates) {
                            isoCode = (string) sobjectExchangeRate.get('ISOCode');
                            if(map_CurrId_CurrIsoCode.containsKey(payment.Currency__c)) {
                                paymentIsoCode = map_CurrId_CurrIsoCode.get(payment.Currency__c);
                                if(isoCode == paymentIsoCode) {
                                    payment.Exchange_Rate_Applied__c = (decimal) sobjectExchangeRate.get('ConversionRate');
                                    break;
                                }
                            }
                        }
                    }
                }  
            }                 
        }
    }