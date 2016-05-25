global with sharing class PaymentOperations {   
     WebService static PaymentOperations.PaymentResult authorize(Id invoiceId, string invoiceName, decimal amount) {
         Invoice__c invoice;
         Gateway__c gateWayToUse;
         
         if(invoiceName != null) {
             list<Invoice__c> listOfInvoices = InvoicingUtilClass.getInvoiceByName(invoiceName);
             if(listOfInvoices.isEmpty()) {
                 return InvoicingUtilClass.sendResponse(system.Label.NoInvoiceExistWithTheInvoiceName+' ' + invoiceName, false);
             } else {
                 invoice = listOfInvoices.get(0);
             }
         } else {
             invoice = InvoicingUtilClass.getInvoiceById(invoiceId);
         }
         
         list<Gateway__c> listOfGateway = new list<Gateway__c>();
         if(invoice.Account__r.Gateway__c == null) {
              listOfGateway = InvoicingUtilClass.getDefaultGateway();
              if(listOfGateway.isEmpty()) {
                 return InvoicingUtilClass.sendResponse(system.Label.Gateway_Warning, false);
              }
              
              gateWayToUse = listOfGateway.get(0);               
         } else {
            gateWayToUse = InvoicingUtilClass.getGateway(invoice.Account__r.Gateway__c);
         }
         //1  To find which is the default & active gateway record
         //1.1  check if the field(Gateway__c) on account is null
         //1.2  if it not equals to null then query full details of gateway
         //1.3  if it is null then query the gateway record form sf where it is active and default
         //1.4      if the 1.3 query returns zero records then show a warning message
         
         //2 To find which payment method should we use for above gateway
         //2.1  query the payment method record using the accountId(from invoice)
         //2.2  if the query doesn't return record then show a warning messages        
         //Rewrite
          list<Payment_Method__c> paymentMethods = InvoicingUtilClass.getDefaultMethodForAccount(invoice.Account__c);
          
          //If payment method doesnt exist throw an exception
          if(paymentMethods.isEmpty()) {
             return InvoicingUtilClass.sendResponse(system.Label.PaymentMethod_Warning, false);
          }
          
          Payment_Method__c paymentMethodToUse = paymentMethods.get(0);
          
          //Check if there is an existing authorized transaction against the same gateway and same payment method and same invoice
          list<Transaction__c> transactions = [   SELECT Name, Gateway_ID__c,
                                                  (   SELECT Id 
                                                      FROM Transactions__r
                                                      WHERE Type__c IN (:CommonUtilClass.TRANSACTION_TYPE_CHARGE, :CommonUtilClass.TRANSACTION_TYPE_VOID)
                                                      AND Response_Status__c =: CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED
                                                  )
                                                  FROM Transaction__c
                                                  WHERE Response_Status__c =: CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED
                                                  AND Gateway_ID__c != null
                                                  AND Type__c =: CommonUtilClass.TRANSACTION_TYPE_AUTHORIZATION
                                                  AND Request_Invoice__c = :invoiceId
                                                  AND Payment_Gateway__c = :gateWayToUse.Id
                                                  AND Payment_Method__c = :paymentMethodToUse.Id
                                                  order BY Name DESC
                                                  LIMIT 1
                                                  ];

          //Pick up the latest authorization txn and see if it has been charged or voided 
          Transaction__c transactionToUse;                                                
          if(!transactions.isEmpty()) {
              transactionToUse = transactions.get(0);
              
              //If paypal do additional checks as a new txn is created separately for authorize, void etc
              //If authorize.Net the inner query will always be empty
              if(transactionToUse.Transactions__r.isEmpty()){
                  
                  if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_SAGEPAY) {
                      return InvoicingUtilClass.sendResponse(system.Label.ChargeExistingAuthorizationTransaction + '\nTransaction Id : ' + transactions.get(0).Name, false);
                  } else {
                      return InvoicingUtilClass.sendResponse(system.Label.ChargeOrVoidExistingAuthorizationTransaction +'\nTransaction Id : ' + transactions.get(0).Name, false);              
                  }
              }
          } 
          
          //Create the relevant handler class 
          InterfacePaymentClass.paymentOperationsInterface paymentOperationsInterface;
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_AUTHORIZEDOTNET) {
              //Modified By Laxman, Ref : INVOICEIT-221
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingAuthorizeDotNet(gateWayToUse, invoice, paymentMethodToUse);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_PAYPAL) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingPaypal(gateWayToUse, invoice, paymentMethodToUse);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_WIRECARD) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingWireCard(gateWayToUse, invoice, paymentMethodToUse);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
              // Manigandan SA, INVOICEIT-600
          if((gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_CyberSource || gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_CyberSource_CC_Token) && paymentMethodToUse.Payment_Method__c == CommonUtilClass.PAYMENTTYPE_ACH) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentBankDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingCyberSource(gateWayToUse, invoice, paymentMethodToUse);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              } 
          } 
           // Manigandan SA, INVOICEIT-600
         if((gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_CyberSource || gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_CyberSource_CC_Token) && paymentMethodToUse.Payment_Method__c == CommonUtilClass.PAYMENTTYPE_CREDITCARD) { 
                  paymentOperationsInterface = new ClassForHandlingCyberSourceForCreditCard(gateWayToUse, invoice, paymentMethodToUse);  
          }

          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_ACH) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentBankDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingAuthorizeECheck(gateWayToUse, invoice, paymentMethodToUse);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_FIRSTDATA) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingFirstdataCard(gateWayToUse, invoice, paymentMethodToUse, null, null, null, null);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_AUTHORIZEDOTNETCIM) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentProfileInfo(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingAuthorizeDotNetCIM(gateWayToUse, paymentMethodToUse, null, invoice);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_STRIPE) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingStripeCard(gateWayToUse, invoice, paymentMethodToUse, null, null, null, null);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_SAGEPAY) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingSagePay(gateWayToUse, invoice, paymentMethodToUse, null, null, null, null);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          
          //below if condition added by ram
           if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_EWAY) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingEway(gateWayToUse, invoice, paymentMethodToUse, null, null, null, null);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          } 
          
          //below if condition added by ram,
           if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_BRAINTREE) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(paymentMethodToUse.Token__c != null || sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingBrainTree(gateWayToUse, invoice, paymentMethodToUse, null, null, null, null);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          } 

          //return the response
          return paymentOperationsInterface.handleAuthorize_Click(); 
          
          return null;
     } 
     
     WebService static PaymentOperations.PaymentResult authorizeAndCharge(Id invoiceId, string invoiceName, decimal amount) {
         Invoice__c invoice;
         Gateway__c gateWayToUse;
         
         if(invoiceName != null) {
             list<Invoice__c> listOfInvoices = InvoicingUtilClass.getInvoiceByName(invoiceName);
             if(listOfInvoices.isEmpty()) {
                 return InvoicingUtilClass.sendResponse(system.Label.NoInvoiceExistWithTheInvoiceName + invoiceName, false);
             } else {
                 invoice = listOfInvoices.get(0);
             }
         } else {
             invoice = InvoicingUtilClass.getInvoiceById(invoiceId);
         }
         
         list<Gateway__c> listOfGateway = new list<Gateway__c>();
         if(invoice.Account__r.Gateway__c == null) {
              listOfGateway = InvoicingUtilClass.getDefaultGateway();
              if(listOfGateway.isEmpty()) {
                 return InvoicingUtilClass.sendResponse(system.Label.Gateway_Warning, false);
              }
              
              gateWayToUse = listOfGateway.get(0);               
         } else {
            gateWayToUse = InvoicingUtilClass.getGateway(invoice.Account__r.Gateway__c);
         }
         
          //Rewrite
          list<Payment_Method__c> paymentMethods = InvoicingUtilClass.getDefaultMethodForAccount(invoice.Account__c);
          
          //If payment method doesnt exist throw an exception
          if(paymentMethods.isEmpty()) {
             return InvoicingUtilClass.sendResponse(system.Label.PaymentMethod_Warning, false);
          }
          
          Payment_Method__c paymentMethodToUse = paymentMethods.get(0);
          
          //Check if there is an existing authorized transaction against the same gateway and same payment method and same invoice
          list<Transaction__c> transactions = [   SELECT Name, Gateway_ID__c,
                                                  (   SELECT Id 
                                                      FROM Transactions__r
                                                      WHERE Type__c = :CommonUtilClass.TRANSACTION_TYPE_VOID
                                                      AND Response_Status__c =: CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED
                                                  )
                                                  FROM Transaction__c
                                                  WHERE Response_Status__c =: CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED
                                                  AND Gateway_ID__c != null
                                                  AND Type__c =: CommonUtilClass.TRANSACTION_TYPE_AUTHORIZATION
                                                  AND Request_Invoice__c = :invoiceId
                                                  AND Payment_Gateway__c = :gateWayToUse.Id
                                                  AND Payment_Method__c = :paymentMethodToUse.Id
                                                  order BY Name DESC
                                                  LIMIT 1
                                                  ];                                                  
         
          //If there is an existing transaction that was authorized and not charged, then use that else null
          //For paypal the existing txn may have a child that was voided. If thats the case the transactiontouse will be null
          Transaction__c transactionToUse;
          if(!transactions.isEmpty() && transactions.get(0).Transactions__r.isEmpty()){
              transactionToUse = transactions.get(0);
          }
          
          //Create the relevant handler class 
          InterfacePaymentClass.paymentOperationsInterface paymentOperationsInterface;
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_AUTHORIZEDOTNET) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingAuthorizeDotNet(gateWayToUse, invoice, paymentMethodToUse);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_PAYPAL) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingPaypal(gateWayToUse, invoice, paymentMethodToUse);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_WIRECARD) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingWireCard(gateWayToUse, invoice, paymentMethodToUse);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          // Manigandan SA, INVOICEIT-600
          if((gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_CyberSource || gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_CyberSource_CC_Token) && paymentMethodToUse.Payment_Method__c == CommonUtilClass.PAYMENTTYPE_ACH) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentBankDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingCyberSource(gateWayToUse, invoice, paymentMethodToUse);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              } 
          } 
           // Manigandan SA, INVOICEIT-600
         if((gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_CyberSource || gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_CyberSource_CC_Token) && paymentMethodToUse.Payment_Method__c == CommonUtilClass.PAYMENTTYPE_CREDITCARD) { 
                  paymentOperationsInterface = new ClassForHandlingCyberSourceForCreditCard(gateWayToUse, invoice, paymentMethodToUse);  
          }
          
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_ACH) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentBankDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingAuthorizeECheck(gateWayToUse, invoice, paymentMethodToUse);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }  
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_FIRSTDATA) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingFirstdataCard(gateWayToUse, invoice, paymentMethodToUse, null, null, null, null);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_AUTHORIZEDOTNETCIM) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentProfileInfo(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingAuthorizeDotNetCIM(gateWayToUse, paymentMethodToUse, null, invoice);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_STRIPE) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingStripeCard(gateWayToUse, invoice, paymentMethodToUse, null, null, null, null);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_SAGEPAY) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingSagePay(gateWayToUse, invoice, paymentMethodToUse, null, null, null, null);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          
          //below if condition added by ram
           if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_EWAY) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingEway(gateWayToUse, invoice, paymentMethodToUse, null, null, null, null);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          
          // addded by Supriya to test Braintree gateway
           if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_BRAINTREE) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              
              if(paymentMethodToUse.Token__c != null || sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingBrainTree(gateWayToUse, invoice, paymentMethodToUse, null, null, null, null);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          } 
          
          //If the transaction is null then pass null as the parameter to the global method, else pass the actual id      
          if(transactionToUse != null) {
              //Use the authorize transaction in the system
              return paymentOperationsInterface.handleAuthorizeAndCharge_Click(transactionToUse.Id, transactionToUse.Gateway_ID__c);
          } else {
              //No authorized transaction to use
              return paymentOperationsInterface.handleAuthorizeAndCharge_Click(null, null);
          }
     }

     //Start- Added by DL, INVOICEIT-629, calling generic method
     WebService static PaymentSiteOperation.GenericPaymentResult authorizeAndChargePaymentPlanInstalments(Id invoiceId, Id paymentMethodId, decimal amount){
        
        Invoice__c invoice = InvoicingUtilClass.getInvoiceById(invoiceId);
        Gateway__c gateWayToUse;
        decimal amountToBeProcessed = 0;
        list<Gateway__c> listOfGateway = new list<Gateway__c>();
        if(amount != null){
          amountToBeProcessed = amount;
        }
        if(invoice.Account__r.Gateway__c == null) {
             listOfGateway = InvoicingUtilClass.getDefaultGateway();
             if(listOfGateway.isEmpty()) {
                PaymentSiteOperation.GenericPaymentResult result = new PaymentSiteOperation.GenericPaymentResult();
                result.message = system.Label.Gateway_Warning;
                result.reloadPage = false; 
                return result;
             }
            
             gateWayToUse = listOfGateway.get(0);               
        } else {
           gateWayToUse = InvoicingUtilClass.getGateway(invoice.Account__r.Gateway__c);
        }

        Payment_Method__c paymentMethodToUse = [SELECT Card_Number__c, Card_Type__c, Payment_Method__c, Card_Expiration_Month__c, Card_Expiration_Year__c, CVV__c, Name_on_Card__c, Billing_Country__c,
                  Bank_Routing_Code__c, Bank_Account_Number__c, Bank_Account_Type__c, Bank_Name__c, Bank_Account_Name__c,
                  Billing_First_Name__c, Billing_Last_Name__c, Billing_Address__c, Billing_City__c, Billing_State_Province__c, Billing_Zip_Postal__c ,
                  Account__c, Account__r.Name, Billing_Phone__c, Billing_Fax__c, Billing_Email__c,Account__r.Customer_Profile_ID__c,Payment_Profile_ID__c,
                  Encrypted_CVV__c,Encrypted_Card_Number__c,Token__c 
                  FROM Payment_Method__c
                  WHERE Id =: paymentMethodId];

        Currency__c objCurrency = [select Id, Currency_Symbol__c,Currency_Name__c,Name from Currency__c where id =:invoice.CurrencyL__c];
        PaymentSiteOperation.GenericPaymentParameters genericPaymentParameters =  new PaymentSiteOperation.GenericPaymentParameters();
        genericPaymentParameters.invoiceObj = invoice;
        genericPaymentParameters.gateway = gateWayToUse;
        genericPaymentParameters.paymentMethod = paymentMethodToUse;
        genericPaymentParameters.amountToProcess = amountToBeProcessed;
        genericPaymentParameters.currencyISOCode = objCurrency.Name;
        genericPaymentParameters.shouldTokenizeCard = false;
        //PaymentSiteOperation.GenericPaymentResult genericPaymentResult = new PaymentSiteOperation.GenericPaymentResult();         
        PaymentSiteOperation site = new PaymentSiteOperation();
        return site.processGenericPayment(genericPaymentParameters);
        //return null;
     }
     //End
     
     WebService static PaymentOperations.PaymentResult void(Id invoiceId) {
          Invoice__c invoice = InvoicingUtilClass.getInvoiceById(invoiceId);
          Gateway__c gateWayToUse;
        
          list<Gateway__c> listOfGateway = new list<Gateway__c>();
          if(invoice.Account__r.Gateway__c == null) {
               listOfGateway = InvoicingUtilClass.getDefaultGateway();
               if(listOfGateway.isEmpty()) {
                  return InvoicingUtilClass.sendResponse(system.Label.Gateway_Warning, false);
               }
              
               gateWayToUse = listOfGateway.get(0);               
          } else {
             gateWayToUse = InvoicingUtilClass.getGateway(invoice.Account__r.Gateway__c);
          }
          
          //Rewrite
          list<Payment_Method__c> paymentMethods = InvoicingUtilClass.getDefaultMethodForAccount(invoice.Account__c);
          
          //If payment method doesnt exist throw an exception
          if(paymentMethods.isEmpty()) {
             return InvoicingUtilClass.sendResponse(system.Label.PaymentMethod_Warning, false);
          }
          
          Payment_Method__c paymentMethodToUse = paymentMethods.get(0);
          
          //Check if there is an existing authorized transaction against the same gateway and same payment method and same invoice
          list<Transaction__c> transactions = [   SELECT Name, Gateway_ID__c, Amount__c,
                                                  (   SELECT Id 
                                                      FROM Transactions__r
                                                      WHERE Type__c IN (:CommonUtilClass.TRANSACTION_TYPE_REFUND, :CommonUtilClass.TRANSACTION_TYPE_VOID)
                                                      AND Response_Status__c =: CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED
                                                  )
                                                  FROM Transaction__c
                                                  WHERE Response_Status__c =: CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED
                                                  AND Gateway_ID__c != null
                                                  AND (
                                                         Type__c =: CommonUtilClass.TRANSACTION_TYPE_AUTHORIZATION 
                                                         OR 
                                                         Type__c =: CommonUtilClass.TRANSACTION_TYPE_CHARGE
                                                       )
                                                  AND Request_Invoice__c = :invoiceId
                                                  AND Payment_Gateway__c = :gateWayToUse.Id
                                                  AND Payment_Method__c = :paymentMethodToUse.Id
                                                  order BY Name DESC
                                                  LIMIT 1
                                                  ];                                                      
         
         //Pick up the latest authorization txn and see if it has been charged or voided 
          Transaction__c transactionToUse;                                                
          if(!transactions.isEmpty()) {
              transactionToUse = transactions.get(0);
              
              //If paypal do additional checks as a new txn is created separately for authorize, void etc
              //If authorize.Net the transaction status itself will be changed
              if(!transactionToUse.Transactions__r.isEmpty()){
                  return InvoicingUtilClass.sendResponse(system.Label.NoTransactionToVoid, false);              
              }
          }else{
              return InvoicingUtilClass.sendResponse(system.Label.NoTransactionToVoid, false); 
          } 
          
          //Create the relevant handler class 
          InterfacePaymentClass.paymentOperationsInterface paymentOperationsInterface;
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_AUTHORIZEDOTNET) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingAuthorizeDotNet(gateWayToUse, invoice, paymentMethodToUse);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_PAYPAL) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingPaypal(gateWayToUse, invoice, paymentMethodToUse);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_WIRECARD) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingWireCard(gateWayToUse, invoice, paymentMethodToUse);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          // Manigandan SA, INVOICEIT-600
          if((gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_CyberSource || gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_CyberSource_CC_Token) && paymentMethodToUse.Payment_Method__c == CommonUtilClass.PAYMENTTYPE_ACH) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentBankDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingCyberSource(gateWayToUse, invoice, paymentMethodToUse);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              } 
          } 
           // Manigandan SA, INVOICEIT-600
         if((gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_CyberSource || gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_CyberSource_CC_Token) && paymentMethodToUse.Payment_Method__c == CommonUtilClass.PAYMENTTYPE_CREDITCARD) { 
                  paymentOperationsInterface = new ClassForHandlingCyberSourceForCreditCard(gateWayToUse, invoice, paymentMethodToUse);  
          }

          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_ACH) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentBankDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingAuthorizeECheck(gateWayToUse, invoice, paymentMethodToUse);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_FIRSTDATA) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingFirstdataCard(gateWayToUse, invoice, paymentMethodToUse, null, null, null, null);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_AUTHORIZEDOTNETCIM) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentProfileInfo(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingAuthorizeDotNetCIM(gateWayToUse, paymentMethodToUse, null, invoice);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_STRIPE) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingStripeCard(gateWayToUse, invoice, paymentMethodToUse, null, null, null, null);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_SAGEPAY) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingSagePay(gateWayToUse, invoice, paymentMethodToUse, null, null, null, null);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          
          //below if condition added by ram
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_EWAY) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingEway(gateWayToUse, invoice, paymentMethodToUse, null, null, null, null);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          
          //below if condition added by ram, 19-2-2015,braintree
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_BRAINTREE) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(paymentMethodToUse.Token__c != null || sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingBrainTree(gateWayToUse, invoice, paymentMethodToUse, null, null, null, null);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          } 
          
          return paymentOperationsInterface.handleVoid_Click(transactionToUse.Gateway_ID__c, transactionToUse.Id, transactionToUse.Amount__c);
          
          return null;
     }
     
      WebService static PaymentOperations.PaymentResult refund(Id invoiceId, string invoiceName, decimal amount) {
          Invoice__c invoice = InvoicingUtilClass.getInvoiceById(invoiceId);
          Gateway__c gateWayToUse;
        
          list<Gateway__c> listOfGateway = new list<Gateway__c>();
          if(invoice.Account__r.Gateway__c == null) {
               listOfGateway = InvoicingUtilClass.getDefaultGateway();
               if(listOfGateway.isEmpty()) {
                  return InvoicingUtilClass.sendResponse(system.Label.Gateway_Warning, false);
               }
              
               gateWayToUse = listOfGateway.get(0);               
          } else {
             gateWayToUse = InvoicingUtilClass.getGateway(invoice.Account__r.Gateway__c);
          }
          
          //Rewrite
          list<Payment_Method__c> paymentMethods = InvoicingUtilClass.getDefaultMethodForAccount(invoice.Account__c);
          
          //If payment method doesnt exist throw an exception
          if(paymentMethods.isEmpty()) {
             return InvoicingUtilClass.sendResponse(system.Label.PaymentMethod_Warning, false);
          }
          
          Payment_Method__c paymentMethodToUse = paymentMethods.get(0);
          
          list<Transaction__c> transactions = [   SELECT Name, Gateway_ID__c, Amount__c,
                                                  (   SELECT Id 
                                                      FROM Transactions__r
                                                      WHERE Type__c IN (:CommonUtilClass.TRANSACTION_TYPE_REFUND, :CommonUtilClass.TRANSACTION_TYPE_VOID)
                                                      AND Response_Status__c =: CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED
                                                  )
                                                  FROM Transaction__c
                                                  WHERE Response_Status__c =: CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED
                                                  AND Gateway_ID__c != null
                                                  AND Type__c =: CommonUtilClass.TRANSACTION_TYPE_CHARGE
                                                  AND Request_Invoice__c = :invoiceId
                                                  AND Payment_Gateway__c = :gateWayToUse.Id
                                                  AND Payment_Method__c = :paymentMethodToUse.Id
                                                  order BY Name DESC
                                                  LIMIT 1
                                              ];  
                                                  
          //Check if there is an existing authorized transaction against the same gateway and same payment method and same invoice
          
          //Pick up the latest authorization txn and see if it has been charged or voided 
          Transaction__c transactionToUse;
          if(!transactions.isEmpty()) {
              transactionToUse = transactions.get(0);
              //If paypal do additional checks as a new txn is created separately for authorize, void etc
              //If authorize.Net the transaction status itself will be changed
              if(!transactionToUse.Transactions__r.isEmpty()){
                  return InvoicingUtilClass.sendResponse(system.Label.NoTransactionsToRefund, false);                
              }
          }else{
              return InvoicingUtilClass.sendResponse(system.Label.NoTransactionsToRefund, false);
          } 
          
          //Create the relevant handler class 
          InterfacePaymentClass.paymentOperationsInterface paymentOperationsInterface;
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_AUTHORIZEDOTNET) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingAuthorizeDotNet(gateWayToUse, invoice, paymentMethodToUse);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_PAYPAL) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingPaypal(gateWayToUse, invoice, paymentMethodToUse);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_WIRECARD) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingWireCard(gateWayToUse, invoice, paymentMethodToUse);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          // Manigandan SA, INVOICEIT-600
          if((gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_CyberSource || gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_CyberSource_CC_Token) && paymentMethodToUse.Payment_Method__c == CommonUtilClass.PAYMENTTYPE_ACH) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentBankDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingCyberSource(gateWayToUse, invoice, paymentMethodToUse);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              } 
          } 
           // Manigandan SA, INVOICEIT-600
         if((gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_CyberSource || gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_CyberSource_CC_Token) && paymentMethodToUse.Payment_Method__c == CommonUtilClass.PAYMENTTYPE_CREDITCARD) { 
                  paymentOperationsInterface = new ClassForHandlingCyberSourceForCreditCard(gateWayToUse, invoice, paymentMethodToUse);  
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_ACH) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentBankDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingAuthorizeECheck(gateWayToUse, invoice, paymentMethodToUse);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_FIRSTDATA) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingFirstdataCard(gateWayToUse, invoice, paymentMethodToUse, null, null, null, null);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_AUTHORIZEDOTNETCIM) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentProfileInfo(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingAuthorizeDotNetCIM(gateWayToUse, paymentMethodToUse, null, invoice);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_STRIPE) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingStripeCard(gateWayToUse, invoice, paymentMethodToUse, null, null, null, null);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_SAGEPAY) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingSagePay(gateWayToUse, invoice, paymentMethodToUse, null, null, null, null);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          
          //below if condition added by ram
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_EWAY) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingEway(gateWayToUse, invoice, paymentMethodToUse, null, null, null, null);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
         
          //below if condition added by ram, 19-2-2015,braintree
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_BRAINTREE) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(paymentMethodToUse.Token__c != null || sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingBrainTree(gateWayToUse, invoice, paymentMethodToUse, null, null, null, null);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          } 
          
          return paymentOperationsInterface.handleRefund_Click(transactionToUse.Gateway_ID__c, transactionToUse.Id, transactionToUse.Amount__c);
          
          return null;
     }
     //Added by dhanalakshmi for INVOICEIT-18(Refund for transaction)
      WebService static PaymentOperations.PaymentResult transactionRefund(Id transactionId){
              Transaction__c transactionObj = InvoicingUtilClass.getTransaction(transactionId);
          Gateway__c gateWayToUse;
          Invoice__c invoice;
          
          // some gateways, we are creating child transaction with out updating the main transaction records
          // in order to check whether child transaction is created or not to reprocess the same the ransaction
          list<Transaction__c> transactions = [SELECT Id, Transaction__c, Type__c
                                               FROM Transaction__c
                                               WHERE Transaction__c != null
                                               AND (Type__c = 'Refund' OR Type__c = 'Void')
                                               AND Response_Status__c = 'Approved'
                                               AND Transaction__c =: transactionId
                                              ];
          if(!transactions.isEmpty())
          {
              return InvoicingUtilClass.sendResponse(system.Label.TransactionIsAlreadyRefunded, false);
          }
        
          list<Gateway__c> listOfGateway = new list<Gateway__c>();
          list<Payment_Method__c> PaymentMethods = new List<Payment_Method__c>();
          if(transactionObj.Payment_Gateway__c == null) {
               listOfGateway = InvoicingUtilClass.getDefaultGateway();
               if(listOfGateway.isEmpty()) {
                  return InvoicingUtilClass.sendResponse(system.Label.Gateway_Warning, false);
               }
              
               gateWayToUse = listOfGateway.get(0);               
          } else {
             gateWayToUse = InvoicingUtilClass.getGateway(transactionObj.Payment_Gateway__c);
          }
          Account objAccount = [select id, Name FROM Account where id =:transactionObj.Payment_Method__r.Account__c];
          if(transactionObj.Request_Invoice__c != null)
          {
              invoice = InvoicingUtilClass.getInvoiceById(transactionObj.Request_Invoice__c);
          }
          Payment_Method__c paymentMethodToUse = [SELECT Card_Number__c, Card_Type__c, Payment_Method__c, Card_Expiration_Month__c, Card_Expiration_Year__c, CVV__c, Name_on_Card__c, Billing_Country__c,
                                  Bank_Routing_Code__c, Bank_Account_Number__c, Bank_Account_Type__c, Bank_Name__c, Bank_Account_Name__c,
                                  Billing_First_Name__c, Billing_Last_Name__c, Billing_Address__c, Billing_City__c, Billing_State_Province__c, Billing_Zip_Postal__c ,
                                  Account__c, Account__r.Name, Billing_Phone__c, Billing_Fax__c, Billing_Email__c,Account__r.Customer_Profile_ID__c,Payment_Profile_ID__c,
                                  Encrypted_CVV__c,Encrypted_Card_Number__c,Token__c
                                  FROM Payment_Method__c
                                  WHERE id =: transactionObj.Payment_Method__c
                                  ];
          
          
          //Create the relevant handler class 
          InterfacePaymentClass.paymentOperationsInterface paymentOperationsInterface;
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_AUTHORIZEDOTNET) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingAuthorizeDotNet(gateWayToUse, invoice, paymentMethodToUse);
              } else { 
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_PAYPAL) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingPaypal(gateWayToUse, invoice, paymentMethodToUse);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_WIRECARD) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingWireCard(gateWayToUse, invoice, paymentMethodToUse);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
             // Manigandan SA, INVOICEIT-600
          if((gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_CyberSource || gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_CyberSource_CC_Token) && paymentMethodToUse.Payment_Method__c == CommonUtilClass.PAYMENTTYPE_ACH) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentBankDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingCyberSource(gateWayToUse, invoice, paymentMethodToUse);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              } 
          } 
           // Manigandan SA, INVOICEIT-600
         if((gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_CyberSource || gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_CyberSource_CC_Token) && paymentMethodToUse.Payment_Method__c == CommonUtilClass.PAYMENTTYPE_CREDITCARD) { 
                  paymentOperationsInterface = new ClassForHandlingCyberSourceForCreditCard(gateWayToUse, invoice, paymentMethodToUse);  
          }

          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_ACH) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentBankDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingAuthorizeECheck(gateWayToUse, invoice, paymentMethodToUse);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_FIRSTDATA) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingFirstdataCard(gateWayToUse, invoice, paymentMethodToUse, null, null, objAccount, null );
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_AUTHORIZEDOTNETCIM) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentProfileInfo(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingAuthorizeDotNetCIM(gateWayToUse, paymentMethodToUse, null, invoice);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_STRIPE) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingStripeCard(gateWayToUse, invoice, paymentMethodToUse, null, null, null, null);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_SAGEPAY) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingSagePay(gateWayToUse, invoice, paymentMethodToUse, null, null, null, null);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_EWAY) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingEway(gateWayToUse, invoice, paymentMethodToUse, null, null, null, null);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          
          //below if condition added by ram, 19-2-2015,braintree
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_BRAINTREE) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(paymentMethodToUse.Token__c != null || sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingBrainTree(gateWayToUse, invoice, paymentMethodToUse, null, null, null, null);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          } 
          
          return paymentOperationsInterface.handleRefund_Click(transactionObj.Gateway_ID__c, transactionObj.Id, transactionObj.Amount__c);
          //return null;
     }
     
     WebService static PaymentOperations.PaymentResult transactionVoid(Id transactionId){
          Transaction__c transactionObj = InvoicingUtilClass.getTransaction(transactionId);
          Gateway__c gateWayToUse;
          Invoice__c invoice;
          list<Gateway__c> listOfGateway = new list<Gateway__c>();
          list<Payment_Method__c> PaymentMethods = new List<Payment_Method__c>();
          
          // some gateways, we are creating child transaction with out updating the main transaction records
          // in order to check whether child transaction is created or not to reprocess the same the ransaction
          list<Transaction__c> transactions = [SELECT Id, Transaction__c, Type__c
                                               FROM Transaction__c
                                               WHERE Transaction__c != null
                                               AND (Type__c = 'Void' OR Type__c = 'Refund')
                                               AND Response_Status__c = 'Approved'
                                               AND Transaction__c =: transactionId
                                              ];
          if(!transactions.isEmpty())
          {
              return InvoicingUtilClass.sendResponse(system.Label.TransactionIsAlreadyVoid, false);
          }
          
          
          if(transactionObj.Payment_Gateway__c == null) {
               listOfGateway = InvoicingUtilClass.getDefaultGateway();
               if(listOfGateway.isEmpty()) {
                  return InvoicingUtilClass.sendResponse(system.Label.Gateway_Warning, false);
               }
              
               gateWayToUse = listOfGateway.get(0);               
          } else {
             gateWayToUse = InvoicingUtilClass.getGateway(transactionObj.Payment_Gateway__c);
          }
          Account objAccount = [select id, Name FROM Account where id =:transactionObj.Payment_Method__r.Account__c];

          if(transactionObj.Request_Invoice__c != null)
          {
              invoice = InvoicingUtilClass.getInvoiceById(transactionObj.Request_Invoice__c);
          }
          
          Payment_Method__c paymentMethodToUse = [SELECT Card_Number__c, Card_Type__c, Payment_Method__c, Card_Expiration_Month__c, Card_Expiration_Year__c, CVV__c, Name_on_Card__c, Billing_Country__c,
                                  Bank_Routing_Code__c, Bank_Account_Number__c, Bank_Account_Type__c, Bank_Name__c, Bank_Account_Name__c,
                                  Billing_First_Name__c, Billing_Last_Name__c, Billing_Address__c, Billing_City__c, Billing_State_Province__c, Billing_Zip_Postal__c ,
                                  Account__c, Account__r.Name, Billing_Phone__c, Billing_Fax__c, Billing_Email__c,Account__r.Customer_Profile_ID__c,Payment_Profile_ID__c,
                                  Encrypted_CVV__c,Encrypted_Card_Number__c,Token__c 
                                  FROM Payment_Method__c
                                  WHERE id =: transactionObj.Payment_Method__c
                                  ];
          
          
          //Create the relevant handler class 
          InterfacePaymentClass.paymentOperationsInterface paymentOperationsInterface;
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_AUTHORIZEDOTNET) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingAuthorizeDotNet(gateWayToUse, invoice, paymentMethodToUse);
              } else { 
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_PAYPAL) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingPaypal(gateWayToUse, invoice, paymentMethodToUse);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_WIRECARD) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingWireCard(gateWayToUse, invoice, paymentMethodToUse);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          
          // Manigandan SA, INVOICEIT-600
          if((gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_CyberSource || gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_CyberSource_CC_Token) && paymentMethodToUse.Payment_Method__c == CommonUtilClass.PAYMENTTYPE_ACH) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentBankDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingCyberSource(gateWayToUse, invoice, paymentMethodToUse);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              } 
          } 
           // Manigandan SA, INVOICEIT-600
         if((gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_CyberSource || gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_CyberSource_CC_Token) && paymentMethodToUse.Payment_Method__c == CommonUtilClass.PAYMENTTYPE_CREDITCARD) { 
                  paymentOperationsInterface = new ClassForHandlingCyberSourceForCreditCard(gateWayToUse, invoice, paymentMethodToUse);  
          }

          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_ACH) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentBankDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingAuthorizeECheck(gateWayToUse, invoice, paymentMethodToUse);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_FIRSTDATA) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingFirstdataCard(gateWayToUse, invoice, paymentMethodToUse, null, null, objAccount, null );
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_AUTHORIZEDOTNETCIM) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentProfileInfo(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingAuthorizeDotNetCIM(gateWayToUse, paymentMethodToUse, null, invoice);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_STRIPE) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingStripeCard(gateWayToUse, invoice, paymentMethodToUse, null, null, null, null);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_SAGEPAY) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingSagePay(gateWayToUse, invoice, paymentMethodToUse, null, null, null, null);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_EWAY) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingEway(gateWayToUse, invoice, paymentMethodToUse, null, null, null, null);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }
          
          //below if condition added by ram, 19-2-2015,braintree
          if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_BRAINTREE) {
              string sAnyMissingFields = InvoicingUtilClass.validatePaymentCardDetails(paymentMethodToUse);
              if(paymentMethodToUse.Token__c != null || sAnyMissingFields == null) {
                  paymentOperationsInterface = new ClassForHandlingBrainTree(gateWayToUse, invoice, paymentMethodToUse, null, null, null, null);
              } else {
                  return InvoicingUtilClass.sendResponse(sAnyMissingFields, false);
              }
          }  
          
          return paymentOperationsInterface.handleVoid_Click(transactionObj.Gateway_ID__c, transactionObj.Id, transactionObj.Amount__c);
          //return null;
     }
     //End

     global class PaymentResult {
        webService String message;
        webService Boolean reloadPage;
        webService Transaction__c transactionObj;
     }
  }