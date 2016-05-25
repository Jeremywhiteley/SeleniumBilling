global with sharing class ControllerForUpdateTokenForCyberSource {
   public list<paymentMethodWrapper> listOfPaymentMethodWrapper{get;set;}
   public list<Payment_Method__c> listOfPaymentMethod;
   PaymentMethodWrapper paymentMethodWrapper;
   Gateway__c gateWayToUse;
   public boolean isVisible {get;set;}
    global Account account {get;set;}
    global Payment_Method__c paymentMethod {get;set;}
    global Gateway__c gateway;
    public boolean isRender{get;set;}

    Global string sMessege;
    global boolean isRedirectToAccount = true;
   
    private string sHttpEndPoint = '';
    private string MERCHANT_KEY = '';
    private string PUBLIC_KEY = '';
    private String sFirstName = '';
    private String sLastName = '';
    private String sAddress1 = '';
    private String sCity = '';
    private String sZipCode = '';
    private String sState = '';
    private String sCountry = '';
    private String sEmail = '';
    private String sPhone = '';
    
    string sRawHttpResponse;
    global String selectedValue { get; set; }
    private String UpdateTokenForCyberSource_Page2 = 'UpdateTokenForCyberSource_Page2';
    public map<string, string> mapOfKeyValue = new map<string, string>();

global ControllerForUpdateTokenForCyberSource(ApexPages.StandardController stdController) {
 this.account = (Account)stdController.getRecord();
        account = [Select Name, Id, Gateway__c,BillingStreet, BillingState, BillingPostalCode, BillingCountry, BillingCity, Website, Phone From Account WHERE Id =: this.account.Id];
        listOfPaymentMethodWrapper = new list<paymentMethodWrapper>();
        isRender = true;
        listOfPaymentMethod = new list<Payment_Method__c>();
        paymentMethod = new Payment_Method__c(Account__c = this.account.id);
        
        
        list<Gateway__c> listOfGateway = new list<Gateway__c>();
           if(account.Gateway__c == null) {
                listOfGateway = InvoicingUtilClass.getDefaultGateway();
                if(!listOfGateway.isEmpty()){
                    gateway = listOfGateway.get(0);   
                }else{
                    Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.WARNING, system.Label.Gateway_Warning));
                    isRender = false;
                    return;
                }   
           } else {
               gateway = InvoicingUtilClass.getGateway(account.Gateway__c);
           }
          
       if(gateway.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_CyberSource_CC_Token && isRedirectToAccount) {
       listOfPaymentMethod = [SELECT Card_Number__c, Card_Type__c, Card_Expiration_Month__c, Card_Expiration_Year__c, CVV__c, Name_on_Card__c, Billing_Country__c,
                                           Bank_Routing_Code__c, Bank_Account_Number__c, Bank_Account_Type__c, Bank_Name__c, Bank_Account_Name__c,
                                           Billing_First_Name__c, Billing_Last_Name__c, Billing_Address__c, Billing_City__c, Billing_State_Province__c, Billing_Zip_Postal__c ,
                                           Account__c, Account__r.Name, Billing_Phone__c, Billing_Fax__c, Billing_Email__c,Payment_Profile_ID__c,Account__r.Customer_Profile_ID__c  
                                           ,Encrypted_Card_Number__c,Encrypted_CVV__c ,Token__c
                                           FROM Payment_Method__c 
                                           WHERE
                                           Account__c =: this.account.id
                                           AND
                                           Active__c = true
                                           AND
                                           Payment_Profile_ID__c != null
                                           AND
                                           Is_Dummy__c = false
                                                                                
                                           AND
                                           Payment_Method__c = 'Credit Card'];
                                           isVisible = true;
       
          isRender = false;
       } 
       if(!listOfPaymentMethod.isEmpty()) {
       for(Payment_Method__c paymentMethod : listOfPaymentMethod) {
                        paymentMethodWrapper = new PaymentMethodWrapper(paymentMethod.Id);
                        paymentMethodWrapper.paymentMethod = paymentMethod;
                        listOfPaymentMethodWrapper.add(paymentMethodWrapper);
                    }
              }
    }

    global PageReference step2() {  
    if(selectedValue != '' && selectedValue != null){
     paymentMethod =  [SELECT Card_Number__c, Card_Type__c, Card_Expiration_Month__c, Card_Expiration_Year__c, CVV__c, Name_on_Card__c, Billing_Country__c,
                                           Bank_Routing_Code__c, Bank_Account_Number__c, Bank_Account_Type__c, Bank_Name__c, Bank_Account_Name__c,
                                           Billing_First_Name__c, Billing_Last_Name__c, Billing_Address__c, Billing_City__c, Billing_State_Province__c, Billing_Zip_Postal__c ,
                                           Account__c, Account__r.Name, Billing_Phone__c, Billing_Fax__c, Billing_Email__c,Payment_Profile_ID__c,Account__r.Customer_Profile_ID__c  
                                           ,Encrypted_Card_Number__c,Encrypted_CVV__c ,Token__c,Default__c 
                                           FROM Payment_Method__c 
                                           WHERE
                                           Account__c =: this.account.id AND id =: selectedValue];
      }else{
          Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, system.label.Selectonecard));
          return null;
      }                                     
      return page.UpdateTokenForCyberSource_Page2;
    }
    
    
  global pagereference updateToken(){
         try {
           this.MERCHANT_KEY = gateway.Merchant_ID__c;
           this.PUBLIC_KEY = gateway.Security_Key__c;

            populateCustomerDetails();
            //Framing request body
            string sRequestBody = frameHttpRequestData(gateway,paymentMethod);
            //call the exteernal system  
            sendHttpRequest(sRequestBody,gateway);  
            if(mapOfKeyValue.get('decision') == 'ACCEPT' && mapOfKeyValue.get('decision') != null){
                sMessege = 'Success';
                paymentMethod.Payment_Profile_ID__c = mapOfKeyValue.get('subscriptionID');
                paymentMethod.Name_on_Card__c = paymentMethod.Name_on_Card__c;
                paymentMethod.Card_Type__c = paymentMethod.Card_Type__c;
                paymentMethod.CVV__c = null;
                
                if(paymentMethod.Card_Number__c != null){
                    paymentMethod.Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4));
                }
                
                paymentMethod.Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c;
                paymentMethod.Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c;
                
                update paymentMethod;
                
                if(isRedirectToAccount){
                    pagereference ref = new pagereference('/'+account.id);
                    return ref;
                }else{
                  return null;
                }

            }else{
              String sReasonCode = mapOfKeyValue.get('reasonCode');

              if(sReasonCode != null){
                  map<string,string> map_errorCodes = errorCodeMessege();
                  Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, map_errorCodes.get(sReasonCode)));
                  sMessege =  map_errorCodes.get(sReasonCode);
                  return null;
              }else{
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, system.label.Authentication_Failed));
                sMessege = system.label.Authentication_Failed;
                
                return null;
              }
              return null;
            }  
          
        }catch(Exception ex) {
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
             return null;
        }    
         
       return null;
    }
    
     public void sendHttpRequest(string requestBody, Gateway__c gateway) {
        Http httpObject = new Http();
        HttpRequest httpRequest = new HttpRequest();
        HttpResponse httpResponse;
        
        String username = gateway.Merchant_ID__c;
        String password = gateway.Security_Key__c;
        
        if(gateway.Test_Mode__c) {
            sHttpEndPoint = CommonUtilClass.ENDPOINT_CyberSource_CC_Token_TEST;
        }else{
            sHttpEndPoint = CommonUtilClass.ENDPOINT_CyberSource_CC_Token_LIVE;
        }
        
             
        Blob headerValue = blob.valueOf(username + ':' + password);
        string tokenisationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        
        httpRequest.setHeader('Tokenisation', tokenisationHeader);
        httpRequest.setHeader('Content-type', 'text/xml');
        
        httpRequest.setEndpoint(sHttpEndPoint);
        httpRequest.setMethod('POST');
       
        httpRequest.setTimeout(120000);
        
        httpRequest.setBody(requestBody);
        
        if(!system.test.isRunningTest()) {
            httpResponse = httpObject.send(httpRequest);
            if(httpResponse.getStatusCode() == 401) {

            } else if(httpResponse.getStatusCode() == 200) {
                //parse the xml and create key-value pair
                sRawHttpResponse = httpResponse.getBody();
                Dom.Document doc = httpResponse.getBodyDocument();
                Dom.XMLNode rootElement = doc.getRootElement();
                getElements(rootElement);
            } else {

            }

        } else {
            string sSuccess = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Header><wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"><wsu:Timestamp xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" wsu:Id="Timestamp-501816472"><wsu:Created>2015-09-28T07:46:09.286Z</wsu:Created></wsu:Timestamp></wsse:Security></soap:Header><soap:Body><c:replyMessage xmlns:c="urn:schemas-cybersource-com:transaction-data-1.115"><c:merchantReferenceCode>acertiscloud_23</c:merchantReferenceCode><c:requestID>4434263683455000001521</c:requestID><c:decision>ACCEPT</c:decision><c:reasonCode>100</c:reasonCode><c:requestToken>Ahj/7wSR4MOKfLuc6HfiIkGLZowcsWjSlFqs5s1xCT+WejmnYBT+WejmnbSACkvDJpJlukB3NYkCcjwYcU+Xc50O/EAA+g9b</c:requestToken><c:purchaseTotals><c:currency>USD</c:currency></c:purchaseTotals><c:ccAuthReply><c:reasonCode>100</c:reasonCode><c:amount>0.00</c:amount><c:authorizationCode>888888</c:authorizationCode><c:avsCode>X</c:avsCode><c:avsCodeRaw>I1</c:avsCodeRaw><c:authorizedDateTime>2015-09-28T07:46:09Z</c:authorizedDateTime><c:processorResponse>100</c:processorResponse><c:reconciliationID>16409144REU3MM8B</c:reconciliationID></c:ccAuthReply><c:paySubscriptionCreateReply><c:reasonCode>100</c:reasonCode><c:subscriptionID>4434263683455000001521</c:subscriptionID></c:paySubscriptionCreateReply></c:replyMessage></soap:Body></soap:Envelope>';
            Dom.Document doc = new Dom.Document();
            doc.load(sSuccess);     
            Dom.XMLNode rootElement = doc.getRootElement();
            getElements(rootElement);
        }
    }
    
    

            
    public string frameHttpRequestData(Gateway__c gateway, Payment_Method__c paymentMethod){
        populateCustomerDetails();
        string sRequestBody = '<?xml version="1.0" encoding="UTF-8"?>' +
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
      
              '<billTo>' +
              '<firstName>' + sFirstName + '</firstName>' +
              '<lastName>' + sLastName + '</lastName>' +
              '<street1>' + sAddress1 + '</street1>' +
              '<city>' + sCity + '</city>' +
              '<state>' + sState + '</state>' +
              '<postalCode>' + sZipCode + '</postalCode>' +
              '<country>' + sCountry + '</country>' +
              '<email>' + sEmail + '</email>' +
              '</billTo>' +
              '<purchaseTotals>' +
              '<currency>USD</currency>' +
              '</purchaseTotals>' +
              '<card>' +
              //'<accountNumber>' + paymentMethod.Card_Number__c + '</accountNumber>' +
              '<expirationMonth>' + paymentMethod.Card_Expiration_Month__c + '</expirationMonth>' +
              '<expirationYear>' + paymentMethod.Card_Expiration_Year__c + '</expirationYear>';
              //'<cardType>001</cardType>';
               If (paymentMethod.Card_Type__c == 'Visa')
               sRequestBody += '<cardType>001</cardType>';
               If (paymentMethod.Card_Type__c == 'Mastercard')
               sRequestBody += '<cardType>002</cardType>';
               If (paymentMethod.Card_Type__c == 'American Express') 
               sRequestBody +='<cardType>003</cardType>';
               If (paymentMethod.Card_Type__c == 'Discover') 
               sRequestBody +='<cardType>004</cardType>';
               
               sRequestBody +='</card>' +
              '<recurringSubscriptionInfo>' +
              //'<frequency>on-demand</frequency>' +
              '<subscriptionID>' + paymentMethod.Payment_Profile_ID__c + '</subscriptionID>' +
              '</recurringSubscriptionInfo>' +
              //'<paySubscriptionCreateService run="true"/>' +
              '<paySubscriptionUpdateService run="true"/>' +
              '</requestMessage>' +
              '</s:Body>' +
              '</s:Envelope>';
              
        return sRequestBody;
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
    public class PaymentMethodWrapper {
        public Payment_Method__c paymentMethod{get;set;}
        public String Value { get; set; }

        public paymentMethodWrapper(String Value) {
            paymentMethod = new Payment_Method__c();
            this.Value = Value;
        }
    }

public static map<string,string> errorCodeMessege(){
        map<string,string> map_errorCodes = new map<string,string>();

        map_errorCodes.put('100','Successful transaction');
        map_errorCodes.put('101','The request is missing one or more required fields.Possible action: see the reply fields missingField_0...N for which fields are missing. Resend the request with the complete information. For information about missing or invalid fields');
        map_errorCodes.put('102','Invalid data');
        map_errorCodes.put('110','Partial amount approved');
        map_errorCodes.put('150','General system failure');
        map_errorCodes.put('151','This error does not include timeouts between the client and the server.To avoid duplicating the transaction, do not resend the request until you have reviewed the transaction status at the Business Center');
        map_errorCodes.put('152','The request was received, but a service did not finish running in time.To avoid duplicating the transaction, do not resend the request until you have reviewed the transaction status at the Business Center');
        map_errorCodes.put('200','The authorization request was approved by the issuing bank but declined by CyberSource because it did not pass the AVS check');
        map_errorCodes.put('201','The issuing bank has questions about the request. You will not receive an authorization code programmatically, but you can obtain one verbally by calling the processor');
        map_errorCodes.put('202','Expired card');
        map_errorCodes.put('203','General decline of the card');
        map_errorCodes.put('204','Insufficient funds in the account');
        map_errorCodes.put('205','Stolen or lost card');
        map_errorCodes.put('207','Issuing bank unavailable');
        map_errorCodes.put('208','Inactive card or card not authorized for card-not-present transactions');
        map_errorCodes.put('210','The card has reached the credit limit');
        map_errorCodes.put('211','Invalid card verification number');
        map_errorCodes.put('220','The processor declined the request based on a general issue with the customer’s account');
        map_errorCodes.put('221','The customer matched an entry on the processor’s negative file');
        map_errorCodes.put('231','Invalid account number Possible action: Request a different card or other form of payment ');
        map_errorCodes.put('236','Processor failure');
        map_errorCodes.put('240','The card type sent is invalid or does not correlate with the card number');


        map_errorCodes.put('104','The merchant reference code for this authorization request matches the merchant reference code of another authorization request that you sent within the past 15 minutes');
        map_errorCodes.put('209','CVN did not match');
        map_errorCodes.put('232','The card type is not accepted by the payment processor');
        map_errorCodes.put('234','There is a problem with the information in your CyberSource account');
        map_errorCodes.put('235','The requested capture amount exceeds the originally authorized amount');
        map_errorCodes.put('237','The authorization has already been reversed');
        map_errorCodes.put('238','The authorization has already been captured');
        map_errorCodes.put('239','The requested transaction amount must match the previous transaction amount');
        map_errorCodes.put('240','The card type sent is invalid or does not correlate with the credit card number');
        map_errorCodes.put('241','The request ID is invalid');
        map_errorCodes.put('242','You requested a capture, but there is no corresponding, unused authorization record. Occurs if there was not a previously successful authorization request or if the previously successful authorization has already been used by another capture request');
        map_errorCodes.put('243','The transaction has already been settled or reversed');
        map_errorCodes.put('246','One of the following- The capture or credit is not voidable because the capture or credit information has already been submitted to your processor or You requested a void for a type of transaction that cannot be voided');
        map_errorCodes.put('247','You requested a credit for a capture that was previously voided');
        map_errorCodes.put('250','The request was received, but there was a timeout at the payment processor.');
        map_errorCodes.put('254','Stand-alone credits are not allowed');

        map_errorCodes.put('222','The customer bank account is frozen');
        map_errorCodes.put('223','The customer payment or credit has been declined. This could relate to an existing duplicate check, the original transaction was not approved, or a valid authorization could not be located');
        map_errorCodes.put('233','The processor declined the request based on an issue with the request itself');
        map_errorCodes.put('234','There is a problem with your merchant configuration');
        map_errorCodes.put('246','The debit or credit is not voidable because the debit or credit information has already been submitted to your processor');
        map_errorCodes.put('247','You requested a credit for a debit that was previously voided');
        map_errorCodes.put('250','Error: The request was received, but there was a timeout at the payment processor');
        map_errorCodes.put('388','Error: The routing number did not pass verification');

    return map_errorCodes;

 }

}