public with sharing class ControllerForExportImportTemplate 
{
    public string recStr {get;set;}
    public Blob contentFile { get; set; }
    public String nameFile { get; set; }
    public Integer rowCount { get; set; }
    public Integer colCount { get; set; }
    public Integer rowNum;
    public String sLabel;
    public String previousProductCode='';
    public String previousRateplanName='';
    public String previouskeyforrateplan='';
    public  String sPrefix = CommonUtilClass.getPrefix();
    public list<string> listOfLocal = CommonUtilClass.getObjectFieldsWritable(sPrefix+'Product__c');
    public list<string>listOfProductLabels = listOfLocal.get(0).split(',');
    public list<string> listOfProductApis = listOfLocal.get(1).split(',');
    public String sProductApis = listOfLocal.get(1);
    public Integer sizeoflistOfProductApis = listOfProductApis.size();
    public list<string>  listOfLocal1 = CommonUtilClass.getObjectFieldsWritable(sPrefix+'Product_Rate_Plan__c');
    public list<string> listOfProductRatePlanLabels = listOfLocal1.get(0).split(',');
    public list<string> listOfProductRatePlanApis = listOfLocal1.get(1).split(',');
    public String sProductRatePlanApis = listOfLocal1.get(1);
    public Integer sizeoflistOfProductRatePlanApis = listOfProductRatePlanApis.size();
    public list<string>  listOfLocal2 = CommonUtilClass.getObjectFieldsWritable(sPrefix+'Product_Rate_Plan_Charge__c');
    public list<string> listOfChargesLabels = listOfLocal2.get(0).split(',');
    public list<string> listOfChargesApis = listOfLocal2.get(1).split(',');
    public String sChargesApis = listOfLocal2.get(1);
    public Integer sizeoflistOfChargesApis = listOfChargesApis.size();
    public Integer sizeProdNRateplanlist = sizeoflistOfProductApis+sizeoflistOfProductRatePlanApis;
    public map<Integer,String> mapOfNameAndKeyforproduct = CommonUtilClass.getObjectFieldsNKey(sPrefix+'Product__c');
    public map<Integer,String> mapOfNameAndKeyforprp = CommonUtilClass.getObjectFieldsNKey(sPrefix+'Product_rate_plan__c');
    public map<Integer,String> mapOfNameAndKeyforprpc = CommonUtilClass.getObjectFieldsNKey(sPrefix+'Product_rate_plan_charge__c');
    public map<String,Sobject> mapofcodeNProducts;
    public map<String,Sobject> mapofcodeNProductrateplans;
    public map<String,Sobject> mapofIdNProductrateplancharges;
    public map<String,Id> mapOfCurrencyNameAndCurrencyId = CommonUtilClass.getCurrencyNameNCurrencyId();
    public map<String,list<Sobject>> mapofCodeNlistofProductrateplans = new map<String,list<Sobject>>();
    public map<String,list<Sobject>> mapofCodeNlistofProductrateplancharges = new map<String,list<Sobject>>();
    public Product__c product {get; set;}
    public Product_Rate_Plan__c ratePlan {get; set;}
    public Product_Rate_Plan_Charge__c ratePlanCharge {get; set;}
    public list<Product_Rate_Plan__c> listOfratePlan {get; set;}
    public list<Product_Rate_Plan_Charge__c> listOfratePlanCharges {get; set;}

    public ProductsClass productsClass {get; set;}
    public ProductClass productClass {get; set;}
    public ProductRatePlanClass productRatePlanClass {get; set;}
    public ProductRatePlanChargeClass productRatePlanChargeClass = new ProductRatePlanChargeClass();

    private Integer productRatePlanCounter = 0;
    private Integer productRateplanChargeCounter = 0;
    private Integer productRateplanChargeTierCounter = 0;
    public map<Id,String> mapOfCurrencyIdAndCurrencyName = CommonUtilClass.getCurrencyIdNCurrencyName();


    public void uploadCSV()
    {
        if (contentFile != null)
        {
            String fileString = contentFile.toString();
            parseCSV(fileString);
        }

    }

    public  List<List<String>> parseCSV(String contents) 
    {
        list<list<String>> allFields = new list<list<String>>();
        mapofcodeNProducts = new map<String,Sobject>();
        mapofcodeNProductrateplans = new map<String,Sobject>();
        mapofIdNProductrateplancharges = new map<String,Sobject>();
        contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
        contents = contents.replaceAll('""','DBLQT');
        List<String> lines = new List<String>();
        previousProductCode='';
        previousRateplanName='';
        previouskeyforrateplan='';

        try 
        {
            lines = contents.split('\n'); // using carriage return accomodates windows, unix, and mac files
            
        }
        catch (System.ListException e) 
        {
   
        }
        Integer num = 0;
        try
        {
            for(String line: lines) 
            {
         
                if (line.replaceAll(',','').trim().length() == 0) break;
                List<String> fields = line.split(',');  
                List<String> cleanFields = new List<String>();
                String compositeField;
                Boolean makeCompositeField = false;

                for(String field: fields) 
                {
              
                    if (field.startsWith('"') && field.endsWith('"')) 
                    {
                        cleanFields.add(field.replaceAll('DBLQT','"'));
                    }
                    else if (field.startsWith('"')) 
                    {
                        makeCompositeField = true;
                        compositeField = field;
                    }
                    else if (field.endsWith('"')) 
                    {
                        compositeField += ',' + field;
                        cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                        makeCompositeField = false;
                    }
                    else if (makeCompositeField) 
                    {
                        compositeField +=  ',' + field;
                    }
                    else
                    {
                        cleanFields.add(field.replaceAll('DBLQT','"'));
                    }

                }

                allFields.add(cleanFields);
            }
        }
        catch (Exception e) 
        {
            Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.ProblemReadingCSV);
            Apexpages.addMessage(errorMessage);
        }
        if(allFields.size()> 1)
        {
            getAllfields(allFields);
        }
        return null;            
    }



    public  Pagereference getAllfields(list<list<String>> allFields)
    {
        rowNum=1;
        Savepoint sp ;
        try{
            sp = Database.setSavepoint();
            for(list<String> cleanFields:allFields)
            {
                Product__c prod = new Product__c();
                Sobject  productObject = (Sobject)prod;
                Product_Rate_Plan__c prp = new Product_Rate_Plan__c();
                Sobject  productrateplanObject = (Sobject)prp;
                Product_Rate_Plan_Charge__c prpc = new Product_Rate_Plan_Charge__c();
                Sobject  productrateplanchargeObject = (Sobject)prpc;
                Integer columnNum =1;
                Integer columnNumToInsert = 0;
                String productId;
                String productCode;
                String productPlanName;
                String productPlanValidtodate;
                String productPlanValidfromdate;
                String chargename;
        
        
                if(rowNum > 1)
                {
                    for(String fielddata:cleanFields)
                    {
                        if(columnNum <= sizeoflistOfProductApis)
                        {
                   
                        
                            String productApiNTypeName = mapOfNameAndKeyforproduct.get(columnNum);
                            String [] productApiNTypeNamearray = productApiNTypeName.split('-');
                            String productTypeName = productApiNTypeNamearray[1];
                            String productApiName = productApiNTypeNamearray[0];
                            sLabel= productApiNTypeNamearray[2];
                            if('DATE'==productTypeName)
                            {
                                if(fielddata!=null && fielddata.trim()!='')
                                {
                                    Date convertedDate = CommonUtilClass.convertStringtoDateNFormat(fielddata);
                                    productObject.put(productApiName,convertedDate);
                                }  
                            }
                            else if('BOOLEAN'==productTypeName)
                            {
                                if(fielddata!=null && fielddata.trim()!='')
                                    productObject.put(productApiName,boolean.valueOf(fielddata));
                            }
                            else if('DOUBLE'==productTypeName)
                            {
                                if(fielddata!=null && fielddata.trim()!='')
                                    productObject.put(productApiName,double.valueOf(fielddata));
                            }
                            else
                            {
                                if(sPrefix+'Product_Code__c'==productApiName)
                                {
                                    productCode =fielddata;
                                }
                                productObject.put(productApiName,fielddata);
                            }
                        }
                        else if(columnNum > sizeoflistOfProductApis && columnNum <=sizeProdNRateplanlist)
                        {
                    
                            String productrateplanapiNtypename = mapOfNameAndKeyforprp.get(columnNum-sizeoflistOfProductApis);
                            String [] productrateplanapiNTypeNamearray = productrateplanapiNtypename.split('-');
                            String productrateplanTypeName = productrateplanapiNTypeNamearray[1];
                            String productrateplanapiname = productrateplanapiNTypeNamearray[0];
                            sLabel = productrateplanapiNTypeNamearray[2];
                            if('DATE'==productrateplanTypeName)
                            {
                                Date convertedDate;
                                if(fielddata!=null && fielddata.trim()!='')
                                {
                                    convertedDate = CommonUtilClass.convertStringtoDateNFormat(fielddata);
                                    productrateplanObject.put(productrateplanapiname,convertedDate);
                                }
                                if(sPrefix+'Valid_From_Date__c'==productrateplanapiname && convertedDate!= null)
                                {
                                    productPlanValidfromdate = String.valueof(convertedDate);
                                }
                                if(sPrefix+'Valid_To_Date__c'==productrateplanapiname && convertedDate!= null)
                                {
                                    productPlanValidtodate = String.valueof(convertedDate);
                                }


                            }
                            else if('BOOLEAN'==productrateplanTypeName)
                            {
                                if(fielddata!=null && fielddata.trim()!='')
                                productrateplanObject.put(productrateplanapiname,boolean.valueOf(fielddata));
                            }
                            else if('DOUBLE'==productrateplanTypeName)
                            {
                               if(fielddata!=null && fielddata.trim()!='')  
                                productrateplanObject.put(productrateplanapiname,double.valueOf(fielddata));
                            }
                            else
                            {
                                if('Name'==productrateplanapiname)
                                {
                                    productPlanName =fielddata;
                                }

                                productrateplanObject.put(productrateplanapiname,fielddata);
                            }
                        }
                        else if(columnNum > sizeProdNRateplanlist)
                        {
                            Integer finalcol = columnNum-sizeProdNRateplanlist;
                            String chargeapiNtypename = mapOfNameAndKeyforprpc.get(finalcol);
                            String [] productrateplanchargeapiNTypeNamearray = chargeapiNtypename.split('-');
                            String productrateplanchargeTypeName = productrateplanchargeapiNTypeNamearray[1];
                            String productrateplanchargeapiname = productrateplanchargeapiNTypeNamearray[0];
                            sLabel = productrateplanchargeapiNTypeNamearray[2];
                            if('DATE'==productrateplanchargeTypeName)
                            {
                                Date convertedDate;
                                if(fielddata!=null && fielddata!='')
                                {
                                    convertedDate = CommonUtilClass.convertStringtoDateNFormat(fielddata);
                                    productrateplanchargeObject.put(productrateplanchargeapiname,convertedDate);
                                }

                            }
                            else if('BOOLEAN'==productrateplanchargeTypeName)
                            {
                                if(fielddata!=null && fielddata.trim()!='')
                                    productrateplanchargeObject.put(productrateplanchargeapiname,boolean.valueOf(fielddata));
                            }
                            else if('DOUBLE'==productrateplanchargeTypeName)
                            {
                                if(fielddata!=null && fielddata.trim()!='')
                                    productrateplanchargeObject.put(productrateplanchargeapiname,double.valueOf(fielddata));
                            }
                            else if('REFERENCE'==productrateplanchargeTypeName)
                            {
                                String currencyid;
                                if(fielddata!=null && fielddata.trim()!='' && sPrefix+'CurrencyL__c'==productrateplanchargeapiname)
                                {
                                    currencyid = mapOfCurrencyNameAndCurrencyId.get(fielddata);
                                    productrateplanchargeObject.put(productrateplanchargeapiname,currencyid);
                                }
                                else
                                {
                                    productrateplanchargeObject.put(productrateplanchargeapiname,fielddata);
                                }
                            }

                            else
                            {
                                if('Name'==productrateplanchargeapiname)
                                {
                                    chargename= fielddata;
                                }
                                productrateplanchargeObject.put(productrateplanchargeapiname,fielddata);
                            }


                        }
                        columnNum++;
                    }

                  if(productCode.trim()=='AC001' || productCode.trim()=='AC002' || productCode.trim()=='AC003')
                  {
                  } 
                  else
                  {
                    if(previousProductCode!=productCode)
                    {
                       
                            mapofcodeNProducts.put(productCode,productObject);
                    }
                    String keyforrateplan = productCode+'~'+productPlanName+'~'+productPlanValidfromdate+'~'+productPlanValidtodate;
                    if(previouskeyforrateplan!=keyforrateplan)
                    {
                        mapofcodeNProductrateplans.put(keyforrateplan,productrateplanObject);
                    }
                    String  keyforrateplancharge =  keyforrateplan +'~'+  chargename;               
                    mapofIdNProductrateplancharges.put(keyforrateplancharge,productrateplanchargeObject);
                    previousProductCode = productCode;
                    previouskeyforrateplan = keyforrateplan;
                  
                  
                  }

                }
                rowNum++;
            }

        }
        catch (Exception e) 
        {
    
            Database.rollback(sp);
            Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.InvalidDataInCSV);
            Apexpages.addMessage(errorMessage);
            return null;
        }


        try
        {

            Database.SaveResult[] products;
            if(mapofcodeNProducts!= null && mapofcodeNProducts.size() > 0)
            { 
                products = Database.insert(mapofcodeNProducts.values(),false);
            }

             if(products!= null && products.size() >0)
             {
                 for(Database.Saveresult sr:products)
                 {
                    if(sr.getId()==null)
                    {
                         Database.rollback(sp);
                         Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.InvalidDataInCSV);
                         Apexpages.addMessage(errorMessage);
                         return null;
                        
                    }
                    
                 }
                
             }
            

            list<String> listofrateplanchargekeys = new list<String>();
            list<String> listofrateplankeys = new list<String>();
            for(String productCode:mapofcodeNProducts.Keyset())
            {
                if(mapofcodeNProducts.get(productCode).id != null)
                {
                    for(String keyofrateplan:mapofcodeNProductrateplans.Keyset())
                    {
                        String[] keyofrateplanarray = keyofrateplan.split('~');
                        if(productCode==keyofrateplanarray[0])
                        {
                            Id productId = mapofcodeNProducts.get(productCode).id;
                            Sobject sobjectrateplan = mapofcodeNProductrateplans.get(keyofrateplan);
                            sobjectrateplan.put('product__c', productId);
                        }
                    }
                }
                else
                {
                    for(String keyofrateplan:mapofcodeNProductrateplans.Keyset())
                    {
                        String[] keyofrateplanarray = keyofrateplan.split('~');
                        if(productCode==keyofrateplanarray[0])
                        {
                            listofrateplankeys.add(keyofrateplan);
                            for(String rateplankeycharge:mapofIdNProductrateplancharges.keyset())
                            {
                                String [] rateplankeychargearray = rateplankeycharge.split('~');
                                String rateplankey = rateplankeychargearray[0]+'~'+rateplankeychargearray[1]+'~'+rateplankeychargearray[2]+'~'+rateplankeychargearray[3];
                                if(keyofrateplan==rateplankey)
                                {
                                    listofrateplanchargekeys.add(rateplankeycharge);
                                }
                            }
                        }
                    }
                }

            }

            for(String key:listofrateplankeys)
            {
                mapofcodeNProductrateplans.remove(key);
            }

            for(String key:listofrateplanchargekeys)
            {
                mapofIdNProductrateplancharges.remove(key);
            }



            Database.SaveResult[] rateplans;
            if(mapofcodeNProductrateplans!= null && mapofcodeNProductrateplans.size() > 0)
            { 
                rateplans = Database.insert(mapofcodeNProductrateplans.values(),false);
            }

 
            if(rateplans!= null && rateplans.size() >0)
             {
                 for(Database.Saveresult sr:rateplans)
                 {
                    if(sr.getId()==null)
                    {
                         Database.rollback(sp);
                         Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.InvalidDataInCSV);
                         Apexpages.addMessage(errorMessage);
                         return null;
                        
                    }
                    
                 }
                
             }
           
            list<String> listofrateplanchargekeys1 = new list<String>();                
            for(String rateplankey:mapofcodeNProductrateplans.keyset())
            {
                if(mapofcodeNProductrateplans.get(rateplankey).id != null)
                {
                    for(String keyofrateplancharge:mapofIdNProductrateplancharges.Keyset())
                    {
                        String[] keyofrateplanarray = keyofrateplancharge.split('~');
                        String keyofrateplan = keyofrateplanarray[0]+'~'+keyofrateplanarray[1]+'~'+keyofrateplanarray[2]+'~'+keyofrateplanarray[3];
                        if(rateplankey==keyofrateplan)
                        {
                            Id rateplanId = mapofcodeNProductrateplans.get(rateplankey).id;
                            Sobject sobjectrateplancharge = mapofIdNProductrateplancharges.get(keyofrateplancharge);
                            sobjectrateplancharge.put('product_rate_plan__c', rateplanId);
                        }
                    }
                }
                else
                {
                    for(String keyofrateplancharge:mapofIdNProductrateplancharges.Keyset())
                    {
                        String[] keyofrateplanarray = keyofrateplancharge.split('~');
                        String keyofrateplan = keyofrateplanarray[0]+'~'+keyofrateplanarray[1]+'~'+keyofrateplanarray[2]+'~'+keyofrateplanarray[3];
                        if(rateplankey==keyofrateplan)
                        {
                            listofrateplanchargekeys1.add(keyofrateplancharge);
                        }
                    }
                }
            }

            for(String key:listofrateplanchargekeys1)
            {
                mapofIdNProductrateplancharges.remove(key);
            }


            Database.SaveResult[] charges;
            if(mapofIdNProductrateplancharges!= null && mapofIdNProductrateplancharges.size() > 0)
            {
                charges = Database.insert(mapofIdNProductrateplancharges.values(),false);
            }

             if(charges!= null && charges.size() >0)
             {
                 for(Database.Saveresult sr:charges)
                 {
                    if(sr.getId()==null)
                    {
                         Database.rollback(sp);
                         Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.InvalidDataInCSV);
                         Apexpages.addMessage(errorMessage);
                         return null;
                    }
                 }
             }    
        }
        catch(Exception e1)
        {
            Database.rollback(sp);
            Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.IssueWhileInsertingFromCSV);
            Apexpages.addMessage(errorMessage);
            return null;
        }     
        
        Apexpages.Message successMessage = new Apexpages.Message(ApexPages.Severity.INFO,system.Label.CSVDataUploadedSucessfully);
        Apexpages.addMessage(successMessage);
        return null;
    }




    public PageReference exportCsv() { 
        recStr = '';
       // exportProductsToCsv();
        return new PageReference('/apex/downloadProductTemplate');  
    }

    public PageReference downloadTemplateCsv() { 
        recStr = '';
        exportProductsToCsvForSample();
        return new PageReference('/apex/downloadProductTemplate'); 
    }

    public void exportProductsToCsvForSample() {
        list<string> listOfLocal = CommonUtilClass.getObjectFieldsWritable(sPrefix+'Product__c');
        listOfProductLabels = listOfLocal.get(0).split(',');
        listOfProductApis = listOfLocal.get(1).split(',');
        String sProductApis = listOfLocal.get(1);
        listOfLocal = CommonUtilClass.getObjectFieldsWritable(sPrefix+'Product_Rate_Plan__c');
        listOfProductRatePlanLabels = listOfLocal.get(0).split(',');
        listOfProductRatePlanApis = listOfLocal.get(1).split(',');
        String sProductRatePlanApis = listOfLocal.get(1);

        listOfLocal = CommonUtilClass.getObjectFieldsWritable(sPrefix+'Product_Rate_Plan_Charge__c');
        listOfChargesLabels = listOfLocal.get(0).split(',');
        listOfChargesApis = listOfLocal.get(1).split(',');
        String sChargesApis = listOfLocal.get(1);

        set<Id> setOfRatePlanIds = new set<Id>();
        list<Id> listOfRatePlanIds = new list<Id>();
        productsClass = new ProductsClass();
        // Addeb for security scan results check
        string sProductCode1 = '\'' + 'AC001' + '\'';
        string sProductCode2 = '\'' + 'AC002' + '\'';
        string sProductCode3 = '\'' + 'AC003' + '\'';
        string sQuery = 'SELECT ' + sProductApis
                        + ',(' + 'SELECT ' + sProductRatePlanApis + ' From ProductRatePlan__r)'
                        + ' FROM Product__c '
                        + ' WHERE Product_Code__c ='+sProductCode1+ 'OR '
                        + 'Product_Code__c = '+sProductCode2+'OR '
                        + 'Product_Code__c = ' + sProductCode3 +' ';

        list<Product__c>  listOfProducts = Database.query(sQuery);
        
            for(string productLabel : listOfProductLabels) {
                recStr += productLabel  + ','; 
            }

            for(string productRatePlanLabel : listOfProductRatePlanLabels) {
                recStr += productRatePlanLabel + ','; 
            }
            for(string chargeLabel : listOfChargesLabels) {
                recStr += chargeLabel  + ','; 
            }

            recStr += '\n' ;
            
        if(listOfProducts != null && listOfProducts.size() > 0) {
            for(Product__c product :listOfProducts) {
                productClass = new ProductClass();
                productClass.product = product;

                for(Product_Rate_Plan__c productRatePlan : product.ProductRatePlan__r) {
                    productRatePlanClass = new  ProductRatePlanClass();
                    productRatePlanClass.productRatePlan = productRatePlan;
                    setOfRatePlanIds.add(productRatePlan.id);
                    listOfRatePlanIds.add(productRatePlan.id);
                    productClass.productRatePlans.add(productRatePlanClass);
                }
                productsClass.products.add(productClass);
            }

            sQuery = '';
            string sRatePlanIdsInCommaSeparated = CommonUtilClass.convertListOfIdsIntoString(listOfRatePlanIds);
            sQuery = 'SELECT Product_Rate_Plan__c,' + sChargesApis
                    + ' FROM Product_Rate_Plan_Charge__c'
                    + ' WHERE Product_Rate_Plan__c In (' + sRatePlanIdsInCommaSeparated + ')';
                    
            list<Product_Rate_Plan_Charge__c> listOfRatePlanCharges = Database.query(sQuery);

            for(ProductClass productClass: productsClass.products)  {
                for(ProductRatePlanClass productRatePlanClass:productClass.productRatePlans) {
                    for(Product_Rate_Plan_Charge__c prpc:listOfRatePlanCharges) {
                        if(productRatePlanClass.productRatePlan.id == prpc.Product_Rate_Plan__c) {
                            productRatePlanChargeClass = new productRatePlanChargeClass();
                            productRatePlanChargeClass.productRatePlancharge = prpc;
                            productRatePlanClass.productRatePlanChargeClass.add(productRatePlanChargeClass);  
                        }
                    }
                }
            }  

            for(ProductClass productClass : productsClass.products)  {
                sobject sobjectProduct = (sobject)productClass.product;
                for(ProductRatePlanClass productRatePlanClass : productClass.productRatePlans) {
                    sobject sobjectProductRatePlan = (sobject)productRatePlanClass.productRatePlan;
                    for(ProductRatePlanChargeClass productRatePlanChargeClass : productRatePlanClass.productRatePlanChargeClass) {  
                        sobject sobjectProductRatePlanCharge = (sobject)productRatePlanChargeClass.productRatePlancharge;
                        for(string productApi : listOfProductApis) {
                            recStr += sobjectProduct.get(productApi) + ','; 
                        } 

                        for(string productRatePlanApi : listOfProductRatePlanApis) {
                            recStr += sobjectProductRatePlan.get(productRatePlanApi) + ','; 
                        }

                        for(string chargeApi : listOfChargesApis) {
                            if(sPrefix+'CurrencyL__c' == chargeApi) {
                                String currencyname;
                                String  idLocal = (string)sobjectProductRatePlanCharge.get(chargeApi);
                                currencyname = mapOfCurrencyIdAndCurrencyName.get((string)sobjectProductRatePlanCharge.get(chargeApi));
                                recStr += currencyname + ','; 
                            }    
                            else {
                                recStr += sobjectProductRatePlanCharge.get(chargeApi) + ','; 
                            }
                        }    
                        recStr += '\n' ;       
                    }  
                }
            }   
        }                                                                                                        
    } 
}