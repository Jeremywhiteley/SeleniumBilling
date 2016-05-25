public with sharing class ClassForHandlingBrainTree implements InterfacePaymentClass.paymentOperationsInterface{

    @TestVisible private map<string, string> parameters;
    private string sHttpBody = ''; 
    private string sHttpEndPoint = '';
    private string sHttpResponse;
    private list<string> responseArray;
    private Payment_Method__c paymentMethod;
    private Gateway__c gateway;
    private Invoice__c invoice;
    private PaymentOperations.PaymentResult result = new PaymentOperations.PaymentResult();
    private Transaction__c transactionObj;
    private boolean isException = false;
    private string sDummyPaymentId;
    private Account account;
    private decimal dAmount;

    private string MERCHANT_KEY = '';
    private string PUBLIC_KEY = '';
    private string PRIVATE_KEY = '';

    string sRawHttpResponse;
    map<string, string> mapOfKeyValue = new map<string, string>();
    
    // this variable is declared because on force.com site page if user selected the savecard information.
    boolean isSavePaymentMethod = false;

    //This is used for Virtualterminal Purpose
    private Id currencyId;
    private boolean isGenericMethodCall = true;
    
    
    public ClassForHandlingBrainTree(Gateway__c gateway, Invoice__c invoice, Payment_Method__c paymentMethod,string sDummyPaymentId,decimal dAmount,Account account, Id currencyId){
        this.invoice = invoice;
        this.account = account;
        this.dAmount = dAmount;
        this.paymentMethod = paymentMethod;
        this.gateway = gateway; 
        this.sDummyPaymentId = sDummyPaymentId;
        this.currencyId = currencyId;
        parameters = new map<string, string>();
        this.MERCHANT_KEY = gateway.Merchant_ID__c;
        this.PUBLIC_KEY =gateway.Security_Key__c;
        this.PRIVATE_KEY =gateway.Exact_ID_Security_Key__c;
        
        if(invoice == null)
        {
            this.invoice = new Invoice__c();
        } 
        
        // sandbox and live, using common endpoint Url
        //sHttpEndPoint = CommonUtilClass.ENDPOINT_BRAINTREE;

        //this determines is it sandboz or live
        if(gateway.Test_Mode__c) {
            sHttpEndPoint = CommonUtilClass.ENDPOINT_BRAINTREE_SANDBOX;
        }else{
            sHttpEndPoint = CommonUtilClass.ENDPOINT_BRAINTREE_PRODUCTION;
        }
         
    }

    public PaymentOperations.PaymentResult handleAuthorize_Click() {
        result.message = system.Label.BT_authorization;
        return result; 
    }
    
    public PaymentOperations.PaymentResult handleAuthorizeAndCharge_Click(string transactionId, string gatewayID) {
        try {
            if(paymentMethod.Token__c == null){
              sHttpEndPoint = sHttpEndPoint + '/payment';
           }else{
              sHttpEndPoint = sHttpEndPoint + '/token';
           }
           
            decimal amountToBeProcessed = 0;
            if(invoice.Payment_Request_Amount__c != null && invoice.Payment_Request_Amount__c > 0 && invoice.Payment_Request_Amount__c < invoice.Unpaid_Amount__c) {
                amountToBeProcessed = invoice.Payment_Request_Amount__c;
            } else {
                amountToBeProcessed = invoice.Unpaid_Amount__c;
            }
            if(transactionId == null) {
                transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, 
                        Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, 
                        Amount__c = amountToBeProcessed, Request_Invoice__c = invoice.Id,
                        Currency__c = invoice.CurrencyL__c, Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD,
                        Payment_Gateway__c = gateway.Id, Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE
                         );
             if(paymentMethod.Token__c == null){
                    transactionObj.Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c;
                    transactionObj.Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c;
                    transactionObj.Card_Type__c = paymentMethod.Card_Type__c;
                    transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
             }
            }
            
            string sRequestBody = frameHttpRequestData();
            sendHttpRequest(sRequestBody,sHttpEndPoint);
            if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                //create the payment and payment allocation against the inv
                InvoicingUtilClass.createPaymentAndPaymentAllocation(invoice, transactionObj); 
                transactionObj.Is_Payment_Processed_Successfully__c = true;
                update transactionObj;                                                                 
            } 

        }catch(Exception ex) {
            result.message += '\n \n '+system.Label.ExceptionOccurred+ ' ' + ex.getMessage() + '  Line Number :- ' +  ex.getLineNumber();
            transactionObj.Exception_Message__c = result.message;
            
            if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                result.message += system.Label.InvoiceIsCharged;
                transactionObj.Is_Payment_Processed_Successfully__c = false;
                transactionObj.Exception_Message__c = system.Label.transactionIsDoneButPAIsNotDone + '\n' + 'Exception message is : ' +  ex.getMessage() + ' \n Line no is ' +  ex.getLineNumber() + ' \n Type of exception ' + ex.getTypeName(); 
            }

            upsert transactionObj; 
        }
        return result; 
    }
    


   /* =================== Start ====================================== */

    /*
    Modified By         : Madhu Keshav     :25 Nov 2015   :INVOICEIT-641
    Comments         : Creating a generic method for processing all payments. This will be used in global methods and API
    */
    
   public PaymentSiteOperation.GenericPaymentResult handleAuthorizeAndCharge(PaymentSiteOperation.GenericPaymentParameters genericPaymentParameters)
    {
        isGenericMethodCall = false;
        PaymentSiteOperation.GenericPaymentResult genericPaymentResult = new  PaymentSiteOperation.GenericPaymentResult();
        try {
             if(paymentMethod.Token__c == null){
              sHttpEndPoint = sHttpEndPoint + '/payment';
           }else{
              sHttpEndPoint = sHttpEndPoint + '/token';
           }
            decimal amountToBeProcessed = genericPaymentParameters.amountToProcess;

            transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, 
                        Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, 
                        Amount__c = amountToBeProcessed, Request_Invoice__c = invoice.Id,
                        Currency__c = invoice.CurrencyL__c, Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD,
                        Payment_Gateway__c = gateway.Id, Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE
                         );
                                                    

            string sRequestBody = frameHttpRequestData();
            sendHttpRequest(sRequestBody,sHttpEndPoint);

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

    public PaymentOperations.PaymentResult handleAuthorizeAndCharge_Site(boolean isSaveCardDetails){  
        try {
           if(paymentMethod.Token__c == null){
              sHttpEndPoint = sHttpEndPoint + '/payment';
           }else{
              sHttpEndPoint = sHttpEndPoint + '/token';
           }
           isSavePaymentMethod = isSaveCardDetails;
           decimal amountToBeProcessed = 0;
            if(invoice.id != null && currencyId == null) {
                if(invoice.Payment_Request_Amount__c != null && invoice.Payment_Request_Amount__c > 0 && invoice.Payment_Request_Amount__c < invoice.Unpaid_Amount__c) {
                    amountToBeProcessed = invoice.Payment_Request_Amount__c;
                } else {
                    amountToBeProcessed = invoice.Unpaid_Amount__c;
             }
            } else {
                amountToBeProcessed = dAmount;
            }
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
                
            if(invoice != null){
                transactionObj.Currency__c = invoice.CurrencyL__c;
                transactionObj.Request_Invoice__c = invoice.Id;
            } else{
                transactionObj.Currency__c = Currency1.id;
            }
             
            transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
            transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE;
            if(paymentMethod.Token__c == null){
                transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
                transactionObj.Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c;
                transactionObj.Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c;
                transactionObj.Card_Type__c = paymentMethod.Card_Type__c; 
            } 
            
            
            string sRequestData = frameHttpRequestData();
            if(isSaveCardDetails) {
                sendHttpRequest(sRequestData,sHttpEndPoint);
                result.message = transactionObj.Response_Status__c + ' ' + transactionObj.Response_Message__c;
                result.transactionObj = transactionObj;
                    
                // query the default payment method present for the account and update default to false
                list<Payment_Method__c> defaultPaymentMethods;
                if(invoice.id != null){
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
                
                result.message =  system.Label.transactioncreated;
                upsert transactionObj;

                transactionObj = [SELECT Name, Response_Status__c, Amount__c, Response_Code__c, Transaction__c, Response_Message__c
                                  FROM Transaction__c
                                  WHERE Id =: transactionObj.Id];

                result.message  +=  transactionObj.Name + ' \n'
                + 'Gateway Response : ' + transactionObj.Response_Code__c + ' \n'
                + 'Gateway Status : ' + transactionObj.Response_Status__c;
                
            } else {
                transactionObj.Payment_Method__c = sDummyPaymentId;
                sendHttpRequest(sRequestData,sHttpEndPoint);
                result.message = transactionObj.Response_Status__c + ' ' + transactionObj.Response_Message__c;
                result.transactionObj = transactionObj;
            }
            
            if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
              //create the payment and payment allocation against the inv
              if(invoice.id != null){
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
           result.message += '\n \n '+system.Label.ExceptionOccurred +' ' + ex.getMessage() + '  Line Number :- ' +  ex.getLineNumber();
           if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED && transactionObj.Response_Status__c != null) {
               result.message += system.Label.InvoiceIsCharged;
               transactionObj.Is_Payment_Processed_Successfully__c = false;
               transactionObj.Exception_Message__c = system.Label.transactionIsDoneButPAIsNotDone + '\n' + 'Exception message is : ' +  ex.getMessage() + ' \n Line no is ' +  ex.getLineNumber() + ' \n Type of exception ' + ex.getTypeName();
               //upsert transactionObj;   
           }
        }
        return result; 
    }
    
    public PaymentOperations.PaymentResult handleVoid_Click(string gatewayId, string transactionId, decimal transactionAmount) {
          try{
          list<Transaction__c> transactions = [SELECT Name, Payment_Gateway__r.Test_Mode__c, Gateway_ID__c,Authorization__c,Amount__c,Transaction__c
                                                FROM Transaction__c
                                                WHERE Id =:transactionId 
                                                LIMIT 1
                                                ];
            string authorizationRequest = '';
            sHttpEndPoint = sHttpEndPoint + '/void';
            
            transactionObj = new Transaction__c(Transaction__c = transactions[0].Id,
                    Payment_Method__c = paymentMethod.Id, 
                    Type__c = CommonUtilClass.TRANSACTION_TYPE_VOID, 
                    Gateway_ID__c = gatewayId, 
                    Amount__c = transactions[0].Amount__c, 
                    Payment_Gateway__c = gateway.Id
                    );

            transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
            transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_VOID;
            if(paymentMethod.Token__c == null){
                transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
                transactionObj.Request_Invoice__c = invoice.Id; 
                transactionObj.Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c;
                transactionObj.Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c;
                transactionObj.Card_Type__c = paymentMethod.Card_Type__c;
            }
            
            string sRefundRequestData = 'merchant=' + MERCHANT_KEY +'&publickey='+PUBLIC_KEY+'&privatekey='+PRIVATE_KEY;
            
            sRefundRequestData += '&transactionid='+transactions[0].Gateway_ID__c;
            
            //Check whether it is pointing to production or sandbox
            if(transactions[0].Payment_Gateway__r.Test_Mode__c) {
                sRefundRequestData += '&environment=Sandbox';
            } else {
                sRefundRequestData += '&environment=Production';
            }

            sendHttpRequest(sRefundRequestData,sHttpEndPoint);
            
            if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                //cancel the payment 
                InvoicingUtilClass.cancelPayment(transactions[0].Id);
            }
        } catch(Exception ex) {
            result.message = ex.getMessage();
        }
        return result; 
    }
    
    public PaymentOperations.PaymentResult handleRefund_Click(string gatewayId, string transactionId, decimal transactionAmount) {
       try{
          list<Transaction__c> transactions = [SELECT Name, Payment_Gateway__r.Test_Mode__c, Gateway_ID__c,Authorization__c,Amount__c,Transaction__c
                                                FROM Transaction__c
                                                WHERE Id =:transactionId 
                                                LIMIT 1
                                                ];
            string authorizationRequest = '';
            sHttpEndPoint = sHttpEndPoint + '/refund';
            
            transactionObj = new Transaction__c(Transaction__c = transactions[0].Id,
                    Payment_Method__c = paymentMethod.Id, 
                    Type__c = CommonUtilClass.TRANSACTION_TYPE_REFUND, 
                    Gateway_ID__c = gatewayId, 
                    Amount__c = transactions[0].Amount__c, 
                    Payment_Gateway__c = gateway.Id
                    );

            transactionObj.Request_Invoice__c = invoice.Id;
            transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
            transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_REFUND;
            if(paymentMethod.Token__c == null){
                transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
                transactionObj.Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c;
                transactionObj.Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c;
                transactionObj.Card_Type__c = paymentMethod.Card_Type__c;
            }
            
            string sRefundRequestData = 'merchant=' + MERCHANT_KEY +'&publickey='+PUBLIC_KEY+'&privatekey='+PRIVATE_KEY;
            
            sRefundRequestData += '&transactionid='+transactions[0].Gateway_ID__c;
            
            
            //Check whether it is pointing to production or sandbox
            if(transactions[0].Payment_Gateway__r.Test_Mode__c) {
                sRefundRequestData += '&environment=Sandbox';
            } else {
                sRefundRequestData += '&environment=Production';
            }
        
        
            sendHttpRequest(sRefundRequestData,sHttpEndPoint);
            
            if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                //cancel the payment 
                InvoicingUtilClass.cancelPayment(transactions[0].Id);
            }
        } catch(Exception ex) {
            result.message = ex.getMessage();
        }
        return result; 
    }
    
    public void sendHttpRequest(string requestBody,String endpoint){
        
        // request the end popint url with user name and password
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setBody(requestBody);
        req.setTimeout(120000);

        if(!system.test.isRunningTest()) {
            Http h = new Http();
            HttpResponse res = h.send(req);
            // get the response from the requested url

            string sHttpResponseBody = res.getBody();
            if((sHttpResponseBody.contains('SUCCESS') 
                    || sHttpResponseBody.contains('success') 
                    || sHttpResponseBody.contains('processorResponseText') 
                    || sHttpResponseBody.contains('processorAuthorizationCode') 
                    || sHttpResponseBody.contains('processorResponseCode') 
                     ) && sHttpResponseBody != null
                    ){
               
                        Map<String, Object> map_JsonString  = (Map<String, Object>)JSON.deserializeUntyped(sHttpResponseBody);
                        Map<String, Object>  mapchildObject = (Map<String, Object>)map_JsonString.get('SUCCESS');
              
              for(String s : mapchildObject.keyset()){
                  parameters.put('success',string.valueof((boolean)mapchildObject.get('success')));
                  
                  Map<String, Object>  mapchildObjectNew = (Map<String, Object>)mapchildObject.get('transaction');
                  for(String s1 : mapchildObjectNew.keyset()){
                      parameters.put('id',string.valueof((string)mapchildObjectNew.get('id')));
                      parameters.put('processorAuthorizationCode',(string)mapchildObjectNew.get('processorAuthorizationCode'));
                      parameters.put('processorResponseText',(string)mapchildObjectNew.get('processorResponseText'));
                      parameters.put('processorResponseCode',(string)mapchildObjectNew.get('processorResponseCode'));
                  }
              }

              }else{
                  
                  if(sHttpResponseBody.contains('ERROR') && !sHttpResponseBody.contains('<')) {

                    //If both heroku and braintree is up and message is in JSON format.
                     Map<String, Object> map_JsonString = (Map<String, Object>)JSON.deserializeUntyped(sHttpResponseBody);
                     Map<String, Object>  mapOfErrors = (Map<String, Object>)map_JsonString.get('ERROR');
                     for(String s1 : mapOfErrors.keyset()){
                         parameters.put('code',string.valueof((string)mapOfErrors.get('code')));
                         parameters.put('message',string.valueof((string)mapOfErrors.get('message')));
                         parameters.put('status',string.valueof((string)mapOfErrors.get('status')));
                     }
                      parameters.put('ERROR',string.valueOf(map_JsonString.get('ERROR')));
                  } else {
                       //parameters.put('ERROR',sHttpResponseBody);
                       //if heroku is up abd brain tree is down, heroku sends error in html format and that is 
                       // captured here.
                       Map<String, Object> map_JsonString = (Map<String, Object>)JSON.deserializeUntyped(sHttpResponseBody);
                       parameters.put('ERROR',string.valueof(map_JsonString.get('ERROR')));
                  }    

              } 
          } else {
               parameters.put(string.valueof('success'),'true');
               parameters.put('processorResponseCode','1000');
               parameters.put('processorAuthorizationCode','000000');
               parameters.put('processorResponseText','Approved');
               parameters.put('id','3g278y');
          }
         handleRequest(); 
      }  
      
    private void handleRequest() {
        //if it contains OK,then transaction is approved
        if(parameters.get('success') == 'true') {
            result.reloadPage = true;
            transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED;
            transactionObj.Response__c = 'This transaction has been approved.';
            transactionObj.Response_Code__c = parameters.get('processorResponseCode');
            transactionObj.Gateway_ID__c = parameters.get('id');
            transactionObj.Response_Message__c = parameters.get('processorResponseText');
            transactionObj.Authorization__c = parameters.get('processorAuthorizationCode');
        } else {
            result.reloadPage = false;
            
            if(parameters.get('ERROR').length() < 32766) {
                if(parameters.get('ERROR').length() < 254) {
                    transactionObj.Response_Status__c = parameters.get('status');
                    transactionObj.Response_Message__c = parameters.get('message');
                    transactionObj.Response_Code__c = parameters.get('code');
                 }   
                transactionObj.Exception_Message__c = parameters.get('ERROR');
            } else {
                transactionObj.Response_Status__c = parameters.get('status');
                transactionObj.Response_Message__c = parameters.get('message');
                transactionObj.Response_Code__c = parameters.get('code');
                transactionObj.Exception_Message__c = parameters.get('ERROR').substring(0,32766);
            } 
        }

        if(transactionObj.Id == null) {
            result.message =  system.Label.transactioncreated;
        } else {
            result.message =  system.Label.transactionupdated;
        }

        if(transactionObj.Id == null) {
            transactionObj.Payment_Gateway__c = gateway.Id;
        }
        if(isGenericMethodCall){
            result.message =  system.label.transactioncreated;
        // for the site payment, if the the boolean is true dont insert transaction record
        if(!isSavePaymentMethod){
             upsert transactionObj;
            
             transactionObj = [SELECT Name, Response_Status__c, Amount__c, Response_Code__c, Transaction__c, Response_Message__c
                               FROM Transaction__c
                               WHERE Id =: transactionObj.Id];
                              
             result.message +=  transactionObj.Name + ' \n'
                + 'Gateway Response : ' + parameters.get('processorResponseText') + ' \n'
                + 'Gateway Status : ' + transactionObj.Response_Status__c;
        }
        result.transactionObj = transactionObj;  
      }
    }
    
    public string frameHttpRequestData(){
        decimal amountToBeProcessed = 0;
        if(invoice.id != null && currencyId == null) {
            if(invoice.Payment_Request_Amount__c != null && invoice.Payment_Request_Amount__c > 0 && invoice.Payment_Request_Amount__c < invoice.Unpaid_Amount__c) {
                amountToBeProcessed = invoice.Payment_Request_Amount__c;
            } else {
                amountToBeProcessed = invoice.Unpaid_Amount__c;
         }

        } else {
            amountToBeProcessed = dAmount;
        }
        
        string sRequestBody = 'merchant=' + MERCHANT_KEY +'&publickey='+PUBLIC_KEY+'&privatekey='+PRIVATE_KEY;
        
        sRequestBody += '&amount='+ amountToBeProcessed;
        
        if(invoice != null){
             sRequestBody += '&order='+ invoice.Name;
        }else{
            sRequestBody += '&order= advance payment';
        }
        
         
        if(paymentMethod.Card_Number__c != null && paymentMethod.Token__c == null){
            sRequestBody += '&cardno='+paymentMethod.Card_Number__c;
            
            if(paymentMethod.CVV__c != null){
                sRequestBody += '&cvv='+paymentMethod.CVV__c;
            }
            
            if(paymentMethod.Name_on_Card__c != null){
                sRequestBody += '&cardholdername='+ paymentMethod.Name_on_Card__c;
            }
            
            if(paymentMethod.Card_Expiration_Month__c != null){
                sRequestBody += '&mm='+paymentMethod.Card_Expiration_Month__c;
            }
            
            if(paymentMethod.Card_Expiration_Year__c != null){
                sRequestBody += '&yy='+paymentMethod.Card_Expiration_Year__c;
            }
            
        }else{
            sRequestBody += '&payment_token='+paymentMethod.Token__c;
        }
        
        
        //starting of payment method basic info
        if(paymentMethod.Billing_First_Name__c != null) 
           sRequestBody += '&c_fname='+paymentMethod.Billing_First_Name__c;
        if(paymentMethod.Billing_Last_Name__c != null) 
          sRequestBody += '&c_lname='+paymentMethod.Billing_Last_Name__c;

        if(paymentMethod.Account__r.Name != null) 
            sRequestBody += '&c_company='+paymentMethod.Account__r.Name;
        if(paymentMethod.Billing_Email__c != null) 
            sRequestBody += '&c_email='+paymentMethod.Billing_Email__c;
        if(paymentMethod.Billing_Phone__c != null) 
           sRequestBody += '&c_phone='+paymentMethod.Billing_Phone__c; 
        // ending of payment details
        
        // starting of invoice billing details    
           
        if(invoice != null && invoice.Billing_Contact__r.FirstName != null)
            sRequestBody += '&b_fname='+invoice.Billing_Contact__r.FirstName; 
        if(invoice != null && invoice.Billing_Contact__r.LastName != null)
            sRequestBody += '&b_lname='+invoice.Billing_Contact__r.LastName; 
        if(invoice != null && invoice.Billing_Contact__r.MailingStreet != null)
           sRequestBody += '&b_street='+invoice.Billing_Contact__r.MailingStreet; 
        if(invoice != null && invoice.Billing_Contact__r.MailingCity != null)
            sRequestBody += '&b_city='+invoice.Billing_Contact__r.MailingCity; 
        if(invoice != null && invoice.Billing_Contact__r.MailingState != null)
            sRequestBody += '&b_state='+invoice.Billing_Contact__r.MailingState; 
        if(invoice != null && invoice.Billing_Contact__r.MailingPostalCode != null)
            sRequestBody += '&b_postal='+invoice.Billing_Contact__r.MailingPostalCode; 
        if(invoice != null && invoice.Billing_Contact__r.MailingCountry != null)
           sRequestBody += '&b_country='+invoice.Billing_Contact__r.MailingCountry;   
        // ending of billing details
        
        //Check whether it is pointing to production or sandbox
        if(gateway.Test_Mode__c) {
            sRequestBody += '&environment=Sandbox';
        } else {
            sRequestBody += '&environment=Production';
        }
        return sRequestBody;
    }

}