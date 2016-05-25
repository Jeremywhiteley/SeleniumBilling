/**
   * Webservice for handling payments using Authorized.net CIM.
   * @author Ankit Sharma,Acertis Cloud Ltd
     Copyright (c) 2011, Acertis Cloud, Salesforce.com Inc.
     All rights reserved.
   */
   
  /*
   
   Host Addresses
          Use the following host addresses for the authorize.net:
          1 For live transactions, use https://api.authorize.net/xml/v1/request.api
          2 For testing purposes, use https://apitest.authorize.net/xml/v1/request.api
          
  Attributes :
      
      Customer Profile ID(Required)
      
      Payment Profile ID(Required)
        
      Amount(Required)
      
      CVV(A conditional (con.) message field must be included in some instances. Its omission may cause the process request type to be rejected)
      
      -American Express Test Card: 370000000000002
      - Discover Test Card: 6011000000000012
      - Visa Test Card: 4007000000027
      - Second Visa Test Card: 4012888818888
      - JCB: 3088000000000017
      - Diners Club/ Carte Blanche: 38000000000006
  */ 

  public with sharing class ClassForHandlingAuthorizeDotNetCIM implements InterfacePaymentClass.paymentOperationsInterface{
      
      private string sHttpEndPoint = '';
      private Payment_Method__c paymentMethod;
      private Gateway__c gateway;
      private Account account;
      private Invoice__c invoice = new Invoice__c();
      private Transaction__c transactionObj;
      private list<string> responseArray = new list<string>();
      private string sDummyPaymentId;
      private decimal dAmount;
      private Id currencyId;
      string sRawHttpResponse;
      map<string, string> mapOfKeyValue = new map<string, string>();    
      private ControllerForPaymentMethod.ProfileResult controllerResult = new ControllerForPaymentMethod.ProfileResult();
      private PaymentOperations.PaymentResult result = new PaymentOperations.PaymentResult();
      private boolean fromSite = true;
      private Payment_Method__c  paymentProfile;    

      private boolean isGenericMethodCall = true;
      
      //initialize constructor 
      public ClassForHandlingAuthorizeDotNetCIM(Gateway__c gateway, Payment_Method__c paymentMethod, Account account, Invoice__c invoice) {
          
          this.paymentMethod = paymentMethod;
          this.gateway = gateway;
          this.account = account;
          this.invoice = invoice;  
          //Added by dhanalakshmi for INVOICEIT-18
          if(invoice == null)
          {
              this.invoice = new Invoice__c();
          } 
               
          initialize();
      }
      // This used for Force.com site and Virtualterminal Purpose
      public ClassForHandlingAuthorizeDotNetCIM(Gateway__c gateway, Invoice__c invoice, Payment_Method__c paymentMethod, string sDummyPaymentId, decimal dAmount,Account account,Id currencyId) {
          
          this.invoice = invoice;     
          this.account = account;
          this.dAmount = dAmount;
          this.paymentMethod = paymentMethod;
          this.gateway = gateway;
          this.sDummyPaymentId = sDummyPaymentId;
          this.currencyId = currencyId;

          initialize();
      }
      
      private void initialize() {
          
          if(gateway.Test_Mode__c) {
              sHttpEndPoint = CommonUtilClass.ENDPOINT_AUTHORIZEDOTNETCIM_TEST;
          } else {
              sHttpEndPoint = CommonUtilClass.ENDPOINT_AUTHORIZEDOTNETCIM_LIVE;
          }    
          
      }
      
      
      //method for creating customer profile
      public ControllerForPaymentMethod.ProfileResult handleCustomerProfileCreation() {
          try {
               string customerProfileXmlRequest = '<?xml version="1.0" encoding="utf-8" ?>' + 
                                  '<createCustomerProfileRequest xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">' + 
                                      '<merchantAuthentication>' + 
                                          '<name>'+ gateway.Exact_ID__c + '</name>' +
                                          '<transactionKey>'+ gateway.Exact_ID_Security_Key__c + '</transactionKey>' + 
                                      '</merchantAuthentication>' + 
                                      '<profile>'+ 
                                          '<merchantCustomerId>'+ account.id +'</merchantCustomerId>' +                                                            
                                      '</profile>'+
                                  '</createCustomerProfileRequest>';       
                sendHttpRequest(customerProfileXmlRequest);   
                if(mapOfKeyValue.get('code') == 'I00001' && mapOfKeyValue.get('customerProfileId') != null && mapOfKeyValue.get('resultCode') == 'Ok'){
                    String sCustomerProfileId = mapOfKeyValue.get('customerProfileId');
                    mapOfKeyValue = new map<string, string>();              
                    controllerResult = handlePaymentProfileCreation(sCustomerProfileId);
                    if(controllerResult.messageCode == 'I00001' && controllerResult.resultCode  == 'Ok'){
                        account.Customer_Profile_ID__c = sCustomerProfileId;
                        if(fromSite){
                          update account;
                        }                                        
                    }               
                }else{
                    result.message = mapOfKeyValue.get('text');
                    controllerResult.resultCode =  mapOfKeyValue.get('resultCode');
                    controllerResult.messageCode = mapOfKeyValue.get('code');
                    controllerResult.messageText = mapOfKeyValue.get('text');                           
                }
          } catch(Exception ex) {         
              controllerResult.messageText = ex.getMessage();                 
          }
          return controllerResult;
      }
      //method for creating customer payment profile
      public ControllerForPaymentMethod.ProfileResult handlePaymentProfileCreation(string sCustomerProfileId) {     
           try {
               String paymentProfileXmlRequest = '<?xml version="1.0" encoding="utf-8"?>'+
                                                  '<createCustomerPaymentProfileRequest xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">' +
                                                    '<merchantAuthentication>'+
                                                      '<name>'+ gateway.Exact_ID__c +'</name>'+
                                                      '<transactionKey>'+ gateway.Exact_ID_Security_Key__c +'</transactionKey>'+
                                                    '</merchantAuthentication>'+
                                                    '<customerProfileId>'+ sCustomerProfileId +'</customerProfileId>'+
                                                    '<paymentProfile>'+                                               
                                                      '<billTo>'+                               
                                                        '<firstName>'+ paymentMethod.Billing_First_Name__c +'</firstName>'+
                                                        '<lastName>'+ paymentMethod.Billing_Last_Name__c +'</lastName>';
                 if(paymentMethod.Billing_Address__c != null){                                                  
                      paymentProfileXmlRequest += '<address>'+ paymentMethod.Billing_Address__c +'</address>';
                 }
                 if(paymentMethod.Billing_City__c != null){                                                 
                      paymentProfileXmlRequest += '<city>'+ paymentMethod.Billing_City__c +'</city>';
                 }
                 if(paymentMethod.Billing_State_Province__c != null){                                               
                      paymentProfileXmlRequest += '<state>'+ paymentMethod.Billing_State_Province__c +'</state>';
                 }
                 if(paymentMethod.Billing_Zip_Postal__c != null){                                               
                      paymentProfileXmlRequest += '<zip>'+ paymentMethod.Billing_Zip_Postal__c +'</zip>';
                 }
                 if(paymentMethod.Billing_Country__c != null){                                                  
                      paymentProfileXmlRequest += '<country>'+ paymentMethod.Billing_Country__c +'</country>';
                 }
                 if(paymentMethod.Billing_Phone__c != null){                                                
                      paymentProfileXmlRequest += '<phoneNumber>'+ paymentMethod.Billing_Phone__c +'</phoneNumber>';
                 }
                 
                 paymentProfileXmlRequest +=  '</billTo>'+
                                              '<payment>'+
                                                '<creditCard>'+
                                                  '<cardNumber>'+ paymentMethod.Card_Number__c +'</cardNumber>'+
                                                  '<expirationDate>'+ paymentMethod.Card_Expiration_Year__c+'-'+ paymentMethod.Card_Expiration_Month__c +'</expirationDate>'+
                                                  '<cardCode>'+ paymentMethod.CVV__c +'</cardCode>'+                                   
                                                '</creditCard>'+                                                                
                                              '</payment>'+
                                            '</paymentProfile>';
                 if(gateway.Test_Mode__c){                                                  
                      paymentProfileXmlRequest += '<validationMode>testMode</validationMode>';
                 }else{
                      paymentProfileXmlRequest += '<validationMode>liveMode</validationMode>';    
                 }
                            
                 paymentProfileXmlRequest +=  '</createCustomerPaymentProfileRequest>';                
                 sendHttpRequest(paymentProfileXmlRequest);
                 
                 if(mapOfKeyValue.get('code') == 'I00001' && mapOfKeyValue.get('customerPaymentProfileId') != null && mapOfKeyValue.get('resultCode') == 'Ok'){
                    paymentProfile = new Payment_Method__c ();
                    paymentMethod.Payment_Profile_ID__c = mapOfKeyValue.get('customerPaymentProfileId');
                    paymentProfile.Account__c = account.id;
                    paymentProfile.Payment_Profile_ID__c = mapOfKeyValue.get('customerPaymentProfileId');
                    paymentProfile.Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4));
                    paymentProfile.Default__c = paymentMethod.Default__c;
                    paymentProfile.Active__c = true;
                    if(fromSite){
                      insert paymentProfile;
                    }              
                    controllerResult.resultCode =  mapOfKeyValue.get('resultCode');
                    controllerResult.messageCode = mapOfKeyValue.get('code');
                    controllerResult.messageText = mapOfKeyValue.get('text');                 
                }else{
                      if(account.Customer_Profile_ID__c == null){
                        account.Customer_Profile_ID__c = sCustomerProfileId;  
                        update account;
                      }   
                    result.message = mapOfKeyValue.get('text');
                    controllerResult.resultCode =  mapOfKeyValue.get('resultCode');
                    controllerResult.messageCode = mapOfKeyValue.get('code');
                    controllerResult.messageText = mapOfKeyValue.get('text');                                 
                }
            } catch(Exception ex) {           
                controllerResult.messageText = ex.getMessage();       
            }
            
            return controllerResult;                         
      }
      // This method for Authorization 
      public PaymentOperations.PaymentResult handleAuthorize_Click() {
          try {
              fromSite = false;
              decimal amountToBeProcessed = 0;
              
              if(invoice.Payment_Request_Amount__c != null && invoice.Payment_Request_Amount__c > 0 && invoice.Payment_Request_Amount__c < invoice.Unpaid_Amount__c) {
                  amountToBeProcessed = invoice.Payment_Request_Amount__c;            
              } else {
                  amountToBeProcessed = invoice.Unpaid_Amount__c;         
              }
              string authorizationXmlRequest = '<?xml version="1.0" encoding="utf-8"?>'+
                                          '<createCustomerProfileTransactionRequest xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">'+
                                              '<merchantAuthentication>'+
                                                  '<name>'+ gateway.Exact_ID__c +'</name>'+
                                                  '<transactionKey>'+ gateway.Exact_ID_Security_Key__c + '</transactionKey>'+
                                              '</merchantAuthentication>'+
                                              '<transaction>'+
                                                  '<profileTransAuthOnly>'+
                                                  '<amount>'+ amountToBeProcessed +'</amount>'+                                
                                                  '<customerProfileId>'+ paymentMethod.Account__r.Customer_Profile_ID__c +'</customerProfileId>'+
                                                  '<customerPaymentProfileId>'+ paymentMethod.Payment_Profile_ID__c +'</customerPaymentProfileId>'+
                                                  '<order>'+
                                                      '<invoiceNumber>'+ invoice.Name +'</invoiceNumber>'+
                                                      '<description>'+ 'SalesForce Id : ' + invoice.Id + ' and Invoice Number : ' + invoice.Name +'</description>'+                                
                                                  '</order>'+                             
                                                  '</profileTransAuthOnly>'+
                                              '</transaction>'+  
                                          '</createCustomerProfileTransactionRequest>';
              
              transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, Type__c = CommonUtilClass.TRANSACTION_TYPE_AUTHORIZATION, Amount__c = amountToBeProcessed, Currency__c = invoice.CurrencyL__c, Is_Payment_Processed_Successfully__c = true, Payment_Gateway__c = gateway.Id);
              transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
              transactionObj.Request_Invoice__c = invoice.Id;
              transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
              transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_AUTHORIZATION;            
              sendHttpRequest(authorizationXmlRequest);
              handleRequest();
          } catch(Exception ex) {
              result.message += system.Label.ExceptionOccurred +' ' + ex.getMessage();
              if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                  result.message += system.Label.InvoiceIsCharged;
                  transactionObj.Is_Payment_Processed_Successfully__c = false;
                  transactionObj.Exception_Message__c = system.Label.transactionIsDoneButPAIsNotDone + '\n' + 'Exception message is : ' +  ex.getMessage() + ' \n Line no is ' +  ex.getLineNumber() + ' \n Type of exception ' + ex.getTypeName();
                  update transactionObj;   
              }
          }
                  
          return result;  
      }
      // This method for charge the invoice
      public PaymentOperations.PaymentResult handleAuthorizeAndCharge_Click(string transactionId, string gatewayID) {
          
          try {
              decimal amountToBeProcessed = 0;
              fromSite = false;
              if(invoice.Payment_Request_Amount__c != null && invoice.Payment_Request_Amount__c > 0 && invoice.Payment_Request_Amount__c < invoice.Unpaid_Amount__c) {
                  amountToBeProcessed = invoice.Payment_Request_Amount__c;
              } else {
                  amountToBeProcessed = invoice.Unpaid_Amount__c;
              }
              
              string chargeXmlRequest = '<?xml version="1.0" encoding="utf-8"?>'+
                                          '<createCustomerProfileTransactionRequest xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">'+
                                              '<merchantAuthentication>'+
                                                  '<name>'+ gateway.Exact_ID__c +'</name>'+
                                                  '<transactionKey>'+ gateway.Exact_ID_Security_Key__c + '</transactionKey>'+
                                              '</merchantAuthentication>';                                            
              
              if(transactionId == null) {
                  transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, Amount__c = amountToBeProcessed, Currency__c = invoice.CurrencyL__c, Payment_Gateway__c = gateway.Id);
                  chargeXmlRequest +='<transaction>'+
                                              '<profileTransAuthCapture>'+
                                              '<amount>'+ amountToBeProcessed +'</amount>'+                                
                                              '<customerProfileId>'+ paymentMethod.Account__r.Customer_Profile_ID__c +'</customerProfileId>'+
                                              '<customerPaymentProfileId>'+ paymentMethod.Payment_Profile_ID__c +'</customerPaymentProfileId>'+
                                              '<order>'+
                                                  '<invoiceNumber>'+ invoice.Name +'</invoiceNumber>'+
                                                  '<description>'+ 'SalesForce Id : ' + invoice.Id + ' and Invoice Number : ' + invoice.Name +'</description>'+                                
                                              '</order>'+                             
                                              '</profileTransAuthCapture>'+
                                            '</transaction>';                                                               
                  
              } else {                
                  transactionObj = new Transaction__c(Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, Id = transactionId, Amount__c = amountToBeProcessed, Currency__c = invoice.CurrencyL__c);
                  chargeXmlRequest +='<transaction>'+
                                              '<profileTransPriorAuthCapture>'+
                                              '<amount>'+ amountToBeProcessed +'</amount>'+                                
                                              '<customerProfileId>'+ paymentMethod.Account__r.Customer_Profile_ID__c +'</customerProfileId>'+
                                              '<customerPaymentProfileId>'+ paymentMethod.Payment_Profile_ID__c +'</customerPaymentProfileId>'+
                                              '<transId>'+ gatewayID + '</transId>'+                          
                                              '</profileTransPriorAuthCapture>'+
                                            '</transaction>';             
              }
              
              chargeXmlRequest +='</createCustomerProfileTransactionRequest>';
              transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
              transactionObj.Request_Invoice__c = invoice.Id;
              transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
              transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE;
              sendHttpRequest(chargeXmlRequest);
              handleRequest();
              if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {               
                  //create the payment and payment allocation against the inv
                  InvoicingUtilClass.createPaymentAndPaymentAllocation(invoice, transactionObj);

                  transactionObj.Is_Payment_Processed_Successfully__c = true;
                  update transactionObj;                                                                                                 
              }
          }catch(Exception ex) {
              result.message += system.Label.ExceptionOccurred +' ' + ex.getMessage();
              if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                  result.message += system.Label.InvoiceIsCharged;
                  transactionObj.Is_Payment_Processed_Successfully__c = false;
                  transactionObj.Exception_Message__c = system.Label.transactionIsDoneButPAIsNotDone + '\n' + 'Exception message is : ' +  ex.getMessage() + ' \n Line no is ' +  ex.getLineNumber() + ' \n Type of exception ' + ex.getTypeName();
                  update transactionObj;   
              }   
          }   
          return result;      
      }

  /* =================== Start ====================================== */

      /*
      Modified By : Madhu Keshav: 1 Dec 2015: INVOICEIT-641
      Comment     : Creating a generic method for processing all payments. This will be used in global methods and API
      */
      
     public PaymentSiteOperation.GenericPaymentResult handleAuthorizeAndCharge(PaymentSiteOperation.GenericPaymentParameters genericPaymentParameters)
      {
          isGenericMethodCall = false;
          PaymentSiteOperation.GenericPaymentResult genericPaymentResult = new  PaymentSiteOperation.GenericPaymentResult();
          try {
     
              decimal amountToBeProcessed = genericPaymentParameters.amountToProcess;
              

              string chargeXmlRequest = '<?xml version="1.0" encoding="utf-8"?>'+
                                          '<createCustomerProfileTransactionRequest xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">'+
                                              '<merchantAuthentication>'+
                                                  '<name>'+ gateway.Exact_ID__c +'</name>'+
                                                  '<transactionKey>'+ gateway.Exact_ID_Security_Key__c + '</transactionKey>'+
                                              '</merchantAuthentication>'; 
              transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, Amount__c = amountToBeProcessed, Currency__c = invoice.CurrencyL__c, Payment_Gateway__c = gateway.Id);

             chargeXmlRequest +='<transaction>'+
                                              '<profileTransAuthCapture>'+
                                              '<amount>'+ amountToBeProcessed +'</amount>'+                                
                                              '<customerProfileId>'+ paymentMethod.Account__r.Customer_Profile_ID__c +'</customerProfileId>'+
                                              '<customerPaymentProfileId>'+ paymentMethod.Payment_Profile_ID__c +'</customerPaymentProfileId>'+
                                              '<order>'+
                                                  '<invoiceNumber>'+ invoice.Name +'</invoiceNumber>'+
                                                  '<description>'+ 'SalesForce Id : ' + invoice.Id + ' and Invoice Number : ' + invoice.Name +'</description>'+                                
                                              '</order>'+                             
                                              '</profileTransAuthCapture>'+
                                            '</transaction>';   

              chargeXmlRequest +='</createCustomerProfileTransactionRequest>';
              sendHttpRequest(chargeXmlRequest);
              handleRequest();

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

      // This method for void the transaction
      public PaymentOperations.PaymentResult handleVoid_Click(string gatewayId, string transactionId, decimal transactionAmount) {
          try {
              fromSite = false;
              string voidXmlRequest = '<?xml version="1.0" encoding="utf-8"?>'+
                                  '<createCustomerProfileTransactionRequest xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">'+
                                    '<merchantAuthentication>'+
                                      '<name>'+ gateway.Exact_ID__c  +'</name>'+
                                      '<transactionKey>'+ gateway.Exact_ID_Security_Key__c  + '</transactionKey>'+
                                    '</merchantAuthentication>'+
                                    '<transaction>'+
                                      '<profileTransVoid>'+
                                          '<customerProfileId>'+ paymentMethod.Account__r.Customer_Profile_ID__c +'</customerProfileId>'+
                                          '<customerPaymentProfileId>'+ paymentMethod.Payment_Profile_ID__c +'</customerPaymentProfileId>'+                                                                                               
                                          '<transId>'+ gatewayId +'</transId>'+                                                        
                                      '</profileTransVoid>'+
                                    '</transaction>'+  
                                  '</createCustomerProfileTransactionRequest>';
                      
              transactionObj = new Transaction__c(Type__c = CommonUtilClass.TRANSACTION_TYPE_VOID, Id = transactionId, Gateway_ID__c = gatewayId, Is_Payment_Processed_Successfully__c = true, Amount__c = transactionAmount);
              transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
              transactionObj.Request_Invoice__c = invoice.Id;
              transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
              transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_VOID;
              sendHttpRequest(voidXmlRequest);
              handleRequest();
              
              if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                  //cancel the payment 
                  InvoicingUtilClass.cancelPayment(transactionObj.Id);
              }
              
          } catch(Exception ex) {
              result.message = ex.getMessage();
          } 
          
          return result;      
      }
       // This method for refund the amount
       public PaymentOperations.PaymentResult handleRefund_Click(string gatewayId, string transactionId, decimal transactionAmount) {
          try {
               fromSite = false;
               string refundXmlRequest = '<?xml version="1.0" encoding="utf-8"?>'+
                                  '<createCustomerProfileTransactionRequest xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">'+
                                    '<merchantAuthentication>'+
                                      '<name>'+ gateway.Exact_ID__c +'</name>'+
                                      '<transactionKey>'+ gateway.Exact_ID_Security_Key__c + '</transactionKey>'+
                                    '</merchantAuthentication>'+
                                    '<transaction>'+
                                      '<profileTransRefund>'+
                                          '<amount>'+ transactionAmount +'</amount>'+     
                                          '<customerProfileId>'+  paymentMethod.Account__r.Customer_Profile_ID__c +'</customerProfileId>'+
                                          '<customerPaymentProfileId>'+ paymentMethod.Payment_Profile_ID__c +'</customerPaymentProfileId>'+                                                                                                                                          
                                          '<order>'+
                                              '<invoiceNumber>'+ invoice.Name +'</invoiceNumber>'+
                                              '<description>'+ 'SalesForce Id : ' + invoice.Id + ' and Invoice Number : ' + invoice.Name +'</description>'+
                                          '</order>'+
                                          '<transId>'+ gatewayId +'</transId>'+                                                                                      
                                      '</profileTransRefund>'+
                                    '</transaction>'+  
                                  '</createCustomerProfileTransactionRequest>';
              transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, Type__c = CommonUtilClass.TRANSACTION_TYPE_REFUND, Id = transactionId, Gateway_ID__c = gatewayId, Amount__c = transactionAmount, Is_Payment_Processed_Successfully__c = true, Payment_Gateway__c = gateway.Id);
              transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
              transactionObj.Request_Invoice__c = invoice.Id;
              transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
              transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_REFUND;
              sendHttpRequest(refundXmlRequest);
              handleRequest();
              if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                  //cancel the payment 
                  InvoicingUtilClass.cancelPayment(transactionObj.Id);
              }
              
          } catch(Exception ex) {
              result.message = ex.getMessage();
          }

          return result;      
       }
       // This method used for force.com site and vitrual terminal.
       public PaymentOperations.PaymentResult handleAuthorizeAndCharge_Site(boolean isSaveCardDetails) {
          
          decimal amountToBeProcessed = 0;
          try {
              if(invoice != null && currencyId == null) {
                  if(invoice.Payment_Request_Amount__c != null && invoice.Payment_Request_Amount__c > 0 && invoice.Payment_Request_Amount__c < invoice.Unpaid_Amount__c) {
                      amountToBeProcessed = invoice.Payment_Request_Amount__c;
                  } else {
                      amountToBeProcessed = invoice.Unpaid_Amount__c;
                  }
              } else{
                  amountToBeProcessed = dAmount;
              }
              
              Currency__c currency1 = [SELECT Name FROM Currency__c WHERE Name = 'USD'];

              transactionObj = new Transaction__c(Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, Amount__c = amountToBeProcessed, Payment_Gateway__c = gateway.Id);

              if(invoice != null) {
                  transactionObj.Currency__c = invoice.CurrencyL__c;
                  transactionObj.Request_Invoice__c = invoice.Id;
              } else {
                  if(currencyId != null) {
                      //This is used for Virtualterminal Purpose
                      transactionObj.Currency__c = currencyId;
                  } else{
                      //This is used for Advance Request Payment Purpose
                      transactionObj.Currency__c = currency1.id;
                  }
              }
              
              transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
              transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
              transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE;
              list<Payment_Method__c> defaultPaymentMethods;
              fromSite = false;
              if(isSaveCardDetails) {                             
                      if(invoice != null){
                          defaultPaymentMethods = InvoicingUtilClass.getDefaultMethodForAccount(invoice.Account__c);
                      } else{
                          defaultPaymentMethods = InvoicingUtilClass.getDefaultMethodForAccount(account.Id);
                      }

                      if(!defaultPaymentMethods.isEmpty()) {
                          for(Payment_Method__c pm : defaultPaymentMethods) {
                              pm.Default__c = false;
                          }
                          //update defaultPaymentMethods;
                          
                      }
                      Account accountRef = account;
                      account = [SELECT Gateway__c, Name, Customer_Profile_ID__c FROM Account WHERE Id=:account.id];  
                      // make the new payment method to default
                      paymentMethod.Default__c = true;
                      if(account.Customer_Profile_ID__c != null){
                          handlePaymentProfileCreation(account.Customer_Profile_ID__c);       
                      } else{
                          handleCustomerProfileCreation();    
                      }
                      if(paymentMethod.Id != null ){
                         transactionObj.Payment_Method__c = paymentMethod.Id;
                      }else{
                        transactionObj.Payment_Method__c = sDummyPaymentId;
                      }                                     
                      string chargeXmlRequest = '<?xml version="1.0" encoding="utf-8"?>'+
                                          '<createCustomerProfileTransactionRequest xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">'+
                                              '<merchantAuthentication>'+
                                                  '<name>'+ gateway.Exact_ID__c +'</name>'+
                                                  '<transactionKey>'+ gateway.Exact_ID_Security_Key__c + '</transactionKey>'+
                                              '</merchantAuthentication>'+ 
                                              '<transaction>'+
                                                  '<profileTransAuthCapture>'+
                                                  '<amount>'+ amountToBeProcessed +'</amount>'+                                
                                                  '<customerProfileId>'+ account.Customer_Profile_ID__c +'</customerProfileId>'+
                                                  '<customerPaymentProfileId>'+ paymentMethod.Payment_Profile_ID__c +'</customerPaymentProfileId>';
                         
                      if(invoice != null){
                          chargeXmlRequest += '<order>'+
                                                  '<invoiceNumber>'+ invoice.Name +'</invoiceNumber>'+
                                                  '<description>'+ 'SalesForce Id : ' + invoice.Id + ' and Invoice Number : ' + invoice.Name +'</description>'+                                
                                              '</order>';     
                      } else{
                          chargeXmlRequest += '<order>'+
                                                  '<invoiceNumber>'+ accountRef.Name +'</invoiceNumber>'+
                                                  '<description>'+ 'SalesForce Id : ' + accountRef.Id + '</description>'+                                
                                              '</order>';
                      }
                          chargeXmlRequest += '</profileTransAuthCapture>'+
                                              '</transaction>'+
                                              '</createCustomerProfileTransactionRequest>';
                                                                       
                       sendHttpRequest(chargeXmlRequest);  
                  
                       if(mapOfKeyValue.get('directResponse') != null ){
                           responseArray = mapOfKeyValue.get('directResponse').split(',');
                                   
                           if(responseArray.get(0) == '1') {
                             update defaultPaymentMethods;                    
                             upsert paymentProfile;
                             //Modified by Dev M : INVOICEIT-530
                             account.Payment_Method__c = paymentProfile.Id;
                             update account;
                             transactionObj.Payment_Method__c = paymentProfile.id;                                                     
                              transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED;   
                           } else {               
                              if(responseArray.get(0) == '2') {
                                  transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_DECLINED;
                              } else if(responseArray.get(0) == '3') {
                                  transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_ERROR;
                              } else {
                                  transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_HELDFORREVIEW;
                              }
                              transactionObj.Payment_Method__c = sDummyPaymentId;
                          }
                          
                          if(invoice != null){
                              transactionObj.Request_Invoice__c = invoice.Id;
                          }
              
                          transactionObj.Gateway_Date__c = system.now(); 
                          transactionObj.Response_Code__c = responseArray.get(0);
                          transactionObj.Reason_Code__c = decimal.ValueOf(responseArray.get(0));
                          transactionObj.Response_Message__c = responseArray.get(3);
                          transactionObj.Response__c = responseArray.get(3);
                          transactionObj.AVS_Response_Code__c =  responseArray.get(5);    
                          transactionObj.Authorization__c = responseArray.get(4); // Authorization code  
                          transactionObj.Gateway_ID__c = responseArray.get(6); // transaction Id 
                       }else{
                          transactionObj.Response_Message__c = controllerResult.messageText;
                          transactionObj.Response_Code__c =  controllerResult.messageCode;
                          transactionObj.Response__c  = controllerResult.resultCode;
                          transactionObj.Response_Status__c = controllerResult.resultCode;
                       }               
              } else {
                  if(paymentMethod.Payment_Profile_ID__c == null || paymentMethod.Payment_Profile_ID__c == ''){
                      string chargeXmlRequest = '<?xml version="1.0" encoding="utf-8"?>'+
                                           '<createTransactionRequest xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">'+
                                              '<merchantAuthentication>'+
                                                  '<name>'+ gateway.Exact_ID__c  +'</name>'+
                                                  '<transactionKey>'+ gateway.Exact_ID_Security_Key__c + '</transactionKey>'+
                                              '</merchantAuthentication>'+
                                              '<transactionRequest>'+
                                                  '<transactionType>authCaptureTransaction</transactionType>'+
                                                  '<amount>'+ amountToBeProcessed +'</amount>'+                                
                                                  '<payment>'+
                                                      '<creditCard>'+
                                                          '<cardNumber>'+ paymentMethod.Card_Number__c +'</cardNumber>'+
                                                          '<expirationDate>'+ paymentMethod.Card_Expiration_Year__c+'-'+ paymentMethod.Card_Expiration_Month__c +'</expirationDate>'+
                                                          '<cardCode>'+ paymentMethod.CVV__c +'</cardCode>'+
                                                      '</creditCard>'+
                                                  '</payment>';
                    if(invoice != null){
                      chargeXmlRequest += '<order>'+
                                              '<invoiceNumber>'+ invoice.Name +'</invoiceNumber>'+
                                              '<description>'+ 'SalesForce Id : ' + invoice.Id + ' and Invoice Number : ' + invoice.Name +'</description>'+                                
                                          '</order>';     
                     } else{
                          chargeXmlRequest += '<order>'+
                                                  '<invoiceNumber>'+ account.Name +'</invoiceNumber>'+
                                                  '<description>'+ 'SalesForce Id : ' + account.Id + '</description>'+                                
                                              '</order>';
                      }

                    // Added By Manigandan Sivadassan: INVOICEIT-527  
                    chargeXmlRequest += '<billTo>'+                               
                        '<firstName>'+ paymentMethod.Billing_First_Name__c +'</firstName>'+
                        '<lastName>'+ paymentMethod.Billing_Last_Name__c +'</lastName>';
                        
                     if(paymentMethod.Billing_Address__c != null){                                                  
                          chargeXmlRequest += '<address>'+ paymentMethod.Billing_Address__c +'</address>';
                     }
                     if(paymentMethod.Billing_City__c != null){                                                 
                          chargeXmlRequest += '<city>'+ paymentMethod.Billing_City__c +'</city>';
                     }
                     if(paymentMethod.Billing_State_Province__c != null){                                               
                          chargeXmlRequest += '<state>'+ paymentMethod.Billing_State_Province__c +'</state>';
                     }
                     if(paymentMethod.Billing_Zip_Postal__c != null){                                               
                          chargeXmlRequest += '<zip>'+ paymentMethod.Billing_Zip_Postal__c +'</zip>';
                     }
                     if(paymentMethod.Billing_Country__c != null){                                                  
                          chargeXmlRequest += '<country>'+ paymentMethod.Billing_Country__c +'</country>';
                     }
                     if(paymentMethod.Billing_Phone__c != null){                                                
                          chargeXmlRequest += '<phoneNumber>'+ paymentMethod.Billing_Phone__c +'</phoneNumber>';
                     }
                     
                     chargeXmlRequest +=  '</billTo>';
                                                                        
                       chargeXmlRequest +='</transactionRequest>'+  
                                          '</createTransactionRequest>';                  
                       sendHttpRequest(chargeXmlRequest);
                       
                       
                       if(mapOfKeyValue.get('responseCode') == '1') {
                          transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED;
                          transactionObj.Response_Message__c = mapOfKeyValue.get('description');
                          transactionObj.Response__c = mapOfKeyValue.get('description');
                          transactionObj.Payment_Method__c = sDummyPaymentId;
                      } else {
                          transactionObj.Response_Message__c = mapOfKeyValue.get('errorText');
                          transactionObj.Response__c = mapOfKeyValue.get('errorText');
                          if(mapOfKeyValue.get('responseCode') == '2') {
                              transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_DECLINED;
                          } else if(mapOfKeyValue.get('responseCode') == '3') {
                              transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_ERROR;
                          } else {
                              transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_HELDFORREVIEW;
                          }
                          transactionObj.Payment_Method__c = sDummyPaymentId;
                      }

                      if(invoice != null){
                          transactionObj.Request_Invoice__c = invoice.Id;
                      }
          
                      transactionObj.Gateway_Date__c = system.now(); 
                      transactionObj.Response_Code__c = mapOfKeyValue.get('responseCode');
                      transactionObj.Reason_Code__c = decimal.ValueOf(mapOfKeyValue.get('responseCode'));                 
                      transactionObj.AVS_Response_Code__c =  mapOfKeyValue.get('avsResultCode');    
                      transactionObj.Authorization__c = mapOfKeyValue.get('authCode'); // Authorization code  
                      transactionObj.Gateway_ID__c = mapOfKeyValue.get('transId'); // transaction Id          
                  } else{
                       transactionObj.Payment_Method__c = paymentMethod.Id;
                       string chargeXmlRequest = '<?xml version="1.0" encoding="utf-8"?>'+
                                          '<createCustomerProfileTransactionRequest xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">'+
                                              '<merchantAuthentication>'+
                                                  '<name>'+ gateway.Exact_ID__c +'</name>'+
                                                  '<transactionKey>'+ gateway.Exact_ID_Security_Key__c + '</transactionKey>'+
                                              '</merchantAuthentication>'+ 
                                              '<transaction>'+
                                                  '<profileTransAuthCapture>'+
                                                  '<amount>'+ amountToBeProcessed +'</amount>'+                                
                                                  '<customerProfileId>'+ account.Customer_Profile_ID__c +'</customerProfileId>'+
                                                  '<customerPaymentProfileId>'+ paymentMethod.Payment_Profile_ID__c +'</customerPaymentProfileId>';
                         
                      if(invoice != null){
                          chargeXmlRequest += '<order>'+
                                                  '<invoiceNumber>'+ invoice.Name +'</invoiceNumber>'+
                                                  '<description>'+ 'SalesForce Id : ' + invoice.Id + ' and Invoice Number : ' + invoice.Name +'</description>'+                                
                                              '</order>';     
                      } else{
                          chargeXmlRequest += '<order>'+
                                                  '<invoiceNumber>'+ account.Name +'</invoiceNumber>'+
                                                  '<description>'+ 'SalesForce Id : ' + account.Id + '</description>'+                                
                                              '</order>';
                      }

                     chargeXmlRequest += '</profileTransAuthCapture>'+
                                              '</transaction>'+
                                              '</createCustomerProfileTransactionRequest>';
                                                                        
                       sendHttpRequest(chargeXmlRequest);               
                       responseArray = mapOfKeyValue.get('directResponse').split(',');
                                   
                       if(responseArray.get(0) == '1') {                                                                        
                          transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED;   
                       } else {               
                          if(responseArray.get(0) == '2') {
                              transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_DECLINED;
                          } else if(responseArray.get(0) == '3') {
                              transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_ERROR;
                          } else {
                              transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_HELDFORREVIEW;
                          }
                          transactionObj.Payment_Method__c = sDummyPaymentId;
                      }
                      
                      if(invoice != null){
                          transactionObj.Request_Invoice__c = invoice.Id;
                      }
          
                      transactionObj.Gateway_Date__c = system.now(); 
                      transactionObj.Response_Code__c = responseArray.get(0);
                      transactionObj.Reason_Code__c = decimal.ValueOf(responseArray.get(0));
                      transactionObj.Response_Message__c = responseArray.get(3);
                      transactionObj.Response__c = responseArray.get(3);
                      transactionObj.AVS_Response_Code__c =  responseArray.get(5);    
                      transactionObj.Authorization__c = responseArray.get(4); // Authorization code  
                      transactionObj.Gateway_ID__c = responseArray.get(6); // transaction Id  
                  }
                                     
              } 
              
              upsert transactionObj;
              result.message = transactionObj.Response_Status__c + ' ' + transactionObj.Response_Message__c;          

              if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                  //create the payment and payment allocation against the inv
                  if(invoice != null){
                      if(currencyId != null){
                          //this is used for virtual terminal payment
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
              }
                    
          } catch(Exception ex){
              result.message += system.Label.ExceptionOccurred ;
              if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                  result.message += system.Label.InvoiceIsCharged;
                  transactionObj.Exception_Message__c = system.Label.transactionIsDoneButPAIsNotDone + '\n' + 'Exception message is : ' +  ex.getMessage() + ' \n Line no is ' +  ex.getLineNumber() + ' \n Type of exception ' + ex.getTypeName();   
              } else {
                  result.message += '\n \n '+system.Label.InvoiceIsNotCharged;   
                  transactionObj.Exception_Message__c = 'Exception message is : ' +  ex.getMessage() + ' \n Line no is ' +  ex.getLineNumber() + ' \n Type of exception ' + ex.getTypeName();
              }

              transactionObj.Is_Payment_Processed_Successfully__c = false;
              if(transactionObj.Payment_Method__c == null) {
                  transactionObj.Payment_Method__c = sDummyPaymentId;  
              }
              upsert transactionObj;  
          }
          result.transactionObj = transactionObj;
          return result;
       } 
       
      // method for sending request and getting response to CIM. 
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
          /*
              Modified By : Rama Krishna: 19 august 2014: SUP-312
              Comment     : exending the callout time to max
            */
          httpRequest.setTimeout(120000);
          httpRequest.setBody(xmlBody);       
                 
          if(!system.test.isRunningTest()) {
              httpResponse = httpObject.send(httpRequest);
              
              if(httpResponse.getStatusCode() == 200) {
                  sRawHttpResponse = httpResponse.getBody();
                  Dom.Document doc = httpResponse.getBodyDocument();
                  Dom.XMLNode rootElement = doc.getRootElement();
                  getElements(rootElement);            
              }
          } else {
              if(fromSite){
                  string sSuccess = '<?xml version="1.0" encoding="utf-8"?><createCustomerPaymentProfileResponse xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd"><messages><resultCode>Ok</resultCode><message><code>I00001</code><text>Successful.</text></message></messages><customerProfileId>24873481</customerProfileId><customerPaymentProfileId>22792840</customerPaymentProfileId><validationDirectResponse>1,1,1,(TESTMODE) This transaction has been approved.,000000,P,0,none,Test transaction for ValidateCustomerPaymentProfile.,1.00,CC,auth_only,none,Acertis,Cloud,,BLr,Blr,Indiana,90126,United States,9999999999,,email@example.com,,,,,,,,,0.00,0.00,0.00,FALSE,none,32CCAD776F9130847AA1C48BBD362885,,,,,,,,,,,,,XXXX0027,Visa,,,,,,,,,,,,,,,,</validationDirectResponse></createCustomerPaymentProfileResponse>';
                  Dom.Document doc = new Dom.Document();
                  doc.load(sSuccess);     
                  Dom.XMLNode rootElement = doc.getRootElement();
                  getElements(rootElement);               
              } else{
                  string sSuccess = '<?xml version="1.0" encoding="utf-8"?><createCustomerProfileTransactionResponse xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd"><messages><resultCode>Ok</resultCode><message><code>I00001</code><text>Successful.</text></message></messages><directResponse>1,1,1,This transaction has been approved.,C9V80Y,Y,2208836990,INV-69621,SalesForce Id : a06U000000GQjlnIAD and Invoice Number : INV-69621,33.00,CC,auth_capture,001U000000gvtCoIAI,Lakshya,Singh,,BLr,Blr,Indiana,90126,United States,,,,,,,,,,,,,,,,,48A956492072E8A5EEF31F2CC0EB656C,,2,,,,,,,,,,,XXXX0027,Visa,,,,,,,,,,,,,,,,</directResponse></createCustomerProfileTransactionResponse>';
                  Dom.Document doc = new Dom.Document();
                  doc.load(sSuccess);     
                  Dom.XMLNode rootElement = doc.getRootElement();
                  getElements(rootElement);
                  handleRequest();
              }
          } 
          
       }
       // This method for creating the transactions.
       private void handleRequest() {
          
          if(mapOfKeyValue.get('directResponse') != null){                
              responseArray = mapOfKeyValue.get('directResponse').split(',');         
              Transaction__c transactionObj2;
              //we have to refer page http://www.authorize.net/support/AIM_guide.pdf 37 page
              //if responseArray.get(0). 1 = Approved, 2 = Declined, 3 = Error, 4 = Held For review
              if(responseArray.get(0) == '1') {
                  transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED;
                  result.reloadPage = true;
              } else {
                  if(transactionObj.Id != null) {                 
                      transactionObj2 = new Transaction__c(Payment_Method__c = paymentMethod.Id, Type__c = transactionObj.Type__c, Gateway_ID__c = transactionObj.Gateway_ID__c, Amount__c = transactionObj.Amount__c);
                      transactionObj2.Request_Credit_Card_Number__c = transactionObj.Request_Credit_Card_Number__c;
                      transactionObj2.Currency__c = transactionObj.Currency__c;
                      transactionObj2.Request_Type_Of_Payment__c = transactionObj.Request_Type_Of_Payment__c;
                      transactionObj2.Request_Transaction_Type__c = transactionObj.Request_Transaction_Type__c;
                      sObject sObjTrasn = (sObject)transactionObj2;
                      transactionObj = (Transaction__c)sObjTrasn;
                  }
      
                  if(responseArray.get(0) == '2') {
                      transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_DECLINED;
                      //Added by DL, INVOICEIT-635
                      transactionObj.Is_Payment_Processed_Successfully__c = false;
                  } else if(responseArray.get(0) == '3') {
                      transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_ERROR;
                      //Added by DL, INVOICEIT-635
                      transactionObj.Is_Payment_Processed_Successfully__c = false;
                  } else {
                      transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_HELDFORREVIEW;
                      //Added by DL, INVOICEIT-635
                      transactionObj.Is_Payment_Processed_Successfully__c = false;
                  }
              }
              transactionObj.Gateway_Date__c = system.now(); 
              transactionObj.Response_Code__c = responseArray.get(0);
              transactionObj.Reason_Code__c = decimal.ValueOf(responseArray.get(0));
              transactionObj.Response_Message__c = responseArray.get(3);
              transactionObj.Response__c = responseArray.get(3);
              transactionObj.AVS_Response_Code__c =  responseArray.get(5);    
              transactionObj.Authorization__c = responseArray.get(4); // Authorization code  
              if(transactionObj.Gateway_ID__c == null) {  
                  transactionObj.Gateway_ID__c = responseArray.get(6); // transaction Id  
              }
              
              if(transactionObj.Id == null) {
                  result.message =  system.Label.transactioncreated;
              } else {
                  result.message =  system.Label.transactionupdated;
              }

              if(isGenericMethodCall){
      
              if(transactionObj.Id == null) {
                  transactionObj.Payment_Gateway__c = gateway.Id;
                  transactionObj.Payment_Method__c = paymentMethod.Id;
              }

              upsert transactionObj;
      
              transactionObj = [SELECT Name, Response_Status__c, Amount__c
                                FROM Transaction__c
                                WHERE Id =: transactionObj.Id];
              
              result.message +=  transactionObj.Name + ' \n'
              + 'Gateway Response : ' +  responseArray.get(3) + ' \n'
              + 'Gateway Status : ' + transactionObj.Response_Status__c;  
              result.transactionObj = transactionObj;
            }    
          } else {
              result.transactionObj = new Transaction__c();
              result.message =  mapOfKeyValue.get('text');
          }

      }
            
       // method for parsing presponse and store values in map corresponding node vale.
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
  }