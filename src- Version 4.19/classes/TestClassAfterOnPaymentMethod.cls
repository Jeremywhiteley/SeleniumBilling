// This class contains unit tests for validating the behavior of ClassAfterOnPaymentMethod classes 
     //Created By Asish
     
    @isTest
    private class TestClassAfterOnPaymentMethod {

        static testMethod void testMethodForClassAfterOnPaymentMethod() {
            
            
            try{
                Account account = new Account(Name = 'Test Account');
                insert account;
                
                system.assert(account.Name == 'Test Account');
                Payment_Method__c paymethod = new Payment_Method__c();
                paymethod.Account__c = account.Id;
                paymethod.Default__c = false;
                insert paymethod;
                 
                Payment_Method__c newPaymethod = new Payment_Method__c();
                newPaymethod.Account__c = account.Id;
                newPaymethod.Default__c = false;
                insert newPaymethod;
                
                map<Id,Payment_Method__c> mapOfPaymethod = new map<Id,Payment_Method__c>();
                mapOfPaymethod.put(paymethod.id,paymethod);
                
                map<Id,Payment_Method__c> newMapOfPaymethod = new map<Id,Payment_Method__c>();
                newMapOfPaymethod.put(newPaymethod.id,newPaymethod);
                
                ClassAfterOnPaymentMethod clsObj = new ClassAfterOnPaymentMethod();
                clsObj.map_AccountId_PaymentMethod = mapOfPaymethod;
               
                ClassAfterOnPaymentMethod.PAYMENTMETHOD_AFTER_PROCESSING_COMPLETE = false;
                paymethod.Default__c = true;
                upsert paymethod;
                 
                
                
                List<Account> listOfAccounts = new List<Account>();
                set<id> setOfAccountIds = new set<id>();
                setOfAccountIds.add(newPaymethod.Account__c);
                listOfAccounts.add(account);
                
                list<Payment_Method__c> listOfPaymentMethods = new list<Payment_Method__c>();
                listOfPaymentMethods.add(paymethod);
                listOfPaymentMethods.add(newPaymethod);
                
                
                ClassAfterOnPaymentMethod.PAYMENTMETHOD_AFTER_PROCESSING_COMPLETE = false;
                newPaymethod.Default__c = true;
                upsert newPaymethod;
                
            }   
            catch(Exception Ex){
            
            }
           
            
        }
    }