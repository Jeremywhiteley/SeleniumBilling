global with sharing class ControllerForGenerateTokenForCyberSource {

      global Account account {get;set;}
      global Payment_Method__c paymentMethod {get;set;}
      global Gateway__c gateway;
      Global string sMessege;
      global boolean isRedirectToAccount = true;

      public boolean isRender{get;set;}
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
      public map<string, string> mapOfKeyValue = new map<string, string>();
      
      
       global ControllerForGenerateTokenForCyberSource(ApexPages.StandardController stdController){
          this.account = (Account)stdController.getRecord();
          account = [Select Name, Id, Gateway__c,BillingStreet, BillingState, BillingPostalCode, BillingCountry, BillingCity, Website, Phone From Account WHERE Id =: this.account.Id];
          
          isRender = true;
          paymentMethod = new Payment_Method__c(Account__c = account.id);
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
            
         if(gateway.Gateway_Type__c != CommonUtilClass.GATEWAY_TYPE_CyberSource_CC_Token) {
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, system.label.BT_GatewayInfo));
            isRender = false;
         } 
         
      }
      

      global ControllerForGenerateTokenForCyberSource(){
        
      }
      
      global pagereference generateToken(){
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
                  Payment_Method__c paymentMethodTocheck;
                  if(paymentMethod.Default__c == true){
                      list<Payment_Method__c> paymentMethods = InvoicingUtilClass.getDefaultMethodForAccount(account.id);
                      if(!paymentMethods.isEmpty()) {
                          paymentMethodTocheck = paymentMethods.get(0);    
                          paymentMethodTocheck.Default__c = false;
                          paymentMethodTocheck.Active__c = false;
                          update paymentMethodTocheck;    
                      }                                      
                  }

                  paymentMethod.Payment_Profile_ID__c = mapOfKeyValue.get('subscriptionID');
                  paymentMethod.Name_on_Card__c = paymentMethod.Name_on_Card__c;
                  paymentMethod.Card_Type__c = paymentMethod.Card_Type__c;
                  paymentMethod.CVV__c = null;
                  if(paymentMethod.Card_Number__c != null){
                      paymentMethod.Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4));
                  }
                  paymentMethod.Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c;
                  paymentMethod.Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c;
                  insert paymentMethod;
                  
                  if(isRedirectToAccount){
                      pagereference ref = new pagereference('/'+account.id);
                      return ref;
                  }else{
                    return null;
                  }
                  
              }else{

                String sReasonCode = mapOfKeyValue.get('reasonCode');

                if(sReasonCode != null){
                    map<string,string> map_errorCodes = ControllerForUpdateTokenForCyberSource.errorCodeMessege();
                    Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, map_errorCodes.get(sReasonCode)));
                    sMessege =  map_errorCodes.get(sReasonCode);
                    return null;
                }else{
                   Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, system.Label.Authentication_Failed));
                  sMessege = system.Label.Authentication_Failed;
                 
                  return null;
                }
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
                '<accountNumber>' + paymentMethod.Card_Number__c + '</accountNumber>' +
                '<expirationMonth>' + paymentMethod.Card_Expiration_Month__c + '</expirationMonth>' +
                '<expirationYear>' + paymentMethod.Card_Expiration_Year__c + '</expirationYear>';
                //'<cardType>001</cardType>';
                 If (paymentMethod.Card_Type__c == 'VISA')
                 sRequestBody += '<cardType>001</cardType>';
                 If (paymentMethod.Card_Type__c == 'Mastercard')
                 sRequestBody += '<cardType>002</cardType>';
                 If (paymentMethod.Card_Type__c == 'American Express') 
                 sRequestBody +='<cardType>003</cardType>';
                 If (paymentMethod.Card_Type__c == 'Discover') 
                 sRequestBody +='<cardType>004</cardType>';
                 
                 sRequestBody +='</card>' +
                '<recurringSubscriptionInfo>' +
                '<frequency>on-demand</frequency>' +
                '</recurringSubscriptionInfo>' +
                '<paySubscriptionCreateService run="true"/>' +
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
  }