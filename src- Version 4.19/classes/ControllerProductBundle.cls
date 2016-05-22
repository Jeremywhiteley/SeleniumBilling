/*
     * Combining several products and offering the bundle at a reduced price is a Product Bundle
     *
     * Product bundling is combining two or more products or services together, creating differentiation, greater value and therefore enhancing the offering to the customer.
     * Bundling is based on the idea that consumers value the grouped package more than the individual items.
     * Bundling can enhance an organization’s offering mix while minimizing costs. This is attractive to consumers who will benefit from a single, 
     * value-oriented purchase of complementary offerings. Bundling is attractive to producers by increasing efficiencies, such as reducing marketing and distribution costs. 
     * It can also encourage customers to look to one single source to offer several solutions.
     
     * This class mainly consists of Creating the Product bundles & editing the product bundle
     * This save bundle are used in Quote, Order, Opportunity
     * @author Devender M, Invoice IT
     * Copyright (c) 2011, Invoice IT, Salesforce.com Inc.
     * All rights reserved.
     */

    public with sharing class ControllerProductBundle {

        public map<string,map<string,list<ProductChargeWrapperCharges>>> map_Product_mapRate_Charges{get;set;}
        public String searchstring { get; set; }
        public String objectname { get; set; }
        public String searchfields { get; set; }
        public String displayfields { get; set; }
        public String orderfield { get; set; }
        public String sFilterCriteria { get; set; }
        public String sProductsLimit { get; set; }
        public String sSelectedProductId {get;set;}
        public map<Id, string> mapOfProductRatePlan;
        public Product_Bundle__c productBundle {get;set;}
        public map<Id,String> map_ProductName{get;set;}
        public map<Id,String> map_RatePlanName {get;set;}
        list<Product_Rate_Plan_Charge__c> listOfproductCharge;
        public Boolean isEditMode {get;set;}
        public Boolean isTypeSelected {get;set;}
        public Boolean displayPopupForProductRP {get;set;}
        set<Id> setofProductIdDelete = new set<Id>();
        set<Id> setofChargeIds = new set<Id>();
        map<Id,Product_Bundle_Line__c> mapIdProductCharge_BundleLine = new map<Id,Product_Bundle_Line__c>();
        public list<ClassProductRatePlan> listOfClassProductRatePlan { get; set; }
        set<string> setOfRatePlanId;
        public Boolean isClone = false;

            
        public ControllerProductBundle(ApexPages.StandardController controller) {
            try{ 
                searchstring = '';
                // Custom setting used for the product search
                objectname = Configuration__c.getValues('PRODUCT_OBJECTNAME').String_Value__c;
                searchfields =  Configuration__c.getValues('PRODUCT_SEARCHFIELDS').String_Value__c;
                displayfields =  Configuration__c.getValues('PRODUCT_DISPLAYFIELDS').String_Value__c;
                orderfield =  Configuration__c.getValues('PRODUCT_ORDERFIELD').String_Value__c;

                sProductsLimit = '10';
                setOfRatePlanId = new set<string>();
                productBundle = (Product_Bundle__c)controller.getRecord();
                isEditMode = false;
                isTypeSelected = false;
                displayPopupForProductRP = false;
                map_ProductName = new map<Id,String>();
                map_RatePlanName = new map<Id,String>();
                map_Product_mapRate_Charges = new map<string,map<string,list<ProductChargeWrapperCharges>>>();
                mapOfProductRatePlan = new map<Id,String>();
                
                // On Edit of Product Bundle we are prepopulating the existing data
                if(productBundle.Id != null) {
                    productBundle = CommonUtilClass.getProductBundle(productBundle.Id);
                    isEditMode = true;
                    onChangeType();
                    list<Product_Bundle_Line__c> listOfProductBundleLineItem = CommonUtilClass.getProductBundleLine(productBundle.Id);
                    
                    // Added by Kesav Madhu: INVOICEIT-611
                    string sURL = ApexPages.currentPage().getURL();
                    if(sURL.contains('Clone')) {
                        isEditMode = false;
                        isClone = true;
                        productBundle = productBundle.clone(false);
                        productBundle.OwnerId = UserInfo.getUserId();
                    }
                                    
                    // Getting all the Product, RatePlan, Charge for Bundle Line
                    for(Product_Bundle_Line__c bundleLine : listOfProductBundleLineItem) {
                    // Added by Kesav Madhu:INVOICEIT-611
                        if(isClone) {
                            bundleLine = bundleLine.clone(false);                        
                        }

                        setOfRatePlanId.add(bundleLine.Product_Rate_Plan__c);
                        mapOfProductRatePlan.put(bundleLine.Product_Rate_Plan__c,bundleLine.Product_Rate_Plan__r.Name);
                        setofChargeIds.add(bundleLine.Product_Rate_Plan_Charge__c);
                        mapIdProductCharge_BundleLine.put(bundleLine.Product_Rate_Plan_Charge__c, bundleLine);
                    }   
                    populate(); 
                }
            } catch(Exception ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber())); 
            }
        }

        //This is used to get the Product and realated ratePlans and display it on popup
        public void addProductDetail() {
            sSelectedProductId = system.currentPageReference().getParameters().get('productId');  
            listOfClassProductRatePlan = new list<ClassProductRatePlan>();
            list<Product_Rate_Plan__c> listofRatePlan = [SELECT Id,Name FROM Product_Rate_Plan__c WHERE Product__c =:sSelectedProductId AND Valid_From_Date__c <=: productBundle.Start_Date__c 
                                                         AND (Valid_To_Date__c >=: productBundle.Start_Date__c OR Valid_To_Date__c = null)];

            if(!listofRatePlan.isEmpty()) {
                if(listofRatePlan.size() > 1) {
                    ClassProductRatePlan classProductRatePlanObj;
                    for(Product_Rate_Plan__c ratePlan : listofRatePlan) {
                        classProductRatePlanObj = new ClassProductRatePlan();
                        classProductRatePlanObj.productRatePlan = ratePlan;
                        listOfClassProductRatePlan.add(classProductRatePlanObj);
                    }
                    displayPopupForProductRP = true;
                } else if(mapOfProductRatePlan.containsKey(listofRatePlan[0].Id)) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, system.Label.ProductAlreadyAdded));
                } else {
                    setOfRatePlanId.add(listofRatePlan[0].Id);
                    populate();
                }
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, system.Label.Product_ProductRatePlan));
            }
        }   
        
        //This is called when we cancel the rateplan charge popup
        public void closePopupForProductRatePlan() {        
            displayPopupForProductRP = false;    
            listOfClassProductRatePlan.clear();
        } 
        
        // This close the popup and populates the values displayed on the visualforce page
        public void saveAndCloseProductRPPopup() {

            string sError = ' ';
            for(classProductRatePlan classProductRatePlanObj : listOfClassProductRatePlan) {
                if(classProductRatePlanObj.isSelected && mapOfProductRatePlan.containskey(classProductRatePlanObj.productRatePlan.Id)) {
                    sError = classProductRatePlanObj.productRatePlan.Name + ',' +sError;
                } else if(classProductRatePlanObj.isSelected) {
                    setOfRatePlanId.add(classProductRatePlanObj.productRatePlan.Id);
                }
            }

            if(sError != ' ') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, system.Label.AlreadySelectedRatePlan +sError));
            }else if(setOfRatePlanId.isEmpty()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, system.Label.MessageSelectRatePlan));
            }else {
                displayPopupForProductRP = false;
                populate();    
                listOfClassProductRatePlan.clear();
            }
            setOfRatePlanId = new set<string>();
        }
        
        // Verfiying the Bundle Type is change or not, displaying some fields based on the Type Bundle.
        public void onChangeType() {
            if(productBundle.Bundle_Type__c != null && productBundle.Bundle_Type__c != 'Line') {
                // Added by Balachary:product Bundle Impovement:INVOICEIT-568      
                isTypeSelected = true;
                productBundle.Quantity__c =productBundle.Quantity__c;
                productBundle.Bundle_Price__c =productBundle.Bundle_Price__c; 
                productBundle.Price_Type__c=productBundle.Price_Type__c;
                productBundle.Pricing_Model__c=productBundle.Pricing_Model__c;   
            } else {
                isTypeSelected = false;
                productBundle.Quantity__c = null;
                productBundle.Bundle_Price__c = null;
            }
            map_Product_mapRate_Charges.clear();
        }
        
        //This is used to populate the innerlist which is displayed on the visualforc
        public void populate() {
            list<ProductChargeWrapperCharges> locProductChargeWrapperCharges;
            map<string,list<ProductChargeWrapperCharges>> locMapProduct_Charges;
            //If the Type is bundle donot display the Usage charges
            if(productBundle.Bundle_Type__c != 'Bundle') {
                listOfproductCharge = [SELECT Id, Name,  Unit_Price__c, Default_Quantity__c, Price_Type__c,Product_Rate_Plan__c, Product_Rate_Plan__r.Name, 
                                       Product_Rate_Plan__r.Product__r.Name, Product_Rate_Plan__r.Product__c
                                       FROM Product_Rate_Plan_Charge__c
                                       WHERE Product_Rate_Plan__c in:setOfRatePlanId
                                       AND
                                       CurrencyL__c  =: productBundle.Currency__c 
                                       ];
            } else {
                listOfproductCharge = [SELECT Id, Name,  Unit_Price__c, Default_Quantity__c,Price_Type__c, Product_Rate_Plan__c, Product_Rate_Plan__r.Name, 
                                       Product_Rate_Plan__r.Product__r.Name, Product_Rate_Plan__r.Product__c
                                       FROM Product_Rate_Plan_Charge__c
                                       WHERE Product_Rate_Plan__c in:setOfRatePlanId
                                       AND
                                       CurrencyL__c  =: productBundle.Currency__c 
                                       AND
                                       Price_Type__c !=: System.Label.OptionUsage
                                       ];      
            }
            
            // Prepopulate the inner list based on selected charges of particular currency
            if(!listOfproductCharge.isEmpty()) {
                for(Product_Rate_Plan_Charge__c charge : listOfproductCharge) {
                    setofProductIdDelete.remove(charge.Product_Rate_Plan__r.Product__c);
                    ProductChargeWrapperCharges productChargeWrapperCharges = new ProductChargeWrapperCharges();
                    productChargeWrapperCharges.productCharge = charge;
                    mapOfProductRatePlan.put(charge.Product_Rate_Plan__c,charge.Product_Rate_Plan__r.Name);

                    if(setofChargeIds.contains(charge.Id)) {
                        productChargeWrapperCharges.isSelectedCharge = true;
                        productChargeWrapperCharges.productLine = mapIdProductCharge_BundleLine.get(charge.Id);
                    } else if(productBundle.Bundle_Type__c != null && productBundle.Bundle_Type__c != 'Line'){
                        productChargeWrapperCharges.productLine.Quantity__c = 1.00;
                    } else {
                        productChargeWrapperCharges.productLine.Unit_Price__c = charge.Unit_Price__c;
                        productChargeWrapperCharges.productLine.Quantity__c = charge.Default_Quantity__c;
                    }
                    if(map_Product_mapRate_Charges.containsKey(charge.Product_Rate_Plan__r.Product__c)) {
                        locMapProduct_Charges = map_Product_mapRate_Charges.get(charge.Product_Rate_Plan__r.Product__c);   

                        if(locMapProduct_Charges.containskey(charge.Product_Rate_Plan__c)) {
                            locProductChargeWrapperCharges = locMapProduct_Charges.get(charge.Product_Rate_Plan__c);
                        } else {  
                            locProductChargeWrapperCharges = new list<ProductChargeWrapperCharges>();
                        }
                    } else {   
                        locMapProduct_Charges = new map<string,list<ProductChargeWrapperCharges>>();
                        locProductChargeWrapperCharges = new list<ProductChargeWrapperCharges>();                                   
                    } 

                    map_ProductName.put(charge.Product_Rate_Plan__r.Product__c, charge.Product_Rate_Plan__r.Product__r.Name);
                    map_RatePlanName.put(charge.Product_Rate_Plan__c, charge.Product_Rate_Plan__r.Name);    
                    locProductChargeWrapperCharges.add(productChargeWrapperCharges); 
                    locMapProduct_Charges.put(charge.Product_Rate_Plan__c, locProductChargeWrapperCharges);
                    map_Product_mapRate_Charges.put(charge.Product_Rate_Plan__r.Product__c , locMapProduct_Charges);

                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, system.Label.SelectProductOrRatePlan)); 
            } 
            // clear of the selected ratePlans
            setOfRatePlanId.clear(); 
        }
        
        // This is used to remove the product in step of wizard
        public void removeProduct() {
            sSelectedProductId = system.currentPageReference().getParameters().get('productId');  
            map<string,list<ProductChargeWrapperCharges>> locMapProduct_Charges = new map<string,list<ProductChargeWrapperCharges>>();
            locMapProduct_Charges = map_Product_mapRate_Charges.get(sSelectedProductId);
            // This is for deleting for unselected charges
            for(string ratePlanId : locMapProduct_Charges.keySet()) {
                setOfRatePlanId.remove(ratePlanId);
                mapOfProductRatePlan.remove(ratePlanId);
            }
            map_Product_mapRate_Charges.remove(sSelectedProductId);
            setofProductIdDelete.add(sSelectedProductId);
        }
        
        //This is used to redirect to step2 and filter criteria
        public PageReference step2() {  
            sFilterCriteria = ' and Valid_From_Date__c <= ' + CommonUtilClass.convertDateToString(productBundle.Start_Date__c)
            + ' and (Valid_To_Date__c >= ' + CommonUtilClass.convertDateToString(productBundle.Start_Date__c)
            + ' Or Valid_To_Date__c = null )';
                    
            // Added by Balachary:product Bundle Impovement:INVOICEIT-568      
            if(productBundle.Bundle_Type__c != null && productBundle.Bundle_Type__c != 'Line')
            {
                if ( productBundle.Bundle_Price__c ==0 || productBundle.Bundle_Price__c ==null)
                {
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, system.label.Please_Select_Bundle_Price ));              
                     return null;
                }
                if(productBundle.Quantity__c ==0 || productBundle.Quantity__c ==null)
                {
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, system.label.Please_Select_Quantity));              
                     return null;
                }
                if(productBundle.Price_Type__c ==null)
                {
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, system.label.Please_Select_Price_Type ));              
                  return null;
                }
                if(productBundle.Pricing_Model__c ==null)
                {
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, system.label.Please_Select_Pricing_Model ));              
                  return null;
                }
           }
            return new PageReference('/apex/productBundleStep2');       
        }
        
        // This is used to redirect to step1
        public PageReference step1() {  
            return new PageReference('/apex/productBundleStep1');       
        }
        
        // This is used to save the product & product bundle line
        public pageReference save() {
            try {
                set<Id> setOfProductCharge = new set<Id>();
                list<Product_Bundle_Line__c> listOfProductBundleLineItem = new list<Product_Bundle_Line__c>();
                Product_Bundle_Line__c productBundleLineItemObj;

                map<string,list<ProductChargeWrapperCharges>> locMapProduct_Charges;
                list<ProductChargeWrapperCharges> listOfWrapperChargesLoc;
                // Checking the selecting values and saving the things into DB if they are selected
                for(string productId : map_Product_mapRate_Charges.keySet()) {
                    locMapProduct_Charges = map_Product_mapRate_Charges.get(productId);
                    for(string productRatePlanId : locMapProduct_Charges.keySet()) {
                        listOfWrapperChargesLoc = locMapProduct_Charges.get(productRatePlanId);
                        for(ProductChargeWrapperCharges productChargeWrapperCharges : listOfWrapperChargesLoc) {
                            if(productChargeWrapperCharges.isSelectedCharge) {
                                
                                if(setofChargeIds.contains(productChargeWrapperCharges.productCharge.Id)) {
                                    productChargeWrapperCharges.productLine.put('Id' , mapIdProductCharge_BundleLine.get(productChargeWrapperCharges.productCharge.Id).Id);    
                                } 

                                productChargeWrapperCharges.productLine.Product__c = productChargeWrapperCharges.productCharge.Product_Rate_Plan__r.Product__c;
                                productChargeWrapperCharges.productLine.Product_Rate_Plan__c = productChargeWrapperCharges.productCharge.Product_Rate_Plan__c;
                                productChargeWrapperCharges.productLine.Product_Rate_Plan_Charge__c = productChargeWrapperCharges.productCharge.Id;

                                listOfProductBundleLineItem.add(productChargeWrapperCharges.productLine);
                            }else {
                                setOfProductCharge.add(productChargeWrapperCharges.productCharge.Id);
                            }
                        }
                    }
                }

                // This is used to delete the unselected charges on step2 and update the group
                if(!listOfProductBundleLineItem.isEmpty()) {

                    if(isEditMode) {
                         list<Product_Bundle_Line__c> listOfProductBundleLineItemToDelete = [SELECT Id FROM Product_Bundle_Line__c
                                                                                                 WHERE 
                                                                                                 (Product__c IN:setofProductIdDelete 
                                                                                                     OR
                                                                                                 Product_Rate_Plan_Charge__c IN:setOfProductCharge
                                                                                                 )
                                                                                                AND
                                                                                                Product_Bundle__c =: productBundle.Id
                        ];
                        delete  listOfProductBundleLineItemToDelete;                                                                  
                    }

                    upsert productBundle;
                    //Assigning the Bundle Id for new line Line Items
                    for(Product_Bundle_Line__c line : listOfProductBundleLineItem) {
                        if(line.Id == null) {
                            line.Product_Bundle__c = productBundle.Id;
                        }
                    }

                    upsert listOfProductBundleLineItem;

                }else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, system.Label.SelectCharge)); 
                    return null;
                }
            } catch(Exception ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, system.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber())); 
                return null;
            }
            return new pagereference('/' + productBundle.id);
        }

        // order charge wrapper class, This is used to display on step2 for selecting the charges
        public class ProductChargeWrapperCharges {
            public boolean isSelectedCharge {get;set;}
            public Product_Rate_Plan_Charge__c productCharge {get;set;}
            public Product_Bundle_Line__c productLine {get;set;}
            public ProductChargeWrapperCharges() {
                // Added by Kesav Madhu:INVOICEIT-611
                isSelectedCharge = false;
                productCharge = new Product_Rate_Plan_Charge__c();
                productLine = new Product_Bundle_Line__c(Quantity__c = 0.00, Unit_Price__c = 0.00,Is_Price_Editable__c = false, Is_Quantity_Editable__c = false);
            }
        }

        // ProductRatePlan inner class is used to display ratePlans in the popup for selected product
        public class ClassProductRatePlan {
            public boolean isSelected {get;set;}
            public Product_Rate_Plan__c productRatePlan {get;set;}
            public ClassProductRatePlan() {
                isSelected = false;
            }
        }
        
        public PageReference cloneProductBundle() {
            String ProductBundleId;
            savepoint sp = Database.setSavepoint();
            try{
                
            }
            catch(Exception ex){
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber());
                Apexpages.addMessage(errorMessage);
                DataBase.RollBack(sp); 
                return null;
            }
            
            return new PageReference('/' + ProductBundleId);
        }
        
        
    }