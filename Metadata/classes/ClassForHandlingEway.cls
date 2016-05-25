/*
 * Webservice for handling payments.
 * @Author : Rama Krishna.V
   @Company         : Invoice It
   @CreatedBy Date  : 25-07-2014

    implemented by using the described api url : http://api-portal.anypoint.mulesoft.com/eway/api/eway-rapid-31-api/docs/reference/direct-connection
    
    Below points to be remember while testing eway gateway sanbox: 
    1. firstly in sandbox or live, we need to create user
    2. after creation of user, enable the pci-dss setting 
    3. dont enable the 3d-secure 
    4. At the moment eway don't have an authorization & void facility in place.
    5. Sandbox can only accept the one currency, if you have a live account multi-currency can be setup
    6. snadbox test gateway, the response code is determined by the cents value passed in a transaction. For example, $12.05 will return response code 05. 
       For a successful response on the test gateway, pass an amount ending in 00, such as $12.00.
    7. Live accounts the response code is dictated by the bank's response
    
    End point  for sandbox : https://api.sandbox.ewaypayments.com
    
    End point  for LIVE : https://api.ewaypayments.com
    
     */

public with sharing class ClassForHandlingEway implements InterfacePaymentClass.paymentOperationsInterface {

    public static final String ENDPOINT_EWAY_CHARGE_TEST = 'https://api.sandbox.ewaypayments.com/Transaction';
    public static final String ENDPOINT_EWAY_CHARGE_LIVE  = 'https://api.ewaypayments.com/Transaction';
    public static final String GATEWAY_TYPE_EWAY = 'Eway';

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

    private string API_KEY = '';
    private string GATEWAYPASSWORD = '';
    

    string sRawHttpResponse;
    map<string, string> mapOfKeyValue = new map<string, string>();

    // this variable is declared because on force.com site page if user selected the savecard information.
    boolean isSavePaymentMethod = false;

    //This is used for Virtualterminal Purpose
    private Id currencyId;

    private boolean isGenericMethodCall = true;

    //This is used for Virtualterminal Purpose
    public ClassForHandlingEway(Gateway__c gateway, Invoice__c invoice, Payment_Method__c paymentMethod,string sDummyPaymentId,decimal dAmount,Account account, Id currencyId) {
        this.invoice = invoice;
        this.account = account;
        this.dAmount = dAmount;
        this.paymentMethod = paymentMethod;
        this.gateway = gateway; 
        this.sDummyPaymentId = sDummyPaymentId;
        this.currencyId = currencyId;
        parameters = new map<string, string>();

        this.API_KEY = gateway.Security_Key__c;
        this.GATEWAYPASSWORD = gateway.Merchant_ID__c;
        
        //Added by dhanalakshmi for INVOICEIT-18
        if(invoice == null)
        {
            this.invoice = new Invoice__c();
        } 
        
        //this determines is it sandboz or live
        if(gateway.Test_Mode__c) {
            sHttpEndPoint = ENDPOINT_EWAY_CHARGE_TEST;
        } else {
            sHttpEndPoint = ENDPOINT_EWAY_CHARGE_LIVE;
        }  
              
    } 

    public PaymentOperations.PaymentResult handleAuthorize_Click() {
        //Added by Shruthi related to INVOICEIT-200
        result.message = system.Label.Eway_Authorization;
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
            if(transactionId == null) {
                transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, 
                        Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, 
                        Amount__c = amountToBeProcessed, Request_Invoice__c = invoice.Id,
                        Currency__c = invoice.CurrencyL__c, Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD,
                        Payment_Gateway__c = gateway.Id, Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE,
                        Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c, Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c,
                        Card_Type__c = paymentMethod.Card_Type__c, Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length()));
            }

            string sJonData = frameJsonData();
            sendHttpRequest(sJonData,sHttpEndPoint);
            
            if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                //create the payment and payment allocation against the inv
                InvoicingUtilClass.createPaymentAndPaymentAllocation(invoice, transactionObj); 
                transactionObj.Is_Payment_Processed_Successfully__c = true;
                update transactionObj;                                                                 
            } 

        }catch(Exception ex) {
            result.message += '\n \n '+system.Label.ExceptionOccurred  + ex.getMessage() + '  Line Number :- ' +  ex.getLineNumber();

            if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                result.message += system.Label.InvoiceIsCharged;
                transactionObj.Is_Payment_Processed_Successfully__c = false;
                transactionObj.Exception_Message__c = system.Label.transactionIsDoneButPAIsNotDone  + '\n' + 'Exception message is : ' +  ex.getMessage() + ' \n Line no is ' +  ex.getLineNumber() + ' \n Type of exception ' + ex.getTypeName();
                upsert transactionObj;   
            }
        }
        return result;  
    }

    /* =================== Start ====================================== */

    /*
    Modified By          : Madhu Keshav    :1 Dec 2015:  INVOICEIT-641
    Comments           : Creating a generic method for processing all payments. This will be used in global methods and API
    */
    
   public PaymentSiteOperation.GenericPaymentResult handleAuthorizeAndCharge(PaymentSiteOperation.GenericPaymentParameters genericPaymentParameters)
    {
        isGenericMethodCall = false;
        PaymentSiteOperation.GenericPaymentResult genericPaymentResult = new  PaymentSiteOperation.GenericPaymentResult();
        try {

            decimal amountToBeProcessed = genericPaymentParameters.amountToProcess;

            transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, 
                        Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, 
                        Amount__c = amountToBeProcessed, Request_Invoice__c = invoice.Id,
                        Currency__c = invoice.CurrencyL__c, Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD,
                        Payment_Gateway__c = gateway.Id, Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE,
                        Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c, Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c,
                        Card_Type__c = paymentMethod.Card_Type__c, Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length()));
    
            string sJonData = frameJsonData();
            sendHttpRequest(sJonData,sHttpEndPoint);  

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
                
            if(invoice.id != null){
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
            
            string sJonData = frameJsonData();
            if(isSaveCardDetails) {
                sendHttpRequest(sJonData,sHttpEndPoint);
                result.message = transactionObj.Response_Status__c + ' ' + transactionObj.Response_Message__c;
                result.transactionObj = transactionObj;
                    
                // query the default payment method present for the account and update default to false
                list<Payment_Method__c> defaultPaymentMethods;
                if(invoice.Id != null){
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
                
                result.message = system.Label.transactioncreated;
                upsert transactionObj;

                transactionObj = [SELECT Name, Response_Status__c, Amount__c, Response_Code__c, Transaction__c, Response_Message__c
                                  FROM Transaction__c
                                  WHERE Id =: transactionObj.Id];

                result.message  +=  transactionObj.Name + ' \n'
                + 'Gateway Response : ' + transactionObj.Response_Code__c + ' \n'
                + 'Gateway Status : ' + transactionObj.Response_Status__c;
                
            } else {
                transactionObj.Payment_Method__c = sDummyPaymentId;
                sendHttpRequest(sJonData,sHttpEndPoint);
                result.message = transactionObj.Response_Status__c + ' ' + transactionObj.Response_Message__c;
                result.transactionObj = transactionObj;
            }
            
            if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
              //create the payment and payment allocation against the inv
              if(invoice.Id != null){
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
           result.message += '\n \n '+system.Label.ExceptionOccurred  + ex.getMessage() + '  Line Number :- ' +  ex.getLineNumber();
           if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED && transactionObj.Response_Status__c != null) {
               result.message += system.Label.InvoiceIsCharged;
               transactionObj.Is_Payment_Processed_Successfully__c = false;
               transactionObj.Exception_Message__c = system.Label.transactionIsDoneButPAIsNotDone + '\n' + 'Exception message is : ' +  ex.getMessage() + ' \n Line no is ' +  ex.getLineNumber() + ' \n Type of exception ' + ex.getTypeName();
           }
        }
        return result;          
    }

    public PaymentOperations.PaymentResult handleVoid_Click(string gatewayId, string transactionId, decimal transactionAmount) {
        result.message = system.Label.Eway_Void;
        return result; 
    }

    public PaymentOperations.PaymentResult handleRefund_Click(string gatewayId, string transactionId, decimal transactionAmount) {
        try{
            list<Transaction__c> transactions = [   SELECT Name, Gateway_ID__c,Authorization__c,Amount__c,Transaction__c
                                                    FROM Transaction__c
                                                    WHERE Id =:transactionId 
                                                    LIMIT 1
                                                    ];
            string authorizationRequest = '';
            sHttpEndPoint = sHttpEndPoint + '/' +transactions[0].Gateway_ID__c + '/Refund';

            string totalAmountValue = transactionAmount.toPlainString().replace('.', '');

            // frame json data
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeFieldName('Refund');
            gen.writeStartObject();
            gen.writeStringField('TotalAmount',totalAmountValue);
            gen.writeStringField('TransactionID',transactions[0].Gateway_ID__c);
            gen.writeEndObject();

            gen.writeFieldName('Customer');
            gen.writeStartObject();
            gen.writeObjectField('Title','.MR');
            if(paymentMethod.Billing_First_Name__c != null) 
                gen.writeObjectField('FirstName',paymentMethod.Billing_First_Name__c);
            if(paymentMethod.Billing_Last_Name__c != null) 
                gen.writeObjectField('LastName',paymentMethod.Billing_Last_Name__c);

            if(paymentMethod.Account__r.Name != null) 
                gen.writeObjectField('CompanyName',paymentMethod.Account__r.Name);
              if(paymentMethod.Billing_Address__c != null) 
                gen.writeObjectField('Street1',paymentMethod.Billing_Address__c);
            if(paymentMethod.Billing_City__c != null) 
                gen.writeObjectField('City',paymentMethod.Billing_City__c);
            if(paymentMethod.Billing_State_Province__c != null) 
                gen.writeObjectField('State',paymentMethod.Billing_State_Province__c);
            if(paymentMethod.Billing_Zip_Postal__c != null) 
                gen.writeObjectField('PostalCode',paymentMethod.Billing_Zip_Postal__c);
            if(paymentMethod.Billing_Email__c != null) 
                gen.writeObjectField('Email',paymentMethod.Billing_Email__c);
            if(paymentMethod.Billing_Phone__c != null) 
                gen.writeObjectField('Phone',paymentMethod.Billing_Phone__c);
             if(paymentMethod.Billing_Fax__c != null) 
                gen.writeObjectField('Fax',paymentMethod.Billing_Fax__c);
                gen.writeFieldName('CardDetails');
            gen.writeStartObject(); 
            if(paymentMethod.Card_Expiration_Month__c != null) 
                gen.writeObjectField('ExpiryMonth',paymentMethod.Card_Expiration_Month__c);
            if(paymentMethod.Card_Expiration_Year__c != null) 
                gen.writeObjectField('ExpiryYear',paymentMethod.Card_Expiration_Year__c.substring((paymentMethod.Card_Expiration_Year__c.Length() - 2), paymentMethod.Card_Expiration_Year__c.Length()));
            gen.writeEndObject();
            gen.writeEndObject();

            gen.writeFieldName('ShippingAddress');

            gen.writeStartObject(); 
            if(invoice.Shipping_Contact__r.FirstName != null)
                gen.writeObjectField('FirstName',invoice.Shipping_Contact__r.FirstName);
            if(invoice.Shipping_Contact__r.LastName != null)
                gen.writeObjectField('LastName',invoice.Shipping_Contact__r.LastName);
            if(invoice.Shipping_Contact__r.MailingStreet != null)
                gen.writeObjectField('Street1',invoice.Shipping_Contact__r.MailingStreet);
            if(invoice.Shipping_Contact__r.MailingCity != null)
                gen.writeObjectField('City',invoice.Shipping_Contact__r.MailingCity);
            if(invoice.Shipping_Contact__r.MailingState != null)
                gen.writeObjectField('State',invoice.Shipping_Contact__r.MailingState);
                     if(invoice.Shipping_Contact__r.MailingPostalCode != null)
                gen.writeObjectField('PostalCode',invoice.Shipping_Contact__r.MailingPostalCode);
            if(invoice.Shipping_Contact__r.Phone != null)
                gen.writeObjectField('Phone',invoice.Shipping_Contact__r.Phone);
            gen.writeEndObject();

            gen.writeEndObject();

            transactionObj = new Transaction__c(Transaction__c = transactions[0].Id,
                    Payment_Method__c = paymentMethod.Id, 
                    Type__c = CommonUtilClass.TRANSACTION_TYPE_REFUND, 
                    Gateway_ID__c = gatewayId, 
                    Amount__c = transactionAmount, 
                    Payment_Gateway__c = gateway.Id
                    );

            transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
            transactionObj.Request_Invoice__c = invoice.Id;
            transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
            transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_REFUND;
            transactionObj.Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c;
            transactionObj.Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c;
            transactionObj.Card_Type__c = paymentMethod.Card_Type__c;
            
            string sRefundData = gen.getAsString();
            // request and response parse
            sendHttpRequest(sRefundData,sHttpEndPoint);

            if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                //cancel the payment 
                InvoicingUtilClass.cancelPayment(transactions[0].Id);
            }
        } catch(Exception ex) {
            result.message = ex.getMessage();
        }
        return result; 
    }


    public void sendHttpRequest(string jsonData,String endpoint){
        if(!system.test.isRunningTest()) {
            // request the end popint url with user name and password
            HttpRequest req = new HttpRequest();

            Blob headerValue = Blob.valueOf(API_KEY + ':' + GATEWAYPASSWORD);
            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-Type', 'application/json');

            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setBody(jsonData);
            // send the request
            req.setTimeout(120000);

            Http h = new Http();
            HttpResponse res = h.send(req);

            // get the response from the requested url
            string sHttpResponseBody = res.getBody();
           
            if((sHttpResponseBody.contains('ResponseCode') 
                    || sHttpResponseBody.contains('AuthorisationCode') 
                    || sHttpResponseBody.contains('ResponseMessage') 
                    || sHttpResponseBody.contains('TransactionID') 
                    || sHttpResponseBody.contains('TransactionStatus') 
                    || sHttpResponseBody.contains('Errors') ) && sHttpResponseBody != null
                    ){
                Map<String, Object> map_JsonString = (Map<String, Object>)JSON.deserializeUntyped(sHttpResponseBody);

                parameters.put(string.valueof('TransactionStatus'),string.valueof((Boolean)map_JsonString.get('TransactionStatus')));
                parameters.put('ResponseCode',(string)map_JsonString.get('ResponseCode'));
                parameters.put('AuthorisationCode',(string)map_JsonString.get('AuthorisationCode'));
                parameters.put('ResponseMessage',(string)map_JsonString.get('ResponseMessage'));
                parameters.put('TransactionID',string.valueof((integer)map_JsonString.get('TransactionID')));
                parameters.put('Errors',(string)map_JsonString.get('Errors'));
            }else{
                parameters.put('Errors','Unauthorized');
            } 
        } else {
             parameters.put(string.valueof('TransactionStatus'),'false');
             parameters.put('ResponseCode','2');
             parameters.put('AuthorisationCode','000000');
             parameters.put('ResponseMessage','D4458');
             parameters.put('TransactionID','1006615');
             parameters.put('Errors', 'A2000,A2000,D4401');
        }
        handleRequest();
        
    }  

    private void handleRequest() {
        //if it contains OK,then transaction is approved
        if(((parameters.get('TransactionStatus') == 'true' || parameters.get('ResponseCode') == '00') && parameters.get('ResponseMessage') == 'A2000') && parameters.get('Errors') == null) {
            result.reloadPage = true;
            transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED;
            transactionObj.Response__c = 'This transaction has been approved.';
            transactionObj.Response_Code__c = parameters.get('ResponseCode');
            transactionObj.Gateway_ID__c = parameters.get('TransactionID');
            transactionObj.Response_Message__c = parameters.get('ResponseMessage');
            transactionObj.Authorization__c = parameters.get('AuthorisationCode');
        } else {
            result.reloadPage = false;
            transactionObj.Authorization__c = parameters.get('AuthorisationCode');
            transactionObj.Response_Status__c = parameters.get('Errors');
            transactionObj.Response_Message__c = parameters.get('ResponseMessage');
            transactionObj.Response__c = parameters.get('ResponseCode');
            transactionObj.Response_Code__c = parameters.get('ResponseCode');

            if(parameters.get('Errors') != null && parameters.get('Errors') != 'Unauthorized'){
                map<string,string> map_errorCodes = ewayErrorCodes();
                string sList = parameters.get('Errors');
                list<string> lstOfCodeMessege = sList.split(',');
                string displayErrorMessege = '';
                for(string s : lstOfCodeMessege){
                    s = s.trim();
                    if(map_errorCodes.containsKey(s)){
                        displayErrorMessege +=  map_errorCodes.get(s) + ',';
                    }
                }

                transactionObj.Response_Status__c = displayErrorMessege;
            }else if(parameters.get('ResponseMessage') != null){
                map<string,string> map_errorCodes = ewayErrorCodes();
                string sList = parameters.get('ResponseMessage');
                list<string> lstOfCodeMessege = sList.split(',');
                string displayErrorMessege = '';
                for(string s : lstOfCodeMessege){
                    s = s.trim();
                    if(map_errorCodes.containsKey(s)){
                        displayErrorMessege +=  map_errorCodes.get(s) + ',';
                    }
                }
               transactionObj.Response_Status__c = displayErrorMessege;
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

        result.message =  system.label.transactioncreated;
       if(isGenericMethodCall){
        
       // for the site payment, if the the boolean is true dont insert transaction record
        if(!isSavePaymentMethod){
             upsert transactionObj;
            
             transactionObj = [SELECT Name, Response_Status__c, Amount__c, Response_Code__c, Transaction__c, Response_Message__c
                               FROM Transaction__c
                               WHERE Id =: transactionObj.Id];
                              
             result.message +=  transactionObj.Name + ' \n'
                + 'Gateway Response : ' + parameters.get('ResponseMessage') + ' \n'
                + 'Gateway Status : ' + transactionObj.Response_Status__c;
        }
        result.transactionObj = transactionObj;  
    }
      
    }


    public string frameJsonData(){
        JSONGenerator gen = JSON.createGenerator(true);
        // Write data to the JSON string.
        gen.writeStartObject();
        gen.writeFieldName('Customer');
        gen.writeStartObject();
          gen.writeObjectField('Title','.MR');
        if(paymentMethod.Billing_First_Name__c != null) 
            gen.writeObjectField('FirstName',paymentMethod.Billing_First_Name__c);
        if(paymentMethod.Billing_Last_Name__c != null) 
            gen.writeObjectField('LastName',paymentMethod.Billing_Last_Name__c);

        if(paymentMethod.Account__r.Name != null) 
            gen.writeObjectField('CompanyName',paymentMethod.Account__r.Name);
        //gen.writeObjectField('JobDescription',paymentMethod.Billing_Last_Name__c);
        if(paymentMethod.Billing_Address__c != null) 
            gen.writeObjectField('Street1',paymentMethod.Billing_Address__c);
        //gen.writeObjectField('Street2',paymentMethod.Billing_Last_Name__c);
        if(paymentMethod.Billing_City__c != null) 
            gen.writeObjectField('City',paymentMethod.Billing_City__c);
        if(paymentMethod.Billing_State_Province__c != null) 
            gen.writeObjectField('State',paymentMethod.Billing_State_Province__c);
        if(paymentMethod.Billing_Zip_Postal__c != null) 
            gen.writeObjectField('PostalCode',paymentMethod.Billing_Zip_Postal__c);
         if(paymentMethod.Billing_Email__c != null) 
            gen.writeObjectField('Email',paymentMethod.Billing_Email__c);
        if(paymentMethod.Billing_Phone__c != null) 
            gen.writeObjectField('Phone',paymentMethod.Billing_Phone__c);
         if(paymentMethod.Billing_Fax__c != null) 
            gen.writeObjectField('Fax',paymentMethod.Billing_Fax__c);
        //gen.writeObjectField('Url',paymentMethod.Billing_Last_Name__c);

        gen.writeFieldName('CardDetails');

        gen.writeStartObject(); 
        if(paymentMethod.Name_on_Card__c != null) 
            gen.writeObjectField('Name',paymentMethod.Name_on_Card__c);
        else if(paymentMethod.Billing_First_Name__c != null &&  paymentMethod.Billing_Last_Name__c != null)
           gen.writeObjectField('Name',paymentMethod.Billing_First_Name__c + ''+ paymentMethod.Billing_Last_Name__c);
           
           
        if(paymentMethod.Encrypted_Card_Number__c != null) {
            gen.writeObjectField('Number',paymentMethod.Encrypted_Card_Number__c);
        }else if(paymentMethod.Card_Number__c != null){
            gen.writeObjectField('Number',paymentMethod.Card_Number__c);
        }
            
        if(paymentMethod.Encrypted_CVV__c != null) {
            gen.writeObjectField('CVN',paymentMethod.Encrypted_CVV__c);   
        }else if(paymentMethod.CVV__c != null){
             gen.writeObjectField('CVN',paymentMethod.CVV__c);   
        }
            
        if(paymentMethod.Card_Expiration_Month__c != null) 
            gen.writeObjectField('ExpiryMonth',paymentMethod.Card_Expiration_Month__c);
        if(paymentMethod.Card_Expiration_Year__c != null) 
            gen.writeObjectField('ExpiryYear',paymentMethod.Card_Expiration_Year__c.substring((paymentMethod.Card_Expiration_Year__c.Length() - 2), paymentMethod.Card_Expiration_Year__c.Length()));
        
        gen.writeEndObject();
        gen.writeEndObject();

        gen.writeFieldName('ShippingAddress');

        gen.writeStartObject(); 
        if(invoice != null && invoice.Shipping_Contact__r.FirstName != null)
            gen.writeObjectField('FirstName',invoice.Shipping_Contact__r.FirstName);
        if(invoice != null && invoice.Shipping_Contact__r.LastName != null)
            gen.writeObjectField('LastName',invoice.Shipping_Contact__r.LastName);
        if(invoice != null && invoice.Shipping_Contact__r.MailingStreet != null)
            gen.writeObjectField('Street1',invoice.Shipping_Contact__r.MailingStreet);
        if(invoice != null && invoice.Shipping_Contact__r.MailingCity != null)
            gen.writeObjectField('City',invoice.Shipping_Contact__r.MailingCity);
        if(invoice != null && invoice.Shipping_Contact__r.MailingState != null)
            gen.writeObjectField('State',invoice.Shipping_Contact__r.MailingState);
 
        if(invoice != null && invoice.Shipping_Contact__r.MailingPostalCode != null)
            gen.writeObjectField('PostalCode',invoice.Shipping_Contact__r.MailingPostalCode);
        if(invoice != null && invoice.Shipping_Contact__r.Phone != null)
            gen.writeObjectField('Phone',invoice.Shipping_Contact__r.Phone);
        gen.writeEndObject();

        gen.writeFieldName('Payment');
        gen.writeStartObject(); 
        
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
        
        string totalAmountValue = amountToBeProcessed.toPlainString().replace('.', '');
        
        Currency__c currency1;
       // if the currency id is not null, means process for the virtual terminal
       if(currencyId != null) {
           currency1 = [SELECT Name FROM Currency__c WHERE id =: currencyId];
       } else {
         currency1 = [SELECT Name FROM Currency__c WHERE Name = 'USD' limit 1];
       }
       String sCurrrency = invoice != null ? invoice.CurrencyL__r.Name : currency1.Name;

        if(amountToBeProcessed > 0 )
            gen.writeObjectField('TotalAmount', totalAmountValue);
        if(invoice.id != null && invoice.Name != null)    
            gen.writeObjectField('InvoiceNumber',invoice.Name);
        if(sCurrrency != null)
            gen.writeObjectField('CurrencyCode',sCurrrency);
        if(invoice.id != null)
            gen.writeObjectField('InvoiceDescription','SalesForce Record Id : ' + invoice.Id);
         else
           gen.writeObjectField('InvoiceDescription','SalesForce Record Id : ' + account.Id);  
        if(invoice.id != null && invoice.Invoice_Reference__c != null)
            gen.writeObjectField('InvoiceReference',invoice.Invoice_Reference__c);

        gen.writeEndObject();

        gen.writeObjectField('TransactionType','Purchase');
        gen.writeObjectField('Method','ProcessPayment');

        gen.writeEndObject();


        return gen.getAsString();
    }

    public map<string,string> ewayErrorCodes(){
        map<string,string> map_errorCodes = new map<string,string>();

        map_errorCodes.put('A2000','Transaction Approved');
        map_errorCodes.put('A2008','Honour With Identification');
        map_errorCodes.put('A2010','Approved For Partial Amount');
        map_errorCodes.put('A2011','Approved, VIP');
        map_errorCodes.put('A2016','Approved, Update Track 3');
        map_errorCodes.put('D4401','Refer to Issuer');
        map_errorCodes.put('D4402','Refer to Issuer, special');
        map_errorCodes.put('D4403','No Merchant');
        map_errorCodes.put('D4404','Pick Up Card');
        map_errorCodes.put('D4405','Do Not Honour');
        map_errorCodes.put('D4406','Error ');
        map_errorCodes.put('D4407','Pick Up Card, Special');
        map_errorCodes.put('D4409','Request In Progress');
        map_errorCodes.put('D4412','Invalid Transaction');
        map_errorCodes.put('D4413','Invalid Amount');
        map_errorCodes.put('D4414','Invalid Card Number');
        map_errorCodes.put('D4415','No Issuer');
        map_errorCodes.put('D4419','Re-enter Last Transaction');
        map_errorCodes.put('D4421','No Action Taken');
        map_errorCodes.put('D4422','Suspected Malfunction');
        map_errorCodes.put('D4423','Unacceptable Transaction Fee');
        map_errorCodes.put('D4425','Unable to Locate Record On File');
        map_errorCodes.put('D4430','Format Error');
        map_errorCodes.put('D4431','Bank Not Supported By Switch');
        map_errorCodes.put('D4433','Expired Card, Capture');
        map_errorCodes.put('D4434','Suspected Fraud, Retain Card');
        map_errorCodes.put('D4435','Card Acceptor, Contact Acquirer, Retain Card');
        map_errorCodes.put('D4436','Restricted Card, Retain Card');
        map_errorCodes.put('D4437','Contact Acquirer Security Department, Retain Card');
        map_errorCodes.put('D4438','PIN Tries Exceeded, Capture');
        map_errorCodes.put('D4439','No Credit Account');
        map_errorCodes.put('D4440','Function Not Supported');
        map_errorCodes.put('D4441','Lost Card');
        map_errorCodes.put('D4442','No Universal Account');
        map_errorCodes.put('D4443','Stolen Card');
        map_errorCodes.put('D4444','No Investment Account');
        map_errorCodes.put('D4451','Insufficient Funds');
        map_errorCodes.put('D4452','No Cheque Account');
        map_errorCodes.put('D4453','No Savings Account');
        map_errorCodes.put('D4454','Expired Card');
        map_errorCodes.put('D4455','Incorrect PIN');
        map_errorCodes.put('D4456','No Card Record');
        map_errorCodes.put('D4457','Function Not Permitted to Cardholder');
        map_errorCodes.put('D4458','Function Not Permitted to Terminal');
        map_errorCodes.put('D4459','Suspected Fraud');
        map_errorCodes.put('D4460','Acceptor Contact Acquirer');
        map_errorCodes.put('D4461','Exceeds Withdrawal Limit');
        map_errorCodes.put('D4462','Restricted Card');
        map_errorCodes.put('D4463','Security Violation');
        map_errorCodes.put('D4464','Original Amount Incorrect');
        map_errorCodes.put('D4466','Acceptor Contact Acquirer, Security');
        map_errorCodes.put('D4467','Capture Card');
        map_errorCodes.put('D4475','PIN Tries Exceeded');
        map_errorCodes.put('D4482','CVV Validation Error');
        map_errorCodes.put('D4490','Cut off In Progress');
        map_errorCodes.put('D4491','Card Issuer Unavailable');
        map_errorCodes.put('D4492','Unable To Route Transaction');
        map_errorCodes.put('D4493','Cannot Complete, Violation Of The Law');
        map_errorCodes.put('D4494','Duplicate Transaction');
        map_errorCodes.put('D4496','System Error');
        map_errorCodes.put('D4497','MasterPass Error');
        map_errorCodes.put('D4498','PayPal Create Transaction Error');
        map_errorCodes.put('D4499','Invalid Transaction for Auth/Void');
        map_errorCodes.put('F7000','Undefined Fraud Error');
        map_errorCodes.put('F7001*','Challenged Fraud');
        map_errorCodes.put('F7002','Country Match Fraud');
        map_errorCodes.put('F7003','High Risk Country Fraud');
        map_errorCodes.put('F7004','Anonymous Proxy Fraud');
        map_errorCodes.put('F7005','Transparent Proxy Fraud');
        map_errorCodes.put('F7006','Free Email Fraud');
        map_errorCodes.put('F7007','International Transaction Fraud');
        map_errorCodes.put('F7008','Risk Score Fraud');
        map_errorCodes.put('F7009*','Denied Fraud');
        map_errorCodes.put('F7010','Denied by PayPal Fraud Rules');
        map_errorCodes.put('F9010','High Risk Billing Country');
        map_errorCodes.put('F9011','High Risk Credit Card Country');
        map_errorCodes.put('F9012','High Risk Customer IP Address');
        map_errorCodes.put('F9013','High Risk Email Address');
        map_errorCodes.put('F9014','High Risk Shipping Country ');
        map_errorCodes.put('F9015','Multiple card numbers for single email address');
        map_errorCodes.put('F9016','Multiple card numbers for single location');
        map_errorCodes.put('F9017','Multiple email addresses for single card number');
        map_errorCodes.put('F9018','Multiple email addresses for single location');
        map_errorCodes.put('F9019','Multiple locations for single card number');
        map_errorCodes.put('F9020','Multiple locations for single email address');
        map_errorCodes.put('F9021','Suspicious Customer First Name');
        map_errorCodes.put('F9022','Suspicious Customer Last Name');
        map_errorCodes.put('F9023','Transaction Declined');
        map_errorCodes.put('F9024','Multiple transactions for same address with known credit card ');
        map_errorCodes.put('F9025','Multiple transactions for same address with new credit card');
        map_errorCodes.put('F9026','Multiple transactions for same email with new credit card');
        map_errorCodes.put('F9027','Multiple transactions for same email with known credit card');
        map_errorCodes.put('F9028','Multiple transactions for new credit card');
        map_errorCodes.put('F9029','Multiple transactions for known credit card');
        map_errorCodes.put('F9030','Multiple transactions for same email address');
        map_errorCodes.put('F9031','Multiple transactions for same credit card');
        map_errorCodes.put('F9032','Invalid Customer Last Name ');
        map_errorCodes.put('F9033','Invalid Billing Street');
        map_errorCodes.put('F9034','Invalid Shipping Street ');
        map_errorCodes.put('F9037','Suspicious Customer Email Address');
        map_errorCodes.put('S5000','System Error');
        map_errorCodes.put('S5011','PayPal Connection Error');
        map_errorCodes.put('S5012','PayPal Settings Error');
        map_errorCodes.put('S5085','Started 3dSecure');
        map_errorCodes.put('S5086','Routed 3dSecure');
        map_errorCodes.put('S5087','Completed 3dSecure');
        map_errorCodes.put('S5088','PayPal Transaction Created');
        map_errorCodes.put('S5099','Incomplete (Access Code in progress/incomplete)');
        map_errorCodes.put('S5010','Unknown error returned by gateway');
        map_errorCodes.put('V6000','Validation error');
        map_errorCodes.put('V6001','Invalid CustomerIP');
        map_errorCodes.put('V6002','Invalid DeviceID');
        map_errorCodes.put('V6003','Invalid Request PartnerID');
        map_errorCodes.put('V6004','Invalid Request Method');
        map_errorCodes.put('V6010','Invalid TransactionType, account not certified for eCome only MOTO or Recurring available');
        map_errorCodes.put('V6011','Invalid Payment TotalAmount');
        map_errorCodes.put('V6012','Invalid Payment InvoiceDescription');
        map_errorCodes.put('V6013','Invalid Payment InvoiceNumber');
        map_errorCodes.put('V6014','Invalid Payment InvoiceReference');
        map_errorCodes.put('V6015','Invalid Payment CurrencyCode');
        map_errorCodes.put('V6016','Payment Required');
        map_errorCodes.put('V6017','Payment CurrencyCode Required ');
        map_errorCodes.put('V6018','Unknown Payment CurrencyCode');
        map_errorCodes.put('V6021','EWAY_CARDHOLDERNAME Required');
        map_errorCodes.put('V6022','EWAY_CARDNUMBER Required');
        map_errorCodes.put('V6023','EWAY_CARDCVN Required');
        map_errorCodes.put('V6033','Invalid Expiry Date');
        map_errorCodes.put('V6034','Invalid Issue Number ');
        map_errorCodes.put('V6035','Invalid Valid From Date');
        map_errorCodes.put('V6040','Invalid TokenCustomerID');
        map_errorCodes.put('V6041','Customer Required');
        map_errorCodes.put('V6042','Customer FirstName Required ');
        map_errorCodes.put('V6043','Customer LastName Required');
        map_errorCodes.put('V6044','Customer CountryCode Required');
        map_errorCodes.put('V6045','Customer Title Required ');
        map_errorCodes.put('V6046','TokenCustomerID Required');
        map_errorCodes.put('V6047','RedirectURL Required');
        map_errorCodes.put('V6048','CheckoutURL Required when CheckoutPayment specified');
        map_errorCodes.put('​V6049','Invalid Checkout URL');
        map_errorCodes.put('V6051','Invalid Customer FirstName');
        map_errorCodes.put('V6052','Invalid Customer LastName');
        map_errorCodes.put('V6053','Invalid Customer CountryCode');
        map_errorCodes.put('V6058','Invalid Customer Title ');
        map_errorCodes.put('V6059','Invalid RedirectURL');
        map_errorCodes.put('V6060','Invalid TokenCustomerID');
        map_errorCodes.put('V6061','Invalid Customer Reference');
        map_errorCodes.put('V6062','Invalid Customer CompanyName');
        map_errorCodes.put('V6063','Invalid Customer JobDescription');
        map_errorCodes.put('V6064','Invalid Customer Street1');
        map_errorCodes.put('V6065','Invalid Customer Street2');
        map_errorCodes.put('V6066','Invalid Customer City');
        map_errorCodes.put('V6067','Invalid Customer State');
        map_errorCodes.put('V6068','Invalid Customer PostalCode');
        map_errorCodes.put('V6069','Invalid Customer Email ');
        map_errorCodes.put('V6070','Invalid Customer Phone');
        map_errorCodes.put('V6071','Invalid Customer Mobile');
        map_errorCodes.put('V6072','Invalid Customer Comments');
        map_errorCodes.put('V6073','Invalid Customer Fax');
        map_errorCodes.put('V6074','Invalid Customer URL');
        map_errorCodes.put('V6075','Invalid ShippingAddress FirstName');
        map_errorCodes.put('V6076','Invalid ShippingAddress LastName');
        map_errorCodes.put('V6077','Invalid ShippingAddress Street1');
        map_errorCodes.put('V6078','Invalid ShippingAddress Street2');
        map_errorCodes.put('V6079','Invalid ShippingAddress City');
        map_errorCodes.put('V6080','Invalid ShippingAddress State');
        map_errorCodes.put('V6081','Invalid ShippingAddress PostalCode');
        map_errorCodes.put('V6082','Invalid ShippingAddress Email');
        map_errorCodes.put('V6083','Invalid ShippingAddress Phone');
        map_errorCodes.put('V6084','Invalid ShippingAddress Country');
        map_errorCodes.put('V6085','Invalid ShippingAddress ShippingMethod');
        map_errorCodes.put('V6086','Invalid ShippingAddress Fax');
        map_errorCodes.put('V6091','Unknown Customer CountryCode');
        map_errorCodes.put('V6092','Unknown ShippingAddress CountryCode');
        map_errorCodes.put('V6100','Invalid EWAY_CARDNAME');
        map_errorCodes.put('V6101','Invalid EWAY_CARDEXPIRYMONTH');
        map_errorCodes.put('V6102','Invalid EWAY_CARDEXPIRYYEAR ');
        map_errorCodes.put('V6103','Invalid EWAY_CARDSTARTMONTH');
        map_errorCodes.put('V6104','Invalid EWAY_CARDSTARTYEAR');
        map_errorCodes.put('V6105','Invalid EWAY_CARDISSUENUMBER ');
        map_errorCodes.put('V6106','Invalid EWAY_CARDCVN');
        map_errorCodes.put('V6107','Invalid EWAY_ACCESSCODE');
        map_errorCodes.put('V6108','Invalid CustomerHostAddress');
        map_errorCodes.put('V6109','Invalid UserAgent');
        map_errorCodes.put('V6110','Invalid EWAY_CARDNUMBER');
        map_errorCodes.put('V6111','Unauthorised API Access, Account Not PCI Certified');
        map_errorCodes.put('V6112','Redundant card details other than expiry year and month');
        map_errorCodes.put('V6113','Invalid transaction for refund');
        map_errorCodes.put('V6114','Gateway validation error');
        map_errorCodes.put('V6115','Invalid DirectRefundRequest, Transaction ID ');
        map_errorCodes.put('V6116','Invalid card data on original TransactionID ');
        map_errorCodes.put('V6117','Invalid CreateAccessCodeSharedRequest, FooterText');
        map_errorCodes.put('V6118','Invalid CreateAccessCodeSharedRequest, HeaderText');
        map_errorCodes.put('V6119','Invalid CreateAccessCodeSharedRequest, Language');
        map_errorCodes.put('V6120','Invalid CreateAccessCodeSharedRequest, LogoUrl ');
        map_errorCodes.put('V6121','Invalid TransactionSearch, Filter Match Type');
        map_errorCodes.put('V6122','Invalid TransactionSearch, Non numeric Transaction ID');
        map_errorCodes.put('V6123','Invalid TransactionSearch,no TransactionID or AccessCode specified ');
        map_errorCodes.put('V6124','Invalid Line Items. The line items have been provided however the totals do not match the TotalAmount field');
        map_errorCodes.put('V6125','Selected Payment Type not enabled');
        map_errorCodes.put('V6126','Invalid encrypted card number, decryption failed');
        map_errorCodes.put('V6127','Invalid encrypted cvn, decryption failed');
        map_errorCodes.put('V6128','Invalid Method for Payment Type');
        map_errorCodes.put('V6129','Transaction has not been authorised for Capture/Cancellation');
        map_errorCodes.put('V6130','Generic customer information error ');
        map_errorCodes.put('V6131','Generic shipping information error');
        map_errorCodes.put('V6132','Transaction has already been completed or voided, operation not permitted');
        map_errorCodes.put('V6133','Checkout not available for Payment Type');
        map_errorCodes.put('V6134','Invalid Auth Transaction ID for Capture/Void');
        map_errorCodes.put('V6135','PayPal Error Processing Refund');
        map_errorCodes.put('V6140','Merchant account is suspended');
        map_errorCodes.put('V6141','Invalid PayPal account details or API signature');
        map_errorCodes.put('V6142','Authorise not available for Bank/Branch');
        map_errorCodes.put('V6150','Invalid Refund Amount');
        map_errorCodes.put('V6151','Refund amount greater than original transaction');

        return map_errorCodes;
    }

}