/**
     * Webservice for handling payments.
     *
     * @author Acertis Cloud Ltd, Naveen Mallela, Devender M
     * Copyright (c) 2011, Acertis Cloud, Salesforce.com Inc. All rights reserved.
     **/
     
    /*
     
     Host Addresses
            Use the following host addresses for the authorize.net:
            1 For live transactions, use https://api.stripe.com/v1/charges
            2 For testing purposes, use 
            
    Attributes :
        
        CreditCardNumber(Required)
        ExpirationYear(Required)
        ExpirationMonth(Required)
        Type(Required)
        Amount(Required)
        CVV(A conditional (con.) message field must be included in some instances. Its omission may cause the process request type to be rejected)
        
        Demo Test cards
        JCB 3530111333300000
        DINERS 38520000023237
        Discover 6011111111111117
        VISA 4242424242424242
        MASTER 5555555555554444
        American Express 378282246310005 
        
        Mail Body From Stripe Support
        Hey there,

        You can void an authorized charge by using the refund endpoint (the same endpoint for refunding an already captured charge):
        
        - https://stripe.com/docs/api#refund_charge
        
        Please let me know if you have any questions!
    */ 

    public with sharing class ClassForHandlingStripeCard implements InterfacePaymentClass.paymentOperationsInterface{
        
        private map<string, Object> parameters;
        private string sHttpBody = '';
        private string sHttpEndPoint = '';
        private string sHttpResponse;
        private Payment_Method__c paymentMethod;
        private Gateway__c gateway;
        private Invoice__c invoice;
        private PaymentOperations.PaymentResult result = new PaymentOperations.PaymentResult();
        private Transaction__c transactionObj;
        private string sDummyPaymentId;
        private Account account;
        private decimal dAmount;
        private String sFirstName = '';
        private String sLastName = '';
        private String sAddress1 = '';
        private String sCity = '';
        private String sZipCode = '';
        private String sState = '';
        private String sCountry = '';
        private String sPhone = '';
        private String sEmail = '';
        private string API_KEY = '';
        private boolean isGenericMethodCall = true;
        
        // this variable is declared because on force.com site page if user selected the savecard information.
        boolean isSavePaymentMethod = false;
        
        //This is used for Virtualterminal Purpose
        private Id currencyId;
        //This is used for Virtualterminal Purpose
        public ClassForHandlingStripeCard(Gateway__c gateway, Invoice__c invoice, Payment_Method__c paymentMethod,string sDummyPaymentId,decimal dAmount,Account account, Id currencyId) {
            this.invoice = invoice;
            this.account = account;
            this.dAmount = dAmount;
            this.paymentMethod = paymentMethod;
            this.gateway = gateway; 
            this.sDummyPaymentId = sDummyPaymentId;
            this.currencyId = currencyId;
            this.API_KEY = gateway.Security_Key__c;
            sHttpEndPoint = CommonUtilClass.ENDPOINT_STRIPE;
            
            populateCustomerDetails();   
        } 
        
        public PaymentOperations.PaymentResult handleAuthorize_Click() {
            try {
                decimal amountToBeProcessed = 0;
                
                if(invoice.Payment_Request_Amount__c != null && invoice.Payment_Request_Amount__c > 0 && invoice.Payment_Request_Amount__c < invoice.Unpaid_Amount__c) {
                    amountToBeProcessed = invoice.Payment_Request_Amount__c;            
                } else {
                    amountToBeProcessed = invoice.Unpaid_Amount__c;         
                }
                
                string amount = amountToBeProcessed.toPlainString().replace('.', '');
                String authorizationRequest ='card[number]='+paymentMethod.Card_Number__c+'&capture=false&card[exp_year]='+paymentMethod.Card_Expiration_Year__c+'&card[exp_month]='+paymentMethod.Card_Expiration_Month__c+'&card[cvc]='+paymentMethod.CVV__c+'&amount='+amount+ '&currency='+invoice.CurrencyL__r.Name + '&description='+invoice.Name + '&card[name]='+sFirstName+ ' ' +sLastName;
                
                transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, Type__c = CommonUtilClass.TRANSACTION_TYPE_AUTHORIZATION, Amount__c = amountToBeProcessed, Currency__c = invoice.CurrencyL__c, Is_Payment_Processed_Successfully__c = true, Payment_Gateway__c = gateway.Id);
                transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
                if(invoice != null)
                {
                    transactionObj.Request_Invoice__c = invoice.Id;
                }
                transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
                transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_AUTHORIZATION;
                transactionObj.Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c;
                transactionObj.Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c;
                transactionObj.Card_Type__c = paymentMethod.Card_Type__c;   
                transactionObj.Currency__c = currencyId;
                sendHttpRequest(authorizationRequest);
            } catch(Exception ex) {
                result.message = ex.getMessage();
            }
            
            return result; 
        }
        
        public PaymentOperations.PaymentResult handleAuthorizeAndCharge_Click(string transactionId, string gatewayID) {
            try {
                decimal amountToBeProcessed = 0;
                
                if(invoice.Payment_Request_Amount__c != null && invoice.Payment_Request_Amount__c > 0 && invoice.Payment_Request_Amount__c < invoice.Unpaid_Amount__c) {
                    amountToBeProcessed = invoice.Payment_Request_Amount__c;            
                } else {
                    amountToBeProcessed = invoice.Unpaid_Amount__c;         
                }
                
                string amount = amountToBeProcessed.toPlainString().replace('.', '');
                String authorizationRequest ='card[number]='+paymentMethod.Card_Number__c+'&card[exp_year]='+paymentMethod.Card_Expiration_Year__c+'&card[exp_month]='+paymentMethod.Card_Expiration_Month__c+'&card[cvc]='+paymentMethod.CVV__c+'&amount='+amount+ '&currency='+invoice.CurrencyL__r.Name +'&description='+invoice.Name + '&card[name]='+sFirstName+ ' ' +sLastName;
                
                if(transactionId == null) {
                  transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, 
                                                        Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, 
                                                        Amount__c = amountToBeProcessed, Request_Invoice__c = invoice.Id,
                                                        Currency__c = invoice.CurrencyL__c, Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD,
                                                        Payment_Gateway__c = gateway.Id, Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE,
                                                        Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c, Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c,
                                                        Card_Type__c = paymentMethod.Card_Type__c, Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length())
                                                        );
                 } else {
                    Transaction__c transactionObj1 = [ SELECT Name, Gateway_ID__c,Authorization__c
                                                        FROM Transaction__c
                                                        WHERE Id =:transactionId 
                                                        ];
                    sHttpEndPoint = sHttpEndPoint+ '/' +transactionObj1.Gateway_ID__c + '/capture';
                    authorizationRequest = '';
                    transactionObj = new Transaction__c(Id = transactionId, Payment_Method__c = paymentMethod.Id, 
                                                        Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, 
                                                        Amount__c = amountToBeProcessed, Request_Invoice__c = invoice.Id,
                                                        Currency__c = invoice.CurrencyL__c, Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD,
                                                        Payment_Gateway__c = gateway.Id, Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE,
                                                        Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c, Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c,
                                                        Card_Type__c = paymentMethod.Card_Type__c, Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length())
                                                        );
                 }  
                
                 sendHttpRequest(authorizationRequest);   
                 

                 if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                  //create the payment and payment allocation against the inv
                  InvoicingUtilClass.createPaymentAndPaymentAllocation(invoice, transactionObj); 
                  transactionObj.Is_Payment_Processed_Successfully__c = true;
                  update transactionObj;                                                                 
                 } 
                
            } catch(Exception ex) {
               result.message += '\n \n'+system.Label.ExceptionOccurred + ex.getMessage();
               if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                   result.message += '\n \n '+ system.Label.InvoiceIsCharged;
                   transactionObj.Is_Payment_Processed_Successfully__c = false;
                   transactionObj.Exception_Message__c = system.Label.transactionIsDoneButPAIsNotDone + '\n' + 'Exception message is : ' +  ex.getMessage() + ' \n Line no is ' +  ex.getLineNumber() + ' \n Type of exception ' + ex.getTypeName();
                   upsert transactionObj;   
               }
            }
            
            return result;          
        }
        
        public PaymentOperations.PaymentResult handleVoid_Click(string gatewayId, string transactionId, decimal transactionAmount) {
            handleRefund_And_Void(gatewayId ,transactionId ,transactionAmount, CommonUtilClass.TRANSACTION_TYPE_VOID);
            return result;
        }
        
        public void handleRefund_And_Void(string gatewayId, string transactionId, decimal transactionAmount, string sStatus) {
            try {
                list<Transaction__c> transactions = [   SELECT Name, Gateway_ID__c,Authorization__c
                                                        FROM Transaction__c
                                                        WHERE Id =:transactionId 
                                                        LIMIT 1
                                                        ];
                string amount = transactionAmount.toPlainString().replace('.', '');
                string authorizationRequest = '';
                sHttpEndPoint = sHttpEndPoint +'/'+transactions[0].Gateway_ID__c+'/refund';
                transactionObj = new Transaction__c(Id = transactions[0].Id,
                                                    Payment_Method__c = paymentMethod.Id, 
                                                    Type__c = sStatus, 
                                                    Gateway_ID__c = gatewayId, 
                                                    Amount__c = transactionAmount, 
                                                    Is_Payment_Processed_Successfully__c = true, 
                                                    Payment_Gateway__c = gateway.Id
                                                    );
                                                    
                transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
                if(invoice != null)
                {
                     transactionObj.Request_Invoice__c = invoice.Id;
                }
                transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
                transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_REFUND;
                transactionObj.Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c;
                transactionObj.Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c;
                transactionObj.Card_Type__c = paymentMethod.Card_Type__c;
            
            
                sendHttpRequest(authorizationRequest);
                
                if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                    //cancel the payment 
                    InvoicingUtilClass.cancelPayment(transactionObj.Id);
                } 
            } catch(Exception ex) {
               result.message += '\n \n  '+ system.Label.ExceptionOccurred + ex.getMessage();
              } 
        }
        
        public PaymentOperations.PaymentResult handleRefund_Click(string gatewayId, string transactionId, decimal transactionAmount) {
            handleRefund_And_Void(gatewayId ,transactionId ,transactionAmount, CommonUtilClass.TRANSACTION_TYPE_REFUND);
            return result;
        }
        
        public PaymentOperations.PaymentResult handleAuthorizeAndCharge_Site(boolean isSaveCardDetails) {  
            try {
                
                isSavePaymentMethod = isSaveCardDetails;
                decimal amountToBeProcessed = 0;
                if(invoice != null && currencyId == null) {
                    if(invoice.Payment_Request_Amount__c != null && invoice.Payment_Request_Amount__c > 0 && invoice.Payment_Request_Amount__c < invoice.Unpaid_Amount__c) {
                        amountToBeProcessed = invoice.Payment_Request_Amount__c;
                    } else {
                        amountToBeProcessed = invoice.Unpaid_Amount__c;
                 }
                } else {
                    amountToBeProcessed = dAmount;
                }
                
                string s1 = amountToBeProcessed.toPlainString();
                decimal d = amountToBeProcessed;
                if(!s1.contains('.')){
                    s1 = s1 + '.00';
                    d = decimal.valueof(s1);
                }   
                    
                string amount = d.toPlainString().replace('.', '');
                
                string authorizationRequest;
        
               Currency__c currency1;
               // if the currency id is not null, means process for the virtual terminal
               if(currencyId != null) {
                   currency1 = [SELECT Name FROM Currency__c WHERE id =: currencyId];
               } else {
                 currency1 = [SELECT Name FROM Currency__c WHERE Name = 'USD' limit 1];
               }
                   
               transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, 
                                                        Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, 
                                                            Amount__c = amountToBeProcessed, 
                                                            Payment_Gateway__c = gateway.Id
                                                            );
                      
              String sCurrrency = invoice != null ? invoice.CurrencyL__r.Name : currency1.Name;
              String sdescription = invoice != null ? invoice.Name : account.Name;
              
              authorizationRequest ='card[number]='+paymentMethod.Card_Number__c+'&card[exp_year]='+paymentMethod.Card_Expiration_Year__c+'&card[exp_month]='+paymentMethod.Card_Expiration_Month__c+'&card[cvc]='+paymentMethod.CVV__c+'&amount='+amount+ '&currency='+sCurrrency +'&description='+sdescription + '&card[name]='+sFirstName+ ' ' +sLastName;                                         
                    
                if(invoice != null){
                    transactionObj.Currency__c = invoice.CurrencyL__c;
                    transactionObj.Request_Invoice__c = invoice.Id;
                } else{
                    transactionObj.Currency__c = Currency1.id;
                }
                    
                    
                transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
                transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
                transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE;
                transactionObj.Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c;
                transactionObj.Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c;
                transactionObj.Card_Type__c = paymentMethod.Card_Type__c;
            
                if(isSaveCardDetails) {
                    sendHttpRequest(authorizationRequest);
                    result.message = transactionObj.Response_Status__c + ' ' + transactionObj.Response_Message__c;
                    result.transactionObj = transactionObj;
                        
                    // query the default payment method present for the account and update default to false
                    list<Payment_Method__c> defaultPaymentMethods;
                    if(invoice != null){
                        defaultPaymentMethods = InvoicingUtilClass.getDefaultMethodForAccount(invoice.Account__c);
                    } else {
                        defaultPaymentMethods = InvoicingUtilClass.getDefaultMethodForAccount(account.Id);
                    }
                    if(!defaultPaymentMethods.isEmpty()) {
                        for(Payment_Method__c pm : defaultPaymentMethods) {
                            pm.Default__c = false;
                        }
                        update defaultPaymentMethods;
                    }
                    
                    // make the new payment method to default
                    paymentMethod.Default__c = true;
                    /*
                    Modified By : Rama Krishna: 03 feb 2016 : INVOICEIT-679
                    Comments    : make cvv as null
                    */    
                    paymentMethod.CVV__c = null;
                    upsert paymentMethod;
                    //populate Default Method on account
                    CommonUtilClass.populateDefaultMethod(paymentMethod);
                    
                    transactionObj.Payment_Method__c = paymentMethod.Id;
                    
                    result.message =  system.Label.transactioncreated+' ';
                    upsert transactionObj;

                    transactionObj = [SELECT Name, Response_Status__c, Amount__c, Response_Code__c, Transaction__c, Response_Message__c
                                      FROM Transaction__c
                                      WHERE Id =: transactionObj.Id];

                    result.message  +=  transactionObj.Name + ' \n'
                    + 'Gateway Response : ' + transactionObj.Response_Code__c + ' \n'
                    + 'Gateway Status : ' + transactionObj.Response_Status__c;
                    
                } else {
                    transactionObj.Payment_Method__c = sDummyPaymentId;
                    sendHttpRequest(authorizationRequest);
                    result.message = transactionObj.Response_Status__c + ' ' + transactionObj.Response_Message__c;
                    result.transactionObj = transactionObj;
                }
                
                if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                  //create the payment and payment allocation against the inv
                  if(invoice != null){
                     if(currencyId != null){
                            // this is used for virtual terminal payment
                            InvoicingUtilClass.createPaymentAndAllocationForVirtualTerminal(invoice, transactionObj);
                        } else{
                            InvoicingUtilClass.createPaymentAndPaymentAllocation(invoice, transactionObj);
                        }
                  } else {
                      if(currencyId != null){
                         // this is used for virtual terminal payment
                        Payment__c payment = new Payment__c(Account__c = account.Id, 
                                                            Amount__c = transactionObj.Amount__c, 
                                                            Status__c = CommonUtilClass.STATUS_COMPLETED, 
                                                            Payment_Type__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD,
                                                            Payment_Date__c = system.today(),
                                                            Transaction__c = transactionObj.Id,
                                                            Currency__c = currencyId,
                                                            Payment_Description__c = 'Virtual terminal payment');
            
                         insert payment;
                      } else{
                         Payment__c payment = new Payment__c(Account__c = account.Id, 
                                                                Amount__c = transactionObj.Amount__c, 
                                                                Status__c = CommonUtilClass.STATUS_COMPLETED, 
                                                                Payment_Type__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD,
                                                                Payment_Date__c = system.today(),
                                                                Transaction__c = transactionObj.Id,
                                                                Currency__c = Currency1.Id,
                                                                Payment_Description__c = 'Against Advance Payment Request');
                
                         insert payment;
                          Account accToUpdate = new Account(id = account.Id,Advance_Request_Status__c = CommonUtilClass.STATUS_PAID);
                          update accToUpdate;
                      }
                  }
                  
                  transactionObj.Is_Payment_Processed_Successfully__c = true;
                  update transactionObj;                                                                 
                }else {
                    upsert transactionObj; 
                }
            } catch(Exception ex) {
               result.message += '\n \n '+ system.Label.ExceptionOccurred + ex.getMessage();
               if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                   result.message += '\n \n '+ system.Label.InvoiceIsCharged;
                   transactionObj.Is_Payment_Processed_Successfully__c = false;
                   transactionObj.Exception_Message__c = system.Label.transactionIsDoneButPAIsNotDone + '\n' + 'Exception message is : ' +  ex.getMessage() + ' \n Line no is ' +  ex.getLineNumber() + ' \n Type of exception ' + ex.getTypeName();
                   upsert transactionObj;   
               }
            }
            return result;          
        } 
     
       /* =================== Start ====================================== */
       /*
        Modified By : Madhu Keshav :26 Nov 2015 :INVOICEIT-641
        Comments    : Creating a generic method for processing all payments. This will be used in global methods and API
        */

        // this constructor is created because we do not want to pass any values from ohter method 
        public ClassForHandlingStripeCard(){

        }

        public PaymentSiteOperation.GenericPaymentResult handleAuthorizeAndCharge(PaymentSiteOperation.GenericPaymentParameters genericPaymentParameters)
        {
            isGenericMethodCall = false;

            PaymentSiteOperation.GenericPaymentResult genericPaymentResult = new  PaymentSiteOperation.GenericPaymentResult();
            try {
                    gateway = new Gateway__c();
                    invoice = new invoice__c();
                    paymentMethod  = new Payment_Method__c();
                    gateway = genericPaymentParameters.gateway;
                    invoice = genericPaymentParameters.invoiceObj;
                    paymentMethod = genericPaymentParameters.paymentMethod;
                    API_KEY = gateway.Security_Key__c;

                   decimal amountToBeProcessed = genericPaymentParameters.amountToProcess;

                   string amount = amountToBeProcessed.toPlainString().replace('.', '');
                   String authorizationRequest ='card[number]='+paymentMethod.Card_Number__c+'&card[exp_year]='+paymentMethod.Card_Expiration_Year__c+'&card[exp_month]='+paymentMethod.Card_Expiration_Month__c+'&card[cvc]='+paymentMethod.CVV__c+'&amount='+amount+ '&currency='+genericPaymentParameters.currencyISOCode +'&description=Tes&card[name]=test' ;

                   transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, 
                                                        Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, 
                                                        Amount__c = genericPaymentParameters.amountToProcess, Request_Invoice__c = invoice.Id,
                                                        Currency__c = invoice.CurrencyL__c, Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD,
                                                        Payment_Gateway__c = gateway.Id, Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE,
                                                        Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c, Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c,
                                                        Card_Type__c = paymentMethod.Card_Type__c, Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length())
                                                        );


       
                    sHttpEndPoint = CommonUtilClass.ENDPOINT_STRIPE;
              
                    sendHttpRequest(authorizationRequest); 
     
                    genericPaymentResult.transactionObj = transactionObj;
                    genericPaymentResult.message = transactionObj.Response_Status__c; 
                
                if(transactionObj.Exception_Message__c != null){
                    genericPaymentResult.message = transactionObj.Exception_Message__c;
                }

                if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED){
                    genericPaymentResult.isSuccess = true;
                }else{
                    genericPaymentResult.isSuccess = false;
                }
                return genericPaymentResult;

                } catch (Exception ex) {
                    genericPaymentResult.message += '\n \n ' + system.Label.ExceptionOccurred;
                    genericPaymentResult.message += 'Exception message is : ' +  ex.getMessage() + ' \n Line no is ' +  ex.getLineNumber() + ' \n Type of exception ' + ex.getTypeName();
                    genericPaymentResult.isSuccess = false;
                     
                    return genericPaymentResult;   
            }
                  return null;        
        }
        
      /* =================== ended ====================================== */
         
            public void sendHttpRequest(string reqBody) {
            HttpResponse httpResponse;
            Http httpObject = new Http();
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndpoint(sHttpEndPoint);
            httpRequest.setMethod('POST');
            Blob headerValue = Blob.valueOf(API_KEY + ':');
            String authorizationHeader = 'BASIC ' +
            EncodingUtil.base64Encode(headerValue);
            httpRequest.setHeader('Authorization', authorizationHeader);
            
            // Ram V:19-AUG-2014:SUP-312:exending the callout time to max
          
            httpRequest.setTimeout(120000);
            httpRequest.setBody(reqBody);   
            
            if(!system.test.isRunningTest()) {
                httpResponse = httpObject.send(httpRequest);
                parameters = (Map<String, Object>)JSON.deserializeUntyped(httpResponse.getBody());
            } else {
                String jsonResponse = '{ "id": "ch_104Dgc4wGOBNQf8aCnHInev0", "object": "charge", "created": 1402744992, "livemode": false, "paid": true, "amount": 10000, "currency": "usd", "refunded": false, "card": { "id": "card_104Dgc4wGOBNQf8ahgxKI7Al", "object": "card", "last4": "4242", "type": "Visa", "exp_month": 4, "exp_year": 2015, "fingerprint": "oYKN5GzqdYVz5gYi", "country": "US", "name": null, "address_line1": null, "address_line2": null, "address_city": null, "address_state": null, "address_zip": null, "address_country": null, "cvc_check": "pass", "address_line1_check": null, "address_zip_check": null, "customer": null }, "captured": true, "refunds": [], "balance_transaction": "txn_104Dgc4wGOBNQf8akz5Q9uiN", "failure_message": null, "failure_code": null, "amount_refunded": 0, "customer": null, "invoice": null, "description": "Invoice Charge By Naveen", "dispute": null, "metadata": {}, "statement_description": null, "receipt_email": null }';
                parameters = (Map<String, Object>)JSON.deserializeUntyped(jsonResponse);
            } 
            handleRequest();
        }
        
         private void handleRequest() {
             //if it does not contains error,then transaction is approved
             if(!parameters.containsKey('error') ) 
                {
                    result.reloadPage = true;
                    transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED;
                    transactionObj.Response__c = system.Label.TransactionHasBeenApproved;
                    transactionObj.Response_Code__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED;
                    transactionObj.Gateway_ID__c = ''+parameters.get('id');
                }
                else
                {
                    result.reloadPage = false;
                    Map<String, Object> errorResponse = (Map<String, Object>)parameters.get('error');
                    String sErrorMessage = string.valueof(errorResponse);
                    if(sErrorMessage.contains('Invalid currency')){
                        transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_ERROR + '. ' + 'Invalid currency  ' + invoice.CurrencyL__r.Name;
                        transactionObj.Response_Message__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_ERROR + '. ' + 'Invalid currency  ' + invoice.CurrencyL__r.Name;
                        
                    }else{
                        transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_ERROR + '. ' + errorResponse.get('message');
                        transactionObj.Response_Message__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_ERROR + '. ' + errorResponse.get('message');
                        
                    }
                    
                    //Added by DL, INVOICEIT-635
                    transactionObj.Is_Payment_Processed_Successfully__c = false;
                }
             
             result.message =  system.Label.transactioncreated+' ';
             // for the site payment, if the the boolean is true dont insert transaction record
             if(isGenericMethodCall){
                result.message =  system.label.transactioncreated;
                if(!isSavePaymentMethod){
                     upsert transactionObj;
                    
                     transactionObj = [SELECT Name, Response__c, Response_Status__c, Amount__c, Response_Code__c, Transaction__c, Response_Message__c
                                       FROM Transaction__c
                                       WHERE Id =: transactionObj.Id];
                                      
                     result.message +=  transactionObj.Name + ' \n'
                                    + 'Gateway Response : ' + transactionObj.Response__c + ' \n'
                                    + 'Gateway Status : ' + transactionObj.Response_Status__c;
                }
                result.transactionObj = transactionObj;  
         }
        }
        
        public void populateCustomerDetails() {      
            if(paymentMethod.Billing_First_Name__c != null) {
                sFirstName = paymentMethod.Billing_First_Name__c;
            }
            
            if(paymentMethod.Billing_Last_Name__c != null) {
                sLastName = paymentMethod.Billing_Last_Name__c;
            }   
            
            if(paymentMethod.Billing_Address__c != null) {
               sAddress1 = paymentMethod.Billing_Address__c;
            }
            
            if(paymentMethod.Billing_City__c != null) {
               sCity =  paymentMethod.Billing_City__c;
            }   
            
            if(paymentMethod.Billing_State_Province__c != null) {
              sState = paymentMethod.Billing_State_Province__c;
            }   
            
            if(paymentMethod.Billing_Zip_Postal__c != null) {
                sZipCode = paymentMethod.Billing_Zip_Postal__c;
            }
            
            if(paymentMethod.Billing_Country__c != null) {
                sCountry = paymentMethod.Billing_Country__c;
            }   
            
            if(paymentMethod.Billing_Phone__c != null){
                sPhone = paymentMethod.Billing_Phone__c;
            }
            
            if(paymentMethod.Billing_Email__c != null){
                sEmail = paymentMethod.Billing_Email__c;
            }
        }  
    }