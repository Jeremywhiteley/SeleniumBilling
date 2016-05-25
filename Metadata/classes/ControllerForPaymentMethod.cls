public with sharing class ControllerForPaymentMethod {
    
    public string currentPageId{get;set;}
    public Payment_Method__c paymentMethod{set;get;}
    public list<Gateway__c> listOfGateway;
    public list<Payment_Method__c> listOfPaymentMethod;
    public Gateway__c gateWayToUse;
    public Account account;    
    public ProfileResult innerClsObj;
    public boolean isDisable{set;get;}
    public boolean isVisible{set;get;}
    public boolean isShow{set;get;}
    public list<String> listOfCardTypes {get;set;}
    public string slistOfCardTypes  {get;set;}
       
    public ControllerForPaymentMethod(ApexPages.StandardController controller) {
        listOfCardTypes = new list<String>(); 
        Schema.DescribeFieldResult fieldResult = Payment_Method__c.Card_Type__c.getDescribe();
        List<Schema.PicklistEntry> CreditCardPickListValue = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListValue : CreditCardPickListValue)
        {
           listOfCardTypes.add(pickListValue.getValue());
        } 
        slistOfCardTypes = JSON.serialize(listOfCardTypes);
        paymentMethod = new Payment_Method__c();
        // We are using the currentPageId Id as AccountId
        currentPageId = apexPages.currentPage().getParameters().get('Id');
        account = [SELECT Gateway__c, Name, Customer_Profile_ID__c FROM Account WHERE Id=:currentPageId];
        //check default payment method is present for particular account.
        listOfPaymentMethod = [SELECT Name FROM Payment_Method__c WHERE Account__c =: currentPageId AND Default__c = true];        
        //check default gateway is present at Gateway and Account Level
        if(account.Customer_Profile_ID__c  != null){
            isVisible = true;
        }
        
        listOfGateway = new list<Gateway__c>();
        if(account.Gateway__c == null) {
            listOfGateway = InvoicingUtilClass.getDefaultGateway();
            if(listOfGateway.isEmpty()) {               
               Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.WARNING, system.Label.Gateway_Warning));
            }else if(listOfGateway.get(0).Gateway_Type__c != CommonUtilClass.GATEWAY_TYPE_AUTHORIZEDOTNETCIM){
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.WARNING, system.Label.Authorize_net_CIMisMandatory));  
            }else if(!listOfGateway.isEmpty()){                        
                gateWayToUse = listOfGateway.get(0);
                isDisable = true;
            }               
        } else {
            gateWayToUse = InvoicingUtilClass.getGateway(account.Gateway__c);
            
            if(gateWayToUse.Gateway_Type__c != CommonUtilClass.GATEWAY_TYPE_AUTHORIZEDOTNETCIM){
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.WARNING, system.Label.Authorize_net_CIMisMandatory));  
            } else{
                isDisable = true;
            }
       } 
    }
    
     public PageReference processProfileCreation() {
        
        if(!listOfPaymentMethod.isEmpty() && paymentMethod.Default__c == true){         
            //Added by Shruthi related to INVOICEIT-200
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.DefaultPaymentMethod));
            return null;   
        }
        
         if(paymentMethod.Card_Expiration_Month__c == null || paymentMethod.Card_Expiration_Year__c == null){         
            //Added by Shruthi related to INVOICEIT-200
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.EnterCardexpiryDate));
            return null;   
        }
               
        ClassForHandlingAuthorizeDotNetCIM classForHandlingAuthorizeDotNetCIM = new ClassForHandlingAuthorizeDotNetCIM(gateWayToUse, paymentMethod,account,null);
        if(account.Customer_Profile_ID__c == null){ 
                // call for customer profile and payment profile creation            
            innerClsObj = classForHandlingAuthorizeDotNetCIM.handleCustomerProfileCreation();                                                       
        }else{
                // call for payment profile creation             
            innerClsObj = classForHandlingAuthorizeDotNetCIM.handlePaymentProfileCreation(account.Customer_Profile_ID__c);    
        }
        
        if(innerClsObj.messageCode == 'I00001' && innerClsObj.resultCode == 'Ok'){
            //Added by Shruthi related to INVOICEIT-200
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.CONFIRM, system.Label.PaymentProfileCreated));            
        }else {
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, innerClsObj.messageText));
            return null;
        }
        // display second panel       
        isDisable = false;
        isShow = true;                          
        return null;                                                        
    }
    
    public class ProfileResult {
      public String resultCode;
      public String messageCode;
      public String messageText;
   }

}