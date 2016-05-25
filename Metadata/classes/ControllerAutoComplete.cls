global with sharing class ControllerAutoComplete{
    
    public String sPrefix;
    
    public String getsPrefix()
    {
        string sPrefix = CommonUtilClass.getPrefix().mid(0,11);
        if(sPrefix != '' && sPrefix !=null)
        {
            sPrefix = sPrefix + '.';
            return sPrefix;
        }else
        {
            return sPrefix;
        }
    }
   
    public void setsPrefix(String sOrgPrefix)
    {
        this.sPrefix = sOrgPrefix;
    }
     
    @RemoteAction
    global static SObject[] findSObjects(string objectName, string searchString, string searchFields, String displayFields, String orderField, String filterCriteria, String productLimit) {
        // more than one field can be passed in the searchFields parameter
        // split it into an array for later use
        
        List<String> fieldList;
        if (searchFields != null) {
            fieldList = searchFields.split(',');
        } else {
            return null;
        }
        
       // check to see if the object passed is valid
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(objectName);
        if(sot == null) {
            // Object name not valid
            return null;
        }
        // create the filter text
        String filter = ' LIKE \'%' + String.escapeSingleQuotes(searchString) + '%\'';
        //begin building the dynamic soql query
        String soql = 'SELECT id';
        if(displayFields != null && displayFields.trim().length() > 0) {
            soql += ','+displayFields;
        }
        // if an additional field was passed in add it to the soql
        if (fieldList != null) {
            for (String s : fieldList) {
                  soql += ',' + s;
            }
        }
        // add the object and filter by name to the soql
        soql += ' FROM ' + objectName + ' ';
        // add the filter by additional fields to the soql
        if (fieldList != null) {
            for (Integer i = 0; i < fieldList.size(); i++) {
                String s = fieldList.get(i);
                if(i == 0){
                    soql += ' WHERE ( ' + s + filter;
                } else {
                    soql += ' OR ' + s + filter;                    
                }
            }
            soql += ' )';
        }
        
        //this is used for dynamic filtering criteria of products
        soql += filterCriteria;
        
        if(orderField != null) {
            soql += ' ORDER BY ' + orderField + ' LIMIT ' + productLimit;
        } else {
            soql += ' ORDER BY Name LIMIT ' + productLimit;
        }
        
        List<sObject> L = new List<sObject>();
        try {
            L = Database.query(soql);
        }
        catch (QueryException e) {
            return null;
        }
        return L;
   }
}