global with sharing class OrderSOAPAPI{
       public static String sPrefix = CommonUtilClass.getPrefix(); 
        //This method was added by MG on 09th May 2013
        global string getCustomObjectSchema(String objectName) {
            string sXML = '';
            //string objectLabel;
            
            // Call global describe to get the map of string to token.
            map<String, Schema.SObjectType> m  = Schema.getGlobalDescribe();
            
            // Get the token for the sobject based on the type.
            Schema.SObjectType s = m.get(objectName);
            
            // get the describe of the object
            Schema.DescribeSObjectResult r = s.getDescribe();
            
            // get the object label
            
            // get the fields correspoding to the object
            map<String, Schema.SObjectField> objectFieldMap = r.fields.getMap();
            
            // initialize the object label(start)
            
            // iterate over the fields
            for(Schema.SObjectField  f : objectFieldMap.values())
            {
                // desribeResult for each field
                Schema.DescribeFieldResult desribeResult = f.getDescribe();
                
                if(!desribeResult.getLabel().startsWith(CommonUtilClass.OBSOLETE) && !desribeResult.getLabel().startsWith('Owner ID'))
                {
                    string sLabel = desribeResult.getLabel();
                    sLabel = sLabel.replace(' ', '');
                    sLabel = sLabel.replace('(', '');
                    sLabel = sLabel.replace(')', '');
                    sLabel = sLabel.replace('\'', '');
                    sLabel = sLabel.replace(',', '');
                    sLabel = sLabel.replace('?', '');
                    sLabel = sLabel.replace('%', 'Percentage');
                    sLabel = sLabel.replace('/', '');
                        
                    if(!desribeResult.isNillable() && !desribeResult.isDefaultedOnCreate())
                    {
                        //This is mandatory/required field
                        sXML = sXML + '<' + sLabel + ' dataType="' +  desribeResult.getType() + '" apiName="' + f + '" required="true"></' + sLabel + '>';
                    }
                    else
                    {
                        sXML = sXML + '<' + sLabel + ' dataType="' +  desribeResult.getType() + '" apiName="' + f + '"></' + sLabel + '>';
                    }
                }
            }
            
            return sXML;
        }
        
        //OrderAPI.getObjectSchema('Invoice__c');
        global string getObjectSchema(String objectName) {
            string sXML = '';
            //string objectLabel;
            
            // Call global describe to get the map of string to token.
            map<String, Schema.SObjectType> m  = Schema.getGlobalDescribe();
            
            // Get the token for the sobject based on the type.
            Schema.SObjectType s = m.get(objectName);
            
            // get the describe of the object
            Schema.DescribeSObjectResult r = s.getDescribe();
            
            // get the object label
            
            // get the fields correspoding to the object
            map<String, Schema.SObjectField> objectFieldMap = r.fields.getMap();
            
            // initialize the object label(start)
            
            // iterate over the fields
            for(Schema.SObjectField  f : objectFieldMap.values())
            {
                // desribeResult for each field
                Schema.DescribeFieldResult desribeResult = f.getDescribe();
                
                if(!desribeResult.getLabel().startsWith(CommonUtilClass.OBSOLETE) && !desribeResult.getLabel().startsWith('Owner ID') && desribeResult.isCreateable())
                {
                    string sLabel = desribeResult.getLabel();
                    sLabel = sLabel.replace(' ', '');
                    sLabel = sLabel.replace('(', '');
                    sLabel = sLabel.replace(')', '');
                    sLabel = sLabel.replace('\'', '');
                    sLabel = sLabel.replace(',', '');
                    sLabel = sLabel.replace('%', 'Percentage');
                    sLabel = sLabel.replace('/', '');
                    sLabel = sLabel.replace('Order', 'OrderID');
                        
                    if(!desribeResult.isNillable() && !desribeResult.isDefaultedOnCreate())
                    {
                        //This is mandatory/required field
                        sXML = sXML + '<' + sLabel + ' dataType="' +  desribeResult.getType() + '" apiName="' + f + '" required="true"></' + sLabel + '>';
                    }
                    else
                    {
                        sXML = sXML + '<' + sLabel + ' dataType="' +  desribeResult.getType() + '" apiName="' + f + '"></' + sLabel + '>';
                    }
                }
            }
            
            return sXML;
        }
        
        global string getOrderSchema() {
            // Version 30 Changes
            string sJobScheme         =  getObjectSchema(sPrefix +CommonUtilClass.OBJECT_NAME_JOB);
            string sJobProductScheme  =  getObjectSchema(sPrefix +CommonUtilClass.OBJECT_NAME_JOB_PRODUCT);
            string sJobChargeScheme   =  getObjectSchema(sPrefix +CommonUtilClass.OBJECT_NAME_JOB_RATE_PLAN_CHARGE);
            
            string sDetailsSchema = '<Order>' +sJobScheme
                                        + '<OrderProduct>' + sJobProductScheme
                                                + '<ProductRatePlanId dataType="String" apiName=sPrefix+"Product_Rate_Plan__c"></ProductRatePlanId>'
                                                + '<OrderRatePlanCharge>' + sJobChargeScheme
                                                + '</OrderRatePlanCharge>'
                                        + '</OrderProduct>'
                                    + '</Order>';
            
            sDetailsSchema = sDetailsSchema.replace('%', 'Percentage');
            return sDetailsSchema;
        }
        
        global string getSimpleOrderSchema() {
            string sSimpleSchema =   '<Order>'
                                    + '<OrderName dataType="STRING" apiName="Name" required="true">Test Simple</OrderName>'
                                    + '<Account dataType="REFERENCE" apiName=sPrefix+"Account__c" required="true">001U0000007eqOr</Account>'
                                    + '<OrderDate dataType="DATE" apiName=sPrefix"Start_Date__c" required="true">2013-12-05</OrderDate>'
                                    + '<Currency dataType="REFERENCE" apiName=sPrefix+"CurrencyL__c" required="true">a01U0000000F706</Currency>'
                                    + '<Terms dataType="DOUBLE" apiName=sPrefix+"Number_Of_Terms__c">24</Terms>'
                                    + '<PrimaryContact dataType="REFERENCE" apiName=sPrefix+"Shipping_Contact__c">003U0000008MGNd</PrimaryContact>'
                                    + '<PreferredBillingDayofthemonth dataType="PICKLIST" apiName=sPrefix+"Preferred_Billing_Day__c">12</PreferredBillingDayofthemonth>'
                                    + '<ServiceEndDate dataType="DATE" apiName=sPrefix+"Service_End_Date__c"></ServiceEndDate>'
                                    + '<ServiceStartDateDeliveryDate dataType="DATE" apiName=sPrefix+"Service_Activation_Date__c"></ServiceStartDateDeliveryDate>'
                                    + '<BillingContact dataType="REFERENCE" apiName=sPrefix+"Billing_Contact__c">003U0000008MGNd</BillingContact>'
                                    + '<OrderProduct>'
                                        + '<ProductName dataType="STRING" apiName="Name">Broadband new</ProductName>'
                                        + '<ProductCode dataType="STRING" apiName=sPrefix+"Product_Code__c">AC121456AMM</ProductCode>'
                                        + '<ProductQuantity dataType="DECIMAL" apiName=sPrefix+"Quantity__c">100</ProductQuantity>'
                                        + '<ProductUnitPrice dataType="DECIMAL" apiName=sPrefix+"Unit_Price__c">1000</ProductUnitPrice>'
                                    + '</OrderProduct>'
                                    + '</Order>';
            return sSimpleSchema;
        }
        
        //This method should return the id of the order if it is successful else the error message
        global string createSimpleOrder(String orderXML) {
            JobClass jobclass = new JobClass();
            JobProductClass jpClass;
            JobRatePlanClass jrpClass;
            JobRatePlanChargeClass jrpcClass;
            
            integer jobProductCounter = 0;
            integer jobRatePlanCounter = 0;
            integer jobRatePlanChargeCounter = 0;
                    
            Boolean isChargeExists;
            Product_Rate_Plan__c prp;
            map<string, Job_Rate_Plan_Charge__c> map_ProductCode_Charge = new  map<string, Job_Rate_Plan_Charge__c>();
            map<string, Product__c> map_ProductCode_Product = new  map<string, Product__c>();
            SavePoint sp;
            
            try {
                sp = Database.setSavepoint();
                XMLDom xmlDom = new xmldom(orderXML); 
                XMLDom.Element rootElementOrder = xmlDom.getElementByTagName('Order');
                if(rootElementOrder.hasChildNodes())
                {
                    List<XMLDom.Element> childNodesOfOrder = rootElementOrder.childNodes;
                    Sobject orderSobject = new Job__c();
                    for(XMLDom.Element orderEle : childNodesOfOrder)
                    {
                        if(orderEle.hasChildNodes() && orderEle.nodeName == 'OrderProduct')
                        {
                            List<XMLDom.Element> childNodesOfOrderProduct = orderEle.childNodes;
                            Sobject productSobject = new Product__c();
                            Sobject chargeSobject = new Job_Rate_Plan_Charge__c();
                            string currentProductCode = '';
                            for(XMLDom.Element productEle : childNodesOfOrderProduct)
                            {
                                string product_Field_apiName = productEle.getAttribute('apiName');
                                string dataType = productEle.getAttribute('dataType');
                                
                                if(product_Field_apiName == sPrefix+'Product_Code__c' && productEle.nodeValue != null)
                                {
                                    currentProductCode = productEle.nodeValue;
                                }
                                else
                                {
                                    //return 'No product code metioned';
                                }
                                
                                if(product_Field_apiName != sPrefix+'Quantity__c' && product_Field_apiName != sPrefix+'Unit_Price__c')
                                {
                                    typeCast(productSobject, product_Field_apiName, dataType, productEle.nodeValue);
                                }
                                else
                                {
                                    typeCast(chargeSobject, product_Field_apiName, dataType, productEle.nodeValue);
                                }
                            }
                            
                            map_ProductCode_Charge.put(currentProductCode, (Job_Rate_Plan_Charge__c) chargeSobject);
                            map_ProductCode_Product.put(currentProductCode, (Product__c) productSobject);
                        }
                        else
                        {
                            string order_Field_apiName = orderEle.getAttribute('apiName');
                            string dataType = orderEle.getAttribute('dataType');
                            typeCast(orderSobject, order_Field_apiName, dataType, orderEle.nodeValue);
                        }
                    }          
                    // add the order to the class
                    jobclass.job = (Job__c) orderSobject;
                }
                
                list<string> listOfProductCodes = new list<string>();
                listOfProductCodes.addAll(map_ProductCode_Charge.keySet());
                string sWhereClause = '';
                string sProductCodes = CommonUtilClass.convertListOfStingsIntoString(listOfProductCodes);
                String sQuery =  'Select Id, Name, Description__c, Product_Code__c, Product_Family__c ' 
                                 + ' FROM Product__c WHERE Product_Code__c IN (' + sProductCodes  + ')';
                                 
                if(jobclass.job.Start_Date__c != null) 
                {                            
                    sWhereClause = ' AND Valid_From_Date__c <= ' + CommonUtilClass.convertDateToString(jobclass.job.Start_Date__c)
                    + ' AND (Valid_To_Date__c >= ' + CommonUtilClass.convertDateToString(jobclass.job.Start_Date__c)
                    + ' OR Valid_To_Date__c = null )'; 
                }
                
                sQuery = sQuery + sWhereClause;
                list<Product__c> listOfIntrestedProducts = Database.query(sQuery);
                
                ApexPages.StandardController stdContoller = new ApexPages.StandardController(new Job__c());
                CreateJobController createJobController = new CreateJobController(stdContoller);
                createJobController.jobClass = jobclass;
                createJobController.job = jobclass.job;
                list<Id> productIds = new list<Id>();
                for(Product__c pr : listOfIntrestedProducts)
                {
                    productIds.add(pr.Id);
                }
                
                string sProductIds = CommonUtilClass.convertListOfIdsIntoString(productIds);
                
                String sQueryCharges =  'SELECT ' + CommonUtilClass.getObjectFields(sPrefix+'Product_Rate_Plan__c') + ',' 
                                        + '(SELECT ' + CommonUtilClass.getObjectFields(sPrefix+'Product_Rate_Plan_Charge__c') +  ' FROM ProductRatePlanCharge__r WHERE CurrencyL__c = \'' + jobclass.job.CurrencyL__c + '\')'
                                        + ' FROM Product_Rate_Plan__c WHERE Product__c IN (' + sProductIds  + ')';

                list<Product_Rate_Plan__c> listOfIntrestedProductsRP = Database.query(sQueryCharges);
                map<Id, Product_Rate_Plan__c> map_ProductId_ProductRP = new map<Id, Product_Rate_Plan__c>();
                for(Product_Rate_Plan__c productRatePlan : listOfIntrestedProductsRP) 
                {
                    map_ProductId_ProductRP.put(productRatePlan.Product__c, productRatePlan);
                }
                
                for(Product__c pr : listOfIntrestedProducts)
                {
                    isChargeExists = false;
                    jpClass = new JobProductClass();
                    jpClass.jobproduct = new Job_Product__c();
                    jpClass.jobproduct.Name = pr.Name;
                    jpClass.jobproduct.Description__c = pr.Description__c;
                    jpClass.jobproduct.Product__c = pr.Id;
                    jpClass.jobproduct.Product_Code__c = pr.Product_Code__c;
                    jpClass.jobproduct.Product_Family__c = pr.Product_Family__c;
                    jpClass.jobProductCounter = ++jobProductCounter;
                    jpClass.jobproduct.SequenceNumber__c = jobProductCounter;
                    
                    if(map_ProductId_ProductRP.containsKey(pr.Id))
                    {
                        prp = map_ProductId_ProductRP.get(pr.Id);
                        
                        jrpClass = new JobRatePlanClass();
                        jrpClass.jobrateplan = new Job_Rate_Plan__c();
                        jrpClass.jobrateplan.Product_Rate_Plan__c = prp.Id;
                        jrpClass.jobrateplan.Name = prp.Name;
                        jrpClass.jobrateplan.Description__c = prp.Description__c;
                        jrpClass.jobRatePlanCounter = ++jobRatePlanCounter;
                        
                        for(Product_Rate_Plan_Charge__c selectedProductratePlanCharge : prp.ProductRatePlanCharge__r)
                        {
                            isChargeExists = true;                      
                            Job_Rate_Plan_Charge__c jobRatePlanCharge = new Job_Rate_Plan_Charge__c();
                            jobRatePlanCharge.Unit_Price__c = selectedProductratePlanCharge.Unit_Price__c;  
                            jobRatePlanCharge.Quantity__c = 1;                    
                            jobRatePlanCharge.Unit_Of_Measurement__c = selectedProductratePlanCharge.Unit_Of_Measurement__c;
                            jobRatePlanCharge.Price_Format__c = selectedProductratePlanCharge.Price_Format__c;
                            if(map_ProductCode_Charge.containsKey(pr.Product_code__c))
                            {   
                                Job_Rate_Plan_Charge__c suppliedJobRatePlanCharge = map_ProductCode_Charge.get(pr.Product_code__c);
                                if(suppliedJobRatePlanCharge.Quantity__c != null)
                                {
                                    jobRatePlanCharge.Quantity__c = suppliedJobRatePlanCharge.Quantity__c;
                                }
                                if(suppliedJobRatePlanCharge.Unit_Price__c != null)
                                {
                                    jobRatePlanCharge.Unit_Price__c = suppliedJobRatePlanCharge.Unit_Price__c;
                                }   
                            }                  
                            jobRatePlanCharge.Price_Type__c = selectedProductratePlanCharge.Price_Type__c;
                            jobRatePlanCharge.CurrencyL__c = selectedProductratePlanCharge.CurrencyL__c;
                            jobRatePlanCharge.Accounting_Code__c = selectedProductratePlanCharge.Accounting_Code__c;
                            jobRatePlanCharge.Product_Rate_Plan_Charge__c = selectedProductratePlanCharge.Id;
                            jobRatePlanCharge.Name = selectedProductratePlanCharge.Name;
                            jobRatePlanCharge.Cost_Price__c = selectedProductratePlanCharge.Cost_Price__c;
                            jobRatePlanCharge.Sequence_No__c = 1;
                            jobRatePlanCharge.Is_Product_Editable__c = selectedProductratePlanCharge.Is_Product_Editable__c;
                            jobRatePlanCharge.Product_Charge_Category__c = selectedProductratePlanCharge.Product_Charge_Category__c;
                            jobRatePlanCharge.Percentage_of_other_Charges__c = selectedProductratePlanCharge.Percentage_of_other_Charges__c;
                            
                            jrpcClass = new JobRatePlanChargeClass();
                            jrpcClass.jobrateplancharge = jobRatePlanCharge;
                            jrpcClass.jobRatePlanChargeCounter = ++jobRatePlanChargeCounter;
                            jrpClass.jobRatePlanCharges.add(jrpcClass);
                        }
                        
                        jpClass.jobRatePlans.add(jrpClass);
                    }
                    
                    // only add to the class if has atleast one Job charge/Product charge
                    if(isChargeExists)
                    {
                        jobclass.jobProducts.add(jpClass);
                    }
                }
                
                createJobController.jobClass = jobclass;
                createJobController.jobClass.job = jobclass.job;
                createJobController.saveJob();
                return 'SUCCESS:'+jobclass.job.Id;
                            
            } catch(Exception ex) {
                Database.rollback(sp);
                return 'ERROR:'+ex;
            }
        }
        
        //This method should return the id of the order if it is successful else the error message
        global string createOrder(String orderXML) {
            JobClass jobclass = new JobClass();
            JobProductClass jpClass;
            JobRatePlanClass jrpClass;
            JobRatePlanChargeClass jrpcClass;
            
            integer jobProductCounter = 0;
            integer jobRatePlanCounter = 0;
            integer jobRatePlanChargeCounter = 0;
            SavePoint sp;
            
            try {
                sp = Database.setSavepoint();
                XMLDom xmlDom = new xmldom(orderXML); 
                XMLDom.Element rootElementOrder = xmlDom.getElementByTagName('Order');
                if(rootElementOrder.hasChildNodes())
                {
                    List<XMLDom.Element> childNodesOfOrder = rootElementOrder.childNodes;
                    Sobject orderSobject = new Job__c();
                    for(XMLDom.Element orderEle : childNodesOfOrder)
                    {
                        if(orderEle.hasChildNodes() && orderEle.nodeName == 'OrderProduct')
                        {
                            List<XMLDom.Element> childNodesOfOrderProduct = orderEle.childNodes;
                            Sobject orderProductSobject = new Job_Product__c();
                            jpClass = new JobProductClass();
                            for(XMLDom.Element ProductEle : childNodesOfOrderProduct)
                            {
                                if(orderEle.hasChildNodes() && ProductEle.nodeName == 'OrderRatePlanCharge')
                                {
                                    List<XMLDom.Element> childNodesOfOrderCharge = ProductEle.childNodes;
                                    Sobject orderChargeSobject = new Job_Rate_Plan_Charge__c();
                                    jrpcClass = new JobRatePlanChargeClass();
                                    for(XMLDom.Element orderChargeEle : childNodesOfOrderCharge)
                                    {

                                        string orderCharge_Field_apiName = orderChargeEle.getAttribute('apiName');
                                        string dataType = orderChargeEle.getAttribute('dataType');
                                        
                                        typeCast(orderChargeSobject, orderCharge_Field_apiName, dataType, orderChargeEle.nodeValue);
                                    }
                                    
                                    jrpcClass.jobrateplancharge = (Job_Rate_Plan_Charge__c) orderChargeSobject;
                                    jrpcClass.jobRatePlanChargeCounter = ++jobRatePlanChargeCounter;
                                    jrpClass.jobRatePlanCharges.add(jrpcClass);
                                }
                                else
                                {
                                    string orderProduct_Field_apiName = ProductEle.getAttribute('apiName');
                                    string dataType = ProductEle.getAttribute('dataType');
                                    
                                    typeCast(orderProductSobject, orderProduct_Field_apiName, dataType, ProductEle.nodeValue);
                                    // if it rate plan charge then 
                                    if(ProductEle.nodeName == 'ProductRatePlanId') 
                                    {
                                        jrpClass = new JobRatePlanClass();
                                        jrpClass.jobrateplan = new Job_Rate_Plan__c();
                                        jrpClass.jobrateplan.Product_Rate_Plan__c = ProductEle.nodeValue;
                                        jrpClass.jobrateplan.Name = 'Deafult';
                                        jrpClass.jobRatePlanCounter = ++jobRatePlanCounter;
                                        jpClass.jobRatePlans.add(jrpClass);
                                    }
                                }
                            }
                            
                            jpClass.jobproduct = (Job_Product__c) orderProductSobject;
                            jpClass.jobProductCounter = ++jobProductCounter;
                            jobclass.jobProducts.add(jpClass);
                        }
                        else
                        {
                        
                            string order_Field_apiName = orderEle.getAttribute('apiName');
                            string dataType = orderEle.getAttribute('dataType');
                            
                            typeCast(orderSobject, order_Field_apiName, dataType, orderEle.nodeValue);
                        }
                    }
                    // add the order to the class
                    jobclass.job = (Job__c) orderSobject;           
                }
                ApexPages.StandardController stdContoller = new ApexPages.StandardController(new Job__c());
                CreateJobController createJobController = new CreateJobController(stdContoller);
                createJobController.jobClass = jobclass;
                createJobController.jobClass.job = jobclass.job;
                
                createJobController.saveJob();
                
                return 'SUCCESS:'+jobclass.job.Id;
                            
            } catch(Exception ex) {
                Database.rollback(sp);
                return 'ERROR:'+ex;
            }
        }
        
        // generic method for type casting
        global static void typeCast(Sobject sobjectObj, String apiName, String dataType, string nodeValue) 
        {
            if(nodeValue != null && nodeValue.Length() > 0 && dataType != null) 
            {
                if(dataType == 'DOUBLE' || dataType == 'DECIMAL' || dataType == 'PERCENT') 
                {
                    sobjectObj.put(apiName, decimal.valueOf(nodeValue));
                } 
                else if(dataType == 'BOOLEAN') 
                {
                    sobjectObj.put(apiName, boolean.valueOf(nodeValue));    
                }
                else if(dataType == 'Date')
                {
                    sobjectObj.put(apiName, date.valueOf(nodeValue));
                }
                else
                {
                    sobjectObj.put(apiName, nodeValue);
                }
            }
        }
    }