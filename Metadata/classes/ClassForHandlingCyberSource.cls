public with sharing class ClassForHandlingCyberSource implements InterfacePaymentClass.paymentOperationsInterface {
    private map<string, string> parameters;
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
    private string sIpAddress;
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
    
    /*
    Modified By          : Rama Krishna   :13 Nov 2015    :INVOICEIT-629
    Comments          : added new boolean parameter, by default true and if we set this as false then transaction record will not create.
    */

    private boolean isGenericMethodCall = true;
    
    string sRawHttpResponse;
     map<string, string> mapOfKeyValue = new map<string, string>();
    // this variable is declared because on force.com site page if user selected the savecard information.
    boolean isSavePaymentMethod = false;
    public ClassForHandlingCyberSource(Gateway__c gateway, Invoice__c invoice, Payment_Method__c paymentMethod) {
     this.invoice = invoice;
        this.paymentMethod = paymentMethod;
        this.gateway = gateway; 
        
        
        if(invoice == null)
        {
            this.invoice = new Invoice__c();
        } 
        parameters = new map<string, string>();
        
        //This determines either sandbox or live - INVOICEIT-599 - S.A.Manigandan
        if(gateway.Test_Mode__c) {
            sHttpEndPoint = CommonUtilClass.ENDPOINT_CyberSource_TEST;
        } else {
            sHttpEndPoint = CommonUtilClass.ENDPOINT_CyberSource_LIVE;
        }      
        
        populateCustomerDetails();
    }
    public ClassForHandlingCyberSource(Gateway__c gateway, Invoice__c invoice, Payment_Method__c paymentMethod,string sDummyPaymentId,decimal dAmount,Account account) {
     this.invoice = invoice;
        this.account = account;
        this.dAmount = dAmount;
        this.paymentMethod = paymentMethod;
        this.gateway = gateway; 
        this.sDummyPaymentId = sDummyPaymentId;
        parameters = new map<string, string>();
        
        //This determines either sandbox or live - INVOICEIT-599 - S.A.Manigandan
        if(gateway.Test_Mode__c) {
            sHttpEndPoint = CommonUtilClass.ENDPOINT_CyberSource_TEST;
        } else {
            sHttpEndPoint = CommonUtilClass.ENDPOINT_CyberSource_LIVE;
        }      
        
        populateCustomerDetails();
    }
    public PaymentOperations.PaymentResult handleAuthorize_Click() {

           result.message = system.Label.CS_Authorization;
        return result;
        
    }

   /* =================== Start ====================================== */

    /*
    Modified By          : Rama Krishna   :13 Nov 2015  :INVOICEIT-629
    Comments          : Creating a generic method for processing all payments. This will be used in global methods and API
    */

    public PaymentSiteOperation.GenericPaymentResult handleAuthorizeAndCharge(PaymentSiteOperation.GenericPaymentParameters genericPaymentParameters)
    {
        isGenericMethodCall = false;
        PaymentSiteOperation.GenericPaymentResult genericPaymentResult = new  PaymentSiteOperation.GenericPaymentResult();
        try {

            string amount = genericPaymentParameters.amountToProcess.toPlainString();
            string chargeXmlRequest;


            transactionObj = new Transaction__c(type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, 
                                                    Amount__c = genericPaymentParameters.amountToProcess, 
                                                    Currency__c = invoice.CurrencyL__c, 
                                                    Payment_Gateway__c = gateway.Id
                                                    );  
                                                    
                chargeXmlRequest = '<?xml version="1.0" encoding="UTF-8"?>' + 
                    '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">' +
                    '<s:Header>' + 
                    '<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">' +
                    '<wsse:UsernameToken>' +
                    '<wsse:Username>' + gateway.Merchant_ID__c + '</wsse:Username>' +
                    '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + gateway.Transaction_Security_Key__c + '</wsse:Password>' +
                    '</wsse:UsernameToken>' +
                    ' </wsse:Security>' +
                    '</s:Header>' +
                    '<s:Body>' +
                    '<requestMessage xmlns="urn:schemas-cybersource-com:transaction-data-1.115">' +
                        '<merchantID>' + gateway.Merchant_ID__c + '</merchantID>' +
                        '<merchantReferenceCode>' + gateway.Merchant_Reference__c + '</merchantReferenceCode>' +                               
                                    '<billTo>' +
                                        '<firstName>' + sFirstName + '</firstName>' +
                                        '<lastName>' + sLastName + '</lastName>' +
                                        '<street1>' + sAddress1 + '</street1>' +
                                        '<city>' + sCity + '</city>' +
                                        '<state>' + sState + '</state>' +
                                        '<postalCode>' + sZipCode + '</postalCode>' +
                                        '<country>' + sCountry + '</country>' +
                                        '<phoneNumber>' + sPhone + '</phoneNumber>' +
                                        '<email>' + sEmail + '</email>' +
                                    '</billTo>' +
                                    '<purchaseTotals>' +
                                    '<currency>' + genericPaymentParameters.currencyISOCode + '</currency>' +
                                    '<grandTotalAmount>' + amount + '</grandTotalAmount>' +
                                    '</purchaseTotals>' +
                                    '<check>' +
                                    '<accountNumber>' + paymentMethod.Bank_Account_Number__c + '</accountNumber>';
                                    If (paymentMethod.Bank_Account_Type__c == 'CHECKING')
                                    chargeXmlRequest += '<accountType>C</accountType>';
                                    If (paymentMethod.Bank_Account_Type__c == 'BUSINESSCHECKING')
                                    chargeXmlRequest += '<accountType>X</accountType>';
                                    If (paymentMethod.Bank_Account_Type__c == 'SAVINGS')
                                    chargeXmlRequest += '<accountType>S</accountType>';
                                    chargeXmlRequest += '<bankTransitNumber>' + paymentMethod.Bank_Routing_Code__c + '</bankTransitNumber>' +
                                    '</check>' +
                                '<ecDebitService run="true" />' +
                                '</requestMessage>' +
                                '</s:Body>' +
                                '</s:Envelope>' 
                       ;                                             
           
            transactionObj.Request_Credit_Card_Number__c = paymentMethod.Bank_Account_Number__c.substring((paymentMethod.Bank_Account_Number__c.Length() - 4), paymentMethod.Bank_Account_Number__c.Length());
            transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_ECHECK;
            transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE;

            // http request
            sendHttpRequest(chargeXmlRequest);

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


    public PaymentOperations.PaymentResult handleAuthorizeAndCharge_Click(string transactionId, string gatewayID) {
        try {
            
            
            decimal amountToBeProcessed = 0;
            if(invoice.Payment_Request_Amount__c != null && invoice.Payment_Request_Amount__c > 0 && invoice.Payment_Request_Amount__c < invoice.Unpaid_Amount__c) {
                amountToBeProcessed = invoice.Payment_Request_Amount__c;
            } else {
                amountToBeProcessed = invoice.Unpaid_Amount__c;
            }
            
            string amount = amountToBeProcessed.toPlainString();
            string chargeXmlRequest;
            
           if(transactionId == null) {
                transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, 
                                                    Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, 
                                                    Amount__c = amountToBeProcessed, 
                                                    Currency__c = invoice.CurrencyL__c, 
                                                    Payment_Gateway__c = gateway.Id
                                                    ); 
                                                    
                 
                chargeXmlRequest = '<?xml version="1.0" encoding="UTF-8"?>' + 
                    '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">' +
                    '<s:Header>' + 
                    '<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">' +
                    '<wsse:UsernameToken>' +
                    '<wsse:Username>' + gateway.Merchant_ID__c + '</wsse:Username>' +
                    '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + gateway.Transaction_Security_Key__c + '</wsse:Password>' +
                    '</wsse:UsernameToken>' +
                    ' </wsse:Security>' +
                    '</s:Header>' +
                    '<s:Body>' +
                    '<requestMessage xmlns="urn:schemas-cybersource-com:transaction-data-1.115">' +
                        '<merchantID>' + gateway.Merchant_ID__c + '</merchantID>' +
                        '<merchantReferenceCode>' + gateway.Merchant_Reference__c + '</merchantReferenceCode>' +

                                
                                    '<billTo>' +
                                        '<firstName>' + sFirstName + '</firstName>' +
                                        '<lastName>' + sLastName + '</lastName>' +
                                        '<street1>' + sAddress1 + '</street1>' +
                                        //'<street2>' + sAddress1 + '</street2>' +
                                        '<city>' + sCity + '</city>' +
                                        '<state>' + sState + '</state>' +
                                        '<postalCode>' + sZipCode + '</postalCode>' +
                                        '<country>' + sCountry + '</country>' +
                                        '<phoneNumber>' + sPhone + '</phoneNumber>' +
                                        '<email>' + sEmail + '</email>' +
                                    '</billTo>' +
                                    '<purchaseTotals>' +
                                    '<currency>' + invoice.CurrencyL__r.Name + '</currency>' +
                                    '<grandTotalAmount>' + amount + '</grandTotalAmount>' +
                                    '</purchaseTotals>' +
                                    '<check>' +
                                    '<accountNumber>' + paymentMethod.Bank_Account_Number__c + '</accountNumber>';
                                    If (paymentMethod.Bank_Account_Type__c == 'CHECKING')
                                    chargeXmlRequest += '<accountType>C</accountType>';
                                    If (paymentMethod.Bank_Account_Type__c == 'BUSINESSCHECKING')
                                    chargeXmlRequest += '<accountType>X</accountType>';
                                    If (paymentMethod.Bank_Account_Type__c == 'SAVINGS')
                                    chargeXmlRequest += '<accountType>S</accountType>';
                                    chargeXmlRequest += '<bankTransitNumber>' + paymentMethod.Bank_Routing_Code__c + '</bankTransitNumber>' +
                                    '</check>' +
                                '<ecDebitService run="true" />' +
                                '</requestMessage>' +
                                '</s:Body>' +
                                '</s:Envelope>' 
                       ;                                             
           
            
           transactionObj.Request_Credit_Card_Number__c = paymentMethod.Bank_Account_Number__c.substring((paymentMethod.Bank_Account_Number__c.Length() - 4), paymentMethod.Bank_Account_Number__c.Length());
            transactionObj.Request_Invoice__c = invoice.Id;
            transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_ECHECK;
            transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE;

            
            sendHttpRequest(chargeXmlRequest);
            
            handleRequest();
            if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                Payment__c payment = new Payment__c(Account__c = invoice.Account__c, 
                        Amount__c = transactionObj.Amount__c, 
                        Status__c = CommonUtilClass.STATUS_COMPLETED, 
                        Payment_Type__c = CommonUtilClass.PAYMENTTYPE_ACH,
                        Payment_Date__c = system.today(),
                        Transaction__c = transactionObj.Id,
                        Currency__c = invoice.CurrencyL__c,Invoice__c = invoice.Id);

                insert payment;

                Payment_Allocation__c paymentAllocation = new Payment_Allocation__c(Payment__c = payment.Id,
                        Amount__c = payment.Amount__c,
                        Invoice__c = invoice.Id,
                        Status__c = CommonUtilClass.STATUS_COMPLETED);   

                insert paymentAllocation; 

                transactionObj.Is_Payment_Processed_Successfully__c = true;
                update transactionObj;
            }

            }
        } catch(Exception ex) {
            result.message += '\n \n '+system.Label.ExceptionOccurred +' ' + ex.getMessage();
           if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
               result.message += '\n \n'+ system.Label.InvoiceIsCharged;
               transactionObj.Is_Payment_Processed_Successfully__c = false;
               transactionObj.Exception_Message__c = system.Label.transactionIsDoneButPAIsNotDone + '\n' + 'Exception message is : ' +  ex.getMessage() + ' \n Line no is ' +  ex.getLineNumber() + ' \n Type of exception ' + ex.getTypeName();
               upsert transactionObj;   
           }
        }
        
        
    
        return result;
    }
    public PaymentOperations.PaymentResult handleVoid_Click(string gatewayId, string transactionId, decimal transactionAmount) {
         try {
            
            Transaction__c transactionObjvoid = [SELECT Name, Gateway_ID__c, Response_Status__c, Amount__c, Response_Code__c, Transaction__c, Response_Message__c
                               FROM Transaction__c
                               WHERE Id =: transactionId];
                              

            string voidXmlRequest = '<?xml version="1.0" encoding="UTF-8"?>' +
            '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">' +
            '<s:Header>' +
            '<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">' +
            '<wsse:UsernameToken>' +
            '<wsse:Username>' + gateway.Merchant_ID__c + '</wsse:Username>' +
            '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + gateway.Transaction_Security_Key__c + '</wsse:Password>' +
            '</wsse:UsernameToken>' +
            '</wsse:Security>' +
            '</s:Header>' +
            '<s:Body>' +
            '<requestMessage xmlns="urn:schemas-cybersource-com:transaction-data-1.115">' +
            '<merchantID>' + gateway.Merchant_ID__c + '</merchantID>' + 
            '<merchantReferenceCode>' + gateway.Merchant_Reference__c + '</merchantReferenceCode>' +
            '<voidService run="true">' +
            '<voidRequestID>' + transactionObjvoid.Gateway_ID__c + '</voidRequestID>' +
            '</voidService>' +
            '</requestMessage>' +
            '</s:Body>' +
            '</s:Envelope>' ;
            transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, 
                                                Type__c = CommonUtilClass.TRANSACTION_TYPE_VOID, 
                                                Transaction__c = transactionId, 
                                                Gateway_ID__c = gatewayId, 
                                                Is_Payment_Processed_Successfully__c = true, 
                                                Amount__c = transactionAmount, 
                                                Payment_Gateway__c = gateway.Id
                                                );
            
            transactionObj.Request_Credit_Card_Number__c = paymentMethod.Bank_Account_Number__c.substring((paymentMethod.Bank_Account_Number__c.Length() - 4), paymentMethod.Bank_Account_Number__c.Length());
            transactionObj.Request_Invoice__c = invoice.Id;
            transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_ECHECK;
            transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_VOID;

            
            
            sendHttpRequest(voidXmlRequest);
            handleRequest();
            if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
               
                InvoicingUtilClass.cancelPayment(transactionObj.Transaction__c);
            }
        } catch(Exception ex) {
            result.message = ex.getMessage();
        }
            

         return result;
    }
    public PaymentOperations.PaymentResult handleRefund_Click(string gatewayId, string transactionId, decimal transactionAmount) {
        Transaction__c transactionObjrefund = [SELECT Name, Gateway_ID__c, Response_Status__c, Amount__c, Response_Code__c, Transaction__c, Response_Message__c
                               FROM Transaction__c
                               WHERE Id =: transactionId];
         try {
            string amount = transactionAmount.toPlainString();
            string refundXmlRequest = '<?xml version="1.0" encoding="UTF-8"?>' +
            '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">' +
            '<s:Header>' +
            '<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">' +
            '<wsse:UsernameToken>' +
            '<wsse:Username>' + gateway.Merchant_ID__c + '</wsse:Username>' +
            '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + gateway.Transaction_Security_Key__c + '</wsse:Password>' +
            '</wsse:UsernameToken>' +
            '</wsse:Security>' +
            '</s:Header>' +
            '<s:Body>' +
            '<requestMessage xmlns="urn:schemas-cybersource-com:transaction-data-1.115">' +
            '<merchantID>' + gateway.Merchant_ID__c + '</merchantID>' +
            '<merchantReferenceCode>' + gateway.Merchant_Reference__c + '</merchantReferenceCode>' +
            '<purchaseTotals>' +
            '<currency>' + invoice.CurrencyL__r.Name + '</currency>' +
            //'<currency>' + transactionObjrefund.Currency__r.Name + '</currency>' +
            '<grandTotalAmount>' + amount + '</grandTotalAmount>' +
            '</purchaseTotals>' +
            '<ecCreditService run="true">' +
            '<debitRequestID>' + transactionObjrefund.Gateway_ID__c + '</debitRequestID>' +
            '</ecCreditService>' +
            '</requestMessage>' +
            '</s:Body>' +
            '</s:Envelope>'; 

            
            //for live transactions, demo should be removed
            if(!gateway.Test_Mode__c) {
                refundXmlRequest = refundXmlRequest.replace(' mode="demo"', '');
            }
            transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, 
                                                Type__c = CommonUtilClass.TRANSACTION_TYPE_REFUND, 
                                                Transaction__c = transactionId, 
                                                Gateway_ID__c = gatewayId, 
                                                Amount__c = transactionAmount, 
                                                Is_Payment_Processed_Successfully__c = true, 
                                                Payment_Gateway__c = gateway.Id
                                                );
                                                
            transactionObj.Request_Credit_Card_Number__c = paymentMethod.Bank_Account_Number__c.substring((paymentMethod.Bank_Account_Number__c.Length() - 4), paymentMethod.Bank_Account_Number__c.Length());
            transactionObj.Request_Invoice__c = invoice.Id;
            transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_ECHECK;
            transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_REFUND;
            
            
            transactionObj.Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c;
            transactionObj.Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c;
        
            sendHttpRequest(refundXmlRequest);
            handleRequest();
            if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                //cancel the payment 
                InvoicingUtilClass.cancelPayment(transactionObj.Transaction__c);
            }   
        } catch(Exception ex) {
         result.message += '\n \n'+ system.Label.ExceptionOccurred + ex.getMessage();
        }
        return result;
    } 
    private void createStringFromMap() {
        for(String key : parameters.keyset()) {
            // if the value is null, then it throws an exception
            
            if(parameters.get(key) != null) {
                sHttpBody += key + '=' +  EncodingUtil.urlEncode(parameters.get(key), 'UTF-8') + '&';
            }
        }

        sHttpBody = this.sHttpBody.substring(0, sHttpBody.length() - 1);
    }

    public void sendHttpRequest(string xmlBody) {
        Http httpObject = new Http();
        HttpRequest httpRequest = new HttpRequest();
        HttpResponse httpResponse;
        
        String username = gateway.Merchant_ID__c;
        String password = gateway.Security_Key__c;

        Blob headerValue = blob.valueOf(username + ':' + password);
        string authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        
        httpRequest.setHeader('Authorization', authorizationHeader);
        httpRequest.setHeader('Content-type', 'text/xml');
        
        httpRequest.setEndpoint(sHttpEndPoint);
        httpRequest.setMethod('POST');
        
        httpRequest.setTimeout(120000);
        httpRequest.setBody(xmlBody);
        
        if(!system.test.isRunningTest()) {
            httpResponse = httpObject.send(httpRequest);
            if(httpResponse.getStatusCode() == 401) {
                
                /*
                Modified By         : Rama Krishna   :13 Nov 2015   :INVOICEIT-629
                Comments         :  added if condition, always isGenericMethodCall then return result 
                                                otherwise add to Exception_Message__c field
                */
                if(isGenericMethodCall){
                    result.message = system.Label.AuthorizationRequired;
                    result.reloadPage = false;
                 }else{
                     transactionObj.Exception_Message__c = system.Label.AuthorizationRequired;
                 }
            } else if(httpResponse.getStatusCode() == 200) {
                //parse the xml and create key-value pair
                sRawHttpResponse = httpResponse.getBody();
                Dom.Document doc = httpResponse.getBodyDocument();
                Dom.XMLNode rootElement = doc.getRootElement();
                getElements(rootElement);
                handleRequest();
            } else {
                /*
                Modified By         : Rama Krishna   :13 Nov 2015   :INVOICEIT-629
                Comments          :  added if condition, always isGenericMethodCall then return result otherwise add to Exception_Message__c field                                     
                */
                if(isGenericMethodCall){
                    result.message = httpResponse.getStatus();
                    result.reloadPage = false;
                 }else{
                     transactionObj.Exception_Message__c = system.Label.AuthorizationRequired;
                 }
            }
            
        } else {
            
            string sSuccess = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Header><wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"><wsu:Timestamp xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" wsu:Id="Timestamp-501816472"><wsu:Created>2015-09-28T07:46:09.286Z</wsu:Created></wsu:Timestamp></wsse:Security></soap:Header><soap:Body><c:replyMessage xmlns:c="urn:schemas-cybersource-com:transaction-data-1.115"><c:merchantReferenceCode>acertiscloud_23</c:merchantReferenceCode><c:requestID>4434263683455000001521</c:requestID><c:decision>ACCEPT</c:decision><c:reasonCode>100</c:reasonCode><c:requestToken>Ahj/7wSR4MOKfLuc6HfiIkGLZowcsWjSlFqs5s1xCT+WejmnYBT+WejmnbSACkvDJpJlukB3NYkCcjwYcU+Xc50O/EAA+g9b</c:requestToken><c:purchaseTotals><c:currency>USD</c:currency></c:purchaseTotals><c:ccAuthReply><c:reasonCode>100</c:reasonCode><c:amount>0.00</c:amount><c:authorizationCode>888888</c:authorizationCode><c:avsCode>X</c:avsCode><c:avsCodeRaw>I1</c:avsCodeRaw><c:authorizedDateTime>2015-09-28T07:46:09Z</c:authorizedDateTime><c:processorResponse>100</c:processorResponse><c:reconciliationID>16409144REU3MM8B</c:reconciliationID></c:ccAuthReply><c:paySubscriptionCreateReply><c:reasonCode>100</c:reasonCode><c:subscriptionID>4434263683455000001521</c:subscriptionID></c:paySubscriptionCreateReply></c:replyMessage></soap:Body></soap:Envelope>';
            Dom.Document doc = new Dom.Document();
            doc.load(sSuccess);     
            Dom.XMLNode rootElement = doc.getRootElement();
            getElements(rootElement);
            handleRequest();
        }
    }  

    private void fillCardInformation() {
        

        parameters.put('x_bank_aba_code', paymentMethod.Bank_Routing_Code__c);
        parameters.put('x_bank_acct_num', paymentMethod.Bank_Account_Number__c);
        parameters.put('x_bank_acct_type', paymentMethod.Bank_Account_Type__c);
        parameters.put('x_bank_name', paymentMethod.Bank_Name__c);
        parameters.put('x_bank_acct_name', paymentMethod.Bank_Account_Name__c);
        parameters.put('x_echeck_type', 'CCD');
        parameters.put('x_method', 'ECHECK');
    }
    
    private void handleRequest() {
         transactionObj.Gateway_Date__c = system.now();
         string sResponseFromGateway;
         //if it is 0,then transaction is approved
         if(mapOfKeyValue.containsKey('c:replyMessage')) 
          if(mapOfKeyValue.containsKey('decision'))
         {
            sResponseFromGateway = mapOfKeyValue.get('decision');
            
            
            if(sResponseFromGateway == 'ACCEPT' || sResponseFromGateway == 'PENDING') 
            {
                result.reloadPage = true;
                transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED;
                transactionObj.Gateway_ID__c = mapOfKeyValue.get('requestID');
                transactionObj.Authorization__c = mapOfKeyValue.get('decision');
                transactionObj.Response_Code__c = mapOfKeyValue.get('reasonCode');
                transactionObj.Response__c = 'This transaction has been approved.';
            }
            else
            {
                result.reloadPage = false;

                String sReasonCode = mapOfKeyValue.get('reasonCode');

                  if(sReasonCode != null){
                      //ControllerForUpdateTokenForCyberSource controllerForUpdateTokenForCyberSource= new ControllerForUpdateTokenForCyberSource();
                      map<string,string> map_errorCodes = ControllerForUpdateTokenForCyberSource.errorCodeMessege();
                      transactionObj.Response_Status__c =  map_errorCodes.get(sReasonCode);
                  }else{
                    transactionObj.Response_Status__c= 'UnHandled Exception occured Please contact system administrator';
                  }
                
                transactionObj.Response_Code__c = mapOfKeyValue.get('reasonCode');
                transactionObj.Gateway_ID__c = mapOfKeyValue.get('requestID');
                transactionObj.Exception_Message__c = mapOfKeyValue.get('invalidField');

            }
         }
         else{
               
                    transactionObj.Response_Status__c = 'Security Data : UsernameToken authentication failed';
                    transactionObj.Response__c= 'Security Data : UsernameToken authentication failed'; 
                  
                  }
        /*
        Modified By        : Rama Krishna   :13 Nov 2015 :  INVOICEIT-629
        Comments        :  added if condition, always isGenericMethodCall set as true but we inkove generic method then this boolen will be set as false 
        */
        if(isGenericMethodCall){
        String sReasonCode1 = mapOfKeyValue.get('reasonCode');
            result.message =  system.label.transactioncreated;
         // for the site payment, if the the boolean is true dont insert transaction record
            if(!isSavePaymentMethod){
                 upsert transactionObj;
                
                 transactionObj = [SELECT Name, Response_Status__c, Amount__c, Response_Code__c, Transaction__c, Response_Message__c
                                   FROM Transaction__c
                                   WHERE Id =: transactionObj.Id];
                  if(sReasonCode1 != null){                   
                 result.message +=  transactionObj.Name + ' \n'
                                + 'Gateway Response : ' + transactionObj.Response_Code__c + ' \n'
                                + 'Gateway Status : ' + transactionObj.Response_Status__c;
                                }else{
                                result.message +=  transactionObj.Name + ' \n'
                                + 'Gateway Status : ' + transactionObj.Response_Status__c; 
                                }
                                
            }
             result.transactionObj = transactionObj; 
        }
    }
    
    private void getElements(DOM.XMLNode node) 
    {
      if(node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
        if(node.getText().trim() != '') {
            mapOfKeyValue.put(node.getName(), node.getText().trim());
        }

        for(Dom.XMLNode child : node.getChildElements()) {
            getElements(child);
        }
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