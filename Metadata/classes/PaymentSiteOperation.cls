global with sharing class PaymentSiteOperation {

    global String processPayment(Invoice__c invoice, Payment_Method__c paymentMethod, Id dummyPaymentMethodID, Decimal accountAdvanceRequestedAmount, Account account, Boolean isSaveCardDetails) {
        Gateway__c gateWayToUse = new Gateway__c();
        // Here we are getting the gateway id beacuse it should not create problem for existing customer
        // Modified by Dev M INVOICEIT-519

        if (invoice == null) {
            Account accountRef = [SELECT Gateway__c FROM Account WHERE Id = :account.Id];

            if (accountRef.Gateway__c != null) {
                gateWayToUse = InvoicingUtilClass.getGateway(accountRef.Gateway__c);
            } else {
                list<Gateway__c> listOfGateway = InvoicingUtilClass.getDefaultGateway();
                if (listOfGateway.isEmpty())
                    return system.Label.Payment_Gateway_does_not_exists_Please_contact_your_service_provider;
                else
                    gateWayToUse = listOfGateway.get(0);
            }
        } else {
            Invoice__c invoiceRef = [SELECT Account__r.Gateway__c FROM Invoice__c WHERE Id = : invoice.Id];

            if (invoiceRef.Account__r.Gateway__c != null) {
                gateWayToUse = InvoicingUtilClass.getGateway(invoiceRef.Account__r.Gateway__c);
            } else {
                list<Gateway__c> listOfGateway = InvoicingUtilClass.getDefaultGateway();
                if (listOfGateway.isEmpty())
                    return system.Label.Payment_Gateway_does_not_exists_Please_contact_your_service_provider;
                else
                    gateWayToUse = listOfGateway.get(0);
            }
        }


        PaymentOperations.PaymentResult paymentResult;
        if (gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_AUTHORIZEDOTNET) {
            ClassForHandlingAuthorizeDotNet classForHandlingAuthorizeDotNet = new ClassForHandlingAuthorizeDotNet(gateWayToUse, invoice, paymentMethod, dummyPaymentMethodID, accountAdvanceRequestedAmount, account);
            paymentResult = classForHandlingAuthorizeDotNet.handleAuthorizeAndCharge_Site(isSaveCardDetails);
        } else if (gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_PAYPAL) {
            ClassForHandlingPaypal classForHandlingPaypal = new ClassForHandlingPaypal(gateWayToUse, invoice, paymentMethod, dummyPaymentMethodID, accountAdvanceRequestedAmount, account);
            paymentResult = classForHandlingPaypal.handleAuthorizeAndCharge_Site(isSaveCardDetails);
        } else if (gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_WIRECARD) {
            ClassForHandlingWireCard classForHandlingWireCard = new ClassForHandlingWireCard(gateWayToUse, invoice, paymentMethod, dummyPaymentMethodID, accountAdvanceRequestedAmount, account);
            paymentResult = classForHandlingWireCard.handleAuthorizeAndCharge_Site(isSaveCardDetails);
        } else if (gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_FIRSTDATA) {
            ClassForHandlingFirstdataCard classForHandlingFirstdataCard = new ClassForHandlingFirstdataCard(gateWayToUse, invoice, paymentMethod, dummyPaymentMethodID, accountAdvanceRequestedAmount, account, null );
            paymentResult = classForHandlingFirstdataCard.handleAuthorizeAndCharge_Site(isSaveCardDetails);
        } else if (gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_AUTHORIZEDOTNETCIM) {
            ClassForHandlingAuthorizeDotNetCIM classForHandlingAuthorizeDotNetCIM = new ClassForHandlingAuthorizeDotNetCIM(gateWayToUse, invoice, paymentMethod, dummyPaymentMethodID, accountAdvanceRequestedAmount, account, null);
            paymentResult = classForHandlingAuthorizeDotNetCIM.handleAuthorizeAndCharge_Site(isSaveCardDetails);
        } else if (gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_STRIPE) {
            ClassForHandlingStripeCard classForHandlingStripeCard = new ClassForHandlingStripeCard(gateWayToUse, invoice, paymentMethod, dummyPaymentMethodID, accountAdvanceRequestedAmount, account, null );
            paymentResult = classForHandlingStripeCard.handleAuthorizeAndCharge_Site(isSaveCardDetails);
        } else if (gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_SAGEPAY) {
            ClassForHandlingSagePay classForHandlingSagePay = new ClassForHandlingSagePay(gateWayToUse, invoice, paymentMethod, dummyPaymentMethodID, accountAdvanceRequestedAmount, account, null );
            paymentResult = classForHandlingSagePay.handleAuthorizeAndCharge_Site(isSaveCardDetails);
        } else if (gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_EWAY) {
            ClassForHandlingEway classForHandlingEway = new ClassForHandlingEway(gateWayToUse, invoice, paymentMethod, dummyPaymentMethodID, accountAdvanceRequestedAmount, account, null );
            paymentResult = classForHandlingEway.handleAuthorizeAndCharge_Site(isSaveCardDetails);
        } else if (gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_BRAINTREE) {
            ClassForHandlingBrainTree classForHandlingBrainTree = new ClassForHandlingBrainTree(gateWayToUse, invoice, paymentMethod, dummyPaymentMethodID, accountAdvanceRequestedAmount, account, null );
            paymentResult = classForHandlingBrainTree.handleAuthorizeAndCharge_Site(isSaveCardDetails);
        } else if (gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_ACH) { // Added by Dev M INVOICEIT-536
            ClassForHandlingAuthorizeECheck classForHandlingAuthorizeECheck = new ClassForHandlingAuthorizeECheck(gateWayToUse, invoice, paymentMethod, dummyPaymentMethodID, accountAdvanceRequestedAmount, account, null );
            paymentResult = classForHandlingAuthorizeECheck.handleAuthorizeAndCharge_Site(isSaveCardDetails);
        }

        return paymentResult.message;
    }

    global String processPayment(Gateway__c gateWay, Invoice__c invoice, Payment_Method__c paymentMethod, Id dummyPaymentMethodID, Decimal accountAdvanceRequestedAmount, Account account, Boolean isSaveCardDetails, Id currencyId) {

        PaymentOperations.PaymentResult paymentResult;
        if (gateWay.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_AUTHORIZEDOTNET) {
            ClassForHandlingAuthorizeDotNet classForHandlingAuthorizeDotNet = new ClassForHandlingAuthorizeDotNet(gateWay, invoice, paymentMethod, dummyPaymentMethodID, accountAdvanceRequestedAmount, account, currencyId);
            paymentResult = classForHandlingAuthorizeDotNet.handleAuthorizeAndCharge_Site(isSaveCardDetails);
        } else if (gateWay.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_PAYPAL) {
            ClassForHandlingPaypal classForHandlingPaypal = new ClassForHandlingPaypal(gateWay, invoice, paymentMethod, dummyPaymentMethodID, accountAdvanceRequestedAmount, account, currencyId);
            paymentResult = classForHandlingPaypal.handleAuthorizeAndCharge_Site(isSaveCardDetails);
        } else if (gateWay.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_WIRECARD) {
            ClassForHandlingWireCard classForHandlingWireCard = new ClassForHandlingWireCard(gateWay, invoice, paymentMethod, dummyPaymentMethodID, accountAdvanceRequestedAmount, account, currencyId);
            paymentResult = classForHandlingWireCard.handleAuthorizeAndCharge_Site(isSaveCardDetails);
        } else if (gateWay.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_FIRSTDATA) {
            ClassForHandlingFirstdataCard classForHandlingFirstdataCard = new ClassForHandlingFirstdataCard(gateWay, invoice, paymentMethod, dummyPaymentMethodID, accountAdvanceRequestedAmount, account, currencyId);
            paymentResult = classForHandlingFirstdataCard.handleAuthorizeAndCharge_Site(isSaveCardDetails);
        } else if (gateWay.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_AUTHORIZEDOTNETCIM) {
            ClassForHandlingAuthorizeDotNetCIM classForHandlingAuthorizeDotNetCIM = new ClassForHandlingAuthorizeDotNetCIM(gateWay, invoice, paymentMethod, dummyPaymentMethodID, accountAdvanceRequestedAmount, account, currencyId);
            paymentResult = classForHandlingAuthorizeDotNetCIM.handleAuthorizeAndCharge_Site(isSaveCardDetails);
        } else if (gateWay.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_STRIPE) {
            ClassForHandlingStripeCard classForHandlingStripeCard = new ClassForHandlingStripeCard(gateWay, invoice, paymentMethod, dummyPaymentMethodID, accountAdvanceRequestedAmount, account, currencyId);
            paymentResult = classForHandlingStripeCard.handleAuthorizeAndCharge_Site(isSaveCardDetails);
        } else if (gateWay.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_SAGEPAY) {
            ClassForHandlingSagePay classForHandlingSagePay = new ClassForHandlingSagePay(gateWay, invoice, paymentMethod, dummyPaymentMethodID, accountAdvanceRequestedAmount, account, currencyId);
            paymentResult = classForHandlingSagePay.handleAuthorizeAndCharge_Site(isSaveCardDetails);
        } else if (gateWay.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_EWAY) {
            ClassForHandlingEway classForHandlingEway = new ClassForHandlingEway(gateWay, invoice, paymentMethod, dummyPaymentMethodID, accountAdvanceRequestedAmount, account, currencyId);
            paymentResult = classForHandlingEway.handleAuthorizeAndCharge_Site(isSaveCardDetails);
        } else if (gateWay.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_BRAINTREE) {
            ClassForHandlingBrainTree classForHandlingBrainTree = new ClassForHandlingBrainTree(gateWay, invoice, paymentMethod, dummyPaymentMethodID, accountAdvanceRequestedAmount, account, currencyId);
            paymentResult = classForHandlingBrainTree.handleAuthorizeAndCharge_Site(isSaveCardDetails);
        }  else if (gateWay.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_ACH) { // Added by Dev M INVOICEIT-536
            ClassForHandlingAuthorizeECheck classForHandlingAuthorizeECheck = new ClassForHandlingAuthorizeECheck(gateWay, invoice, paymentMethod, dummyPaymentMethodID, accountAdvanceRequestedAmount, account, null );
            paymentResult = classForHandlingAuthorizeECheck.handleAuthorizeAndCharge_Site(isSaveCardDetails);
        }

        return paymentResult.message;
    }

    global GenericPaymentResult processGenericPayment(GenericPaymentParameters genericPaymentParameters) {

        GenericPaymentResult genericPaymentResult;
        if(genericPaymentParameters.gateway.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_AUTHORIZEDOTNET) {
             ClassForHandlingAuthorizeDotNet classForHandlingAuthorizeDotNet= new ClassForHandlingAuthorizeDotNet();
            genericPaymentResult  = classForHandlingAuthorizeDotNet.handleAuthorizeAndCharge(genericPaymentParameters);
            return genericPaymentResult;
        }else if( (genericPaymentParameters.gateway.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_CyberSource || genericPaymentParameters.gateway.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_CyberSource_CC_Token ) && genericPaymentParameters.paymentMethod.Payment_Method__c == CommonUtilClass.PAYMENTTYPE_ACH) {
            ClassForHandlingCyberSource classForHandlingCyberSourceIns = new ClassForHandlingCyberSource(genericPaymentParameters.gateway,genericPaymentParameters.invoiceObj,genericPaymentParameters.paymentMethod);
             genericPaymentResult = classForHandlingCyberSourceIns.handleAuthorizeAndCharge(genericPaymentParameters);
            return genericPaymentResult;
        }else if ( (genericPaymentParameters.gateway.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_CyberSource || genericPaymentParameters.gateway.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_CyberSource_CC_Token) && genericPaymentParameters.paymentMethod.Payment_Method__c == CommonUtilClass.PAYMENTTYPE_CREDITCARD){
            ClassForHandlingCyberSourceForCreditCard classForHandlingCyberSourceCC = new ClassForHandlingCyberSourceForCreditCard(genericPaymentParameters.gateway,genericPaymentParameters.invoiceObj,genericPaymentParameters.paymentMethod);
             genericPaymentResult = classForHandlingCyberSourceCC.handleAuthorizeAndCharge(genericPaymentParameters);
            return genericPaymentResult;
        }else if(genericPaymentParameters.gateway.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_FirstData) {
            ClassForHandlingFirstdataCard ClassForHandlingFirstdataCardIns = new ClassForHandlingFirstdataCard(genericPaymentParameters.gateway,genericPaymentParameters.invoiceObj,genericPaymentParameters.paymentMethod,null,null,null,null);
             genericPaymentResult = ClassForHandlingFirstdataCardIns.handleAuthorizeAndCharge(genericPaymentParameters);
            return genericPaymentResult;
        }else if(genericPaymentParameters.gateway.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_ACH) {
            ClassForHandlingAuthorizeECheck ClassForHandlingAuthorizeECheckIns = new ClassForHandlingAuthorizeECheck(genericPaymentParameters.gateway,genericPaymentParameters.invoiceObj,genericPaymentParameters.paymentMethod,null,null,null,null);
             genericPaymentResult = ClassForHandlingAuthorizeECheckIns.handleAuthorizeAndCharge(genericPaymentParameters);
            return genericPaymentResult;
        }else if(genericPaymentParameters.gateway.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_STRIPE){
            ClassForHandlingStripeCard classForHandlingStripeCard = new ClassForHandlingStripeCard();
             genericPaymentResult = classForHandlingStripeCard.handleAuthorizeAndCharge(genericPaymentParameters);
            return genericPaymentResult;
        }else if(genericPaymentParameters.gateway.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_BRAINTREE){
            ClassForHandlingBrainTree classForHandlingBrainTree = new ClassForHandlingBrainTree(genericPaymentParameters.gateway,genericPaymentParameters.invoiceObj,genericPaymentParameters.paymentMethod,null,genericPaymentParameters.amountToProcess,null,null);
             genericPaymentResult = classForHandlingBrainTree.handleAuthorizeAndCharge(genericPaymentParameters);
            return genericPaymentResult;  
            }else if(genericPaymentParameters.gateway.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_SAGEPAY){
            ClassForHandlingSagePay classForHandlingSagePay = new ClassForHandlingSagePay(genericPaymentParameters.gateway,genericPaymentParameters.invoiceObj,genericPaymentParameters.paymentMethod,null,genericPaymentParameters.amountToProcess,null,null);
             genericPaymentResult = classForHandlingSagePay.handleAuthorizeAndCharge(genericPaymentParameters);
            return genericPaymentResult;  
            }else if(genericPaymentParameters.gateway.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_AUTHORIZEDOTNETCIM){
            ClassForHandlingAuthorizeDotNetCIM classForHandlingAuthorizeDotNetCIM = new ClassForHandlingAuthorizeDotNetCIM(genericPaymentParameters.gateway,genericPaymentParameters.invoiceObj,genericPaymentParameters.paymentMethod,null,genericPaymentParameters.amountToProcess,null,null);
             genericPaymentResult = classForHandlingAuthorizeDotNetCIM.handleAuthorizeAndCharge(genericPaymentParameters);
            return genericPaymentResult;  
         } else if(genericPaymentParameters.gateway.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_WIRECARD){
            ClassForHandlingWireCard classForHandlingWireCard = new ClassForHandlingWireCard(genericPaymentParameters.gateway,genericPaymentParameters.invoiceObj,genericPaymentParameters.paymentMethod);
             genericPaymentResult = classForHandlingWireCard.handleAuthorizeAndCharge(genericPaymentParameters);
            return genericPaymentResult;  
         }   else if(genericPaymentParameters.gateway.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_EWAY){
            ClassForHandlingEway classForHandlingEway = new ClassForHandlingEway(genericPaymentParameters.gateway,genericPaymentParameters.invoiceObj,genericPaymentParameters.paymentMethod,null,genericPaymentParameters.amountToProcess,genericPaymentParameters.account,null);
             genericPaymentResult = classForHandlingEway.handleAuthorizeAndCharge(genericPaymentParameters);
            return genericPaymentResult;  
        }else if(genericPaymentParameters.gateway.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_PAYPAL){
            ClassForHandlingPaypal classForHandlingPaypal = new ClassForHandlingPaypal(genericPaymentParameters.gateway,genericPaymentParameters.invoiceObj,genericPaymentParameters.paymentMethod);
             genericPaymentResult = classForHandlingPaypal.handleAuthorizeAndCharge(genericPaymentParameters);
            return genericPaymentResult;  
        }
       return null;
    }


    global class GenericPaymentParameters {
        webService Gateway__c gateway;
        webService Decimal amountToProcess;
        webService String currencyISOCode;
        webService Payment_Method__c paymentMethod;
        webService Boolean shouldTokenizeCard;
        webService Invoice__c invoiceObj;
        WebService Account account;
        global GenericPaymentParameters(){
            paymentMethod = new Payment_Method__c();
            gateway = new Gateway__c();
            invoiceObj = new Invoice__c();
            account = new Account();
            
        }

    }

    global class GenericPaymentResult {
        webService Boolean isSuccess;
        webService String message;
        webService Boolean reloadPage;
        webService Transaction__c transactionObj;
        webService String profileID;
         global GenericPaymentResult(){
            transactionObj = new Transaction__c();
         }
    }

}