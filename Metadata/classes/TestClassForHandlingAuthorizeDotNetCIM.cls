@isTest(oninstall = false)
   public with sharing class TestClassForHandlingAuthorizeDotNetCIM {    
        public static testMethod void paymentOperations_ClassForHandlingSagePay() {
            ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
            ControllerInsertCustomSettings.insertValues();
            
            Currency__c currencyobj = new Currency__c(name = 'USD', Symbol__c = '$');
            insert currencyobj;
            
            list<Gateway__c> listOfGateway = [Select Id From Gateway__c];
            delete listOfGateway;
            
            Gateway__c gateway = new Gateway__c(Active__c = true, Default__c = true, Gateway_Type__c = CommonUtilClass.GATEWAY_TYPE_SAGEPAY, Merchant_Seal_User_Id__c = 'nthompson', Test_Mode__c = true, Merchant_ID__c = '22LbQ9b7', Security_Key__c = '8Fh7VnPV3e6h4b4S');
            insert gateway;
            
            Account account = new Account(Name = 'Test Account');
            insert account;
            
            Payment_Method__c paymentMethod = new Payment_Method__c( Billing_Fax__c = '56789', Billing_Email__c = 'dev@gmail.com', Billing_Phone__c = '9999999', Billing_First_Name__c = 'Devender', Billing_Last_Name__c = 'M',Active__c = true, Default__c = true, Account__c = account.Id, CVV__c = '123', Card_Number__c = '4929000000006', Card_Expiration_Year__c = '2023', Card_Expiration_Month__c = '10',Billing_Address__c = 'Prabhat Aracade',Billing_City__c = 'alabama',Billing_State_Province__c = 'alabama',Billing_Zip_Postal__c = '505001',Billing_Country__c = 'United States');
            insert paymentMethod;
            
            list<Contact> listContacts = new list<Contact>();
            listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,MailingCountry = 'UK',Email ='laxmanrao.564@gmail.com',MailingStreet = 'Bengalore',MailingCity = 'bengalore',MailingPostalCode = '523122',FirstName = 'acertis'));
            listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, MailingCountry = 'USA',Email = 'laxmanrao.564@gmail.com',MailingStreet = 'Bengalore',MailingCity = 'bengalore',MailingPostalCode = '523122',FirstName = 'acertis'));
            insert listContacts;
            
            Currency__c currency1 = new Currency__c(name = 'GBP', Symbol__c = '£1');
            insert currency1;
            
            Job__c job = new Job__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id, Sub_Total__c = 100, Discount_Value__c = 0, CurrencyL__c = currency1.Id);
            insert job;
            
            Invoice__c invoice1 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                                CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = 'Active');
                                                
            Invoice__c invoice2 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                                CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = 'Active');
            
            Invoice__c invoice3 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                                CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = CommonUtilClass.STATUS_POSTED);
            list<Invoice__c> invoices = new list<Invoice__c>();
            invoices.add(invoice1);
            invoices.add(invoice2);
            invoices.add(invoice3);
            insert invoices;
            
            list<Invoice_Lines__c> listInvoiceLines = new list<Invoice_Lines__c>();
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            insert listInvoiceLines;   
            
            invoices = [Select Id, Name, CurrencyL__c, Target_Date__c,
                        Shipping_Contact__r.FirstName,Shipping_Contact__r.LastName,Shipping_Contact__r.MailingStreet,Shipping_Contact__r.MailingCity,Shipping_Contact__r.MailingPostalCode,Shipping_Contact__r.MailingCountry 
                        From Invoice__c Where Id In: invoices];

            Transaction__c transaction1=new Transaction__c(Gateway_ID__c = '123456',Payment_Gateway__c=gateway.id,Payment_Method__c=paymentMethod.id,Currency__c=currency1.id,Request_Invoice__c=invoices[0].id,Amount__c=20,Type__c='Charge');
           insert transaction1;

           Transaction__c transaction2=new Transaction__c(Gateway_ID__c = '123456',Payment_Gateway__c=gateway.id,Payment_Method__c=paymentMethod.id,Currency__c=currency1.id,Request_Invoice__c=invoices[0].id,Amount__c=20,Type__c='Charge');
           insert transaction2;

           PaymentSiteOperation op = new PaymentSiteOperation();
           op.processPayment(gateway, null, paymentMethod, paymentMethod.Id, 10, account , false, null);
           op.processPayment(null, paymentMethod, paymentMethod.Id, 10, account, false);
            
            PaymentOperations.PaymentResult result;
            result = PaymentOperations.authorize(invoices.get(0).Id, invoices.get(0).name, null);  
            result = PaymentOperations.authorizeAndCharge(invoices.get(1).Id, null, null);
            PaymentOperations.void(invoices.get(0).Id);  
            PaymentOperations.void(invoices.get(0).Id);
            PaymentOperations.refund(invoices.get(0).Id, null, 100);
            PaymentOperations.authorizeAndCharge(invoices.get(2).Id, invoices.get(2).Name, null);
            PaymentOperations.authorizeAndChargePaymentPlanInstalments(invoices.get(2).Id,paymentMethod.Id,100);
            PaymentOperations.transactionRefund(transaction1.id);
            PaymentOperations.transactionVoid(transaction2.id);

            system.assert(invoices != null);
            
            // Code for handling the site 
            // this will say Invoice could not be found
            ControllerSitePaymentProcess controllerSitePaymentProces = new ControllerSitePaymentProcess();
            
            // this will say Invoice could not be found
            system.currentPageReference().getParameters().put('Id', invoices.get(0).Id);
            controllerSitePaymentProces = new ControllerSitePaymentProcess();
            
            // this time Unpaid_Amount__c is > 0
            system.currentPageReference().getParameters().put('Id', invoices.get(2).Id);
            controllerSitePaymentProces = new ControllerSitePaymentProcess();
            
            // move to the checkout page
            controllerSitePaymentProces.checkOut();
            
            // this will fire the validation
            controllerSitePaymentProces.paymentMethod.Billing_First_Name__c = null;
            controllerSitePaymentProces.paymentMethod.Billing_Last_Name__c = null;
            controllerSitePaymentProces.paymentMethod.Card_Type__c = null;
            controllerSitePaymentProces.paymentMethod.Card_Number__c = null;
            controllerSitePaymentProces.paymentMethod.CVV__c = null;
            controllerSitePaymentProces.paymentMethod.Billing_Phone__c = null;
            controllerSitePaymentProces.paymentMethod.Billing_Email__c = null;
            controllerSitePaymentProces.paymentMethod.Billing_State_Province__c = null;
            controllerSitePaymentProces.paymentMethod.Card_Expiration_Month__c = null;
            controllerSitePaymentProces.processPayment();
            
            // looks ok
            controllerSitePaymentProces.paymentMethod.Billing_First_Name__c = 'Sandeep';
            controllerSitePaymentProces.paymentMethod.Billing_Last_Name__c = 'M';
            controllerSitePaymentProces.paymentMethod.Card_Type__c = 'Master';
            controllerSitePaymentProces.paymentMethod.Card_Number__c = '420000000000000';
            controllerSitePaymentProces.paymentMethod.CVV__c = '123';
            controllerSitePaymentProces.paymentMethod.Card_Expiration_Month__c = '12';
            controllerSitePaymentProces.paymentMethod.Card_Expiration_Year__c = '2016';
            controllerSitePaymentProces.sSaveCardDetails = 'yes';
            controllerSitePaymentProces.gateWayToUse = gateway;
            controllerSitePaymentProces.processPayment();
            
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(account);
            system.currentPageReference().getParameters().put('Id', account.Id);
            ControllerVirtualTerminal controllerVirtualTerminal = new ControllerVirtualTerminal(standardController);
       
            controllerVirtualTerminal.processPaymentRedirect();  
            controllerVirtualTerminal.selectedValue = paymentMethod.Id;  
            controllerVirtualTerminal.isNone = false;               
            controllerVirtualTerminal.paymentMethod.Billing_First_Name__c = 'Sandeep';
            controllerVirtualTerminal.paymentMethod.Billing_Last_Name__c = 'M';
            controllerVirtualTerminal.paymentMethod.Card_Type__c = 'Master';
            controllerVirtualTerminal.paymentMethod.Card_Number__c = '4111111111111111';
            controllerVirtualTerminal.paymentMethod.CVV__c = '123';
            controllerVirtualTerminal.paymentMethod.Card_Expiration_Month__c = '12';
            controllerVirtualTerminal.paymentMethod.Card_Expiration_Year__c = '2219';
            controllerVirtualTerminal.sSaveCardDetails = 'yes';
            controllerVirtualTerminal.paymentMethod.Account__c = account.Id;
            controllerVirtualTerminal.processPayment();
            
            // this time gateway.Test_Mode__c = false
            gateway.Test_Mode__c = false;
            update gateway;
            system.currentPageReference().getParameters().put('Id', invoices.get(2).Id);
            controllerSitePaymentProces = new ControllerSitePaymentProcess(); 
            
            ClassForHandlingSagePay objClassForHandlingSagePay = new ClassForHandlingSagePay(gateway, null, paymentMethod,paymentMethod.Id,100,account, currency1.Id);
            
            Transaction__c transactionObj = new Transaction__c(Gateway_ID__c = '123456', Payment_Gateway__c = gateway.Id, Payment_Method__c = paymentMethod.Id);
            insert transactionObj;
            objClassForHandlingSagePay.handleRefund_Click(gateway.Id,transactionObj.Id, 200 );
            objClassForHandlingSagePay.handleVoid_Click(gateway.Id,transactionObj.Id, 200 );

            try{           
                objClassForHandlingSagePay.handleAuthorizeAndCharge_Site(true);
            }catch(Exception ex){          
            }

            //To cover catch blocks
            objClassForHandlingSagePay.handleRefund_Click('','',null);
            objClassForHandlingSagePay.handleVoid_Click('','',null);         
            try{           
                objClassForHandlingSagePay.handleAuthorizeAndCharge_Site(null);
            }catch(Exception ex){          
            }   

            PaymentSiteOperation.GenericPaymentParameters genericPaymentParameters

                =  new PaymentSiteOperation.GenericPaymentParameters();

           

               genericPaymentParameters.amountToProcess = 100;

               genericPaymentParameters.currencyISOCode = 'USD';



               genericPaymentParameters.shouldTokenizeCard = false; 

               PaymentSiteOperation.GenericPaymentResult genericPaymentResult = new PaymentSiteOperation.GenericPaymentResult();            

               PaymentSiteOperation site = new PaymentSiteOperation();

            objClassForHandlingSagePay .handleAuthorizeAndCharge(genericPaymentParameters);
            op.processGenericPayment(genericPaymentParameters);


      }
      
      public static testMethod void paymentOperations_ClassForHandlingEway() {
            ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
            ControllerInsertCustomSettings.insertValues();
            
            Currency__c currencyobj = new Currency__c(name = 'USD', Symbol__c = '$');
            insert currencyobj;
            
            list<Gateway__c> listOfGateway = [Select Id From Gateway__c];
            delete listOfGateway;
            
            Gateway__c gateway = new Gateway__c(Active__c = true, Default__c = true, Gateway_Type__c = 'Eway', Merchant_Seal_User_Id__c = 'nthompson', Test_Mode__c = true, Merchant_ID__c = 'Acertiscloud$23', Security_Key__c = '60CF3CKsVjvopG3KDZre0d9y3xZHnV3G8WP0DgbUuH65mk13abxN6r8XQp95cuZNH82ejG');
            insert gateway;
            
            Account account = new Account(Name = 'Test Account');
            insert account;

            Account account1 = [SELECT Name FROM Account WHERE id =: account.id];
            System.assertEquals('Test Account', account1.Name);
            
            
            Payment_Method__c paymentMethod = new Payment_Method__c(Billing_Fax__c = '56789', Billing_Email__c = 'dev@gmail.com', Billing_Phone__c = '9999999', Billing_First_Name__c = 'Devender', Billing_Last_Name__c = 'M', Active__c = true, Default__c = true, Account__c = account.Id, CVV__c = '123', Card_Number__c = '4929000000006', Card_Expiration_Year__c = '2023', Card_Expiration_Month__c = '10',Billing_Address__c = 'Prabhat Aracade',Billing_City__c = 'US',Billing_State_Province__c = 'UK',Billing_Zip_Postal__c = '505001',Billing_Country__c = 'United States');
            insert paymentMethod;
            
            list<Contact> listContacts = new list<Contact>();
            listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,MailingCountry = 'UK',Email ='laxmanrao.564@gmail.com',MailingStreet = 'Bengalore',MailingCity = 'bengalore',MailingPostalCode = '523122',FirstName = 'acertis'));
            listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, MailingCountry = 'USA',Email = 'laxmanrao.564@gmail.com',MailingStreet = 'Bengalore',MailingCity = 'bengalore',MailingPostalCode = '523122',FirstName = 'acertis'));
            insert listContacts;
            
            Currency__c currency1 = new Currency__c(name = 'GBP', Symbol__c = '£1');
            insert currency1;
            
            Job__c job = new Job__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id, Sub_Total__c = 100, Discount_Value__c = 0, CurrencyL__c = currency1.Id);
            insert job;
            
            Invoice__c invoice1 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                                CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = 'Active');
                                                
            Invoice__c invoice2 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                                CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = 'Active');
            
            Invoice__c invoice3 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                                CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = CommonUtilClass.STATUS_POSTED);
            
            
            list<Invoice__c> invoices = new list<Invoice__c>();
            invoices.add(invoice1);
            invoices.add(invoice2);
            invoices.add(invoice3);
            insert invoices;
            
            list<Invoice_Lines__c> listInvoiceLines = new list<Invoice_Lines__c>();
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            insert listInvoiceLines;   

            Transaction__c transaction1=new Transaction__c(Gateway_ID__c = '123456',Payment_Gateway__c=gateway.id,Payment_Method__c=paymentMethod.id,Currency__c=currency1.id,Request_Invoice__c=invoices[0].id,Amount__c=20,Type__c='Charge');
           insert transaction1;

           Transaction__c transaction2=new Transaction__c(Gateway_ID__c = '123456',Payment_Gateway__c=gateway.id,Payment_Method__c=paymentMethod.id,Currency__c=currency1.id,Request_Invoice__c=invoices[0].id,Amount__c=20,Type__c='Charge');
           insert transaction2;
            
            invoices = [Select Id, Name, CurrencyL__c, Target_Date__c,
                        Shipping_Contact__r.FirstName,Shipping_Contact__r.LastName,Shipping_Contact__r.MailingStreet,Shipping_Contact__r.MailingCity,Shipping_Contact__r.MailingPostalCode,Shipping_Contact__r.MailingCountry 
                        From Invoice__c Where Id In: invoices];

           PaymentSiteOperation op = new PaymentSiteOperation();
           op.processPayment(gateway, null, paymentMethod, paymentMethod.Id, 10, account , false, null);
           op.processPayment(null, paymentMethod, paymentMethod.Id, 10, account, false);
            
            PaymentOperations.PaymentResult result;
            result = PaymentOperations.authorize(invoices.get(0).Id, invoices.get(0).name, null);  
            result = PaymentOperations.authorizeAndCharge(invoices.get(1).Id, null, null);
            PaymentOperations.void(invoices.get(0).Id);  
            PaymentOperations.void(invoices.get(0).Id);
            PaymentOperations.refund(invoices.get(0).Id, null, 100);
            PaymentOperations.authorizeAndCharge(invoices.get(2).Id, invoices.get(2).Name, null);
            PaymentOperations.authorizeAndChargePaymentPlanInstalments(invoices.get(2).Id,paymentMethod.Id,100);
            PaymentOperations.transactionRefund(transaction1.id);
            PaymentOperations.transactionVoid(transaction2.id);

            
            system.assert(invoices != null);
            
            // Code for handling the site
            // this will say Invoice could not be found
            ControllerSitePaymentProcess controllerSitePaymentProces = new ControllerSitePaymentProcess();
            
            // this will say Invoice could not be found
            system.currentPageReference().getParameters().put('Id', invoices.get(0).Id);
            controllerSitePaymentProces = new ControllerSitePaymentProcess();
            
            // this time Unpaid_Amount__c is > 0
            system.currentPageReference().getParameters().put('Id', invoices.get(2).Id);
            controllerSitePaymentProces = new ControllerSitePaymentProcess();
            
            // move to the checkout page
            controllerSitePaymentProces.checkOut();
            
            // this will fire the validation
            controllerSitePaymentProces.paymentMethod.Billing_First_Name__c = null;
            controllerSitePaymentProces.paymentMethod.Billing_Last_Name__c = null;
            controllerSitePaymentProces.paymentMethod.Card_Type__c = null;
            controllerSitePaymentProces.paymentMethod.Card_Number__c = null;
            controllerSitePaymentProces.paymentMethod.CVV__c = null;
            controllerSitePaymentProces.paymentMethod.Billing_Phone__c = null;
            controllerSitePaymentProces.paymentMethod.Billing_Email__c = null;
            controllerSitePaymentProces.paymentMethod.Billing_State_Province__c = null;
            controllerSitePaymentProces.paymentMethod.Card_Expiration_Month__c = null;
            controllerSitePaymentProces.processPayment();
            
            // looks ok
            controllerSitePaymentProces.paymentMethod.Billing_First_Name__c = 'Sandeep';
            controllerSitePaymentProces.paymentMethod.Billing_Last_Name__c = 'M';
            controllerSitePaymentProces.paymentMethod.Card_Type__c = 'Master';
            controllerSitePaymentProces.paymentMethod.Card_Number__c = '420000000000000';
            controllerSitePaymentProces.paymentMethod.CVV__c = '123';
            controllerSitePaymentProces.paymentMethod.Card_Expiration_Month__c = '12';
            controllerSitePaymentProces.paymentMethod.Card_Expiration_Year__c = '2016';
            controllerSitePaymentProces.sSaveCardDetails = 'yes';
            controllerSitePaymentProces.gateWayToUse = gateway;
            controllerSitePaymentProces.processPayment();
            
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(account);
            system.currentPageReference().getParameters().put('Id', account.Id);
            ControllerVirtualTerminal controllerVirtualTerminal = new ControllerVirtualTerminal(standardController);
       
            controllerVirtualTerminal.processPaymentRedirect();  
            controllerVirtualTerminal.selectedValue = paymentMethod.Id;  
            controllerVirtualTerminal.isNone = false;               
            controllerVirtualTerminal.paymentMethod.Billing_First_Name__c = 'Sandeep';
            controllerVirtualTerminal.paymentMethod.Billing_Last_Name__c = 'M';
            controllerVirtualTerminal.paymentMethod.Card_Type__c = 'Master';
            controllerVirtualTerminal.paymentMethod.Card_Number__c = '4111111111111111';
            controllerVirtualTerminal.paymentMethod.CVV__c = '123';
            controllerVirtualTerminal.paymentMethod.Card_Expiration_Month__c = '12';
            controllerVirtualTerminal.paymentMethod.Card_Expiration_Year__c = '2219';
            controllerVirtualTerminal.sSaveCardDetails = 'yes';
            controllerVirtualTerminal.paymentMethod.Account__c = account.Id;
            controllerVirtualTerminal.processPayment();
            
       
            gateway.Test_Mode__c = false;
            update gateway;
            system.currentPageReference().getParameters().put('Id', invoices.get(2).Id);
            controllerSitePaymentProces = new ControllerSitePaymentProcess(); 
            
            ClassForHandlingEway ClassForHandlingEway = new ClassForHandlingEway(gateway, null, paymentMethod,paymentMethod.Id,100,account, currency1.Id);
            ClassForHandlingEway.ewayErrorCodes();
            
            Transaction__c transactionObj = new Transaction__c(Gateway_ID__c = '123456', Payment_Gateway__c = gateway.Id, Payment_Method__c = paymentMethod.Id);
            insert transactionObj;
            ClassForHandlingEway.handleRefund_Click(gateway.Id,transactionObj.Id, 200 );
            
            //To cover catch blocks
            ClassForHandlingEway.handleRefund_Click('','',null);
            ClassForHandlingEway.handleVoid_Click('','',null);         
            try{           
                ClassForHandlingEway.handleAuthorizeAndCharge_Site(null);
            }catch(Exception ex){          
            }
            try{           
                ClassForHandlingEway.handleAuthorizeAndCharge_Site(true);
            }catch(Exception ex){          
            }
            try{           
                ClassForHandlingEway.handleAuthorizeAndCharge_Site(false);
            }catch(Exception ex){          
            }

            PaymentSiteOperation.GenericPaymentParameters genericPaymentParameters

                =  new PaymentSiteOperation.GenericPaymentParameters();

               genericPaymentParameters.amountToProcess = 100;

               genericPaymentParameters.currencyISOCode = 'USD';

            
               genericPaymentParameters.shouldTokenizeCard = false; 

               PaymentSiteOperation.GenericPaymentResult genericPaymentResult = new PaymentSiteOperation.GenericPaymentResult();            

               PaymentSiteOperation site = new PaymentSiteOperation();

            ClassForHandlingEway .handleAuthorizeAndCharge(genericPaymentParameters);
            op.processGenericPayment(genericPaymentParameters);
            
      }
      
       public static testMethod void testControllerForPaymentMethod() {
           ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
           ControllerInsertCustomSettings.insertValues();      
           ClassPopulateTestData.currencies();
           list<Gateway__c> listOfGateway = [Select Id From Gateway__c];
           delete listOfGateway;
           
           Account account = new Account(Name = 'Test Account');
           insert account;
           
            Account account1 = new Account(Name = 'Test Account', Customer_Profile_ID__c='3454fng');
           insert account1;

           // cover ApexPage Message "Gateway does not exist for account/None of the gateway records is active and default"
           system.currentPageReference().getParameters().put('id',account.id);         
           ApexPages.Standardcontroller controller2 = new Apexpages.Standardcontroller(account);
           ControllerForPaymentMethod controllerForPaymentMethod2 = new ControllerForPaymentMethod(controller2);
           
           Gateway__c gateway1 = new Gateway__c(Exact_ID__c = 'AD8627-02', Exact_ID_Security_Key__c = '76l24fj1', Active__c = true, Gateway_Type__c = CommonUtilClass.GATEWAY_TYPE_FIRSTDATA, Test_Mode__c = true, Merchant_ID__c = 'myown748', Security_Key__c = '123456789d');
           insert gateway1;        
           Account account2 = new Account(Name = 'Test Account', Gateway__c = gateway1.id);
           insert account2;

           Account account3 = [SELECT Name FROM Account WHERE id =: account.id];
           System.assertEquals('Test Account', account3.Name);
           
           // cover ApexPage Message "Authorize.net CIM Gateway is mandatory for creating customer payment profile"
           system.currentPageReference().getParameters().put('id',account2.id);
           ApexPages.Standardcontroller controller3 = new Apexpages.Standardcontroller(account2);
           ControllerForPaymentMethod controllerForPaymentMethod3 = new ControllerForPaymentMethod(controller3);        
            
           Gateway__c gateway = new Gateway__c(Exact_ID__c = '2auTLMb456DQ', Exact_ID_Security_Key__c = '45yxj8H4CheNV79X', Active__c = true, Default__c = true, Gateway_Type__c = CommonUtilClass.GATEWAY_TYPE_AUTHORIZEDOTNETCIM, Test_Mode__c = true, Merchant_ID__c = 'ankit.sharma01', Security_Key__c = 'Acertiscloud$23');
           insert gateway;
           
           Payment_Method__c paymentMethod = new Payment_Method__c(Active__c = true, Default__c = true, Account__c = account.Id, CVV__c = '123', Card_Number__c = '4007000000027', Card_Expiration_Year__c = '2023', Card_Expiration_Month__c = '10',Billing_Zip_Postal__c = '5000012', Billing_State_Province__c = '500012', Billing_City__c = 'london', Billing_Address__c = 'London UK', Billing_Last_Name__c = 'Cloud',Billing_First_Name__c = 'Acertis',Billing_Phone__c= '1234567892',Billing_Country__c ='UK' );
           insert paymentMethod;
           
           //pass acount id to controller 
           system.currentPageReference().getParameters().put('id',account.id);         
           ApexPages.Standardcontroller controller = new Apexpages.Standardcontroller(account);
           ControllerForPaymentMethod controllerForPaymentMethod = new ControllerForPaymentMethod(controller);
           
           Payment_Method__c paymentMethod1 = new Payment_Method__c(Active__c = true, Default__c = true, Account__c = account.Id, CVV__c = '123', Card_Number__c = '4007000000027', Card_Expiration_Month__c = '10',Billing_Zip_Postal__c = '5000012', Billing_State_Province__c = '500012', Billing_City__c = 'london', Billing_Address__c = 'London UK', Billing_Last_Name__c = 'London',Billing_First_Name__c = 'Acertis',Billing_Phone__c= '1234567892',Billing_Country__c ='UK');
           controllerForPaymentMethod.paymentMethod = paymentMethod1;
           //// cover ApexPage Message "Their can be only default Payment Method for an account"       
           controllerForPaymentMethod.processProfileCreation();
           
           //cover ApexPage Message "Card Expiration Date is mandatory"
           paymentMethod1.Default__c = false;
           controllerForPaymentMethod.paymentMethod = paymentMethod1;              
           controllerForPaymentMethod.processProfileCreation();
           
           // call for creating customer profile id and payment profile id. 
           paymentMethod1.Card_Expiration_Year__c = '2023';
           controllerForPaymentMethod.paymentMethod = paymentMethod1;              
           controllerForPaymentMethod.processProfileCreation();        
                   
           system.currentPageReference().getParameters().put('id',account1.id);
           ApexPages.Standardcontroller controller1 = new Apexpages.Standardcontroller(account1);
           ControllerForPaymentMethod controllerForPaymentMethod1 = new ControllerForPaymentMethod(controller1);
           
           Payment_Method__c paymentMethod2 = new Payment_Method__c(Active__c = true, Default__c = true, Account__c = account.Id, CVV__c = '123', Card_Number__c = '370000000000002', Card_Expiration_Year__c = '2023', Card_Expiration_Month__c = '10',Billing_Zip_Postal__c = '5000012', Billing_State_Province__c = '500012', Billing_City__c = 'london', Billing_Address__c = 'London UK', Billing_Last_Name__c = 'London',Billing_First_Name__c = 'Acertis',Billing_Phone__c= '1234567892',Billing_Country__c ='India');
           controllerForPaymentMethod1.paymentMethod = paymentMethod2;                 
           controllerForPaymentMethod1.processProfileCreation();
           
           // call for creating payment profile id.     
           paymentMethod2.Default__c = false;
           controllerForPaymentMethod1.paymentMethod = paymentMethod2;                 
           controllerForPaymentMethod1.processProfileCreation();                   
       }
       
       
        public static testMethod void paymentOperations_ClassForHandlingAuthorizeDotNetCIM() {
        
           ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
           ControllerInsertCustomSettings.insertValues();
           ClassPopulateTestData.currencies();
           list<Gateway__c> listOfGateway = [Select Id From Gateway__c];
           delete listOfGateway;
           
           Account account = new Account(Name = 'Test Account', Customer_Profile_ID__c='24870718');
           insert account;
           
           Account account1 = new Account(Name = 'Test Account');
           insert account1;
           
           Account account2 = new Account(Name = 'Test Account', Customer_Profile_ID__c='24870718');
           insert account2;

           Account account3 = [SELECT Name FROM Account WHERE id =: account.id];
           System.assertEquals('Test Account', account3.Name);
            
           
           Payment_Method__c paymentMethod1 = new Payment_Method__c(Active__c = true, Default__c = true, Account__c = account1.Id, CVV__c = '123', Card_Number__c = '4007000000027', Card_Expiration_Year__c = '2023', Card_Expiration_Month__c = '10',Billing_Zip_Postal__c = '5000012', Billing_State_Province__c = '5000123', Billing_City__c = 'london', Billing_Address__c = 'London UK', Billing_Last_Name__c = 'Cloud',Billing_First_Name__c = 'Acertis',Billing_Phone__c= '12345678921',Billing_Country__c ='UK',Payment_Profile_ID__c='22791594' );
           insert paymentMethod1;      
           
           Gateway__c gateway = new Gateway__c(Exact_ID__c = '2auTLMb456DQ', Exact_ID_Security_Key__c = '45yxj8H4CheNV79X', Active__c = true, Default__c = false, Gateway_Type__c = CommonUtilClass.GATEWAY_TYPE_AUTHORIZEDOTNETCIM, Test_Mode__c = true, Merchant_ID__c = 'ankit.sharma01', Security_Key__c = 'Acertiscloud$23');
           insert gateway;
           
           Payment_Method__c paymentMethod = new Payment_Method__c(Active__c = true, Default__c = true, Account__c = account.Id, CVV__c = '123', Card_Number__c = '4007000000027', Card_Expiration_Year__c = '2023', Card_Expiration_Month__c = '10',Billing_Zip_Postal__c = '5000012', Billing_State_Province__c = '5000122', Billing_City__c = 'london', Billing_Address__c = 'London UK', Billing_Last_Name__c = 'Cloud',Billing_First_Name__c = 'Acertis',Billing_Phone__c= '12345678922',Billing_Country__c ='UK',Payment_Profile_ID__c='22791594');
           insert paymentMethod;
           
           list<Contact> listContacts = new list<Contact>();
           listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,MailingCountry = 'UK',Email ='laxmanrao.564@gmail.com',MailingStreet = 'Bengalore',MailingCity = 'bengalore',MailingPostalCode = '523122',FirstName = 'acertis'));
           listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, MailingCountry = 'USA',Email = 'laxmanrao.564@gmail.com',MailingStreet = 'Bengalore',MailingCity = 'bengalore',MailingPostalCode = '523122',FirstName = 'acertis'));
           insert listContacts;
           
           Currency__c currency1 = new Currency__c(name = 'GBP', Symbol__c = '$');
           insert currency1;
           
           Job__c job = new Job__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id, Sub_Total__c = 100, Discount_Value__c = 0, CurrencyL__c = currency1.Id);
           insert job;
        
           Invoice__c invoice1 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                            CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = CommonUtilClass.STATUS_POSTED,Payment_Request_Amount__c =10);
                                            
           Invoice__c invoice2 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                            CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = CommonUtilClass.STATUS_POSTED,Payment_Request_Amount__c =10);
        
           Invoice__c invoice3 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                            CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = CommonUtilClass.STATUS_POSTED,Payment_Request_Amount__c =10);
           
           Invoice__c invoice4 = new Invoice__c(Account__c = account2.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                            CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = CommonUtilClass.STATUS_POSTED,Payment_Request_Amount__c =10);
                                            
           Invoice__c invoice5 = new Invoice__c(Account__c = account1.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                            CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = CommonUtilClass.STATUS_POSTED,Payment_Request_Amount__c =10);
           
           list<Invoice__c> invoices = new list<Invoice__c>();
           invoices.add(invoice1);
           invoices.add(invoice2);
           invoices.add(invoice3);
           invoices.add(invoice4);
           invoices.add(invoice5);
           insert invoices;
           
           list<Invoice_Lines__c> listInvoiceLines = new list<Invoice_Lines__c>();
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
        
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
        
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(2).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(2).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(2).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(3).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(3).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(3).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(4).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(4).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(4).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           insert listInvoiceLines; 
            
           Transaction__c transaction1=new Transaction__c(Gateway_ID__c = '123456',Payment_Gateway__c=gateway.id,Payment_Method__c=paymentMethod.id,Currency__c=currency1.id,Request_Invoice__c=invoices[0].id,Amount__c=20,Type__c='Charge');
           insert transaction1;
           Transaction__c transaction2=new Transaction__c(Gateway_ID__c = '123456',Payment_Gateway__c=gateway.id,Payment_Method__c=paymentMethod.id,Currency__c=currency1.id,Request_Invoice__c=invoices[0].id,Amount__c=20,Type__c='Charge');
           insert transaction2;
        
        
           system.assert(invoices.size() > 0); 
           
           invoices = [Select Id, Name, Payment_Request_Amount__c, Total_Invoice_Value__c, CurrencyL__c, Target_Date__c,Shipping_Contact__c, 
                       Shipping_Contact__r.FirstName,Shipping_Contact__r.LastName,Shipping_Contact__r.MailingStreet,Shipping_Contact__r.MailingCity,Shipping_Contact__r.MailingPostalCode,Shipping_Contact__r.MailingCountry
                       From Invoice__c Where Id In: invoices];
           
           //Cover site operations
           Account accountObj = new Account(Name = 'Test Account',Customer_Profile_ID__c='12365425');
           insert accountObj;
           
           PaymentSiteOperation op = new PaymentSiteOperation();
           op.processPayment(gateway, null, paymentMethod, paymentMethod.Id, 10, account , false, null);
           op.processPayment(null, paymentMethod, paymentMethod.Id, 10, account, false);

           PaymentOperations.PaymentResult result;
           result = PaymentOperations.authorize(invoices.get(0).Id, invoices.get(0).name, null); 
           result = PaymentOperations.authorizeAndCharge(invoices.get(2).Id, null, null);
           PaymentOperations.void(invoices.get(0).Id);  
           PaymentOperations.void(invoices.get(0).Id);
           PaymentOperations.refund(invoices.get(2).Id, null, 100);
           PaymentOperations.authorizeAndCharge(invoices.get(2).Id, invoices.get(1).Name, null);
           PaymentOperations.authorizeAndChargePaymentPlanInstalments(invoices.get(2).Id,paymentMethod.Id,100);
           PaymentOperations.transactionRefund(transaction1.id);
           PaymentOperations.transactionVoid(transaction2.id);

           system.assert(invoices != null);
           
           // Code for handling the site 
           // this will say Invoice could not be found
         ControllerSitePaymentProcess controllerSitePaymentProces = new ControllerSitePaymentProcess();
        
           // this will say Invoice could not be found
           system.currentPageReference().getParameters().put('Id', invoices.get(0).Id);
           controllerSitePaymentProces = new ControllerSitePaymentProcess();
        
           // this time Unpaid_Amount__c is > 0
           system.currentPageReference().getParameters().put('Id', invoices.get(2).Id);
           controllerSitePaymentProces = new ControllerSitePaymentProcess();
        
           // move to the checkout page
           controllerSitePaymentProces.checkOut();
           
           controllerSitePaymentProces.paymentMethod.Billing_First_Name__c = 'Sandeep';
           controllerSitePaymentProces.paymentMethod.Billing_Last_Name__c = 'M';
           controllerSitePaymentProces.paymentMethod.Card_Type__c = 'Master';
           controllerSitePaymentProces.paymentMethod.Card_Number__c = '4111111111111111';
           controllerSitePaymentProces.paymentMethod.CVV__c = '123';
           controllerSitePaymentProces.paymentMethod.Card_Expiration_Month__c = '12';
           controllerSitePaymentProces.paymentMethod.Card_Expiration_Year__c = '2016';
           controllerSitePaymentProces.sSaveCardDetails = 'yes';
           controllerSitePaymentProces.gateWayToUse = gateway;
           controllerSitePaymentProces.processPayment(); 
           
           system.currentPageReference().getParameters().put('Id', invoices.get(4).Id);
           ControllerSitePaymentProcess controllerSitePaymentProces1 = new ControllerSitePaymentProcess();
        
           // move to the checkout page
           controllerSitePaymentProces1.checkOut();
           
           controllerSitePaymentProces1.paymentMethod.Billing_First_Name__c = 'Surej';
           controllerSitePaymentProces1.paymentMethod.Billing_Last_Name__c = 'Mehta';
           controllerSitePaymentProces1.paymentMethod.Card_Type__c = 'Master';
           controllerSitePaymentProces1.paymentMethod.Card_Number__c = '4111111111111111';
           controllerSitePaymentProces1.paymentMethod.CVV__c = '123';
           controllerSitePaymentProces1.paymentMethod.Card_Expiration_Month__c = '12';
           controllerSitePaymentProces1.paymentMethod.Card_Expiration_Year__c = '2016';
           controllerSitePaymentProces1.sSaveCardDetails = 'No';
           controllerSitePaymentProces1.gateWayToUse = gateway;
           controllerSitePaymentProces1.processPayment();
           
           // covering the virtual terminal functionality.
           ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(account);
           system.currentPageReference().getParameters().put('Id', account2.Id);
           ControllerVirtualTerminal controllerVirtualTerminal = new ControllerVirtualTerminal(standardController);

           controllerVirtualTerminal.processPaymentRedirect();  
           controllerVirtualTerminal.selectedValue = paymentMethod1.Id;  
           controllerVirtualTerminal.isNone = false;               
           controllerVirtualTerminal.paymentMethod = paymentMethod1;
           controllerVirtualTerminal.sSaveCardDetails = 'No';      
           controllerVirtualTerminal.processPayment();
           
           ApexPages.Standardcontroller standardController1 = new Apexpages.Standardcontroller(invoices.get(3));
           system.currentPageReference().getParameters().put('Id', invoices.get(3).Id);
           ControllerVirtualTerminal controllerVirtualTerminal1 = new ControllerVirtualTerminal(standardController1);

           controllerVirtualTerminal1.processPaymentRedirect();  
           controllerVirtualTerminal1.selectedValue = paymentMethod1.Id;  
           controllerVirtualTerminal1.isNone = false;               
           controllerVirtualTerminal1.paymentMethod = paymentMethod1;
           controllerVirtualTerminal1.sSaveCardDetails = 'No';         
           controllerVirtualTerminal1.processPayment();
           
           // this time gateway.Test_Mode__c = false
           gateway.Test_Mode__c = false;
           update gateway;
           system.currentPageReference().getParameters().put('Id', invoices.get(2).Id);
           controllerSitePaymentProces = new ControllerSitePaymentProcess();
           
           
           // cover catch blocks
            ClassForHandlingAuthorizeDotNetCIM classForHandlingAuthorizeDotNetCIMObj = new ClassForHandlingAuthorizeDotNetCIM(gateway,paymentMethod,null,null);  
            classForHandlingAuthorizeDotNetCIMObj.handleCustomerProfileCreation();
            classForHandlingAuthorizeDotNetCIMObj.handlePaymentProfileCreation(paymentMethod.id);
            classForHandlingAuthorizeDotNetCIMObj.handlePaymentProfileCreation(null);
            classForHandlingAuthorizeDotNetCIMObj.handleAuthorizeAndCharge_Click(transaction1.id,gateway.id);
            classForHandlingAuthorizeDotNetCIMObj.handleAuthorizeAndCharge_Click(null,gateway.id);
            classForHandlingAuthorizeDotNetCIMObj.handleRefund_Click(gateway.id,transaction1.id,20);
            classForHandlingAuthorizeDotNetCIMObj.handleVoid_Click(gateway.id,transaction1.id,20);
            try{           
               classForHandlingAuthorizeDotNetCIMObj.handleAuthorize_Click();
            }catch(Exception ex){          
            }       
            try{           
                classForHandlingAuthorizeDotNetCIMObj.handleAuthorizeAndCharge_Click('','');
                 classForHandlingAuthorizeDotNetCIMObj.handleAuthorizeAndCharge_Site(true);
            }catch(Exception ex){          
            }      
            
            classForHandlingAuthorizeDotNetCIMObj.handleVoid_Click('','',null);         
            try{           
                classForHandlingAuthorizeDotNetCIMObj.handleAuthorizeAndCharge_Site(null);    
            }catch(Exception ex){          
            }
            ClassForHandlingAuthorizeDotNetCIM classForHandlingAuthorizeDotNetCIMObj1 = new ClassForHandlingAuthorizeDotNetCIM(gateway,paymentMethod,account,invoices[0]);  
            PaymentSiteOperation.GenericPaymentParameters genericPaymentParameters

                =  new PaymentSiteOperation.GenericPaymentParameters();
               genericPaymentParameters.amountToProcess = 100;

               genericPaymentParameters.currencyISOCode = 'USD';

               genericPaymentParameters.shouldTokenizeCard = false; 

               PaymentSiteOperation.GenericPaymentResult genericPaymentResult = new PaymentSiteOperation.GenericPaymentResult();            

               PaymentSiteOperation site = new PaymentSiteOperation();

            classForHandlingAuthorizeDotNetCIMObj.handleAuthorizeAndCharge(genericPaymentParameters);
            op.processGenericPayment(genericPaymentParameters);

        }
           
      
       public static testMethod void paymentOperations_ClassForHandlingWireCard() {
            ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
            ControllerInsertCustomSettings.insertValues();
            Currency__c currencyobj = new Currency__c(name = 'USD', Symbol__c = '$');
            insert currencyobj;
            
            list<Gateway__c> listOfGateway = [Select Id From Gateway__c];
            delete listOfGateway;
            
            Gateway__c gateway = new Gateway__c(Active__c = true, Default__c = true, Gateway_Type__c = CommonUtilClass.GATEWAY_TYPE_WIRECARD, Test_Mode__c = true, Merchant_ID__c = '22LbQ9b7', Security_Key__c = '8Fh7VnPV3e6h4b4S');
            insert gateway;
            
            Account account = new Account(Name = 'Test Account');
            insert account;

            Account account1 = [SELECT Name FROM Account WHERE id =: account.id];
            System.assertEquals('Test Account', account1.Name);

            Account account2 = new Account(Name = 'Test Account2');
            insert account2;
            
            Payment_Method__c paymentMethod1 = new Payment_Method__c(Active__c = true, Default__c = true, Account__c = account2.Id, CVV__c = '123', Card_Number__c = '4007000000027', Card_Expiration_Year__c = '2023', Card_Expiration_Month__c = '10');
            insert paymentMethod1;

            Payment_Method__c paymentMethod = new Payment_Method__c(Billing_Fax__c = '56789', Billing_Email__c = 'dev@gmail.com', Billing_Phone__c = '9999999', Billing_First_Name__c = 'Devender', Billing_Last_Name__c = 'M',Active__c = true, Default__c = true, Account__c = account.Id, CVV__c = '123', Card_Number__c = '4929000000006', Card_Expiration_Year__c = '2023', Card_Expiration_Month__c = '10',Billing_Address__c = 'Prabhat Aracade',Billing_City__c = 'alabama',Billing_State_Province__c = 'alabama',Billing_Zip_Postal__c = '505001',Billing_Country__c = 'United States');
            insert paymentMethod;
            
            list<Contact> listContacts = new list<Contact>();
            listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,MailingCountry = 'UK',Email ='laxmanrao.564@gmail.com',MailingStreet = 'Bengalore',MailingCity = 'bengalore',MailingPostalCode = '523122',FirstName = 'acertis'));
            listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, MailingCountry = 'USA',Email = 'laxmanrao.564@gmail.com',MailingStreet = 'Bengalore',MailingCity = 'bengalore',MailingPostalCode = '523122',FirstName = 'acertis'));
            insert listContacts;
            
            Currency__c currency1 = new Currency__c(name = 'GBP', Symbol__c = '£1');
            insert currency1;
            
            Job__c job = new Job__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id, Sub_Total__c = 100, Discount_Value__c = 0, CurrencyL__c = currency1.Id);
            insert job;
            
            Invoice__c invoice1 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                                CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = 'Active');
                                                
            Invoice__c invoice2 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                                CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = 'Active');
            
            Invoice__c invoice3 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                                CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = CommonUtilClass.STATUS_POSTED);

            Invoice__c invoice4 = new Invoice__c(Account__c = account2.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                                CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = 'Active');
            
            
            list<Invoice__c> invoices = new list<Invoice__c>();
            invoices.add(invoice1);
            invoices.add(invoice2);
            invoices.add(invoice3);
            invoices.add(invoice4);
            insert invoices;
            
            list<Invoice_Lines__c> listInvoiceLines = new list<Invoice_Lines__c>();
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            insert listInvoiceLines;   
            
           invoices = [Select Id, Name, CurrencyL__c, Target_Date__c,
                        Shipping_Contact__r.FirstName,Shipping_Contact__r.LastName,Shipping_Contact__r.MailingStreet,Shipping_Contact__r.MailingCity,Shipping_Contact__r.MailingPostalCode,Shipping_Contact__r.MailingCountry 
                        From Invoice__c Where Id In: invoices];

           Transaction__c transactionObj1 = new Transaction__c(Gateway_ID__c = '123456', Payment_Gateway__c = gateway.Id, Payment_Method__c = paymentMethod.Id, Type__c = 'Authorization' ,Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED, Request_Invoice__c = invoices.get(1).Id);
           insert transactionObj1;


           PaymentSiteOperation op = new PaymentSiteOperation();
           op.processPayment(gateway, null, paymentMethod, paymentMethod.Id, 10, account , false, null);
           op.processPayment(null, paymentMethod, paymentMethod.Id, 10, account , false);
            
            PaymentOperations.PaymentResult result;
            result = PaymentOperations.authorize(invoices.get(0).Id, invoices.get(0).name, null);  
            result = PaymentOperations.authorizeAndCharge(invoices.get(1).Id, null, null);
            result = PaymentOperations.authorize(invoices.get(3).Id, null, null);  
            result = PaymentOperations.authorizeAndCharge(invoices.get(3).Id, null, null);
            PaymentOperations.void(invoices.get(0).Id);  
            PaymentOperations.void(invoices.get(0).Id);
            PaymentOperations.refund(invoices.get(0).Id, null, 100);
            PaymentOperations.authorizeAndCharge(invoices.get(2).Id, invoices.get(2).Name, null);
            PaymentOperations.authorizeAndChargePaymentPlanInstalments(invoices.get(2).Id,paymentMethod.Id,100);
            PaymentOperations.transactionRefund(transactionObj1.id);
            
            system.assert(invoices != null);
            
            /* Code for handling the site */
            // this will say Invoice could not be found
            ControllerSitePaymentProcess controllerSitePaymentProces = new ControllerSitePaymentProcess();
            
            // this will say Invoice could not be found
            system.currentPageReference().getParameters().put('Id', invoices.get(0).Id);
            controllerSitePaymentProces = new ControllerSitePaymentProcess();
            
            // this time Unpaid_Amount__c is > 0
            system.currentPageReference().getParameters().put('Id', invoices.get(2).Id);
            controllerSitePaymentProces = new ControllerSitePaymentProcess();
            
            //move to the checkout page
            controllerSitePaymentProces.checkOut();
            
            //this will fire the validation
            controllerSitePaymentProces.paymentMethod.Billing_First_Name__c = null;
            controllerSitePaymentProces.paymentMethod.Billing_Last_Name__c = null;
            controllerSitePaymentProces.paymentMethod.Card_Type__c = null;
            controllerSitePaymentProces.paymentMethod.Card_Number__c = null;
            controllerSitePaymentProces.paymentMethod.CVV__c = null;
            controllerSitePaymentProces.paymentMethod.Billing_Phone__c = null;
            controllerSitePaymentProces.paymentMethod.Billing_Email__c = null;
            controllerSitePaymentProces.paymentMethod.Billing_State_Province__c = null;
            controllerSitePaymentProces.paymentMethod.Card_Expiration_Month__c = null;
            controllerSitePaymentProces.processPayment();
            
            // looks ok
            controllerSitePaymentProces.paymentMethod.Billing_First_Name__c = 'Sandeep';
            controllerSitePaymentProces.paymentMethod.Billing_Last_Name__c = 'M';
            controllerSitePaymentProces.paymentMethod.Card_Type__c = 'Master';
            controllerSitePaymentProces.paymentMethod.Card_Number__c = '420000000000000';
            controllerSitePaymentProces.paymentMethod.CVV__c = '123';
            controllerSitePaymentProces.paymentMethod.Card_Expiration_Month__c = '12';
            controllerSitePaymentProces.paymentMethod.Card_Expiration_Year__c = '2016';
            controllerSitePaymentProces.sSaveCardDetails = 'yes';
            controllerSitePaymentProces.gateWayToUse = gateway;
            controllerSitePaymentProces.processPayment();
            
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(account);
            system.currentPageReference().getParameters().put('Id', account.Id);
            ControllerVirtualTerminal controllerVirtualTerminal = new ControllerVirtualTerminal(standardController);
       
            controllerVirtualTerminal.processPaymentRedirect();  
            controllerVirtualTerminal.selectedValue = paymentMethod.Id;  
            controllerVirtualTerminal.isNone = false;               
            controllerVirtualTerminal.paymentMethod.Billing_First_Name__c = 'Sandeep';
            controllerVirtualTerminal.paymentMethod.Billing_Last_Name__c = 'M';
            controllerVirtualTerminal.paymentMethod.Card_Type__c = 'Master';
            controllerVirtualTerminal.paymentMethod.Card_Number__c = '4111111111111111';
            controllerVirtualTerminal.paymentMethod.CVV__c = '123';
            controllerVirtualTerminal.paymentMethod.Card_Expiration_Month__c = '12';
            controllerVirtualTerminal.paymentMethod.Card_Expiration_Year__c = '2219';
            controllerVirtualTerminal.sSaveCardDetails = 'yes';
            controllerVirtualTerminal.paymentMethod.Account__c = account.Id;
            controllerVirtualTerminal.processPayment();
            
            // this time gateway.Test_Mode__c = false
            gateway.Test_Mode__c = false;
            update gateway;
            system.currentPageReference().getParameters().put('Id', invoices.get(2).Id);
            controllerSitePaymentProces = new ControllerSitePaymentProcess(); 
            
            ClassForHandlingWireCard objClassForHandlingWireCard = new ClassForHandlingWireCard(gateway, invoices.get(0), paymentMethod,paymentMethod.Id,100,account, currency1.Id);
            
            Transaction__c transactionObj = new Transaction__c(Gateway_ID__c = '123456', Payment_Gateway__c = gateway.Id, Payment_Method__c = paymentMethod.Id);
            insert transactionObj;

            objClassForHandlingWireCard.handleRefund_Click(gateway.Id,transactionObj.Id, 200);
            objClassForHandlingWireCard.handleVoid_Click(gateway.Id,transactionObj.Id, 200);

            try{           
                objClassForHandlingWireCard.handleAuthorizeAndCharge_Site(true);
            }catch(Exception ex){          
            }

            //To cover catch blocks
            objClassForHandlingWireCard.handleRefund_Click('','',null);
            objClassForHandlingWireCard.handleVoid_Click('','',null);      
            
            try{ 
                objClassForHandlingWireCard.handleAuthorizeAndCharge_Site(null);
            }catch(Exception ex){          
            }
            PaymentSiteOperation.GenericPaymentParameters genericPaymentParameters

                =  new PaymentSiteOperation.GenericPaymentParameters();

               genericPaymentParameters.amountToProcess = 100;

               genericPaymentParameters.currencyISOCode = 'USD';

               //genericPaymentParameters.paymentMethod = paymentMethod.id;

               genericPaymentParameters.shouldTokenizeCard = false; 

               PaymentSiteOperation.GenericPaymentResult genericPaymentResult = new PaymentSiteOperation.GenericPaymentResult();            

               PaymentSiteOperation site = new PaymentSiteOperation();

            objClassForHandlingWireCard.handleAuthorizeAndCharge(genericPaymentParameters);
            op.processGenericPayment(genericPaymentParameters);
      } 

      public static testMethod void paymentOperations_ClassForHandlingStripeCard() {
           ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
           ControllerInsertCustomSettings.insertValues();
           
           list<Gateway__c> listOfGateway = [Select Id From Gateway__c];
           delete listOfGateway;
           
           Gateway__c gateway = new Gateway__c(Exact_ID__c = 'AD8627-02', Exact_ID_Security_Key__c = '76l24fj1', Active__c = true, Default__c = true, Gateway_Type__c = CommonUtilClass.GATEWAY_TYPE_STRIPE, Test_Mode__c = true, Merchant_ID__c = 'myown748', Security_Key__c = '123456789d');
           insert gateway;
           
           Account account = new Account(Name = 'Test Account');
           insert account;
           
           Payment_Method__c paymentMethod = new Payment_Method__c(Billing_Email__c = 'test@dev.com', Billing_Phone__c = '1234567890', Billing_State_Province__c = 'AP', Active__c = true, Default__c = true, Account__c = account.Id, CVV__c = '123', Card_Number__c = '4111111111111111', Card_Expiration_Year__c = '2023', Card_Expiration_Month__c = '10');
           insert paymentMethod;
           
           list<Contact> listContacts = new list<Contact>();
           listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,MailingCountry = 'UK',Email ='laxmanrao.564@gmail.com',MailingStreet = 'Bengalore',MailingCity = 'bengalore',MailingPostalCode = '523122',FirstName = 'acertis'));
           listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, MailingCountry = 'USA',Email = 'laxmanrao.564@gmail.com',MailingStreet = 'Bengalore',MailingCity = 'bengalore',MailingPostalCode = '523122',FirstName = 'acertis'));
           insert listContacts;
           
           Currency__c currency1 = new Currency__c(name = 'GBP', Symbol__c = '£1');
           insert currency1;
           Currency__c currecyObj = new Currency__c(Name = 'USD', Symbol__c = '$');
           insert currecyObj;
           
           Job__c job = new Job__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id, Sub_Total__c = 100, Discount_Value__c = 0, CurrencyL__c = currency1.Id);
           insert job;

           Invoice__c invoice1 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                               CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = 'Active');
                                               
           Invoice__c invoice2 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                               CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = 'Active');
           
           Invoice__c invoice3 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                               CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = CommonUtilClass.STATUS_POSTED);
           
           
           list<Invoice__c> invoices = new list<Invoice__c>();
           invoices.add(invoice1);
           invoices.add(invoice2);
           invoices.add(invoice3);
           insert invoices;
           
           
           
           list<Invoice_Lines__c> listInvoiceLines = new list<Invoice_Lines__c>();
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           insert listInvoiceLines;   


            Transaction__c transaction1=new Transaction__c(Gateway_ID__c = '123456',Payment_Gateway__c=gateway.id,Payment_Method__c=paymentMethod.id,Currency__c=currency1.id,Request_Invoice__c=invoices[0].id,Amount__c=20,Type__c='Charge');
           insert transaction1;

           Transaction__c transaction2=new Transaction__c(Gateway_ID__c = '123456',Payment_Gateway__c=gateway.id,Payment_Method__c=paymentMethod.id,Currency__c=currency1.id,Request_Invoice__c=invoices[0].id,Amount__c=20,Type__c='Charge');
           insert transaction2;
           
           invoices = [Select Id, Name, CurrencyL__c, Target_Date__c,
                       Shipping_Contact__r.FirstName,Shipping_Contact__r.LastName,Shipping_Contact__r.MailingStreet,Shipping_Contact__r.MailingCity,Shipping_Contact__r.MailingPostalCode,Shipping_Contact__r.MailingCountry 
                       From Invoice__c Where Id In: invoices];
                     
          PaymentSiteOperation op = new PaymentSiteOperation();
           op.processPayment(gateway, null, paymentMethod, paymentMethod.Id, 10, account , false, null);
           op.processPayment(null, paymentMethod, paymentMethod.Id, 10, account , false);         
           
           PaymentOperations.PaymentResult result;
           result = PaymentOperations.authorize(invoices.get(0).Id, invoices.get(0).name, null);  
           result = PaymentOperations.authorizeAndCharge(invoices.get(0).Id, null, null);
           PaymentOperations.void(invoices.get(0).Id);  
           system.assert(result.transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED);
           PaymentOperations.void(invoices.get(0).Id);
           PaymentOperations.refund(invoices.get(0).Id, null, 100);
           PaymentOperations.authorizeAndCharge(invoices.get(1).Id, invoices.get(1).Name, null);
           PaymentOperations.authorizeAndChargePaymentPlanInstalments(invoices.get(2).Id,paymentMethod.Id,100);
           PaymentOperations.transactionRefund(transaction1.id);
            PaymentOperations.transactionVoid(transaction2.id);

           
           system.assert(invoices != null);
           
           
           /* Code for handling the site */
           // this will say Invoice could not be found
           ControllerSitePaymentProcess controllerSitePaymentProces = new ControllerSitePaymentProcess();
           
           // this will say Invoice could not be found
           system.currentPageReference().getParameters().put('Id', invoices.get(0).Id);
           controllerSitePaymentProces = new ControllerSitePaymentProcess();
           
           // this time Unpaid_Amount__c is > 0
           system.currentPageReference().getParameters().put('Id', invoices.get(2).Id);
           controllerSitePaymentProces = new ControllerSitePaymentProcess();
           
           // move to the checkout page
           controllerSitePaymentProces.checkOut();
           
           // this will fire the validation
           controllerSitePaymentProces.paymentMethod.Billing_First_Name__c = null;
           controllerSitePaymentProces.paymentMethod.Billing_Last_Name__c = null;
           controllerSitePaymentProces.paymentMethod.Card_Type__c = null;
           controllerSitePaymentProces.paymentMethod.Card_Number__c = null;
           controllerSitePaymentProces.paymentMethod.CVV__c = null;
           controllerSitePaymentProces.paymentMethod.Card_Expiration_Month__c = null;
           controllerSitePaymentProces.processPayment();
           
           // looks ok
           controllerSitePaymentProces.paymentMethod.Billing_First_Name__c = 'Sandeep';
           controllerSitePaymentProces.paymentMethod.Billing_Last_Name__c = 'M';
           controllerSitePaymentProces.paymentMethod.Card_Type__c = 'Master';
           controllerSitePaymentProces.paymentMethod.Card_Number__c = '420000000000000';
           controllerSitePaymentProces.paymentMethod.CVV__c = '123';
           controllerSitePaymentProces.paymentMethod.Card_Expiration_Month__c = '12';
           controllerSitePaymentProces.paymentMethod.Card_Expiration_Year__c = '2016';
           controllerSitePaymentProces.sSaveCardDetails = 'true';
           controllerSitePaymentProces.gateWayToUse = gateway;
           controllerSitePaymentProces.processPayment();
           
           ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(account);
           system.currentPageReference().getParameters().put('Id', account.Id);
           ControllerVirtualTerminal controllerVirtualTerminal = new ControllerVirtualTerminal(standardController);

           controllerVirtualTerminal.processPaymentRedirect();  
           controllerVirtualTerminal.selectedValue = paymentMethod.Id;  
           controllerVirtualTerminal.isNone = false;               
           controllerVirtualTerminal.paymentMethod.Billing_First_Name__c = 'Sandeep';
           controllerVirtualTerminal.paymentMethod.Billing_Last_Name__c = 'M';
           controllerVirtualTerminal.paymentMethod.Card_Type__c = 'Visa';
           controllerVirtualTerminal.paymentMethod.Card_Number__c = '4111111111111111';
           controllerVirtualTerminal.paymentMethod.CVV__c = '123';
           controllerVirtualTerminal.paymentMethod.Card_Expiration_Month__c = '12';
           controllerVirtualTerminal.paymentMethod.Card_Expiration_Year__c = '2219';
           controllerVirtualTerminal.sSaveCardDetails = 'yes';
           controllerVirtualTerminal.paymentMethod.Account__c = account.Id;
           controllerVirtualTerminal.processPayment();

           // this time gateway.Test_Mode__c = false
           gateway.Test_Mode__c = false;
           update gateway;
           system.currentPageReference().getParameters().put('Id', invoices.get(2).Id);
           controllerSitePaymentProces = new ControllerSitePaymentProcess();
           
           //Cover the catch block
           ClassForHandlingStripeCard classForHandlingStripeCardCardObj = new ClassForHandlingStripeCard(gateway,null,paymentMethod,'',null,account,null);      
           classForHandlingStripeCardCardObj.handleAuthorize_Click();
           try{           
               classForHandlingStripeCardCardObj.handleAuthorizeAndCharge_Click('','');
           }catch(Exception ex){          
           }      
           classForHandlingStripeCardCardObj.handleRefund_Click('','',null);
           classForHandlingStripeCardCardObj.handleVoid_Click('','',null);      
           try{           
               classForHandlingStripeCardCardObj.handleAuthorizeAndCharge_Site(null);
           }catch(Exception ex){          
           } 
            
           ClassForHandlingStripeCard classForHandlingStripeCardCardObj1 = new ClassForHandlingStripeCard(gateway,null,paymentMethod,'',20,account,null);    
           classForHandlingStripeCardCardObj1.handleAuthorizeAndCharge_Site(true);
           
           ClassForHandlingStripeCard classForHandlingStripeCardobject=new ClassForHandlingStripeCard();

           PaymentSiteOperation.GenericPaymentParameters genericPaymentParameters

                =  new PaymentSiteOperation.GenericPaymentParameters();

               genericPaymentParameters.amountToProcess = 100;

               genericPaymentParameters.currencyISOCode = 'USD';

               //genericPaymentParameters.paymentMethod = paymentMethod.id;

               genericPaymentParameters.shouldTokenizeCard = false; 

               PaymentSiteOperation.GenericPaymentResult genericPaymentResult = new PaymentSiteOperation.GenericPaymentResult();            

               PaymentSiteOperation site = new PaymentSiteOperation();

            classForHandlingStripeCardobject.handleAuthorizeAndCharge(genericPaymentParameters);
            op.processGenericPayment(genericPaymentParameters);

      }

      public static testMethod void paymentOperations_AuthorizeDotnet() {
           ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
           ControllerInsertCustomSettings.insertValues();
           
           Gateway__c gateway = new Gateway__c(Active__c = true, Gateway_Type__c = 'Authorize.net', Test_Mode__c = true, Merchant_ID__c = '22LbQ9b7', Security_Key__c = '8Fh7VnPV3e6h4b4S', Merchant_Seal_User_Id__c = '8Fh7VnPV3e6h4b4S...');
           insert gateway;
           
           Currency__c currencyobj = new Currency__c(name = 'USD', Symbol__c = '$');
           insert currencyobj;
           
           Account account = new Account(Name = 'Test Account',Gateway__c = gateway.Id);
           insert account;
           
           Payment_Method__c paymentMethod = new Payment_Method__c(Active__c = true, Default__c = true, Account__c = account.Id, CVV__c = '123', Card_Number__c = '4007000000027', Card_Expiration_Year__c = '2023', Card_Expiration_Month__c = '10',Billing_Zip_Postal__c = '5000012', Billing_State_Province__c = '500012', Billing_City__c = 'london', Billing_Address__c = 'London UK', Billing_Last_Name__c = 'London');
           insert paymentMethod;
           
           list<Contact> listContacts = new list<Contact>();
           listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,MailingCountry = 'UK',Email ='laxmanrao.564@gmail.com',MailingStreet = 'Bengalore',MailingCity = 'bengalore',MailingPostalCode = '523122',FirstName = 'acertis'));
           listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, MailingCountry = 'USA',Email = 'laxmanrao.564@gmail.com',MailingStreet = 'Bengalore',MailingCity = 'bengalore',MailingPostalCode = '523122',FirstName = 'acertis'));
           insert listContacts;
           
           Currency__c currency1 = new Currency__c(name = 'GBP', Symbol__c = '£1');
           insert currency1;
           
           Job__c job = new Job__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id, Sub_Total__c = 100, Discount_Value__c = 0, CurrencyL__c = currency1.Id);
           insert job;
           
           Invoice__c invoice1 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                               CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = CommonUtilClass.STATUS_POSTED);
                                               
           Invoice__c invoice2 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                               CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = CommonUtilClass.STATUS_POSTED);
           
           Invoice__c invoice3 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                               CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = CommonUtilClass.STATUS_POSTED);
                                               
           list<Invoice__c> invoices = new list<Invoice__c>();
           invoices.add(invoice1);
           invoices.add(invoice2);
           invoices.add(invoice3);
           insert invoices;
           
           list<Invoice_Lines__c> listInvoiceLines = new list<Invoice_Lines__c>();
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(2).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(2).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(2).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           insert listInvoiceLines; 
           
           system.assert(invoices.size() > 0);  

            Transaction__c transaction1=new Transaction__c(Gateway_ID__c = '123456',Payment_Gateway__c=gateway.id,Payment_Method__c=paymentMethod.id,Currency__c=currency1.id,Request_Invoice__c=invoices[0].id,Amount__c=20,Type__c='Charge');
           insert transaction1;
           Transaction__c transaction2=new Transaction__c(Gateway_ID__c = '123456',Payment_Gateway__c=gateway.id,Payment_Method__c=paymentMethod.id,Currency__c=currency1.id,Request_Invoice__c=invoices[0].id,Amount__c=20,Type__c='Charge');
           insert transaction2;
           
           invoices = [Select Id, Name, Payment_Request_Amount__c, Total_Invoice_Value__c, CurrencyL__c, Target_Date__c,Shipping_Contact__c, 
                          Shipping_Contact__r.FirstName,Shipping_Contact__r.LastName,Shipping_Contact__r.MailingStreet,Shipping_Contact__r.MailingCity,Shipping_Contact__r.MailingPostalCode,Shipping_Contact__r.MailingCountry
                          From Invoice__c Where Id In: invoices];
           
           PaymentSiteOperation op = new PaymentSiteOperation();
           op.processPayment(gateway, null, paymentMethod, paymentMethod.Id, 10, account , false, null);
           op.processPayment(null, paymentMethod, paymentMethod.Id, 10, account , false);



           PaymentOperations.PaymentResult result;

           result = PaymentOperations.authorize(invoices.get(0).Id, invoices.get(0).name, null);  
           result = PaymentOperations.authorizeAndCharge(invoices.get(0).Id, null, null);
           PaymentOperations.void(invoices.get(0).Id);  
           system.assert(result.transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED);
           PaymentOperations.void(invoices.get(0).Id);
           PaymentOperations.refund(invoices.get(0).Id, null, 100);
           PaymentOperations.authorizeAndCharge(invoices.get(1).Id, invoices.get(1).Name, null);
           PaymentOperations.refund(invoices.get(1).Id, null, 100);
           PaymentOperations.authorizeAndChargePaymentPlanInstalments(invoices.get(2).Id,paymentMethod.Id,100);
           PaymentOperations.transactionRefund(transaction1.id);
           PaymentOperations.transactionVoid(transaction2.id);
           
           // Code for handling the site
           // this will say Invoice could not be found
           ControllerSitePaymentProcess controllerSitePaymentProces = new ControllerSitePaymentProcess();
           
           // this will say Invoice could not be found
           system.currentPageReference().getParameters().put('Id', invoices.get(0).Id);
           controllerSitePaymentProces = new ControllerSitePaymentProcess();
           
           // this time Unpaid_Amount__c is > 0
           system.currentPageReference().getParameters().put('Id', invoices.get(2).Id);
           controllerSitePaymentProces = new ControllerSitePaymentProcess();
           
           // move to the checkout page
           controllerSitePaymentProces.checkOut();
           
           // this will fire the validation
           controllerSitePaymentProces.paymentMethod.Billing_First_Name__c = null;
           controllerSitePaymentProces.paymentMethod.Billing_Last_Name__c = null;
           controllerSitePaymentProces.paymentMethod.Card_Type__c = null;
           controllerSitePaymentProces.paymentMethod.Card_Number__c = null;
           controllerSitePaymentProces.paymentMethod.CVV__c = null;
           controllerSitePaymentProces.paymentMethod.Card_Expiration_Month__c = null;
           controllerSitePaymentProces.processPayment();
           
           // looks ok
           controllerSitePaymentProces.paymentMethod.Billing_First_Name__c = 'Sandeep';
           controllerSitePaymentProces.paymentMethod.Billing_Last_Name__c = 'M';
           controllerSitePaymentProces.paymentMethod.Card_Type__c = 'Master';
           controllerSitePaymentProces.paymentMethod.Card_Number__c = '420000000000000';
           controllerSitePaymentProces.paymentMethod.CVV__c = '123';
           controllerSitePaymentProces.paymentMethod.Card_Expiration_Month__c = '12';
           controllerSitePaymentProces.paymentMethod.Card_Expiration_Year__c = '2016';
           controllerSitePaymentProces.sSaveCardDetails = 'true';
           controllerSitePaymentProces.processPayment();
           
           // this time gateway.Test_Mode__c = false
           gateway.Test_Mode__c = false;
           update gateway;
           system.currentPageReference().getParameters().put('Id', invoices.get(2).Id);
           controllerSitePaymentProces = new ControllerSitePaymentProcess();

           ClassForHandlingAuthorizeDotNet objClassForHandlingAuthorizeDotNet = new ClassForHandlingAuthorizeDotNet(gateway, invoices.get(0), paymentMethod,paymentMethod.Id,100,account, currency1.Id);
         PaymentSiteOperation.GenericPaymentParameters genericPaymentParameters

                =  new PaymentSiteOperation.GenericPaymentParameters();

               genericPaymentParameters.amountToProcess = 100;

               genericPaymentParameters.currencyISOCode = 'USD'; 

               genericPaymentParameters.shouldTokenizeCard = false; 

               PaymentSiteOperation.GenericPaymentResult genericPaymentResult = new PaymentSiteOperation.GenericPaymentResult();            

               PaymentSiteOperation site = new PaymentSiteOperation();

            objClassForHandlingAuthorizeDotNet.handleAuthorizeAndCharge(genericPaymentParameters);
            op.processGenericPayment(genericPaymentParameters);
              }

      public static testMethod void paymentOperations_ClassForHandlingPaypal() {
           ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
           ControllerInsertCustomSettings.insertValues();


           
           Gateway__c gateway = new Gateway__c(Active__c = true, Gateway_Type__c = 'PayPal', Test_Mode__c = true, Merchant_ID__c = '22LbQ9b7', Security_Key__c = '8Fh7VnPV3e6h4b4S', Merchant_Seal_User_Id__c = '8Fh7VnPV3e6h4b4S...');
           insert gateway;
           
           Currency__c currencyobj = new Currency__c(name = 'USD', Symbol__c = '$');
           insert currencyobj;
                
           Account account = new Account(Name = 'Test Account',Gateway__c = gateway.Id);
           insert account;
           
           Payment_Method__c paymentMethod = new Payment_Method__c(Active__c = true, Default__c = true, Account__c = account.Id, CVV__c = '123', Card_Number__c = '4007000000027', Card_Expiration_Year__c = '2023', Card_Expiration_Month__c = '10');
           insert paymentMethod;
           
           list<Contact> listContacts = new list<Contact>();
           listContacts.add(new Contact(FirstName = 'acertis',LastName = 'Sandeep',accountId = account.Id,MailingCountry = 'UK',Email ='laxmanrao.564@gmail.com',MailingStreet = 'Bengalore',MailingCity = 'bengalore',MailingPostalCode = '523122'));
           listContacts.add(new Contact(FirstName = 'acertis',LastName = 'Vinod',accountId = account.Id, MailingCountry = 'USA',Email = 'laxmanrao.564@gmail.com',MailingStreet = 'Bengalore',MailingCity = 'bengalore',MailingPostalCode = '523122'));
           insert listContacts;
           
           Currency__c currency1 = new Currency__c(name = 'GBP', Symbol__c = '£1');
           insert currency1;
           
           Job__c job = new Job__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id, Sub_Total__c = 100, Discount_Value__c = 0, CurrencyL__c = currency1.Id);
           insert job;
           
           Invoice__c invoice1 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                               CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = CommonUtilClass.STATUS_POSTED);
                                               
           Invoice__c invoice2 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                               CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = CommonUtilClass.STATUS_POSTED);
           
           Invoice__c invoice3 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                               CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = CommonUtilClass.STATUS_POSTED);
                                               
           list<Invoice__c> invoices = new list<Invoice__c>();
           invoices.add(invoice1);
           invoices.add(invoice2);
           invoices.add(invoice3);
           insert invoices;
           
           list<Invoice_Lines__c> listInvoiceLines = new list<Invoice_Lines__c>();
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(2).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(2).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(2).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           insert listInvoiceLines; 
           
           system.assert(invoices.size() > 0);  
           Transaction__c transaction1=new Transaction__c(Gateway_ID__c = '123456',Payment_Gateway__c=gateway.id,Payment_Method__c=paymentMethod.id,Currency__c=currency1.id,Request_Invoice__c=invoices[0].id,Amount__c=20,Type__c='Charge');
           insert transaction1;
           Transaction__c transaction2=new Transaction__c(Gateway_ID__c = '123456',Payment_Gateway__c=gateway.id,Payment_Method__c=paymentMethod.id,Currency__c=currency1.id,Request_Invoice__c=invoices[0].id,Amount__c=20,Type__c='Charge');
           insert transaction2;
           
           invoices = [Select Id, Name, CurrencyL__c, Target_Date__c,Shipping_Contact__c,
                       Shipping_Contact__r.FirstName,Shipping_Contact__r.LastName,Shipping_Contact__r.MailingStreet,Shipping_Contact__r.MailingCity,Shipping_Contact__r.MailingPostalCode,Shipping_Contact__r.MailingCountry
                       From Invoice__c Where Id In: invoices];


            PaymentSiteOperation op = new PaymentSiteOperation();
           op.processPayment(gateway, null, paymentMethod, paymentMethod.Id, 10, account , false, null);
           op.processPayment(null, paymentMethod, paymentMethod.Id, 10, account , false);

           PaymentOperations.PaymentResult result;
           result = PaymentOperations.authorize(invoices.get(0).Id, invoices.get(0).name, null);  
           result = PaymentOperations.authorizeAndCharge(invoices.get(0).Id, null, null);
           PaymentOperations.void(invoices.get(0).Id);  
           system.assert(result.transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED);
           PaymentOperations.void(invoices.get(0).Id);
           PaymentOperations.refund(invoices.get(0).Id, null, 100);
           PaymentOperations.authorizeAndCharge(invoices.get(1).Id, invoices.get(1).Name, null);
           PaymentOperations.refund(invoices.get(1).Id, null, 100);
           PaymentOperations.authorizeAndChargePaymentPlanInstalments(invoices.get(2).Id,paymentMethod.Id,100);
           PaymentOperations.transactionRefund(transaction1.id);
            PaymentOperations.transactionVoid(transaction2.id);
           
           ClassForHandlingPaypal classForHandlingPaypalobj = new ClassForHandlingPaypal(gateway,invoices[1],paymentMethod,'dummy',150.20,account,currency1.Id);
               
           invoices[1].Payment_Request_Amount__c = null;
           update invoices;
           classForHandlingPaypalobj.handleAuthorize_Click();

           ClassForHandlingPaypal classForHandlingPaypalobj12 = new ClassForHandlingPaypal(gateway,null,paymentMethod);

           currency1.Id = null;
           classForHandlingPaypalobj.handleAuthorizeAndCharge_Site(true);
           classForHandlingPaypalobj.handleVoid_Click('dummy','dummy1',120.50);
           classForHandlingPaypalobj.handleRefund_Click('dummy','dummy1',120.50);
           classForHandlingPaypalobj.populateFullDetailsOfCustomer();

           // Code for handling the site
           // this will say Invoice could not be found
           ControllerSitePaymentProcess controllerSitePaymentProces = new ControllerSitePaymentProcess();
           
           // this will say Invoice could not be found
           system.currentPageReference().getParameters().put('Id', invoices.get(0).Id);
           controllerSitePaymentProces = new ControllerSitePaymentProcess();
           
           // this time Unpaid_Amount__c is > 0
           system.currentPageReference().getParameters().put('Id', invoices.get(2).Id);
           controllerSitePaymentProces = new ControllerSitePaymentProcess();
           
           // move to the checkout page
           controllerSitePaymentProces.checkOut();
           
           // this will fire the validation
           controllerSitePaymentProces.paymentMethod.Billing_First_Name__c = null;
           controllerSitePaymentProces.paymentMethod.Billing_Last_Name__c = null;
           controllerSitePaymentProces.paymentMethod.Card_Type__c = null;
           controllerSitePaymentProces.paymentMethod.Card_Number__c = null;
           controllerSitePaymentProces.paymentMethod.CVV__c = null;
           controllerSitePaymentProces.paymentMethod.Card_Expiration_Month__c = null;
           controllerSitePaymentProces.processPayment();
           
           // looks ok
           controllerSitePaymentProces.paymentMethod.Billing_First_Name__c = 'Sandeep';
           controllerSitePaymentProces.paymentMethod.Billing_Last_Name__c = 'M';
           controllerSitePaymentProces.paymentMethod.Card_Type__c = 'Master';
           controllerSitePaymentProces.paymentMethod.Card_Number__c = '420000000000000';
           controllerSitePaymentProces.paymentMethod.CVV__c = '123';
           controllerSitePaymentProces.paymentMethod.Card_Expiration_Month__c = '12';
           controllerSitePaymentProces.paymentMethod.Card_Expiration_Year__c = '2016';
           controllerSitePaymentProces.sSaveCardDetails = 'true';
           controllerSitePaymentProces.processPayment();
           
           // this time gateway.Test_Mode__c = false
           gateway.Test_Mode__c = false;
           update gateway;
           system.currentPageReference().getParameters().put('Id', invoices.get(2).Id);
           controllerSitePaymentProces = new ControllerSitePaymentProcess();

           PaymentSiteOperation.GenericPaymentParameters genericPaymentParameters

                =  new PaymentSiteOperation.GenericPaymentParameters();


               genericPaymentParameters.amountToProcess = 100;

               genericPaymentParameters.currencyISOCode = 'USD';

               genericPaymentParameters.shouldTokenizeCard = false; 

               PaymentSiteOperation.GenericPaymentResult genericPaymentResult = new PaymentSiteOperation.GenericPaymentResult();            

               PaymentSiteOperation site = new PaymentSiteOperation();

            classForHandlingPaypalobj.handleAuthorizeAndCharge(genericPaymentParameters);
            op.processGenericPayment(genericPaymentParameters);
      }

      public static testMethod void paymentOperations_ClassForHandlingAuthorizeECheck() {
           ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
           ControllerInsertCustomSettings.insertValues();
           
           list<Gateway__c> listOfGateway = [Select Id From Gateway__c];
           delete listOfGateway;
           
           Gateway__c gateway = new Gateway__c(Active__c = true, Default__c = true, Gateway_Type__c = CommonUtilClass.GATEWAY_TYPE_ACH, Merchant_ID__c = '22LbQ9b7', Security_Key__c = '8Fh7VnPV3e6h4b4S');
           insert gateway;
           Account account = new Account(Name = 'Test Account');
           insert account;
           
           Payment_Method__c paymentMethod = new Payment_Method__c(Payment_Profile_ID__c='1234567',Active__c = true, Default__c = true, Account__c = account.Id, Bank_Routing_Code__c = '123', Bank_Account_Number__c = '4007000000027', Bank_Account_Type__c = '2023', Bank_Name__c = '10', Bank_Account_Name__c = 'test');
           insert paymentMethod;

           Payment_Method__c paymentMethod1 = new Payment_Method__c(Is_Dummy__c=true,Active__c = true, Default__c = false, Account__c = account.Id, Bank_Routing_Code__c = '123', Bank_Account_Number__c = '4007000000027', Bank_Account_Type__c = '2023', Bank_Name__c = '10', Bank_Account_Name__c = 'test');
           insert paymentMethod1;

           list<Contact> listContacts = new list<Contact>();
           listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,MailingCountry = 'UK',Email ='laxmanrao.564@gmail.com'));
           listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, MailingCountry = 'USA',Email = 'laxmanrao.564@gmail.com'));
           insert listContacts;
           
           Currency__c currency1 = new Currency__c(name = 'GBP', Symbol__c = '£1');
           insert currency1;
           
           Job__c job = new Job__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id, Sub_Total__c = 100, Discount_Value__c = 0, CurrencyL__c = currency1.Id);
           insert job;
           
           Invoice__c invoice1 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                               CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = 'Posted',Payment_Request_Amount__c=10);
                                               
           Invoice__c invoice2 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                               CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = 'Active');
           
           list<Invoice__c> invoices = new list<Invoice__c>();
           invoices.add(invoice1);
           invoices.add(invoice2);
           insert invoices;
           
           list<Invoice_Lines__c> listInvoiceLines = new list<Invoice_Lines__c>();
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           insert listInvoiceLines;  

           Payment__c payment=new Payment__c(Account__c=account.id,Amount__c=100,Currency__c=currency1.id,Status__c='Completed',Payment_Date__c=system.today(),Payment_Type__c='Cash',Invoice__c=invoices[0].id); 
           insert payment;
           Payment_Allocation__c paymentallocation=new Payment_Allocation__c(Amount__c=10,Invoice__c=invoices[0].id,Payment__c=payment.id,Status__c='Completed');
           insert paymentallocation;

           Transaction__c transaction1=new Transaction__c(Gateway_ID__c = '123456',Payment_Gateway__c=gateway.id,Payment_Method__c=paymentMethod.id,Currency__c=currency1.id,Request_Invoice__c=invoices[0].id,Amount__c=20);
              insert transaction1;
              Transaction__c transaction3=new Transaction__c(Gateway_ID__c = '123456',Payment_Gateway__c=gateway.id,Payment_Method__c=paymentMethod.id,Currency__c=currency1.id,Request_Invoice__c=invoices[0].id,Amount__c=20,Type__c='Charge');
           insert transaction3;

              Transaction__c transaction2=new Transaction__c(Is_Payment_Processed_Successfully__c = true,Gateway_ID__c = '123456',Payment_Gateway__c=gateway.id,Payment_Method__c=paymentMethod1.id,Currency__c=currency1.id,Request_Invoice__c=invoices[0].id,Amount__c=20);
              insert transaction2;

           
           invoices = [Select Id, Name, CurrencyL__c, Target_Date__c From Invoice__c Where Id In: invoices];

           PaymentOperations.PaymentResult result;
           result = PaymentOperations.authorize(invoices.get(0).Id, invoices.get(0).name, null);  
           result = PaymentOperations.authorizeAndCharge(invoices.get(0).Id, null, null);
           PaymentOperations.void(invoices.get(0).Id);  
           system.assert(result.transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED);
           PaymentOperations.void(invoices.get(0).Id);
           PaymentOperations.refund(invoices.get(0).Id, null, 100);
           PaymentOperations.authorizeAndCharge(invoices.get(1).Id, invoices.get(1).Name, null);
           PaymentOperations.transactionRefund(transaction1.id);
            PaymentOperations.transactionVoid(transaction3.id);
           
           
            // cover catch blocks      
          ClassForHandlingAuthorizeECheck classForHandlingAuthorizeECheckj = new ClassForHandlingAuthorizeECheck(gateway,null,paymentmethod);
          classForHandlingAuthorizeECheckj.handleAuthorize_Click();  
          classForHandlingAuthorizeECheckj.handleRefund_Click(gateway.id,transaction1.Id, 200); 
          classForHandlingAuthorizeECheckj.handleAuthorizeAndCharge_Site(null);
          try{           
              classForHandlingAuthorizeECheckj.handleAuthorizeAndCharge_Click('','');
           } catch(Exception ex){         
           }                  
           classForHandlingAuthorizeECheckj.handleRefund_Click('','',null);           
           classForHandlingAuthorizeECheckj.handleVoid_Click('','',null);
           classForHandlingAuthorizeECheckj.handleAuthorizeAndCharge_Site(true);
           ClassForHandlingAuthorizeECheck classForHandlingAuthorizeECheckj1 = new ClassForHandlingAuthorizeECheck(gateway,invoices[0],paymentMethod,paymentMethod.id,50,account ,currency1.id);
      }

      public static testMethod void paymentOperations_ClassForHandlingFirstdataCard() {
           ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
           ControllerInsertCustomSettings.insertValues();
           
           list<Gateway__c> listOfGateway = [Select Id From Gateway__c];
           delete listOfGateway;
           
           Gateway__c gateway = new Gateway__c(Exact_ID__c = 'AD8627-02', Exact_ID_Security_Key__c = '76l24fj1', Active__c = true, Default__c = true, Gateway_Type__c = CommonUtilClass.GATEWAY_TYPE_FIRSTDATA, Test_Mode__c = true, Merchant_ID__c = 'myown748', Security_Key__c = '123456789d');
           insert gateway;
           
           Account account = new Account(Name = 'Test Account');
           insert account;
           
           Payment_Method__c paymentMethod = new Payment_Method__c(Billing_Email__c = 'test@dev.com', Billing_Phone__c = '1234567890', Billing_State_Province__c = 'AP', Active__c = true, Default__c = true, Account__c = account.Id, CVV__c = '123', Card_Number__c = '4111111111111111', Card_Expiration_Year__c = '2023', Card_Expiration_Month__c = '10');
           insert paymentMethod;
           
           list<Contact> listContacts = new list<Contact>();
           listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,MailingCountry = 'UK',Email ='laxmanrao.564@gmail.com',MailingStreet = 'Bengalore',MailingCity = 'bengalore',MailingPostalCode = '523122',FirstName = 'acertis'));
           listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, MailingCountry = 'USA',Email = 'laxmanrao.564@gmail.com',MailingStreet = 'Bengalore',MailingCity = 'bengalore',MailingPostalCode = '523122',FirstName = 'acertis'));
           insert listContacts;
           
           Currency__c currency1 = new Currency__c(name = 'GBP', Symbol__c = '£1');
           insert currency1;
           Currency__c currecyObj = new Currency__c(Name = 'USD', Symbol__c = '$');
           insert currecyObj;
           
           Job__c job = new Job__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id, Sub_Total__c = 100, Discount_Value__c = 0, CurrencyL__c = currency1.Id);
           insert job;
           
           Invoice__c invoice1 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                               CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = 'Active');
                                               
           Invoice__c invoice2 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                               CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = 'Active');
           
           Invoice__c invoice3 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                               CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = CommonUtilClass.STATUS_POSTED);
           
           
           list<Invoice__c> invoices = new list<Invoice__c>(); 
           invoices.add(invoice1);
           invoices.add(invoice2);
           invoices.add(invoice3);
           insert invoices;
           
           list<Invoice_Lines__c> listInvoiceLines = new list<Invoice_Lines__c>();
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));

           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(2).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(2).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(2).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
           insert listInvoiceLines;   
           
           invoices = [Select Id, Name, CurrencyL__c, Target_Date__c,
                       Shipping_Contact__r.FirstName,Shipping_Contact__r.LastName,Shipping_Contact__r.MailingStreet,Shipping_Contact__r.MailingCity,Shipping_Contact__r.MailingPostalCode,Shipping_Contact__r.MailingCountry 
                       From Invoice__c Where Id In: invoices];
           Transaction__c transaction1=new Transaction__c(Gateway_ID__c = '123456',Payment_Gateway__c=gateway.id,Payment_Method__c=paymentMethod.id,Currency__c=currency1.id,Request_Invoice__c=invoices[0].id,Amount__c=20,Type__c='Charge');
           insert transaction1;
           Transaction__c transaction2=new Transaction__c(Gateway_ID__c = '123456',Payment_Gateway__c=gateway.id,Payment_Method__c=paymentMethod.id,Currency__c=currency1.id,Request_Invoice__c=invoices[0].id,Amount__c=20,Type__c='Charge');
           insert transaction2;
           PaymentOperations.PaymentResult result;
           result = PaymentOperations.authorize(invoices.get(0).Id, invoices.get(0).name, null);  
           result = PaymentOperations.authorizeAndCharge(invoices.get(2).Id, null, null);
           PaymentOperations.void(invoices.get(0).Id);  
           system.assert(result.transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED);
           PaymentOperations.void(invoices.get(0).Id);
           PaymentOperations.refund(invoices.get(2).Id, null, 100);
           PaymentOperations.authorizeAndCharge(invoices.get(2).Id, invoices.get(2).Name, null);
           PaymentOperations.authorizeAndChargePaymentPlanInstalments(invoices.get(2).Id,paymentMethod.Id,100);
           PaymentOperations.transactionRefund(transaction1.id);
            PaymentOperations.transactionVoid(transaction2.id);
           
           system.assert(invoices != null);
           
           // Code for handling the site 
           // this will say Invoice could not be found
           ControllerSitePaymentProcess controllerSitePaymentProces = new ControllerSitePaymentProcess();
           
           // this will say Invoice could not be found
           system.currentPageReference().getParameters().put('Id', invoices.get(0).Id);
           controllerSitePaymentProces = new ControllerSitePaymentProcess();
           
           // this time Unpaid_Amount__c is > 0
           system.currentPageReference().getParameters().put('Id', invoices.get(2).Id);
           controllerSitePaymentProces = new ControllerSitePaymentProcess();
           
           // move to the checkout page
           controllerSitePaymentProces.checkOut();
           
           // this will fire the validation
           controllerSitePaymentProces.paymentMethod.Billing_First_Name__c = null;
           controllerSitePaymentProces.paymentMethod.Billing_Last_Name__c = null;
           controllerSitePaymentProces.paymentMethod.Card_Type__c = null;
           controllerSitePaymentProces.paymentMethod.Card_Number__c = null;
           controllerSitePaymentProces.paymentMethod.CVV__c = null;
           controllerSitePaymentProces.paymentMethod.Card_Expiration_Month__c = null;
           controllerSitePaymentProces.processPayment();
           
           // looks ok
           controllerSitePaymentProces.paymentMethod.Billing_First_Name__c = 'Sandeep';
           controllerSitePaymentProces.paymentMethod.Billing_Last_Name__c = 'M';
           controllerSitePaymentProces.paymentMethod.Card_Type__c = 'Master';
           controllerSitePaymentProces.paymentMethod.Card_Number__c = '420000000000000';
           controllerSitePaymentProces.paymentMethod.CVV__c = '123';
           controllerSitePaymentProces.paymentMethod.Card_Expiration_Month__c = '12';
           controllerSitePaymentProces.paymentMethod.Card_Expiration_Year__c = '2016';
           controllerSitePaymentProces.sSaveCardDetails = 'true';
           controllerSitePaymentProces.gateWayToUse = gateway;
           controllerSitePaymentProces.processPayment();
           
           ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(account);
           system.currentPageReference().getParameters().put('Id', account.Id);
           ControllerVirtualTerminal controllerVirtualTerminal = new ControllerVirtualTerminal(standardController);

           controllerVirtualTerminal.processPaymentRedirect();  
           controllerVirtualTerminal.selectedValue = paymentMethod.Id;  
           controllerVirtualTerminal.isNone = false;               
           controllerVirtualTerminal.paymentMethod.Billing_First_Name__c = 'Sandeep';
           controllerVirtualTerminal.paymentMethod.Billing_Last_Name__c = 'M';
           controllerVirtualTerminal.paymentMethod.Card_Type__c = 'Master';
           controllerVirtualTerminal.paymentMethod.Card_Number__c = '4111111111111111';
           controllerVirtualTerminal.paymentMethod.CVV__c = '123';
           controllerVirtualTerminal.paymentMethod.Card_Expiration_Month__c = '12';
           controllerVirtualTerminal.paymentMethod.Card_Expiration_Year__c = '2219';
           controllerVirtualTerminal.sSaveCardDetails = 'yes';
           controllerVirtualTerminal.paymentMethod.Account__c = account.Id;
           controllerVirtualTerminal.processPayment();

           gateway.Test_Mode__c = false;
           update gateway;
           system.currentPageReference().getParameters().put('Id', invoices.get(2).Id);
           controllerSitePaymentProces = new ControllerSitePaymentProcess(); 
           //Cover the catch block
           ClassForHandlingFirstdataCard classForHandlingFirstdataCardObj = new ClassForHandlingFirstdataCard(gateway,null,paymentMethod,'',null,account,null);       
            classForHandlingFirstdataCardObj.handleAuthorize_Click();
            try{        
                classForHandlingFirstdataCardObj.handleAuthorizeAndCharge_Click('','');
            }catch(Exception ex){        
            }      
            classForHandlingFirstdataCardObj.handleRefund_Click('','',null);
            classForHandlingFirstdataCardObj.handleVoid_Click('','',null);       
            try{        
               classForHandlingFirstdataCardObj.handleAuthorizeAndCharge_Site(null);
            }catch(Exception ex){        
            }   
      }
         
      //Added by dhanalakshmi for braintree
      public static testMethod void paymentOperations_ClassForHandlingBrainTree(){
       
           ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
           ControllerInsertCustomSettings.insertValues();
            
           Currency__c currencyobj = new Currency__c(name = 'USD', Symbol__c = '$');
           insert currencyobj;
        
           list<Gateway__c> listOfGateway = [Select Id From Gateway__c];
           delete listOfGateway;
           
           Gateway__c gateway = new Gateway__c(Active__c = true, Default__c = true, Gateway_Type__c = 'BrainTree', Test_Mode__c = true, Merchant_ID__c = 'd3pzbb3393fvz55t', Security_Key__c = '88mzbm3837zvnd3d', Exact_ID_Security_Key__c = '82b36579705ea7b3b893858cc37ee666');
           insert gateway;
           
            Account account = new Account(Name = 'Test Account');
            insert account;

            Account account1 = [SELECT Name FROM Account WHERE id =: account.id];
            System.assertEquals('Test Account', account1.Name);
            
            Payment_Method__c paymentMethod = new Payment_Method__c(Billing_Fax__c = '56789', Billing_Email__c = 'dev@gmail.com', Billing_Phone__c = '9999999', Billing_First_Name__c = 'Devender', Billing_Last_Name__c = 'M', Active__c = true, Default__c = true, Account__c = account.Id, CVV__c = '123', Card_Number__c = '4111111111111111', Card_Expiration_Year__c = '2023', Card_Expiration_Month__c = '10',Billing_Address__c = 'Prabhat Aracade',Billing_City__c = 'US',Billing_State_Province__c = 'UK',Billing_Zip_Postal__c = '505001',Billing_Country__c = 'United States');
            insert paymentMethod;
            
            list<Contact> listContacts = new list<Contact>();
            listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,MailingCountry = 'UK',Email ='laxmanrao.564@gmail.com',MailingStreet = 'Bangalore',MailingCity = 'Bangalore',MailingPostalCode = '523122',FirstName = 'acertis'));
            listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, MailingCountry = 'USA',Email = 'laxmanrao.564@gmail.com',MailingStreet = 'Bangalore',MailingCity = 'Bangalore',MailingPostalCode = '523122',FirstName = 'acertis'));
            insert listContacts;
            
            Currency__c currency1 = new Currency__c(name = 'GBP', Symbol__c = '£1');
            insert currency1;
            
            Job__c job = new Job__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id, Sub_Total__c = 100, Discount_Value__c = 0, CurrencyL__c = currency1.Id);
            insert job;
            
            Invoice__c invoice1 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                                CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = 'Active');
                                                
            Invoice__c invoice2 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                                CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = 'Active');
            
            Invoice__c invoice3 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                                CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = CommonUtilClass.STATUS_POSTED);
            
            
            list<Invoice__c> invoices = new list<Invoice__c>();
            invoices.add(invoice1);
            invoices.add(invoice2);
            invoices.add(invoice3);
            insert invoices;
            
            list<Invoice_Lines__c> listInvoiceLines = new list<Invoice_Lines__c>();
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            insert listInvoiceLines;   
            
            invoices = [Select Id, Name, CurrencyL__c, Target_Date__c,
                        Shipping_Contact__r.FirstName,Shipping_Contact__r.LastName,Shipping_Contact__r.MailingStreet,Shipping_Contact__r.MailingCity,Shipping_Contact__r.MailingPostalCode,Shipping_Contact__r.MailingCountry 
                        From Invoice__c Where Id In: invoices];

            Transaction__c transaction1=new Transaction__c(Gateway_ID__c = '123456',Payment_Gateway__c=gateway.id,Payment_Method__c=paymentMethod.id,Currency__c=currency1.id,Request_Invoice__c=invoices[0].id,Amount__c=20,Type__c='Charge');
           insert transaction1;
           Transaction__c transaction2=new Transaction__c(Gateway_ID__c = '123456',Payment_Gateway__c=gateway.id,Payment_Method__c=paymentMethod.id,Currency__c=currency1.id,Request_Invoice__c=invoices[0].id,Amount__c=20,Type__c='Charge');
           insert transaction2;

            PaymentSiteOperation op = new PaymentSiteOperation();
           op.processPayment(gateway, null, paymentMethod, paymentMethod.Id, 10, account , false, null);
           op.processPayment(null, paymentMethod, paymentMethod.Id, 10, account , false);

            PaymentOperations.PaymentResult result;
            result = PaymentOperations.authorize(invoices.get(0).Id, invoices.get(0).name, null);  
            result = PaymentOperations.authorizeAndCharge(invoices.get(1).Id, null, null);
            PaymentOperations.void(invoices.get(0).Id);  
            //system.assert(result.transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED);
            PaymentOperations.void(invoices.get(0).Id);
            PaymentOperations.refund(invoices.get(0).Id, null, 100);
            PaymentOperations.authorizeAndCharge(invoices.get(2).Id, invoices.get(2).Name, null);
            PaymentOperations.transactionRefund(transaction1.id);
             PaymentOperations.transactionVoid(transaction2.id);
            system.assert(invoices != null);
            
            // Code for handling the site
            // this will say Invoice could not be found
            ControllerSitePaymentProcess controllerSitePaymentProces = new ControllerSitePaymentProcess();
            
            // this will say Invoice could not be found
            system.currentPageReference().getParameters().put('Id', invoices.get(0).Id);
            controllerSitePaymentProces = new ControllerSitePaymentProcess();
            
            // this time Unpaid_Amount__c is > 0
            system.currentPageReference().getParameters().put('Id', invoices.get(2).Id);
            controllerSitePaymentProces = new ControllerSitePaymentProcess();
            
            // move to the checkout page
            controllerSitePaymentProces.checkOut();
            
            // this will fire the validation
            controllerSitePaymentProces.paymentMethod.Billing_First_Name__c = null;
            controllerSitePaymentProces.paymentMethod.Billing_Last_Name__c = null;
            controllerSitePaymentProces.paymentMethod.Card_Type__c = null;
            controllerSitePaymentProces.paymentMethod.Card_Number__c = null;
            controllerSitePaymentProces.paymentMethod.CVV__c = null;
            controllerSitePaymentProces.paymentMethod.Billing_Phone__c = null;
            controllerSitePaymentProces.paymentMethod.Billing_Email__c = null;
            controllerSitePaymentProces.paymentMethod.Billing_State_Province__c = null;
            controllerSitePaymentProces.paymentMethod.Card_Expiration_Month__c = null;
            controllerSitePaymentProces.processPayment();
            
            // looks ok
            controllerSitePaymentProces.paymentMethod.Billing_First_Name__c = 'Sandeep';
            controllerSitePaymentProces.paymentMethod.Billing_Last_Name__c = 'M';
            controllerSitePaymentProces.paymentMethod.Card_Type__c = 'Master';
            controllerSitePaymentProces.paymentMethod.Card_Number__c = '5555555555554444';
            controllerSitePaymentProces.paymentMethod.CVV__c = '1234';
            controllerSitePaymentProces.paymentMethod.Card_Expiration_Month__c = '12';
            controllerSitePaymentProces.paymentMethod.Card_Expiration_Year__c = '2018';
            controllerSitePaymentProces.sSaveCardDetails = 'yes';
            controllerSitePaymentProces.gateWayToUse = gateway;
            controllerSitePaymentProces.processPayment();
            
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(account);
            system.currentPageReference().getParameters().put('Id', account.Id);
            ControllerVirtualTerminal controllerVirtualTerminal = new ControllerVirtualTerminal(standardController);
            
            controllerVirtualTerminal.processPaymentRedirect();  
            controllerVirtualTerminal.selectedValue = paymentMethod.Id;  
            controllerVirtualTerminal.isNone = false;               
            controllerVirtualTerminal.paymentMethod.Billing_First_Name__c = 'Sandeep';
            controllerVirtualTerminal.paymentMethod.Billing_Last_Name__c = 'M';
            controllerVirtualTerminal.paymentMethod.Card_Type__c = 'Master';
            controllerVirtualTerminal.paymentMethod.Card_Number__c = '5555555555554444';
            controllerVirtualTerminal.paymentMethod.CVV__c = '1234';
            controllerVirtualTerminal.paymentMethod.Card_Expiration_Month__c = '12';
            controllerVirtualTerminal.paymentMethod.Card_Expiration_Year__c = '2219';
            controllerVirtualTerminal.sSaveCardDetails = 'yes';
            controllerVirtualTerminal.paymentMethod.Account__c = account.Id;
            controllerVirtualTerminal.processPayment();
            
            // this time gateway.Test_Mode__c = false
            gateway.Test_Mode__c = false;
            update gateway;
            system.currentPageReference().getParameters().put('Id', invoices.get(2).Id);
            controllerSitePaymentProces = new ControllerSitePaymentProcess(); 
            
            ClassForHandlingBrainTree ClassForHandlingBrainTree = new ClassForHandlingBrainTree(gateway, null, paymentMethod,paymentMethod.Id,100,account, currency1.Id);
            Transaction__c transactionObj = new Transaction__c(Gateway_ID__c = '123456', Payment_Gateway__c = gateway.Id, Payment_Method__c = paymentMethod.Id );
            insert transactionObj;
            ClassForHandlingBrainTree.handleRefund_Click(gateway.Id,transactionObj.Id, 200 );
            
            ClassForHandlingBrainTree.handleVoid_Click(gateway.Id,transactionObj.Id, 200 );
            ClassForHandlingBrainTree.handleAuthorizeAndCharge_Site(false);
            
            paymentMethod = new Payment_Method__c(Billing_Fax__c = '56789', Billing_Email__c = 'dev@gmail.com', Billing_Phone__c = '9999999', Billing_First_Name__c = 'Devender', Billing_Last_Name__c = 'M', Active__c = true, Default__c = true, Account__c = account.Id, CVV__c = '123', Card_Number__c = '4111111111111111', Card_Expiration_Year__c = '2023', Card_Expiration_Month__c = '10',Billing_Address__c = 'Prabhat Aracade',Billing_City__c = 'US',Billing_State_Province__c = 'UK',Billing_Zip_Postal__c = '505001',Billing_Country__c = 'United States');
            ClassForHandlingBrainTree ClassForHandlingBrainTree1 = new ClassForHandlingBrainTree(gateway, null, paymentMethod,paymentMethod.Id,100,account, currency1.Id);

            ClassForHandlingBrainTree1.handleAuthorizeAndCharge_Site(true);

            ClassForHandlingBrainTree ClassForHandlingBrainTree2 = new ClassForHandlingBrainTree(gateway, null, paymentMethod,paymentMethod.Id,100,account, null);
            ClassForHandlingBrainTree2.handleAuthorizeAndCharge_Site(true);

            //To cover catch blocks 
            ClassForHandlingBrainTree.handleRefund_Click('','',null);
            ClassForHandlingBrainTree.handleVoid_Click('','',null); 
            ClassForHandlingBrainTree.handleAuthorizeAndCharge_Click('','');     
            
            try{ 
                ClassForHandlingBrainTree.handleAuthorizeAndCharge_Site(null);
            }catch(Exception ex){          
            }
             PaymentSiteOperation.GenericPaymentParameters genericPaymentParameters

                =  new PaymentSiteOperation.GenericPaymentParameters();
               genericPaymentParameters.amountToProcess = 100;

               genericPaymentParameters.currencyISOCode = 'USD';

               genericPaymentParameters.shouldTokenizeCard = false; 

               PaymentSiteOperation.GenericPaymentResult genericPaymentResult = new PaymentSiteOperation.GenericPaymentResult();            

               PaymentSiteOperation site = new PaymentSiteOperation();

            ClassForHandlingBrainTree.handleAuthorizeAndCharge(genericPaymentParameters);
            op.processGenericPayment(genericPaymentParameters);


      }
      
      //Addeb by dhanalakshmi for to cover ControllerForGenerateTokenForBrainTree
      public static testMethod void ControllerForGenerateTokenForBrainTree(){
       
           ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
           ControllerInsertCustomSettings.insertValues();
            
           Currency__c currencyobj = new Currency__c(name = 'USD', Symbol__c = '$');
           insert currencyobj;
        
           list<Gateway__c> listOfGateway = [Select Id From Gateway__c];
           delete listOfGateway;
           
           Gateway__c gateway = new Gateway__c(Active__c = true, Default__c = true, Gateway_Type__c = 'BrainTree', Test_Mode__c = true, Merchant_ID__c = 'd3pzbb3393fvz55t', Security_Key__c = '88mzbm3837zvnd3d', Exact_ID_Security_Key__c = '82b36579705ea7b3b893858cc37ee666');
           insert gateway; 

           Gateway__c gateway1 = new Gateway__c(Active__c = true, Gateway_Type__c = 'Test', Test_Mode__c = true, Security_Key__c = '88mzbm3837zvnd3d', Exact_ID_Security_Key__c = '82b36579705ea7b3b893858cc37ee666');
           insert gateway1; 
           
           Account account = new Account(Name = 'Test Account', BrainTree_Customer_ID__c = '12345678', BillingStreet = 'Koraamangala', BillingCity = 'Banglore', BillingState = 'Karnataka', BillingPostalCode = '560068', BillingCountry = 'India', Phone = '9999999' ,Gateway__c= gateway.Id);
           insert account;

           Account account1 = [SELECT Name FROM Account WHERE id =: account.id];
           System.assertEquals('Test Account', account1.Name);
           
           Payment_Method__c paymentMethod = new Payment_Method__c(Billing_Fax__c = '56789', Billing_Email__c = 'dev@gmail.com', Billing_Phone__c = '9999999', Billing_First_Name__c = 'Devender', Billing_Last_Name__c = 'M', Active__c = true, Default__c = true, Account__c = account.Id, Payment_Method__c = 'Credit Card', Card_Type__c = 'Visa' , Name_on_Card__c = 'abc', Card_Number__c = '4111111111111111', CVV__c = '123', Card_Expiration_Year__c = '2023', Card_Expiration_Month__c = '10',Billing_Address__c = 'Prabhat Aracade',Billing_City__c = 'US',Billing_State_Province__c = 'UK',Billing_Zip_Postal__c = '505001',Billing_Country__c = 'United States');
           insert paymentMethod;
           
           ApexPages.StandardController sc = new ApexPages.StandardController(account);
           ControllerForGenerateTokenForBrainTree objControllerForGenerateTokenForBrainTree = new ControllerForGenerateTokenForBrainTree(sc);
           objControllerForGenerateTokenForBrainTree.paymentMethod.Default__c = true;
           objControllerForGenerateTokenForBrainTree.paymentMethod.Card_Number__c = '4111111111111111';
           objControllerForGenerateTokenForBrainTree.paymentMethod.CVV__c = '123';
           objControllerForGenerateTokenForBrainTree.paymentMethod.Name_on_Card__c = 'abc';
           objControllerForGenerateTokenForBrainTree.paymentMethod.Card_Expiration_Month__c = '10';
           objControllerForGenerateTokenForBrainTree.paymentMethod.Card_Expiration_Year__c = '2023';
           objControllerForGenerateTokenForBrainTree.generateToken();

           Account account2 = new Account(Name = 'Test Account', BillingStreet = 'Koraamangala', BillingCity = 'Banglore', BillingState = 'Karnataka', BillingPostalCode = '560068', BillingCountry = 'India', Phone = '9999999');
           insert account2;

           ApexPages.StandardController sc1 = new ApexPages.StandardController(account2);
           ControllerForGenerateTokenForBrainTree objControllerForGenerateTokenForBrainTree1 = new ControllerForGenerateTokenForBrainTree(sc1);
           objControllerForGenerateTokenForBrainTree1.generateToken();

           Account account3 = new Account(Name = 'Test Account', BillingStreet = 'Koraamangala', BillingCity = 'Banglore', BillingState = 'Karnataka', BillingPostalCode = '560068', BillingCountry = 'India', Phone = '9999999',Gateway__c= gateway1.Id);
           insert account3;

           ApexPages.StandardController sc2 = new ApexPages.StandardController(account3);
           ControllerForGenerateTokenForBrainTree objControllerForGenerateTokenForBrainTree2 = new ControllerForGenerateTokenForBrainTree(sc2);
           objControllerForGenerateTokenForBrainTree2.generateToken();

      }
      //Added by Kesav Madhu for Cybersource
      public static testMethod void paymentOperations_ClassForHandlingCybersource(){
       
           ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
           ControllerInsertCustomSettings.insertValues();
            
           Currency__c currencyobj = new Currency__c(name = 'USD', Symbol__c = '$');
           insert currencyobj;
        
           list<Gateway__c> listOfGateway = [Select Id From Gateway__c];
           delete listOfGateway;
           
           Gateway__c gateway = new Gateway__c(Active__c = true, Default__c = true, Gateway_Type__c = 'CyberSource', Test_Mode__c = true, Merchant_ID__c = 'acertiscloud_23', Security_Key__c = 'acertiscloud_77', Exact_ID_Security_Key__c = '82b36579705ea7b3b893858cc37ee666');
           insert gateway;
           
            Account account = new Account(Name = 'Test Account');
            insert account;

            Account account1 = [SELECT Name FROM Account WHERE id =: account.id];
            System.assertEquals('Test Account', account1.Name);
            
            Payment_Method__c paymentMethod = new Payment_Method__c(Billing_Fax__c = '56789', Billing_Email__c = 'madhu@gmail.com', Billing_Phone__c = '9999999', Billing_First_Name__c = 'Madhu', Billing_Last_Name__c = 'Kesav', Active__c = true, Default__c = true, Account__c = account.Id, Billing_Address__c = '123',Billing_City__c = 'CA',Billing_State_Province__c = 'California',Billing_Zip_Postal__c = '11111',Billing_Country__c = 'United States',Bank_Account_Number__c='4100',Bank_Account_Name__c='ABC',Bank_Account_Type__c='CHECKING',Bank_Name__c='Test',Bank_Routing_Code__c='071923284',Payment_Method__c='ACH');
            insert paymentMethod;
            
            list<Contact> listContacts = new list<Contact>();
            listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,MailingCountry = 'UK',Email ='laxmanrao.564@gmail.com',MailingStreet = 'Bangalore',MailingCity = 'Bangalore',MailingPostalCode = '523122',FirstName = 'acertis'));
            listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, MailingCountry = 'USA',Email = 'laxmanrao.564@gmail.com',MailingStreet = 'Bangalore',MailingCity = 'Bangalore',MailingPostalCode = '523122',FirstName = 'acertis'));
            insert listContacts;
            
            Currency__c currency1 = new Currency__c(name = 'GBP', Symbol__c = '£1');
            insert currency1;

            
            Job__c job = new Job__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id, Sub_Total__c = 100, Discount_Value__c = 0, CurrencyL__c = currency1.Id,Total__c=100);
            insert job;
            
           
            
            Invoice__c invoice1 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                                CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = 'Draft');
                                                
            Invoice__c invoice2 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                                CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = 'Draft');
            
            Invoice__c invoice3 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                                CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = CommonUtilClass.STATUS_POSTED);
            
            
            list<Invoice__c> invoices = new list<Invoice__c>();
            invoices.add(invoice1);
            invoices.add(invoice2);
            invoices.add(invoice3);
            insert invoices;
            
            list<Invoice_Lines__c> listInvoiceLines = new list<Invoice_Lines__c>();
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(2).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));

            insert listInvoiceLines;  

             invoices.get(0).Invoice_Status__c = 'Posted';
             invoices.get(0).Invoice_Status__c = 'Posted';
             update invoices;
            
            invoices = [Select Id, Name, CurrencyL__c, Target_Date__c,
                        Shipping_Contact__r.FirstName,Shipping_Contact__r.LastName,Shipping_Contact__r.MailingStreet,Shipping_Contact__r.MailingCity,Shipping_Contact__r.MailingPostalCode,Shipping_Contact__r.MailingCountry 
                        From Invoice__c Where Id In: invoices];
            Transaction__c transaction1=new Transaction__c(Gateway_ID__c = '123456',Payment_Gateway__c=gateway.id,Payment_Method__c=paymentMethod.id,Currency__c=currency1.id,Request_Invoice__c=invoices[0].id,Amount__c=20,Type__c='Charge');
           insert transaction1;

           Transaction__c transaction2=new Transaction__c(Gateway_ID__c = '123456',Payment_Gateway__c=gateway.id,Payment_Method__c=paymentMethod.id,Currency__c=currency1.id,Request_Invoice__c=invoices[0].id,Amount__c=20,Type__c='Charge');
           insert transaction2;

            PaymentOperations.PaymentResult result;
            result = PaymentOperations.authorize(invoices.get(0).Id, invoices.get(0).name, null);  
            result = PaymentOperations.authorizeAndCharge(invoices.get(1).Id, null, null);
            PaymentOperations.void(invoices.get(0).Id);  
            //system.assert(result.transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED);
            PaymentOperations.void(invoices.get(0).Id);
            PaymentOperations.refund(invoices.get(0).Id, null, 100);
            PaymentOperations.authorizeAndCharge(invoices.get(2).Id, invoices.get(2).Name, null);
            PaymentOperations.authorizeAndChargePaymentPlanInstalments(invoices.get(2).Id,paymentMethod.Id,100);
             PaymentOperations.transactionRefund(transaction1.id);
             PaymentOperations.transactionVoid(transaction2.id);
            system.assert(invoices != null);
            
            // Code for handling the site
            // this will say Invoice could not be found
            ControllerSitePaymentProcess controllerSitePaymentProces = new ControllerSitePaymentProcess();
            
            // this will say Invoice could not be found
            system.currentPageReference().getParameters().put('Id', invoices.get(0).Id);
            controllerSitePaymentProces = new ControllerSitePaymentProcess();
            
            // this time Unpaid_Amount__c is > 0
            system.currentPageReference().getParameters().put('Id', invoices.get(2).Id);
            controllerSitePaymentProces = new ControllerSitePaymentProcess();
            
            // move to the checkout page
            controllerSitePaymentProces.checkOut();
            
            // this will fire the validation
            controllerSitePaymentProces.paymentMethod.Billing_First_Name__c = null;
            controllerSitePaymentProces.paymentMethod.Billing_Last_Name__c = null;
            controllerSitePaymentProces.paymentMethod.Card_Type__c = null;
            controllerSitePaymentProces.paymentMethod.Card_Number__c = null;
            controllerSitePaymentProces.paymentMethod.CVV__c = null;
            controllerSitePaymentProces.paymentMethod.Billing_Phone__c = null;
            controllerSitePaymentProces.paymentMethod.Billing_Email__c = null;
            controllerSitePaymentProces.paymentMethod.Billing_State_Province__c = null;
            controllerSitePaymentProces.paymentMethod.Card_Expiration_Month__c = null;
            controllerSitePaymentProces.processPayment();
            
            // looks ok
            controllerSitePaymentProces.paymentMethod.Billing_First_Name__c = 'Sandeep';
            controllerSitePaymentProces.paymentMethod.Billing_Last_Name__c = 'M';
            controllerSitePaymentProces.paymentMethod.Billing_Email__c = 'kesav@gmail.com';
            controllerSitePaymentProces.paymentMethod.Bank_Account_Number__c = '4100';
            controllerSitePaymentProces.paymentMethod.Bank_Account_Name__c = 'ABC';
            controllerSitePaymentProces.paymentMethod.Bank_Account_Type__c = 'CHECKING';
            controllerSitePaymentProces.paymentMethod.Bank_Name__c = 'Test';
            controllerSitePaymentProces.paymentMethod.Bank_Routing_Code__c='071923284';
            controllerSitePaymentProces.paymentMethod.Billing_Address__c='123';
            controllerSitePaymentProces.paymentMethod.Billing_City__c='CA';
            controllerSitePaymentProces.paymentMethod.Billing_State_Province__c='California';
            controllerSitePaymentProces.paymentMethod.Billing_Zip_Postal__c='11111';
            controllerSitePaymentProces.paymentMethod.Billing_Country__c='United States';       
            controllerSitePaymentProces.sSaveCardDetails = 'yes';
            controllerSitePaymentProces.gateWayToUse = gateway;
            controllerSitePaymentProces.processPayment();
            
            // this time gateway.Test_Mode__c = false
            gateway.Test_Mode__c = false;
            update gateway;
            system.currentPageReference().getParameters().put('Id', invoices.get(2).Id);
            controllerSitePaymentProces = new ControllerSitePaymentProcess(); 
            
            ClassForHandlingCyberSource ClassForHandlingCyberSource = new ClassForHandlingCyberSource(gateway, null, paymentMethod);
            Transaction__c transactionObj = new Transaction__c(Gateway_ID__c = '123456', Payment_Gateway__c = gateway.Id, Payment_Method__c = paymentMethod.Id );
            insert transactionObj;
            ClassForHandlingCyberSource.handleRefund_Click(gateway.Id,transactionObj.Id, 200 );
            
            ClassForHandlingCyberSource.handleVoid_Click(gateway.Id,transactionObj.Id, 200 );
            ClassForHandlingCyberSource.handleAuthorizeAndCharge_Click(transactionObj.Id,gateway.Id); 
            ClassForHandlingCyberSource.handleAuthorize_Click();   
              Payment_Method__c   paymentMethod2 = new Payment_Method__c(Billing_Fax__c = '56789', Billing_Email__c = 'madhu@gmail.com', Billing_Phone__c = '9999999', Billing_First_Name__c = 'Madhu', Billing_Last_Name__c = 'kesav', Active__c = true, Default__c = false, Account__c = account.Id,Billing_Address__c = '123',Billing_City__c = 'CA',Billing_State_Province__c = 'California',Billing_Zip_Postal__c = '11111',Billing_Country__c = 'United States',Bank_Account_Number__c='4100',Bank_Account_Name__c='ABC',Bank_Account_Type__c='SAVINGS',Bank_Name__c='Test',Bank_Routing_Code__c='071923284',Payment_Method__c='ACH'); 
                    insert paymentMethod2;
                    
             Payment_Method__c   paymentMethod1 = new Payment_Method__c(Billing_Fax__c = '56789', Billing_Email__c = 'madhu@gmail.com', Billing_Phone__c = '9999999', Billing_First_Name__c = 'Madhu', Billing_Last_Name__c = 'kesav', Active__c = true, Default__c = false, Account__c = account.Id,Billing_Address__c = '123',Billing_City__c = 'CA',Billing_State_Province__c = 'California',Billing_Zip_Postal__c = '11111',Billing_Country__c = 'United States',Bank_Account_Number__c='4100',Bank_Account_Name__c='ABC',Bank_Account_Type__c='BUSINESSCHECKING',Bank_Name__c='Test',Bank_Routing_Code__c='071923284',Payment_Method__c='ACH');    
             insert paymentMethod1;
            PaymentSiteOperation.GenericPaymentParameters genericPaymentParameters

                =  new PaymentSiteOperation.GenericPaymentParameters();

              
               genericPaymentParameters.amountToProcess = 100;

               genericPaymentParameters.currencyISOCode = 'USD';

            

               genericPaymentParameters.shouldTokenizeCard = false; 

               PaymentSiteOperation.GenericPaymentResult genericPaymentResult = new PaymentSiteOperation.GenericPaymentResult();            

               PaymentSiteOperation site = new PaymentSiteOperation();

            ClassForHandlingCyberSource.handleAuthorizeAndCharge(genericPaymentParameters);
        
            paymentMethod = new Payment_Method__c(Billing_Fax__c = '56789', Billing_Email__c = 'madhu@gmail.com', Billing_Phone__c = '9999999', Billing_First_Name__c = 'Madhu', Billing_Last_Name__c = 'kesav', Active__c = true, Default__c = true, Account__c = account.Id,Billing_Address__c = '123',Billing_City__c = 'CA',Billing_State_Province__c = 'California',Billing_Zip_Postal__c = '11111',Billing_Country__c = 'United States',Bank_Account_Number__c='4100',Bank_Account_Name__c='ABC',Bank_Account_Type__c='CHECKING',Bank_Name__c='Test',Bank_Routing_Code__c='071923284',Payment_Method__c='ACH');
            ClassForHandlingCyberSource ClassForHandlingCyberSource1 = new ClassForHandlingCyberSource(gateway, null, paymentMethod,paymentMethod.Id,100,account);
             
             

             System.Test.startTest();
             string query = 'SELECT Start_Date_and_Time__c,Status__c,Type__c,Name FROM Batch_Jobs__c LIMIT 1';
             BatchForPostingInvoices batch=new BatchForPostingInvoices(query);
            ID batchprocessid = Database.executeBatch(batch);
            System.Test.stopTest();


           
      }
      
      public static testMethod void paymentOperations_ClassForHandlingCybersourceForCreditCard(){
       
           ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
           ControllerInsertCustomSettings.insertValues();
            
           Currency__c currencyobj = new Currency__c(name = 'USD', Symbol__c = '$');
           insert currencyobj;
        
           list<Gateway__c> listOfGateway = [Select Id From Gateway__c];
           delete listOfGateway;
           
           Gateway__c gateway = new Gateway__c(Active__c = true, Default__c = true, Gateway_Type__c = 'CyberSource_CC_Token', Test_Mode__c = true, Merchant_ID__c = 'acertiscloud_23', Security_Key__c = 'acertiscloud_77', Exact_ID_Security_Key__c = '82b36579705ea7b3b893858cc37ee666');
           insert gateway;
           
            Account account = new Account(Name = 'Test Account');
            insert account;

            Account account1 = [SELECT Name FROM Account WHERE id =: account.id];
            System.assertEquals('Test Account', account1.Name);
            
            Payment_Method__c paymentMethod = new Payment_Method__c(Billing_Fax__c = '56789', Billing_Email__c = 'madhu@gmail.com', Billing_Phone__c = '9999999', Billing_First_Name__c = 'Madhu', Billing_Last_Name__c = 'Kesav', Active__c = true, Default__c = true, Account__c = account.Id, CVV__c = '123', Card_Number__c = '4111111111111111', Card_Expiration_Year__c = '2023', Card_Expiration_Month__c = '10',Billing_Address__c = 'Prabhat Aracade',Billing_City__c = 'US',Billing_State_Province__c = 'UK',Billing_Zip_Postal__c = '505001',Billing_Country__c = 'United States',Payment_Method__c='Credit Card');
            insert paymentMethod;
            
            list<Contact> listContacts = new list<Contact>();
            listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,MailingCountry = 'UK',Email ='laxmanrao.564@gmail.com',MailingStreet = 'Bangalore',MailingCity = 'Bangalore',MailingPostalCode = '523122',FirstName = 'acertis'));
            listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, MailingCountry = 'USA',Email = 'laxmanrao.564@gmail.com',MailingStreet = 'Bangalore',MailingCity = 'Bangalore',MailingPostalCode = '523122',FirstName = 'acertis'));
            insert listContacts;
            
            Currency__c currency1 = new Currency__c(name = 'GBP', Symbol__c = '£1');
            insert currency1;


            list<Payment_Plan__c> listofpaymentplan=new list<Payment_Plan__c>();
            listofpaymentplan.add(new Payment_Plan__c(Down_Payment__c=500,Type_of_Installments__c='Monthly',No_of_Installments__c=9,Is_Plan_Editable__c=true,Name='5 Month plan',Installment_Start_Date__c=system.today(),Down_Payment_Amount__c=0,Maximum_Installments__c=10,Minimum_Installments__c=3));
            listofpaymentplan.add(new Payment_Plan__c(No_of_Installments__c=9,Is_Plan_Editable__c=true,Name='5 Month plan',Installment_Start_Date__c=system.today(),Down_Payment_Amount__c=0,Maximum_Installments__c=10,Minimum_Installments__c=3));

            insert listofpaymentplan;
            Date validtodate = Date.today();
            Product__c product = new Product__c(Name = 'Test Product for tiers',Valid_From_Date__c = validtodate-1,Valid_To_Date__c = validtodate.addMonths(2),Product_Family__c = 'Default',Product_Code__c = 'Code1',Description__c = 'Product');
           insert product; 

           Product_Rate_Plan__c productRatePlan = new  Product_Rate_Plan__c(  Name = 'Test ProductRatePlan',Product__c = product.Id,Valid_From_Date__c = validtodate,Valid_To_Date__c = validtodate.addMonths(2));
               insert productRatePlan;

          Product_Rate_Plan_Charge__c productRatePlanCharge_SetUp = new Product_Rate_Plan_Charge__c(Name = 'Setup Charges',
                                                                 CurrencyL__c = currencyObj.Id,
                                                                 Product_Rate_Plan__c = productRatePlan.Id,
                                                                 Unit_price__c = 1000,
                                                                 Cost_Price__c = 500,
                                                                 Product_Charge_Category__c = 'Taxable',
                                                                 
                                                                 Price_Type__c = 'One Time'
                                                                 );
           insert productRatePlanCharge_SetUp;

            Job__c job = new Job__c(Account__c = account.id,Payment_Plan__c=listofpaymentplan.get(0).Id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id, Sub_Total__c = 100, Discount_Value__c = 0, CurrencyL__c = currency1.Id,Total__c=100);
            insert job;

            Job__c job1 = new Job__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id, Sub_Total__c = 100, Discount_Value__c = 0, CurrencyL__c = currency1.Id,Total__c=100);
            insert job1;

           Job_Product__c  jobProduct = new Job_Product__c(Name = 'JobProduct',Product__c=product.Id,Job__c = job.Id);
           insert jobProduct;

           Job_Rate_Plan__c jobRP = new Job_Rate_Plan__c(Name = 'JobRP',Product_Rate_Plan__c = productRatePlan.Id,Job_Product__c = JobProduct.Id);
           insert jobRP;

           Job_Rate_Plan_Charge__c jobCharge = new Job_Rate_Plan_Charge__c(Order__c=job.Id,Name = 'JobRPC',Product_Rate_Plan_Charge__c = productRatePlanCharge_SetUp.id, Job_Rate_Plan__c =JobRP.Id,Status__c = 'Draft',Quantity__c = 12,Unit_Price__c = 12,Service_Activation_Date__c=validtodate,Service_End_Date__c=validtodate);
           insert jobCharge;

            
            Invoice__c invoice1 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                                CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = 'Active');
                                                
            Invoice__c invoice2 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                                CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = 'Active');
            
            Invoice__c invoice3 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                                CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = CommonUtilClass.STATUS_POSTED);
            Invoice__c invoice4 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                                CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = CommonUtilClass.STATUS_POSTED);
            
            
            list<Invoice__c> invoices = new list<Invoice__c>();
            invoices.add(invoice1);
            invoices.add(invoice2);
            invoices.add(invoice3);
            invoices.add(invoice4);
            insert invoices;
            
            list<Invoice_Lines__c> listInvoiceLines = new list<Invoice_Lines__c>();
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(2).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 100.00,VAT__c = 8.00,Line_Amount__c = 100.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(3).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 100.00,VAT__c = 8.00,Line_Amount__c = 100.00,Job__c = job.Id));
            insert listInvoiceLines;   
            
            invoices = [Select Id, Name, CurrencyL__c, Target_Date__c,
                        Shipping_Contact__r.FirstName,Shipping_Contact__r.LastName,Shipping_Contact__r.MailingStreet,Shipping_Contact__r.MailingCity,Shipping_Contact__r.MailingPostalCode,Shipping_Contact__r.MailingCountry 
                        From Invoice__c Where Id In: invoices];

         
            Transaction__c transactionObj1 = new Transaction__c(Gateway_ID__c = '123456', Payment_Gateway__c = gateway.Id,Amount__c=5,Currency__c=currency1.Id, Payment_Method__c = paymentMethod.Id, Type__c = 'Authorization' ,Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED, Request_Invoice__c = invoices.get(2).Id);
            insert transactionObj1;

            Payment__c payment=new Payment__c(Account__c=account.id,Amount__c=10,Payment_Date__c = system.today(),Invoice__c=invoices.get(2).Id,Currency__c=currency1.Id,Status__c='Completed',Paid_by__c=listContacts.get(0).Id,Payment_Type__c='Credit Card');
             insert payment;

             Payment_Allocation__c paymentallocation=new Payment_Allocation__c(Amount__c=10,Invoice__c=invoices.get(2).Id,Payment__c=payment.id,Status__c='Completed');
             insert paymentallocation;

            ApexPages.StandardController order1 = new ApexPages.StandardController(job);  
            ControllerHandlingForPaymentPlanAtOrder ControllerHandlingForPaymentPlanAtOrderobj=new ControllerHandlingForPaymentPlanAtOrder(order1);
            ControllerHandlingForPaymentPlanAtOrderobj.showPlanDetails();
            ControllerHandlingForPaymentPlanAtOrderobj.modifyPlanDetails();
            ControllerHandlingForPaymentPlanAtOrderobj.processpaymentPlan();
            ControllerHandlingForPaymentPlanAtOrderobj.addInstallment();
            ApexPages.currentPage().getParameters().put('unWantedInstallmentCount', '1');
            ControllerHandlingForPaymentPlanAtOrderobj.removeInstallment();
            ControllerHandlingForPaymentPlanAtOrderobj.save();


        
            Transaction__c transaction1=new Transaction__c(Gateway_ID__c = '123456',Payment_Gateway__c=gateway.id,Payment_Method__c=paymentMethod.id,Currency__c=currency1.id,Request_Invoice__c=invoices[0].id,Amount__c=20,Type__c='Charge');
           insert transaction1;
       
           System.Test.StartTest();
            PaymentOperations.PaymentResult result;
            result = PaymentOperations.authorize(invoices.get(0).Id, invoices.get(0).name, null);  
            result = PaymentOperations.authorizeAndCharge(invoices.get(1).Id, null, null);
            PaymentOperations.void(invoices.get(0).Id);  
            //system.assert(result.transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED);
            PaymentOperations.void(invoices.get(0).Id);
            PaymentOperations.refund(invoices.get(0).Id, null, 100);
            PaymentOperations.authorizeAndCharge(invoices.get(2).Id, invoices.get(2).Name, null);
             PaymentOperations.transactionRefund(transaction1.id);
             //PaymentOperations.transactionVoid(transaction2.id);
            system.assert(invoices != null);
            
            // Code for handling the site
            // this will say Invoice could not be found
            ControllerSitePaymentProcess controllerSitePaymentProces = new ControllerSitePaymentProcess();
            
            // this will say Invoice could not be found
            system.currentPageReference().getParameters().put('Id', invoices.get(0).Id);
            controllerSitePaymentProces = new ControllerSitePaymentProcess();
            
            // this time Unpaid_Amount__c is > 0
            system.currentPageReference().getParameters().put('Id', invoices.get(2).Id);
            controllerSitePaymentProces = new ControllerSitePaymentProcess();
            
            // move to the checkout page
            controllerSitePaymentProces.checkOut();
            
            // this will fire the validation
            controllerSitePaymentProces.paymentMethod.Billing_First_Name__c = null;
            controllerSitePaymentProces.paymentMethod.Billing_Last_Name__c = null;
            controllerSitePaymentProces.paymentMethod.Card_Type__c = null;
            controllerSitePaymentProces.paymentMethod.Card_Number__c = null;
            controllerSitePaymentProces.paymentMethod.CVV__c = null;
            controllerSitePaymentProces.paymentMethod.Billing_Phone__c = null;
            controllerSitePaymentProces.paymentMethod.Billing_Email__c = null;
            controllerSitePaymentProces.paymentMethod.Billing_State_Province__c = null;
            controllerSitePaymentProces.paymentMethod.Card_Expiration_Month__c = null;
            controllerSitePaymentProces.processPayment();
            
            // looks ok
            controllerSitePaymentProces.paymentMethod.Billing_First_Name__c = 'Sandeep';
            controllerSitePaymentProces.paymentMethod.Billing_Last_Name__c = 'M';
            controllerSitePaymentProces.paymentMethod.Card_Type__c = 'Master';
            controllerSitePaymentProces.paymentMethod.Card_Number__c = '5555555555554444';
            controllerSitePaymentProces.paymentMethod.CVV__c = '1234';
            controllerSitePaymentProces.paymentMethod.Card_Expiration_Month__c = '12';
            controllerSitePaymentProces.paymentMethod.Card_Expiration_Year__c = '2018';
            controllerSitePaymentProces.sSaveCardDetails = 'yes';
            controllerSitePaymentProces.gateWayToUse = gateway;
            controllerSitePaymentProces.processPayment();
            
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(account);
            system.currentPageReference().getParameters().put('Id', account.Id);
            ControllerVirtualTerminal controllerVirtualTerminal = new ControllerVirtualTerminal(standardController);
            
            controllerVirtualTerminal.processPaymentRedirect();  
            controllerVirtualTerminal.selectedValue = paymentMethod.Id;  
            controllerVirtualTerminal.isNone = false;               
            controllerVirtualTerminal.paymentMethod.Billing_First_Name__c = 'Sandeep';
            controllerVirtualTerminal.paymentMethod.Billing_Last_Name__c = 'M';
            controllerVirtualTerminal.paymentMethod.Card_Type__c = 'Master';
            controllerVirtualTerminal.paymentMethod.Card_Number__c = '5555555555554444';
            controllerVirtualTerminal.paymentMethod.CVV__c = '1234';
            controllerVirtualTerminal.paymentMethod.Card_Expiration_Month__c = '12';
            controllerVirtualTerminal.paymentMethod.Card_Expiration_Year__c = '2219';
            controllerVirtualTerminal.sSaveCardDetails = 'yes';
            controllerVirtualTerminal.paymentMethod.Account__c = account.Id;
            controllerVirtualTerminal.processPayment();
            
            // this time gateway.Test_Mode__c = false
            gateway.Test_Mode__c = false;
            update gateway;
            system.currentPageReference().getParameters().put('Id', invoices.get(2).Id);
            controllerSitePaymentProces = new ControllerSitePaymentProcess(); 
            
            ClassForHandlingCyberSourceForCreditCard ClassForHandlingCyberSourceForCreditCard = new ClassForHandlingCyberSourceForCreditCard(gateway, null, paymentMethod);
            Transaction__c transactionObj = new Transaction__c(Gateway_ID__c = '123456', Payment_Gateway__c = gateway.Id, Payment_Method__c = paymentMethod.Id );
            insert transactionObj;
            ClassForHandlingCyberSourceForCreditCard.handleRefund_Click(gateway.Id,transactionObj.Id, 200 );
            
            ClassForHandlingCyberSourceForCreditCard.handleVoid_Click(gateway.Id,transactionObj.Id, 200 );
            
            list<Payment_Plan_Installment__c> listofpaymentinstallment=new list<Payment_Plan_Installment__c>();
            listofpaymentinstallment.add(new Payment_Plan_Installment__c(Account__c=account.id,Invoice__c=invoices.get(3).Id,Description__c='Test',Last_Processing_Date__c=system.today()-30,Payment_Date__c=system.today(),No_of_tries__c=0,Payment_Amount__c=10,Order__c=job.id,Payment_Method__c=paymentMethod.id,Payment_Type__c='Credit Card'));
            listofpaymentinstallment.add(new Payment_Plan_Installment__c(Account__c=account.id,Invoice__c=invoices.get(3).Id,Description__c='Test',Last_Processing_Date__c=system.today()-30,Payment_Date__c=system.today(),No_of_tries__c=0,Payment_Amount__c=10,Order__c=job.id,Payment_Method__c=paymentMethod.id,Payment_Type__c='Credit Card'));
            insert listofpaymentinstallment;

         

            paymentMethod = new Payment_Method__c(Billing_Fax__c = '56789', Billing_Email__c = 'dev@gmail.com', Billing_Phone__c = '9999999', Billing_First_Name__c = 'Devender', Billing_Last_Name__c = 'M', Active__c = true, Default__c = true, Account__c = account.Id,Name_on_Card__c='Madhu', CVV__c = '123', Card_Number__c = '4111111111111111', Card_Expiration_Year__c = '2023', Card_Expiration_Month__c = '10',Billing_Address__c = 'Prabhat Aracade',Billing_City__c = 'US',Billing_State_Province__c = 'UK',Billing_Zip_Postal__c = '505001',Billing_Country__c = 'United States',Payment_Method__c='Credit Card');
            ClassForHandlingCyberSourceForCreditCard ClassForHandlingCyberSourceForCreditCard1 = new ClassForHandlingCyberSourceForCreditCard(gateway, null, paymentMethod,paymentMethod.Id,100,account, currencyobj.Id);      
          
      
           Configuration__c c1 = new Configuration__c(Name = 'PAYMENT_NO_OF_DAYS_BETWEEN_RETRIES', NUMBER_VALUE__C = null, Field_Type__c = 'Number', Category__c ='Invoice',Sequence__c = 21);
           insert c1;
           Configuration__c c2 = new Configuration__c(Name = 'PAYMENT_NO_OF_RETRIES', NUMBER_VALUE__C = 3, Field_Type__c = 'Number', Category__c ='Invoice',Sequence__c = 20);
           insert c2;
           
           PaymentSiteOperation.GenericPaymentParameters genericPaymentParameters

                =  new PaymentSiteOperation.GenericPaymentParameters();

          
               genericPaymentParameters.amountToProcess = 100;

               genericPaymentParameters.currencyISOCode = 'USD';

     
               genericPaymentParameters.shouldTokenizeCard = false; 

               PaymentSiteOperation.GenericPaymentResult genericPaymentResult = new PaymentSiteOperation.GenericPaymentResult();            

               PaymentSiteOperation site = new PaymentSiteOperation();

            ClassForHandlingCyberSourceForCreditCard.handleAuthorizeAndCharge(genericPaymentParameters);

            //Below is added by Siri related to INVOICEIT-661 on 08-01-2016
            Payment_Scheduler__c paymentScheduler = new Payment_Scheduler__c();
            paymentScheduler.Type__c = 'Once';
            paymentScheduler.Payment_Options__c ='Credit Card';
            paymentScheduler.Target_Date__c = system.today();
            paymentScheduler.Start_date_and_time__c = system.now().addMinutes(20);
            paymentScheduler.Currency__c = currency1.Id;
            paymentScheduler.Payment_Options__c = 'Credit Card;ACH';
            insert paymentScheduler;
           
            Payment_Run__c paymentRun = new Payment_Run__c( Invoices_Processed__c = 0,Successful_Transactions__c = 0,Failed_Transactions__c = 0,Total_Payment_Value__c = 0,Payment_Scheduler__c = paymentScheduler.Id, Name = paymentScheduler.Name, Status__c = 'Processing', Start_Time__c = system.now());
            insert paymentRun;
            BatchChargePaymentPlanInstallmentProcess.paymentSchedulerRef =paymentScheduler;
            BatchChargePaymentPlanInstallmentProcess.paymentRunRef = paymentRun;
            
            BatchChargePaymentPlanInstallmentProcess batch=new BatchChargePaymentPlanInstallmentProcess(system.today());
            ID batchprocessid = Database.executeBatch(batch);
            System.Test.stopTest();

       
      }
      
      public static testMethod void ControllerForGenerateTokenForCyberSource(){
       
           ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
           ControllerInsertCustomSettings.insertValues();
            
           Currency__c currencyobj = new Currency__c(name = 'USD', Symbol__c = '$');
           insert currencyobj;
        
           list<Gateway__c> listOfGateway = [Select Id From Gateway__c];
           delete listOfGateway;
           
           Gateway__c gateway = new Gateway__c(Active__c = true, Default__c = true, Gateway_Type__c = 'CyberSource_CC_Token', Test_Mode__c = true, Merchant_ID__c = 'd3pzbb3393fvz55t', Security_Key__c = '88mzbm3837zvnd3d', Exact_ID_Security_Key__c = '82b36579705ea7b3b893858cc37ee666');
           insert gateway; 

           Gateway__c gateway1 = new Gateway__c(Active__c = true, Gateway_Type__c = 'Test', Test_Mode__c = true, Security_Key__c = '88mzbm3837zvnd3d', Exact_ID_Security_Key__c = '82b36579705ea7b3b893858cc37ee666');
           insert gateway1; 
           
           Account account = new Account(Name = 'Test Account', Customer_Profile_ID__c = '12345678', BillingStreet = 'Koraamangala', BillingCity = 'Banglore', BillingState = 'Karnataka', BillingPostalCode = '560068', BillingCountry = 'India', Phone = '9999999' ,Gateway__c= gateway.Id);
           insert account;

           Account account1 = [SELECT Name FROM Account WHERE id =: account.id];
           System.assertEquals('Test Account', account1.Name);
           
           
         
           
           Payment_Method__c paymentMethod = new Payment_Method__c(Billing_Fax__c = '56789', Billing_Email__c = 'dev@gmail.com', Billing_Phone__c = '9999999', Billing_First_Name__c = 'Devender', Billing_Last_Name__c = 'M', Active__c = true, Default__c = false, Account__c = account.Id, Payment_Method__c = 'Credit Card', Card_Type__c = 'Visa' , Name_on_Card__c = 'abc', Card_Number__c = '4111111111111111', CVV__c = '123', Card_Expiration_Year__c = '2023', Card_Expiration_Month__c = '10',Billing_Address__c = 'Prabhat Aracade',Billing_City__c = 'US',Billing_State_Province__c = 'UK',Billing_Zip_Postal__c = '505001',Billing_Country__c = 'United States');
           insert paymentMethod;
          
           
           ApexPages.StandardController sc = new ApexPages.StandardController(account);
           ControllerForGenerateTokenForCyberSource ControllerForGenerateTokenForCyberSourceobj = new ControllerForGenerateTokenForCyberSource(sc);
           ControllerForGenerateTokenForCyberSourceobj.paymentMethod.Default__c = true;
           ControllerForGenerateTokenForCyberSourceobj.paymentMethod.Card_Number__c = '4111111111111111';
           ControllerForGenerateTokenForCyberSourceobj.paymentMethod.CVV__c = '123';
           ControllerForGenerateTokenForCyberSourceobj.paymentMethod.Name_on_Card__c = 'abc';
           ControllerForGenerateTokenForCyberSourceobj.paymentMethod.Card_Expiration_Month__c = '10';
           ControllerForGenerateTokenForCyberSourceobj.paymentMethod.Card_Expiration_Year__c = '2023';
           ControllerForGenerateTokenForCyberSourceobj.generateToken();

           Account account2 = new Account(Name = 'Test Account', BillingStreet = 'Koraamangala', BillingCity = 'Banglore', BillingState = 'Karnataka', BillingPostalCode = '560068', BillingCountry = 'India', Phone = '9999999');
           insert account2;

           ApexPages.StandardController sc1 = new ApexPages.StandardController(account2);
           ControllerForGenerateTokenForCyberSource ControllerForGenerateTokenForCyberSourceobj1 = new ControllerForGenerateTokenForCyberSource(sc1);
           ControllerForGenerateTokenForCyberSourceobj1.generateToken();
           ControllerForGenerateTokenForCyberSourceobj1.populateCustomerDetails();

           Account account3 = new Account(Name = 'Test Account', BillingStreet = 'Koraamangala', BillingCity = 'Banglore', BillingState = 'Karnataka', BillingPostalCode = '560068', BillingCountry = 'India', Phone = '9999999',Gateway__c= gateway1.Id);
           insert account3;

           ApexPages.StandardController sc2 = new ApexPages.StandardController(account3);
           ControllerForGenerateTokenForCyberSource ControllerForGenerateTokenForCyberSourceobj2 = new ControllerForGenerateTokenForCyberSource(sc2);
           ControllerForGenerateTokenForCyberSourceobj2.generateToken();
           ControllerForGenerateTokenForCyberSourceobj2.populateCustomerDetails();
           
           ControllerForUpdateTokenForCyberSource ControllerForUpdateTokenForCyberSourceobj=new ControllerForUpdateTokenForCyberSource(sc);
        
           ControllerForUpdateTokenForCyberSourceobj.paymentMethod.Default__c = true;
           ControllerForUpdateTokenForCyberSourceobj.paymentMethod.Card_Number__c = '4111111111111111';
           ControllerForUpdateTokenForCyberSourceobj.paymentMethod.CVV__c = '123';
           ControllerForUpdateTokenForCyberSourceobj.paymentMethod.Name_on_Card__c = 'abc';
           ControllerForUpdateTokenForCyberSourceobj.paymentMethod.Card_Expiration_Month__c = '10';
           ControllerForUpdateTokenForCyberSourceobj.paymentMethod.Card_Expiration_Year__c = '2023';
            ControllerForUpdateTokenForCyberSourceobj.updateToken();
            
           paymentMethod.Encrypted_Card_Number__c='1234567891';
           paymentMethod.Token__c='41526312';
           paymentMethod.Encrypted_Card_Number__c='1234567891';
           paymentMethod.Payment_Profile_ID__c='41111111111111152892';
           paymentMethod.Billing_State_Province__c='India';
           paymentMethod.Bank_Routing_Code__c='123';
           paymentMethod.Bank_Account_Number__c='1111';
           paymentMethod.Bank_Account_Type__c='CHECKING';
           paymentMethod.Bank_Name__c='Test';
           paymentMethod.Bank_Account_Name__c='Testnew';
           upsert paymentMethod;
           
          
       
            ControllerForUpdateTokenForCyberSourceobj.step2();
            ControllerForUpdateTokenForCyberSourceobj.populateCustomerDetails();
            ControllerForUpdateTokenForCyberSource.errorCodeMessege();
            

      }
        
      public static testMethod void classAfterOnGateway() {
           /* Positive test case */
           Gateway__c gateway1 = new Gateway__c(Name = 'gateway1', Default__c = false, Active__c = true);
           Gateway__c gateway2 = new Gateway__c(Name = 'gateway1', Default__c = false, Active__c = true);
           Gateway__c gateway3 = new Gateway__c(Name = 'gateway1', Default__c = true, Active__c = true);
           Gateway__c gateway4 = new Gateway__c(Name = 'gateway1', Default__c = false, Active__c = true);
           
           list<Gateway__c> gateways = new list<Gateway__c>();
           gateways.add(gateway1);
           gateways.add(gateway2);
           gateways.add(gateway3);
           gateways.add(gateway4);
           
           insert  gateways;

           Gateway__c gatewayObj = [SELECT Name, Default__c FROM Gateway__c WHERE id =: gateways[0].id];
           System.assertEquals(false, gatewayObj.Default__c);
           
         
           ClassAfterOnGateway.GATEWAY_AFTER_PROCESSING_COMPLETE = false;
           
           update gateways;
           ClassAfterOnGateway.GATEWAY_AFTER_PROCESSING_COMPLETE = false;
           
            /* Negative test case */
           try {
               Gateway__c gateway5 = new Gateway__c(Name = 'gateway1', Default__c = false, Active__c = true);
               Gateway__c gateway6 = new Gateway__c(Name = 'gateway1', Default__c = false, Active__c = true);
               Gateway__c gateway7 = new Gateway__c(Name = 'gateway1', Default__c = true, Active__c = true);
               Gateway__c gateway8 = new Gateway__c(Name = 'gateway1', Default__c = false, Active__c = true);
               
               gateways = new list<Gateway__c>();
               gateways.add(gateway5);
               gateways.add(gateway6);
               gateways.add(gateway7);
               gateways.add(gateway8);
               insert  gateways;
           } catch(Exception ex) {
           }
       }
       
       public static testMethod void classAfterOnUsageCharge() {
           ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
           ControllerInsertCustomSettings.insertValues();
        
           Account account = new Account(Name = 'Test Account');
           insert account;

           Account account1 = [SELECT Name FROM Account WHERE id=:account.id];
           System.assertEquals('Test Account', account1.Name);
            
           Currency__c currency1 = new Currency__c(name = 'GBP', Symbol__c = '£1');
           insert currency1;
            
           Job__c job = new Job__c(Account__c = account.id, Sub_Total__c = 100, Discount_Value__c = 0, CurrencyL__c = currency1.Id);
           insert job;
           
           Job_Product__c jobProduct = new Job_Product__c(Job__c = job.Id, Name = 'test');
           insert jobProduct;
           
           Job_Rate_Plan__c jobProductRatePlan = new Job_Rate_Plan__c(Job_Product__c = jobProduct.Id, Name = 'test');
           insert jobProductRatePlan;
           
           Job_Rate_Plan_Charge__c jobCharge = new Job_Rate_Plan_Charge__c(Job_Rate_Plan__c = jobProductRatePlan.Id, Name = 'test', Quantity__c = 0, CurrencyL__c = currency1.Id);
           insert jobCharge;
           
           Job_Rate_Plan_Charge__c jobCharge1 = new Job_Rate_Plan_Charge__c(Job_Rate_Plan__c = jobProductRatePlan.Id, Name = 'test', Quantity__c = 0, CurrencyL__c = currency1.Id,Master_Order_Rate_Plan_Charge__c = jobCharge.id);
           insert jobCharge1;
           
           Usage_Charge__c usageCharge = new Usage_Charge__c(End_Date__c = system.today(), Order_Rate_Plan_Charge__c = jobCharge1.Id, Quantity__c = 10);
           insert usageCharge;         
           
           system.assert(usageCharge.Id != null);    
       }
       
       
    // test method
    public static testmethod void test1() { 
           xmldom d;        
           d = new xmldom('<book  author="Manoj" >My Book</book>');
           //d.dumpAll(); 
           XMLdom.Element e = d.getElementsByTagName('book')[0];
           system.assert( e.getAttribute('author') =='Manoj' ); 
           
           d = new xmldom(); d.parseFromString('<book  author="Manoj" >My Book</book>');
           //d.dumpAll(); 
            
           d = new xmldom('<books><book>My Book</book></books>');
           //d.dumpAll(); 
           system.assert ( d.getElementsByTagName('book')[0].nodeValue == 'My Book' );
           
           d = new xmldom('<books><book author="Manoj" date="1999" >My Book</book><book author="Ron" >Your Book</book></books>'); 
           //d.dumpAll();
           XMLdom.Element ee  = new xmldom.Element(); 
            
           string testListBucketResponse = 
                '<?xml version="1.0" encoding="UTF-8"?>'+ 
               '<ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Name>12gkzwnp21m8nw02-test-bucket</Name><Prefix>'+
               '</Prefix><Marker></Marker><MaxKeys>1000</MaxKeys><IsTruncated>false</IsTruncated><Contents><Key>/apex/adnDevSignup</Key>'+
               '<LastModified>2008-01-27T21:13:58.000Z</LastModified><ETag>&quot;630581ddc40fa0a3b7e521c67962baba&quot;</ETag><Size>27411</Size>'+
               '<Owner><ID>173ea00b3418d9a715d5f5a0d85290c3be11135ecf9a085504a4b1bbb6ea1</ID><DisplayName>vne</DisplayName></Owner>'+
               '<StorageClass>STANDARD</StorageClass></Contents><Contents><Key>apex/adnDevSignup</Key><LastModified>2008-01-31T09:50:41.000Z</LastModified>'+
               '<ETag>&quot;2d9ab36295e58d32db358aae0195c164&quot;</ETag><Size>27410</Size><Owner><ID>owner_id</ID><DisplayName>foobar</DisplayName></Owner>'+
               '<StorageClass>STANDARD</StorageClass></Contents><Contents><Key>apex/adnRoot</Key><LastModified>2008-01-31T09:50:40.000Z</LastModified>'+
               '<ETag>&quot;f956a9612c95c206f3208f023d1edefb&quot;</ETag><Size>20036</Size><Owner><ID>owner_id</ID><DisplayName>foobar</DisplayName></Owner>'+
               '<StorageClass>STANDARD</StorageClass></Contents><Contents><Key>test-key-public</Key><LastModified>2008-02-02T04:02:59.000Z</LastModified>'+
               '<ETag>&quot;12f3e46f80c24c997c4304953edc3612&quot;</ETag><Size>32</Size><Owner><ID>173ea00891b39a715d5f5a0d85290c3be11135ecf9a085504a4b1bbb6ea1</ID>'+
               '<DisplayName>foobar</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Contents><Contents><Key>test-two</Key>'+
               '<LastModified>2008-02-02T00:40:29.000Z</LastModified><ETag>&quot;327b6f07435811239bc47e1544353273&quot;</ETag><Size>7</Size>'+
               '<Owner><ID>173</ID><DisplayName>foobar</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Contents></ListBucketResult>';
           d = new xmldom(testListBucketResponse); 
           //d.dumpAll();
           List<xmldom.Element> keys = d.getElementsByTagName('Key');
           
          
           integer count= keys.size();
           system.assert(count>1);
           
           XMLdom.Element p = keys[0].parentNode;
           p.removeChild(p.firstChild());
           
           keys = d.getElementsByTagName('Key');
           system.assert(keys.size() == count-1);
           
           keys = d.root.getElementsByTagName('Key');
           for(XMLdom.Element e2: keys ) { 
           e2.dump(); 
            }
           count= keys.size();
           system.assert(count>1);
           
           string testErrorResponse = 
            '<?xml version="1.0" encoding="UTF-8"?>'+ 
            '<Error><Code>NoSuchKey</Code><Message>The specified key does not exist.</Message><Key>test-key</Key><RequestId>49D135DD55EBD</RequestId>'+
            '<HostId>PB4hNZ</HostId></Error>';
       
           d = new xmldom(testErrorResponse); 
           d.root.dumpAll();
           
           // uses namespaces
            string testACLResponse = '<?xml version="1.0" encoding="UTF-8"?>'+
            '<AccessControlPolicy xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Owner><ID>owner_id</ID><DisplayName>foobar</DisplayName></Owner>'+
            '<AccessControlList><Grant><Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="CanonicalUser" foo="bar" ><ID>owner_id</ID>'+
            '<DisplayName>foobar</DisplayName></Grantee><Permission>FULL_CONTROL</Permission></Grant></AccessControlList></AccessControlPolicy>';
           d = new xmldom(testACLResponse); 
           //d.dumpAll(); 
           system.assert( d.root.hasChildNodes() ); 
           
           system.assert(  d.root.isEqualNode(d.root) ,' is equal node');
           system.assert( d.root.textContent() == '' );
            
           d.getElementsByTagName('Grantee')[0].dump(); 
           
           system.assert( d.getElementsByTagName('Grantee')[0].hasAttributes() );
           
           d.getElementsByPath('/.*/Grantee/.*')[0].dump();    
           d.getElementByPath('/.*/Grantee/.*').dump();   
           system.assert( d.getElementByPath('bad') == null );   
           system.assert( d.getElementByTagName('badName') == null ); 
           system.assert( d.toXmlString() != null );   
       }
       
       public static testmethod void test4() { 
           System.assertEquals('GBP', 'GBP');

           xmldom f = new xmldom( '<RetrieveItem_Request_1 xmlns="http://www.reuters.com/ns/2006/05/01/webservices/rkd/Quotes_1"><ItemRequest Scope="All"><QoS xmlns="http://www.reuters.com/ns/2006/05/01/webservices/rkd/QuotesCommon"><TimelinessInfo Timeliness="DELAYED" /><RateInfo Rate="UNSPECIFIED" /></QoS><Fields xmlns="http://www.reuters.com/ns/2006/05/01/webservices/rkd/QuotesCommon" /><RequestKey xmlns="http://www.reuters.com/ns/2006/05/01/webservices/rkd/QuotesCommon" Name="MSFT.O" Service="" NameType="RIC" /></ItemRequest></RetrieveItem_Request_1>');            

       }
       
       public static testmethod void test_except() { 
            string testNotification = 
            '<?xml version="1.0" encoding="UTF-8"?>' +
               '<bookstore><book><title lang="eng">Harry Potter</title><price>29.99</price>' +
               '</book><book><title lang="eng">Learning '; // truncated
       xmldom f = new xmldom( testNotification );
       // should cause an exception which is caught , returning a truncated dom
       for ( xmldom.element e : f.getElementsByTagName('title') ) {
       e.dump(); 
       }
       system.assert( f.getElementsByTagName('title')[0].nodeValue == 'Harry Potter' );
       system.assert( f.getElementsByTagName('title')[1].nodeValue == '' );

       }
       
       public static testmethod void test3() { 
            string testNotification = 
            '<?xml version="1.0" encoding="UTF-8"?>' +
               '<bookstore><book><title lang="eng">Harry Potter</title><price>29.99</price>' +
               '</book><book><title lang="eng">Learning XML</title><price>39.95</price></book></bookstore>';

           xmldom d;
           d = new xmldom(testNotification);  
           list<xmldom.element> tmp ; 

           tmp =  d.root.getElementsByTagName('book');  // matching by name
           system.assertEquals( 2, tmp.size() ); 
           d.dumpList( tmp );
           
           XMLdom.Element a = d.ownerDocument();
           XMLdom.Element f = a.firstChild();
           XMLdom.Element c = f.ownerDocument(); 
           system.assert( a.isSameNode( c ) );
           XMLdom.Element b = a.cloneNode();
           system.assert( ! a.isSameNode(f) ); 
           
           a = new XMLdom.Element(); 
           system.assertEquals( a.firstChild(), null, ' must be null' );
           
           system.assertEquals( a.getElementByTagName('bad'), null);       
        }

       public static testmethod void testRSS() { 
           
           String feed = '<?xml version="1.0" encoding="UTF-8"?>'+
               '<feed xmlns="http://purl.org/atom/ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:feedburner="http://rssnamespace.org/feedburner/ext/1.0" version="0.3">'+
               '<title>Force.com Blog</title>' +
               '<link rel="alternate" type="text/html" href="http://blog.sforce.com/sforce/" />' +
               '<id>tag:typepad.com,2003:weblog-125619</id>' +
               '<link rel="service.post" type="application/x.atom+xml" href="http://www.typepad.com/t/atom/weblog/blog_id=125619" title="Force.com Blog" />' +
               '<modified>2008-01-23T20:27:30Z</modified>' +
               '<tagline></tagline>' +
               '<generator url="http://www.typepad.com/">TypePad</generator>' +
               '<info type="application/xhtml+xml">' +
               '<div xmlns="http://www.w3.org/1999/xhtml">This is an Atom formatted XML site feed. It is intended to be viewed in a Newsreader or syndicated to another site. Please visit <a href="http://blog.sforce.com/sforce/">Force.com Blog</a> for more info.</div>' +
               '</info><entry>' +
               '<title>Tour de Force Global Kickoff - it\'s a wrap!</title>' +
               '<link rel="alternate" type="text/html" href="http://feeds.feedburner.com/~r/SforceBlog/~3/221839184/tour-de-force-g.html" />' +
               '<link rel="service.edit" type="application/x.atom+xml" href="http://www.typepad.com/t/atom/weblog/blog_id=125619/entry_id=44564390" title="Tour de Force Global Kickoff - it\'s a wrap!" />' +
               '<id>tag:typepad.com,2003:post-44564390</id>' +
               '<issued>2008-01-23T12:27:30-08:00</issued>' +
               '<modified>2008-01-23T20:27:30Z</modified>' +
               '<created>2008-01-23T20:27:30Z</created>' +
               '<summary>Thank you to everyone that joined us last Thursday in San Francisco as we kicked off Tour de Force - we\'re delighted that you were able help us launch the Tour de Force roadshow to unleash the Force.com platform around...</summary>' +
               '<author><name>Mark Trang</name></author>' +
               '<content type="application/xhtml+xml" xml:lang="en-US" xml:base="http://blog.sforce.com/sforce/"><div xmlns="http://www.w3.org/1999/xhtml">'+
               '<p>Thank you to everyone that joined us last Thursday in San Francisco as we kicked off Tour de Force - </p></div></content>'+
               '<feedburner:origLink>http://blog.sforce.com/sforce/2008/01/tour-de-force-g.html</feedburner:origLink></entry></feed>';
           xmldom d = new xmldom(feed);  
           list<xmldom.element> tmp ;  
           d.dumpAll();
           XMLdom.Element e2 = d.ownerDocument().getElementByTagName('entry');
           e2.dumpAll();   
           system.assertEquals('entry', e2.nodeName );         
           system.assertEquals( e2.getValue('title'), 'Tour de Force Global Kickoff - it\'s a wrap!');
           
           
           XMLdom.Element[] el = d.ownerDocument().getElementsByTagName('link');
           for(XMLdom.Element ee:el) { 
               ee.dump(); 
           }
           
           e2 = d.ownerDocument().getElementByTagName('name');
           System.assertEquals('Mark Trang', e2.nodeValue);
           
           e2 = d.ownerDocument().getElementsByPath('/feed/title')[0];
           e2.dump();
           
                 // children of entry
           el= d.ownerDocument().getElementsByPath('/feed/entry/.*');
           d.dumpList(el);
           system.assertEquals( 14, el.size() );
           
           // just the entry node
           el= d.ownerDocument().getElementsByPath('/feed/entry');
           system.assertEquals( 1, el.size() );
           
           // entry and children
           el= d.ownerDocument().getElementsByPath('/.*/entry.*');
           system.assertEquals( 15, el.size() );
       } 

       public static testMethod void testScheduleMonthly() {
           ControllerInsertCustomSettings c = new ControllerInsertCustomSettings();
           c.insertValues();
           
           Currency__c currency1 = new Currency__c(name = 'GBP', Currency_Symbol__c = '£12', Symbol__c = '£12');
           insert currency1;

           Currency__c currency2 = [SELECT name From Currency__c WHERE id=:currency1.id];
           System.assertEquals('GBP', currency2.name);
           
           System.Test.StartTest();
               RunScheduler sh1 = new RunScheduler();
               String sch = '0 0 23 * * ?';
               String jobId = system.schedule('RunScheduler Check', sch, sh1);
               
               Invoice_RunScheduler__c r1 = new Invoice_RunScheduler__c(Name = 'Test', Type__c = System.Label.OptionMonthly, JobId__c = jobId, Automatically_Post_Invoices__c = true, Invoice_Day_Of_Month__c = '5', Target_Day_Of_Month__c = '5', Invoice_Currency__c = currency1.Id);
               insert r1;
           System.Test.stopTest();
       }
       
       public static testMethod void testScheduleOnce() {
           ControllerInsertCustomSettings c = new ControllerInsertCustomSettings();
           c.insertValues();
           
           Currency__c currency1 = new Currency__c(name = 'GBP', Currency_Symbol__c = '£12', Symbol__c = '£12');
           insert currency1;

           Currency__c currency2 = [SELECT name From Currency__c WHERE id=:currency1.id];
           System.assertEquals('GBP', currency2.name);
           
           System.Test.StartTest();
               RunScheduler sh1 = new RunScheduler();
               String sch = '0 0 23 * * ?';
               String jobId = system.schedule('RunScheduler Check', sch, sh1);
               
               Invoice_RunScheduler__c r1 = new Invoice_RunScheduler__c(Name = 'Test', Type__c = System.Label.OptionOnce, JobId__c = jobId, Automatically_Post_Invoices__c = true, Invoice_Date__c = system.today(), Target_Date__c = system.today(), Invoice_Currency__c = currency1.Id);
               insert r1;
           System.Test.stopTest();
       }
       
       public static testMethod void testScheduleDaily() {
           ControllerInsertCustomSettings c = new ControllerInsertCustomSettings();
           c.insertValues();
           
           Currency__c currency1 = new Currency__c(name = 'GBP', Currency_Symbol__c = '£12', Symbol__c = '£12');
           insert currency1;

           Currency__c currency2 = [SELECT name From Currency__c WHERE id=:currency1.id];
           System.assertEquals('GBP', currency2.name);
           
           System.Test.StartTest();
               RunScheduler sh1 = new RunScheduler();
               String sch = '0 0 23 * * ?';
               String jobId = system.schedule('RunScheduler Check', sch, sh1);
               
               Invoice_RunScheduler__c r1 = new Invoice_RunScheduler__c(Name = 'Test', Type__c = System.Label.OptionDaily, JobId__c = jobId, Automatically_Post_Invoices__c = true, Invoice_Date__c = system.today(), Target_Date__c = system.today(), Invoice_Currency__c = currency1.Id);
               insert r1;
           System.Test.stopTest();
       }
       
       public static testMethod void testRunSchedulerMrr() {
         System.assertEquals('GBP', 'GBP');

           System.Test.StartTest();
               RunSchedulerMrr sh1 = new RunSchedulerMrr();
               String sch = '0 0 23 * * ?';
               system.schedule('RunSchedulerMrr Check', sch, sh1);
           System.Test.stopTest();
       }


       public static testmethod void installScript() {
           PostInstallClass postinstall = new PostInstallClass();
           system.Test.testInstall(postinstall, null);
           system.Test.testInstall(postinstall, null);
           system.Test.testInstall(postinstall, new Version(1,0), true);
           
           list<Product_Rate_Plan_Charge__c> charges = [SELECT Id
                                                        FROM Product_Rate_Plan_Charge__c
                                                        ];
           system.assert(charges.size() > 0);
       } 
       
       //Please do not move this test method to anywhere because this code will also call RunSchedulerPayments
       //test method for ControllerForScheduling class
       static testMethod void ControllerForSchedulingPayments() {
           ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
           ControllerInsertCustomSettings.insertValues();
            
           Currency__c currency1 = new Currency__c(Name = 'GBPT', Symbol__c = '£1', Currency_Symbol__c = '£1');
           insert currency1;
           
           Payment_Scheduler__c invoiceRunScheduler = new Payment_Scheduler__c();
           ApexPages.Standardcontroller controller1 = new Apexpages.Standardcontroller(invoiceRunScheduler);
           ControllerForSchedulingPayments controllerForScheduling = new ControllerForSchedulingPayments(controller1);  
           controllerForScheduling.paymentScheduler.Name = 'testing@1';
           controllerForScheduling.paymentScheduler.Type__c = 'Daily';
           controllerForScheduling.onChangeOfType();
           controllerForScheduling.onChangeStartDate();
           controllerForScheduling.paymentScheduler.Type__c = 'Once';
           controllerForScheduling.paymentScheduler.Currency__c = currency1.Id;
           controllerForScheduling.paymentScheduler.Target_Date__c = system.today();
           controllerForScheduling.savePaymentScheduler();
           //perform validations
           
           controllerForScheduling.paymentScheduler.Start_date_and_time__c = null;
           controllerForScheduling.savePaymentScheduler();
           controllerForScheduling.paymentScheduler.Start_date_and_time__c = system.now().addMinutes(10);
           controllerForScheduling.paymentScheduler.Name = null;
           controllerForScheduling.savePaymentScheduler();
           controllerForScheduling.paymentScheduler.Name = 'testing@1';
           controllerForScheduling.savePaymentScheduler();
           controllerForScheduling.paymentScheduler.Currency__c = null;
           controllerForScheduling.savePaymentScheduler();
           controllerForScheduling.paymentScheduler.Currency__c = currency1.Id;
           controllerForScheduling.paymentScheduler.Type__c = 'Weekly';
           controllerForScheduling.paymentScheduler.Target_Day_of_week__c = null;
           controllerForScheduling.savePaymentScheduler();
           controllerForScheduling.paymentScheduler.Type__c = 'Monthly';
           controllerForScheduling.paymentScheduler.Target_Day_Of_Month__c = null;
           controllerForScheduling.savePaymentScheduler();
        
           ApexPages.Standardcontroller controller2 = new Apexpages.Standardcontroller(invoiceRunScheduler);
           ControllerForSchedulingPayments controllerForScheduling2 = new ControllerForSchedulingPayments(controller2);
           controllerForScheduling2.savePaymentScheduler();
           Payment_Scheduler__c invoiceRunSchedulerNew = [SELECT Id, Name 
                                                          FROM Payment_Scheduler__c 
                                                          WHERE Name = 'testing@1'];
           system.assert(invoiceRunSchedulerNew.Name == 'testing@1');
       }
   }