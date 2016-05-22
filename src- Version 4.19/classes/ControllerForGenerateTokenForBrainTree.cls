public with sharing class ControllerForGenerateTokenForBrainTree {
         
        public Account account {get;set;}
        public Payment_Method__c paymentMethod {get;set;}
        public boolean isRender{get;set;}
        private string sHttpEndPoint = '';
        private string MERCHANT_KEY = '';
        private string PUBLIC_KEY = '';
        private string PRIVATE_KEY = '';
        Gateway__c gateway;
        
        public ControllerForGenerateTokenForBrainTree(ApexPages.StandardController stdController){
            this.account = (Account)stdController.getRecord();
            account = [Select Name, Id, BrainTree_Customer_ID__c, Gateway__c,BillingStreet, BillingState, BillingPostalCode, BillingCountry, BillingCity, Website, Phone From Account WHERE Id =: this.account.Id];
            paymentMethod = new Payment_Method__c();
            isRender = true;
            
            paymentMethod.Account__c = account.id;
            
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
              
           if(gateway.Gateway_Type__c != CommonUtilClass.GATEWAY_TYPE_BRAINTREE) {
              Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, system.label.BT_GatewayInfo));
              isRender = false;
           } 
        }
        
        public pagereference generateToken(){
             try {
                  this.MERCHANT_KEY = gateway.Merchant_ID__c;
                  this.PUBLIC_KEY = gateway.Security_Key__c;
                  this.PRIVATE_KEY = gateway.Exact_ID_Security_Key__c;
                  
                // sandbox and live, using common endpoint Url
                //this determines is it sandbox or live
                if(gateway.Test_Mode__c) {
                    sHttpEndPoint = CommonUtilClass.ENDPOINT_BRAINTREE_SANDBOX;
                }else{
                    sHttpEndPoint = CommonUtilClass.ENDPOINT_BRAINTREE_PRODUCTION;
                }

                if(account.BrainTree_Customer_ID__c == null){
                    sHttpEndPoint = sHttpEndPoint + '/token/create';
                }else{
                    sHttpEndPoint = sHttpEndPoint + '/customer/token';
                }
                
                //Framing request body
                string sRequestBody = frameHttpRequestData();
                //call the exteernal system  
                sendHttpRequest(sRequestBody,sHttpEndPoint);  
                    
                if(parameters.get(system.Label.success) == system.Label.true && parameters.get(system.Label.success) != null){
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
                    
                    paymentMethod.Payment_Profile_ID__c = parameters.get(system.Label.customerId);
                    paymentMethod.Token__c = parameters.get(system.Label.token);
                    paymentMethod.Encrypted_Card_Number__c = parameters.get(system.Label.uniqueNumberIdentifier);

                    paymentMethod.Name_on_Card__c = null;
                    paymentMethod.Card_Type__c = null;
                    paymentMethod.CVV__c = null;
                    if(paymentMethod.Card_Number__c != null){
                        paymentMethod.Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4));
                    }
                    
                    paymentMethod.Card_Expiration_Month__c = null;
                    paymentMethod.Card_Expiration_Year__c = null;

                    insert paymentMethod;
                    
                    if(account.BrainTree_Customer_ID__c == null){
                        Account accountObj = new Account(Id = account.Id, BrainTree_Customer_ID__c = parameters.get(system.Label.customerId));
                        upsert accountObj;
                    }
                    
                    pagereference ref = new pagereference('/'+account.id);
                    return ref;
                }else{
                    Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, system.Label.GATEWAY_ERROR + parameters.get(system.Label.message)));
                    return null;
                }
             }catch(Exception ex) {
                 Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                 return null;
            }    
             
           return null;
        }
        
        private map<string, string> parameters;
        public void sendHttpRequest(string requestBody,String endpoint){
            parameters = new map<string, string>();
            if(!system.test.isRunningTest()) {
                HttpRequest req = new HttpRequest();
                req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                req.setEndpoint(endpoint);
                req.setMethod('POST');
                req.setBody(requestBody);
                req.setTimeout(20*1000);
                Http h = new Http();
                HttpResponse res = h.send(req);
                string sHttpResponseBody = res.getBody();
                if((sHttpResponseBody.contains(system.Label.token) 
                        || sHttpResponseBody.contains(system.Label.success) 
                        || sHttpResponseBody.contains(system.Label.creditCard) 
                        || sHttpResponseBody.contains(system.Label.uniqueNumberIdentifier) 
                         ) && sHttpResponseBody != null
                        ){
                   
               Map<String, Object> map_JsonString  = (Map<String, Object>)JSON.deserializeUntyped(sHttpResponseBody);
               Map<String, Object>  mapchildObject = (Map<String, Object>)map_JsonString.get(system.Label.token);
                
                for(String s : mapchildObject.keyset()){
                    Map<String, Object>  mapchildObjectNew = (Map<String, Object>)mapchildObject.get(system.Label.creditCard);
                    parameters.put(system.Label.success,string.valueof((boolean)mapchildObject.get(system.Label.success)));
                    if(parameters.get(system.Label.success) == system.Label.true){
                         for(String s1 : mapchildObjectNew.keyset()){
                            parameters.put(system.Label.token,string.valueof((string)mapchildObjectNew.get(system.Label.token)));
                            parameters.put(system.Label.uniqueNumberIdentifier,string.valueof((string)mapchildObjectNew.get(system.Label.uniqueNumberIdentifier)));
                            parameters.put(system.Label.customerId,string.valueof((string)mapchildObjectNew.get(system.Label.customerId)));
                      }
                    }else{
                        parameters.put(system.Label.message,string.valueof((string)mapchildObject.get(system.Label.message)));
                    }
                } 
                }else{
                    Map<String, Object> map_JsonString = (Map<String, Object>)JSON.deserializeUntyped(sHttpResponseBody);
                    parameters.put(system.Label.message,(string)map_JsonString.get(System.Label.Error));

                } 
            } else {
                 parameters.put(string.valueof(system.Label.success),system.Label.true);
                 parameters.put(System.Label.processorResponseCode,'1000');
                 parameters.put(System.Label.processorAuthorizationCode,'000000');
                 parameters.put(System.Label.processorResponseText,System.Label.Approved);
                 parameters.put(System.Label.id,'3g278y');
            }
        } 
        
        public string frameHttpRequestData(){
            string sRequestBody = 'merchant=' + MERCHANT_KEY +'&publickey='+PUBLIC_KEY+'&privatekey='+PRIVATE_KEY;
            if(paymentMethod.Card_Number__c != null){
                sRequestBody += '&cardno='+paymentMethod.Card_Number__c;
            }
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
            //Check whether it is pointing to production or sandbox
            if(gateway.Test_Mode__c) {
                sRequestBody += '&environment=Sandbox';
            } else {
                sRequestBody += '&environment=Production';
            }
            //starting of payment method basic info
            if(account.Name != null) 
               sRequestBody += '&c_fname='+account.Name;
            if(account.Name != null) 
                sRequestBody += '&c_company='+account.Name;
            if(account.website != null) 
                sRequestBody += '&c_website='+account.website;
            if(account.Phone != null) 
               sRequestBody += '&c_phone='+account.Phone; 
            // ending of payment details
            
            // this is to identify the customer id to store the details
            if(account.BrainTree_Customer_ID__c != null)
                sRequestBody += '&customerId='+account.BrainTree_Customer_ID__c; 
            // starting of customer details    
            if(account.Name != null)
                sRequestBody += '&b_fname='+account.Name; 
            if(account.BillingStreet != null)
               sRequestBody += '&b_street='+account.BillingStreet; 
            if(account.BillingCity != null)
                sRequestBody += '&b_city='+account.BillingCity; 
            if(account.BillingState != null)
                sRequestBody += '&b_state='+account.BillingState; 
            if(account.BillingPostalCode != null)
                sRequestBody += '&b_postal='+account.BillingPostalCode; 
            if(account.BillingCountry != null)
               sRequestBody += '&b_country='+account.BillingCountry; 
            // ending of customer details

            return sRequestBody;
        }
    }