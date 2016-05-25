global with sharing class CommonUtilClassForTaxation{

    //Added by DL, for Avalara Tax
    public static final String ENDPOINT_AVALARATAX_TEST = 'https://development.avalara.net/tax/taxsvc.asmx';
    public static final String ENDPOINT_AVALARATAX_LIVE = 'https://avatax.avalara.net/tax/taxsvc.asmx';
    public static final String TAX_CALCULATION_BASED_ON = 'TAX_CALCULATION_BASED_ON';
    public static final String OBJECT_NAME_ACCOUNT = 'Account';
    public static final String ACCOUNT_BILLING_ADDRESS = 'Account Billing Address';
    public static final String ACCOUNT_SHIPPING_ADDRESS = 'Account Shipping Address';
    public static final String CONTACT_TYPE_BILLING = 'Billing Contact';
    public static final String CONTACT_TYPE_SHIPPING = 'Shipping Contact';

    //This method returns a comma seperated string of all the standard fields of the object
    public static String getObjectFields(String objectName) {
        String sQuery = '';
        Map<String, Schema.SObjectField> objectFieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();

        for (Schema.SObjectField column : objectFieldMap.values()) {
            sQuery += column + ', ';
        }
        sQuery = sQuery.substring(0, sQuery.length() - 2);
        sQuery += ' ';
        return sQuery;
    }

    public static sobject getSobjectById(String sObjectName, String idOfSobject) {
        String sQuery = CommonUtilClassForTaxation.getObjectSelectQuery(sObjectName) + ' WHERE  Id = \'' + idOfSobject + '\'';
        sQuery = String.escapeSingleQuotes(sQuery);
        sQuery = sQuery.replace('\\', '');

        return database.query(sQuery);
    }
    public static String getObjectSelectQuery(String objectName) {
        String sQuery = 'SELECT ';
        sQuery += getObjectFields(objectName);
        sQuery += ' FROM ' + objectName + ' ';
        return sQuery;
    }

    public static list<Tax_Integration__c> getDefaultTax(id OrderID,Id AccountID) {
        list<Tax_Integration__c> listofTaxIntegration = new list<Tax_Integration__c>();
       
        
        Account account = new Account();
         String legalEntiyName;
         Job__c orderObj = new Job__c();

         String legalEntityField = Configuration__c.getValues('ORDER_LEGAL_ENTITY_FIELD_NAME').String_Value__c;
          if(legalEntityField != null) {
           string sObjectQuery = 'SELECT '+ getObjectFields(getPrefix()+'Job__c')
                            + 'FROM Job__c '
                            + 'WHERE Id =' + '\'' + OrderID + '\'';
              orderObj = Database.query(sObjectQuery); 
              SObject sObjTemp = (SObject)orderObj;
              legalEntiyName = (string) sObjTemp.get(legalEntityField);
          }else{
             legalEntityField = Configuration__c.getValues('ACCOUNT_LEGAL_ENTITY_FIELD_NAME').String_Value__c;
              if(legalEntityField != null) {  
                  //account = (Account) CommonUtilClass.getSobjectById(CommonUtilClass.OBJECT_NAME_ACCOUNT, AccountID);
                  string sObjectQuery = 'SELECT '+ getObjectFields('Account')
                            + 'FROM Account '
                            + 'WHERE Id =' + '\'' + AccountID + '\'';
                   account = Database.query(sObjectQuery);
                  SObject sObjTemp = (SObject)account;
                  legalEntiyName = (string) sObjTemp.get(legalEntityField);
           }
          }

        string sQuery;
   
        if(legalEntiyName == null || legalEntiyName == '') {
      
            sQuery = 'SELECT '+ getObjectFields(getPrefix()+'Tax_Integration__c')
                        + 'FROM Tax_Integration__c '
                        + 'WHERE Tax_Engine__c =' + '\'' + 'Avalara AvaTax' + '\' AND Default__c = true AND Active__c = true';
        } else {
    
            sQuery = 'SELECT '+ getObjectFields(getPrefix()+'Tax_Integration__c')
                        + 'FROM Tax_Integration__c '
                        + 'WHERE Tax_Engine__c =' + '\'' + 'Avalara AvaTax' + '\' AND Active__c = true AND AvaTax_Company_Code__c =' + '\'' + legalEntiyName + '\'';
        }
        listofTaxIntegration = Database.query(sQuery);
        return listofTaxIntegration;
       
    }
    public static String getPrefix() {
        return String.valueOf(Invoice__c.sObjectType).toLowerCase().startsWith('invoiceit_s__') ? 'invoiceit_s__' : '';
    }
}