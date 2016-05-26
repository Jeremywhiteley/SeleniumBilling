public with sharing class ClassAfterOnPaymentMethod {
            public static boolean PAYMENTMETHOD_AFTER_PROCESSING_COMPLETE = false;
            public map<Id,Payment_Method__c> map_AccountId_PaymentMethod;

            public void setPaymentMethodAfterProcessingComplete() {
                PAYMENTMETHOD_AFTER_PROCESSING_COMPLETE = true;
            }

            public Boolean getPaymentMethodAfterProcessingComplete() {
                return PAYMENTMETHOD_AFTER_PROCESSING_COMPLETE;
            }

            public void handleBeforeOnPaymentMethod(list<Payment_Method__c> listOfPaymentMethods, map<Id,Payment_Method__c> newMap, map<Id,Payment_Method__c> oldMap) {
                 map_AccountId_PaymentMethod = new map<Id,Payment_Method__c>();
                
                if(trigger.isInsert) {
                    for(Payment_Method__c paymentMethod : listOfPaymentMethods) {
                        if(paymentMethod.Default__c == true) {
                            map_AccountId_PaymentMethod.put(paymentMethod.Account__c, paymentMethod);
                        }
                    }
                }
                else if(trigger.isUpdate) {
                    for(Payment_Method__c newPaymentMethod : newMap.Values()) {
                        Payment_Method__c oldPaymentMethod = oldMap.get(newPaymentMethod.Id);
                        if(newPaymentMethod.Default__c != oldPaymentMethod.Default__c &&
                            newPaymentMethod.Default__c == true) 
                        {
                            map_AccountId_PaymentMethod.put(newPaymentMethod.Account__c, newPaymentMethod);
                        }
                    }
                }
                
                if(!map_AccountId_PaymentMethod.Keyset().isEmpty()) {
                    AggregateResult[] groupedResults = [SELECT Account__c, Count(Id) countOfDefaultPM
                                                        FROM Payment_Method__c 
                                                        WHERE Account__c IN : map_AccountId_PaymentMethod.Keyset()
                                                        AND 
                                                        Default__c = true
                                                        GROUP BY Account__c];
                    for(AggregateResult aggregateResult : groupedResults) {
                        Id accountId = (Id) aggregateResult.get(CommonUtilClass.getPrefix()+'Account__c');
                        Integer countOfDefaultPM = (Integer) aggregateResult.get('countOfDefaultPM');
                        if(countOfDefaultPM > 0) {
                            map_AccountId_PaymentMethod.get(accountId).addError(system.Label.DefaultPaymentMethod);
                        }
                    }
                }                               
            }
            
            public void handleAfterOnPaymentMethod(map<Id,Payment_Method__c> newMap, map<Id,Payment_Method__c> oldMap) {
                set<Id> setOfAccountIds = new set<Id>();
                list<Account> listOfAccountsToUpdate = new list<Account>();
                
                if(trigger.isInsert) {
                    for(Payment_Method__c paymentMethod : newMap.Values()) {
                        //In insert mode we are only intrested if (default = true)
                        if(paymentMethod.Default__c == true) {
                            setOfAccountIds.add(paymentMethod.Account__c);
                        }
                    }
                }
                else if(trigger.isUpdate) {
                    //if it is changed and default is true then query and update the account(one more thing is i feel we does need to query also directly we can update the account paymentmethod field with paymentMethod id)
                    //if it is changed and default is not true update the account payment method will null value
                    for(Payment_Method__c newPaymentMethod : newMap.Values()) {
                        Payment_Method__c oldPaymentMethod = oldMap.get(newPaymentMethod.Id);
                        if(newPaymentMethod.Default__c != oldPaymentMethod.Default__c) 
                        {
                            if(newPaymentMethod.Default__c) 
                            {
                                setOfAccountIds.add(newPaymentMethod.Account__c);
                                //listOfAccountsToUpdate.add(new Account(Id = newPaymentMethod.Account__c, Payment_Method__c = newPaymentMethod.Id));
                            }
                            else 
                            {
                                listOfAccountsToUpdate.add(new Account(Id = newPaymentMethod.Account__c, Payment_Method__c = null));
                            }
                        }
                    }
                }
                
                //i feel we do not require line no from 84 to 95.Why because we can just uncomment the line 73 and comment 72
                if(!setOfAccountIds.isEmpty()) {
                    list<Payment_Method__c> listOfPaymentMethods = [SELECT Default__c, Account__c
                                                                    FROM Payment_Method__c
                                                                    WHERE Account__c In: setOfAccountIds
                                                                    AND
                                                                    Default__c = true];
                    Account account;                                                
                    for(Payment_Method__c paymentMethod : listOfPaymentMethods) {
                        account = new Account(Id = paymentMethod.Account__c, Payment_Method__c = paymentMethod.Id);
                        listOfAccountsToUpdate.add(account);
                    }                                               
                }
                
                if(!listOfAccountsToUpdate.isEmpty()) {
                    update listOfAccountsToUpdate;
                }
            }
        }