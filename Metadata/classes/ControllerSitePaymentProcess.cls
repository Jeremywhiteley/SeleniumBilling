public with sharing class ControllerSitePaymentProcess {  
        Id invoiceId;
        public Invoice__c invoice {get;set;}
        public Account account {get;set;}
        public Payment_Method__c paymentMethod {get;set;}
        public boolean isSaveCardDetails {get;set;}
        public boolean isCybersource {get;set;}
        public boolean isInvoiceExists {get;set;}
        public boolean isPaymentSucessfull {get;set;}
        public boolean isSavePaymentDetails {get;set;}
        public boolean isFooterExist {get;set;}
        public boolean isLogoExist {get;set;}
        Payment_Method__c dummyPaymentMethod;
        public string sSaveCardDetails {get;set;}
        public string sPaymentCss {get;set;}
        public string sBaseURL {get;set;}

        public string sMerchantSealId {get;set;}
        public string sMerchantURL {get;set;}
        public Gateway__c gateWayToUse {get;set;}
        public decimal amountToBeProcessed {get;set;}
        
        public Contact contactRef{get;set;}   
        public boolean isCountryPickListEnable {get;set;}
        public boolean isStateCountryPickListEnable;
        public string sCountryAPIName {get;set;}
        public string sStateAPIName {get;set;}
        map<string,string> mapOfCountry;
        public string paramValue{get;set;} 
        public list<String> listOfCardTypes {get;set;}
        public string slistOfCardTypes  {get;set;}
        Id accountId;
        public boolean isAcountPayment{get;set;}

        public ControllerSitePaymentProcess() {
            amountToBeProcessed = 0;
            try {
                
                listOfCardTypes = new list<String>(); 
                Schema.DescribeFieldResult fieldResult = Payment_Method__c.Card_Type__c.getDescribe();
                List<Schema.PicklistEntry> CreditCardPickListValue = fieldResult.getPicklistValues();
                for( Schema.PicklistEntry pickListValue : CreditCardPickListValue)
                {
                   listOfCardTypes.add(pickListValue.getValue());
                } 
                slistOfCardTypes = JSON.serialize(listOfCardTypes);
                
                contactRef = new Contact();
                mapOfCountry = new map<string,string>();            
                isCountryPickListEnable = false;           
                isFooterExist = false;
                isLogoExist = false;

                list<StaticResource> staticresources = [SELECT Name 
                                                        FROM StaticResource 
                                                        WHERE Name = 'payment_footer' OR Name = 'logo'];

                for(StaticResource staticresource : staticresources) {
                    if(staticresource.Name == 'payment_footer') {
                        isFooterExist = true;
                    } else if(staticresource.Name == 'logo') {
                        isLogoExist = true;
                    }
                }   

                isSavePaymentDetails = Configuration__c.getValues('SAVE_CREDIT_CARD_ON_PAYMENT_PAGE').Boolean_Value__c;
                isStateCountryPickListEnable = Configuration__c.getValues('ENABLE_STATE_AND_COUNTRY_PICKLIST').Boolean_Value__c;
                
                if(isSavePaymentDetails == null) {
                    isSavePaymentDetails = false;
                } 

                sSaveCardDetails = 'none';
                isSaveCardDetails = false;
                sBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
                list<StaticResource> listOfStaticResources = [SELECT Name 
                                                              FROM StaticResource 
                                                              WHERE Name In (:CommonUtilClass.STATICRESOURCE_PAYMENTCSS)
                                                              AND
                                                              (NamespacePrefix = null OR NamespacePrefix = '')];

                for(StaticResource sr : listOfStaticResources) {
                    if(sr.Name == CommonUtilClass.STATICRESOURCE_PAYMENTCSS) {
                        sPaymentCss = CommonUtilClass.STATICRESOURCE_PAYMENTCSS;
                    }
                }
                
                
                
               // Modified By     : Rama Krishna, INVOICEIT-194, Modified Date   : 19 june 2013,
               //Comments :  to allocate the Advance payments without an Invoice for Account.
                                               
                  string recordId = system.currentPageReference().getParameters().get('Id');
                if(recordId.startsWith('001')) {
                    //it is a account payment
                   accountId = recordId; 
                    list<Currency__c> currencys = [SELECT Name FROM Currency__c WHERE Name = 'USD'];
                    if(currencys.isEmpty()) {
                         //Added by Shruthi related to INVOICEIT-200
                         Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.CurrencyIsNotConfigured));
                    } else {
                        account = InvoicingUtilClass.getAccountById(accountId); 
                        isAcountPayment = true;
                        if(account.Gateway__c == null) 
                        {
                            list<Gateway__c> listOfGateway = InvoicingUtilClass.getDefaultGateway();
                            if(listOfGateway.isEmpty()) 
                                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.Payment_Gateway_does_not_exists_Please_contact_your_service_provider));  
                            else
                                gateWayToUse = listOfGateway.get(0);  
                        } 
                        else
                        {
                            gateWayToUse = InvoicingUtilClass.getGateway(account.Gateway__c);
                            
                        }
                        
                        if(account.Advance_Request_Status__c == CommonUtilClass.STATUS_PAID){
                            isAcountPayment = false;
                            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, system.Label.RequestedAdvancePayment));
                        }
                     }
                }
                else {        
                    //it is a invoice payment
                    isAcountPayment = false;
                    invoiceId = recordId;
                    if(invoiceId == null) {
                        Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.Payment_Invoice_details_could_not_be_found));
                    } else {
                        // query the invoice details from db
                        invoice = InvoicingUtilClass.getInvoiceById(invoiceId);

                        if(invoice.Invoice_Status__c != CommonUtilClass.STATUS_POSTED && (invoice.Invoice_State__c != CommonUtilClass.STATUS_PROFORMA || invoice.Invoice_Status__c == CommonUtilClass.STATUS_CANCELLED))
                        {
                            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, system.Label.Payment_Invoice_status_is_draft));
                        } 
                        //Added by DL, INVOICEIT-630, We are not allowing to pay paymentplan invoice through site
                        else if(invoice.Order__r.Payment_Plan__c != null){
                            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, system.Label.paymentPlanInvoice));
                        }
                        else 
                        {
                            if(invoice.Payment_Request_Amount__c != null && invoice.Payment_Request_Amount__c > 0 && invoice.Payment_Request_Amount__c < invoice.Unpaid_Amount__c) {
                                amountToBeProcessed = invoice.Payment_Request_Amount__c;
                            } else {
                                invoice.Payment_Request_Amount__c = invoice.Unpaid_Amount__c;
                                amountToBeProcessed = invoice.Unpaid_Amount__c;
                            }

                            // query the account details from db
                            account = InvoicingUtilClass.getAccountById(invoice.Account__c);

                            if(amountToBeProcessed <= 0) 
                            {
                                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, system.Label.Payment_Invoice_is_already_paid));
                            } 
                            else 
                            {
                                if(invoice.Account__r.Gateway__c == null) 
                                {
                                    list<Gateway__c> listOfGateway = InvoicingUtilClass.getDefaultGateway();
                                    if(listOfGateway.isEmpty()) 
                                        Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.Payment_Gateway_does_not_exists_Please_contact_your_service_provider));
                                    else
                                        gateWayToUse = listOfGateway.get(0);
                                        if(gateWayToUse.Gateway_Type__c == 'CyberSource_CC_Token'){
                                        isCybersource = true;}else{
                                        isCybersource = false;}               
                                } 
                                else
                                {
                                    gateWayToUse = InvoicingUtilClass.getGateway(invoice.Account__r.Gateway__c);
                                    if(gateWayToUse.Gateway_Type__c == 'CyberSource_CC_Token'){
                                    isCybersource = true;}else{
                                    isCybersource = false;}
                                }

                                if(gateWayToUse != null && gateWayToUse.Merchant_Seal_User_Id__c != null && gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_AUTHORIZEDOTNET)
                                {
                                    // we should able to genrate the below url
                                    sMerchantSealId = gateWayToUse.Merchant_Seal_User_Id__c;
                                    if(gateWayToUse.Test_Mode__c)
                                    {
                                        sMerchantURL = 'https://testverify.authorize.net/anetseal/?pid=' + sMerchantSealId + '&rurl=' + URL.getCurrentRequestUrl().toExternalForm();
                                    }
                                    else
                                    {
                                        sMerchantURL = 'https://verify.authorize.net/anetseal/?pid=' + sMerchantSealId + '&rurl=' + URL.getCurrentRequestUrl().toExternalForm();
                                    }
                                } 
                            }    
                        }
                    }
                }
            } catch(Exception ex) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.Payment_Invoice_details_could_not_be_found));
            }
        }
        
             
        //this method is used for invoice payment for moving 1st page to next page
        public PageReference checkOut() {
            list<Payment_Method__c> listOfPaymentMethods;
            
           //Modified By        : Rama Krishna, INVOICEIT-194, Modified Date   : 19 june 2013,  
           //Comments       : querying the payment method for account.
                          
            if(account.Id != null) {
                listOfPaymentMethods = InvoicingUtilClass.getDummyPaymentMethodForAccount(account.Id);
            } else {
                listOfPaymentMethods = InvoicingUtilClass.getDummyPaymentMethodForAccount(invoice.Account__c);
            }

            if(listOfPaymentMethods.isEmpty()) {
                dummyPaymentMethod = new Payment_Method__c(Is_Dummy__c = true, Active__c = false, Payment_Method__c = 'Credit Card');
                dummyPaymentMethod.Account__c = invoice != null ? invoice.Account__c : account.Id;
                insert dummyPaymentMethod;
            } else {
                dummyPaymentMethod = listOfPaymentMethods.get(0);
            }  

            paymentMethod = new Payment_Method__c(Payment_Method__c = 'Credit Card');

            if(invoice != null){
                paymentMethod.Billing_First_Name__c = invoice.Billing_Contact__r.FirstName;
                paymentMethod.Billing_Last_Name__c = invoice.Billing_Contact__r.LastName;
                paymentMethod.Billing_Address__c = invoice.Billing_Contact__r.MailingStreet;
                paymentMethod.Billing_City__c = invoice.Billing_Contact__r.MailingCity;            
                paymentMethod.Billing_Zip_Postal__c = invoice.Billing_Contact__r.MailingPostalCode;
                
                if(isStateCountryPickListEnable != null && isStateCountryPickListEnable && Schema.SObjectType.Contact.fields.getMap().containsKey('MailingCountryCode')){
                   try{
                    if(invoice.Billing_Contact__c != null){
                        string contactId = invoice.Billing_Contact__c;
                        string contactInfo = 'select MailingCountry,MailingState, MailingCountryCode, MailingStateCode from Contact where id =:contactId';
                        list<Contact> contactObj = Database.query(contactInfo);  
                        if(!contactObj.isEmpty())
                            contactRef = contactObj[0].clone(false);  
                    }  
                    sCountryAPIName = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get('MailingCountryCode').getDescribe().getName();
                    sStateAPIName = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get('MailingStateCode').getDescribe().getName();
                                    
                    List<Schema.PicklistEntry> countryListValue = Schema.SObjectType.Contact.fields.getMap().get('MailingCountryCode').getDescribe().getPicklistValues();
                    for( Schema.PicklistEntry countryName : countryListValue)
                    {
                       mapOfCountry.put(countryName.getValue(),countryName.getLabel());                                     
                    }
                    isCountryPickListEnable = true;
                    
                   } catch(Exception ex) {
                        ApexPages.addMessages(ex) ; 
                   }                        
                } else{
                    paymentMethod.Billing_State_Province__c = invoice.Billing_Contact__r.MailingState;
                    paymentMethod.Billing_Country__c = invoice.Billing_Contact__r.MailingCountry;   
                }            
                paymentMethod.Account__c = invoice.Account__c;
            } else{
                paymentMethod.Account__c = account.id;
            }

            return Page.payment_CheckOut;
        }
        
        // as per Jira INVOICEIT-194, modified below code
        public PageReference processPayment() {
        
            if(isStateCountryPickListEnable != null && isStateCountryPickListEnable && isCountryPickListEnable){
                if(mapOfCountry.containsKey((String)contactRef.get('MailingCountryCode'))){
                    paymentMethod.Billing_Country__c = mapOfCountry.get((String)contactRef.get('MailingCountryCode'));              
                } else {
                    paymentMethod.Billing_Country__c = '';  
                }

                if((string)contactRef.get('MailingStateCode') != null) {
                    paymentMethod.Billing_State_Province__c = paramValue;
                    //paymentMethod.Billing_State_Province__c = (string)contactRef.get('MailingStateCode');
                } else if((string)contactRef.get('MailingStateCode') == null){              
                    paymentMethod.Billing_State_Province__c = '';
                } else {                
                    paymentMethod.Billing_State_Province__c = invoice.Billing_Contact__r.MailingState;  
                }         
            }
            if(!validateInformation()) {
                return null;
            }

            if(sSaveCardDetails == 'yes') {
                isSaveCardDetails = true;
            }else {
                isSaveCardDetails = false;
            }

            PaymentOperations.PaymentResult paymentResult;
                
                //Modified By     : Rama Krishna, INVOICEIT-194, Comments        : Account id, requested advanced amount passing to the all Gateway constructors.
                      
            if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_AUTHORIZEDOTNET) {
                ClassForHandlingAuthorizeDotNet classForHandlingAuthorizeDotNet = new ClassForHandlingAuthorizeDotNet(gateWayToUse, invoice, paymentMethod, dummyPaymentMethod.Id,account.Advance_Requested_Amount__c, account); 
                paymentResult = classForHandlingAuthorizeDotNet.handleAuthorizeAndCharge_Site(isSaveCardDetails); 
            } else if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_PAYPAL) {
                ClassForHandlingPaypal classForHandlingPaypal = new ClassForHandlingPaypal(gateWayToUse, invoice, paymentMethod, dummyPaymentMethod.Id,account.Advance_Requested_Amount__c, account); 
                paymentResult = classForHandlingPaypal.handleAuthorizeAndCharge_Site(isSaveCardDetails); 
            } else if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_WIRECARD) {
                ClassForHandlingWireCard classForHandlingWireCard = new ClassForHandlingWireCard(gateWayToUse, invoice, paymentMethod, dummyPaymentMethod.Id,account.Advance_Requested_Amount__c, account); 
                paymentResult = classForHandlingWireCard.handleAuthorizeAndCharge_Site(isSaveCardDetails); 
            } else if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_FIRSTDATA) {
                ClassForHandlingFirstdataCard classForHandlingFirstdataCard = new ClassForHandlingFirstdataCard(gateWayToUse, invoice, paymentMethod, dummyPaymentMethod.Id, account.Advance_Requested_Amount__c, account, null ); 
                paymentResult = classForHandlingFirstdataCard.handleAuthorizeAndCharge_Site(isSaveCardDetails); 
            } else if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_AUTHORIZEDOTNETCIM) {
                ClassForHandlingAuthorizeDotNetCIM classForHandlingAuthorizeDotNetCIM = new ClassForHandlingAuthorizeDotNetCIM(gateWayToUse, invoice, paymentMethod, dummyPaymentMethod.Id,account.Advance_Requested_Amount__c, account, null); 
                paymentResult = classForHandlingAuthorizeDotNetCIM.handleAuthorizeAndCharge_Site(isSaveCardDetails); 
            } else if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_STRIPE) {
                ClassForHandlingStripeCard classForHandlingStripeCard = new ClassForHandlingStripeCard(gateWayToUse, invoice, paymentMethod, dummyPaymentMethod.Id, account.Advance_Requested_Amount__c, account, null ); 
                paymentResult = classForHandlingStripeCard.handleAuthorizeAndCharge_Site(isSaveCardDetails); 
            }else if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_SAGEPAY) {
                ClassForHandlingSagePay classForHandlingSagePay = new ClassForHandlingSagePay(gateWayToUse, invoice, paymentMethod, dummyPaymentMethod.Id, account.Advance_Requested_Amount__c, account, null ); 
                paymentResult = classForHandlingSagePay.handleAuthorizeAndCharge_Site(isSaveCardDetails); 
            } else if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_EWAY) {
                ClassForHandlingEway classForHandlingEway = new ClassForHandlingEway(gateWayToUse, invoice, paymentMethod, dummyPaymentMethod.Id, account.Advance_Requested_Amount__c, account, null ); 
                paymentResult = classForHandlingEway.handleAuthorizeAndCharge_Site(isSaveCardDetails); 
            }else if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_BRAINTREE) {
                ClassForHandlingBrainTree classForHandlingBrainTree = new ClassForHandlingBrainTree(gateWayToUse, invoice, paymentMethod, dummyPaymentMethod.Id, account.Advance_Requested_Amount__c, account, null ); 
                paymentResult = classForHandlingBrainTree.handleAuthorizeAndCharge_Site(isSaveCardDetails); 
            } else if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_CyberSource_CC_Token) {
                ClassForHandlingCyberSourceForCreditCard classForHandlingCyberSourceForCreditCard = new ClassForHandlingCyberSourceForCreditCard(gateWayToUse, invoice, paymentMethod, dummyPaymentMethod.Id, account.Advance_Requested_Amount__c, account, null ); 
                paymentResult = classForHandlingCyberSourceForCreditCard.handleAuthorizeAndCharge_Site(isSaveCardDetails); 
            } 

            if(paymentResult.transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, system.Label.Payment_Success_message));
                isPaymentSucessfull = true;
                paymentMethod.CVV__c = null;
                paymentMethod.Card_Expiration_Month__c = null;
                paymentMethod.Card_Expiration_Year__c = null;
                return page.payment_CheckOut;
                //return null;
            } else {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, paymentResult.message));
            }
           
            return null;
        }

        public boolean validateInformation() {
            if(paymentMethod == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.Label.Payment_You_have_entered_wrong_page));
                return false;
            }

            String[] listOfMissingFields = new list<string>();
            boolean isMissingFields = false;
            if(paymentMethod.Billing_First_Name__c == null) {
                listOfMissingFields.add('First Name');
                isMissingFields = true;
            }
            if(paymentMethod.Billing_Last_Name__c == null) {
                listOfMissingFields.add('Last Name');
                isMissingFields = true;
            }
            if(paymentMethod.Card_Type__c == null) {
                listOfMissingFields.add('Card Type');
                isMissingFields = true;
            }
            if(paymentMethod.Card_Number__c == null) {
                listOfMissingFields.add('Card Number');
                isMissingFields = true;
            }
            if(isCybersource == false){
            if(paymentMethod.CVV__c == null || paymentMethod.CVV__c.trim().length() <= 0 ) {
                listOfMissingFields.add('CVV');
                isMissingFields = true;
            }}
            if(paymentMethod.Card_Expiration_Month__c == null || paymentMethod.Card_Expiration_Year__c == null) {
                listOfMissingFields.add('Card Expiration Date');
                isMissingFields = true;
            }
            if(isSavePaymentDetails && (sSaveCardDetails == null || sSaveCardDetails == 'none')) {
                listOfMissingFields.add('Save Card Information');
                isMissingFields = true;
            }

            if(isMissingFields) {
                String errMsg = system.Label.Thefollowingfieldsarerequired + listOfMissingFields[0];
                for (Integer i = 1; i < listOfMissingFields.size(); i++) 
                    errMsg = errMsg + ', ' + listOfMissingFields[i]; 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errMsg));     
                return false;             
            }
            return true;
        }
    }