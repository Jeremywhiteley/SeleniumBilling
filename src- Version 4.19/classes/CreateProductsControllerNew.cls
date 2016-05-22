public with sharing class CreateProductsControllerNew {

        public list<Product__c> listProducts {get; set;}
        public boolean displayRelatedList{get;set;}
        public Product__c product {get; set;}
        public Product_Rate_Plan__c ratePlan {get; set;}
        public Product_Rate_Plan_Charge__c ratePlanCharge {get; set;}
        public list<Product_Rate_Plan__c> listOfratePlan {get; set;}
        public list<Product_Rate_Plan_Charge__c> listOfratePlanCharges {get; set;}
        public list<string> listCurrencies{ get; set; }
        public ProductClass productClass {get; set;}
        public ProductClass productClassWithoutClone;
        public ProductRatePlanClass productRatePlanClass {get; set;}
        public ProductRatePlanChargeClass productRatePlanChargeClass = new ProductRatePlanChargeClass();
        public ProductRatePlanChargeTierClass productRatePlanChargeTierClass = new ProductRatePlanChargeTierClass();
        private Integer productRatePlanCounter = 0;
        private Integer productRateplanChargeCounter = 0;
        private Integer productRateplanChargeTierCounter = 0;
        public Integer currentRPCounter {get; set;}
        public Integer currentRatePlanCounter {get; set;}
        public Integer currentRatePlanChargeCounter {get; set;}
        public boolean isViewMode {get;set;}    
        public Product_Rate_Plan_Charge_Tier__c productTier{get; set;}
        public integer productrateplanchargeCounterfortier {get; set;}
        public boolean isSelectAll {get;set;}
        public list<ProductRatePlanChargeClass> listProductRatePlanChargeClasses {get; set;}
        public String sChargeCloneName {get; set;}
        public String sChargeName {get; set;}
        public boolean displayProductPopUp {get; set;}
        public boolean displayCloneProductPopUp {get; set;}
        public boolean displayRatePlanPopUp {get; set;}
        public boolean displayClonedRatePlanPopUp {get; set;}
        public boolean displayOptionPopup {get; set;}
        public boolean displayChargesPopUp {get; set;}
        public boolean displayProductLayout {get; set;}
        public boolean displayRatePlanLayout {get; set;}
        public boolean displayChargesLayout {get; set;} 
        public boolean displaychargeOptionPopup  {get; set;}
        public boolean displayClonedChargePopUp {get; set;}
        public boolean displaySelectedCharges {get; set;}
        public boolean displayTierSection {get; set;}
        public boolean saveNewChargeDisabled{get;set;}
        public String sProductActionString {get; set;}
        public String sChargesActionString {get; set;}
        public String sRatePlanActionString {get; set;}
        public String sCurrentRatePlanId {get; set;}
        private String sClonedButtonOption;
        private String sClonedChargeButtonOption;
        public String sColorGreen ='#299a0b';
        public String sColorRed ='#ff1a00';
        public String sColorOrange ='#FF6600';
        public String sProductEffectivePeriod {get; set;}
        public String sProductStyle {get; set;}
        public String sProductActive {get; set;}
        public boolean displayProductToolTip {get; set;}
        private Date currentDate;
        public String finalSelectedProductFields { get; set; }
        public String finalSelectedRatePlanFields { get; set; }
        public String finalSelectedChargeFields { get; set; }
        public SelectOption[] selectedProductFields { get; set; }
        public SelectOption[] selectedRatePlanFields { get; set; }
        public SelectOption[] availableProductFields { get; set; }
        public SelectOption[] availableRatePlanFields { get; set; }
        public SelectOption[] selectedChargeFields { get; set; }
        public SelectOption[] availableChargeFields { get; set; }
        public SelectOption[] selectedFields { get; set; }
        public SelectOption[] availableFields { get; set; }
        public String message { get; set; }
        public Layout_Fields__c layoutProductFields;
        public Layout_Fields__c layoutRatePlanFields;
        public Layout_Fields__c layoutFields;
        public Layout_Fields__c layoutChargeFields;
        public list<String> listFields { get; set; }
        public list<String> listLabels { get; set; }
        public list<String> listProductFields { get; set; }
        public list<String> listProductLabels { get; set; }
        public list<String> listRatePlanFields { get; set; }
        public list<String> listRatePlanLabels { get; set; }
        public list<String> listChargeFields { get; set; }
        public list<String> listChargeLabels { get; set; }
        public Product_Rate_Plan__c productRatePlanTobeClone { get; set; }
        public Product__c newProductTobeClone { get; set; }
        private set<String> setIgnoreFields;
        public String sEditSelected {get;set;}
        public String sPriceFormat {get;set;}
        public String sDynamicwidthRateplanLabel {get;set;}
        public String sDynamicwidthRateplanField {get;set;}
        public String sDynamicwidthProductLabel {get;set;}
        public String sDynamicwidthProductField {get;set;}
        public String sDynamicwidthChargeLabel {get;set;}
        public String sDynamicwidthChargeField {get;set;}
        public map<String,String> mapRateplanFields_Labels {get;set;}
        public map<String,String> mapProductFields_Labels {get;set;}
        public list<string> listselectOptionsforCurrency{ get; set; }
        public list<string> listPriceType { get; set; }
        public String sFilterString { get; set; }
        public String sRatePlanName { get; set; }
        public boolean isTierErrorMsg {get; set;}
        public String sCurrentChargeId;
        public String sProductColumnsWidth {get; set;}
        public String sRateplanColumnsWidth {get; set;}
        public String sChargeColumnsWidth {get; set;}
        public String sProductLabel {get; set;}
        public String sRatePlanLabel {get; set;}
        public String sChargeLabel {get; set;}
        public boolean renderRatePlan   {get; set;}
        public boolean renderCharge   {get; set;}
        public boolean hasNext{get; set;}
        public boolean hasPrevious{get; set;}
        public boolean hasNextCharge{get; set;}
        public boolean hasPreviousCharge{get; set;}
        public boolean disableButton {get; set;}
        public  String sPrefix {get; set;}

        // modified by Laxman:March 11
        map<Integer, ProductRatePlanClass> mapCounterProdRatePlanClass = new map<Integer, ProductRatePlanClass>();
        public ProductRatePlanClass prodRatePlanClassToDisplay {set; get;}

        //modified by Laxman:March 11
        map<Integer, ProductRatePlanChargeClass> mapCounterProdRatePlanChargeClass = new map<Integer, ProductRatePlanChargeClass>();
        public ProductRatePlanChargeClass prodRatePlanChargeClassToDisplay {set; get;}

        // modified by Laxman:March 11
        map<Integer, list<ProductRatePlanChargeTierClass>> mapCounterTierClass = new map<Integer,list<ProductRatePlanChargeTierClass>>();
        public  list<ProductRatePlanChargeTierClass> prodTierDisplay {set; get;}

        CustomIterableForRatePlan customIterableForRatePlanObj;
        CustomIterableForRatePlanCharges customIterableForRatePlanChargesObj;
        list<Product_Rate_Plan_Charge__c> listchargesLocal;

        public CreateProductsControllerNew(ApexPages.StandardController stdController) {
            sPrefix = CommonUtilClass.getPrefix();
            this.product = (Product__c)stdController.getRecord();
            currentDate = System.today();
            setIgnoreFields = new set<String>();
            renderRatePlan = false;
            renderCharge = false;
            hasNextCharge = false;
            hasPreviousCharge = false;
            disableButton = false;
            try {
                displayRelatedList = Configuration__c.getValues('DISPLAY_PRODUCT_RELATED_LIST').Boolean_Value__c;
                // get all the column widths
                sProductColumnsWidth = '';
                sRateplanColumnsWidth = '';
                sChargeColumnsWidth = '';
                // set of fields are added in the set below 'setIgnoreFields' which need to be ignored in the layout addition
                setIgnoreFields.add(ProductCreationUtil.VALID_FROM_DATE);
                setIgnoreFields.add(ProductCreationUtil.VALID_TO_DATE);

                // setLayoutFields is the common method to set the layout fields for all the sections product,rateplan,charges on Load of the page
                setLayoutFields(ProductCreationUtil.PRODUCT_OBJECT_NAME,setIgnoreFields);
                setLayoutFields(ProductCreationUtil.RATEPLAN_OBJECT_NAME,setIgnoreFields);
                setLayoutFields(ProductCreationUtil.CHARGE_OBJECT_NAME,setIgnoreFields);

                // This below query is to pull the list of currencies and display the in the filter currency picklist
                list<Currency__c> listCurrency = [SELECT Name From Currency__c where Name != null];
                if(!listCurrency.isempty()){
                    listselectOptionsforCurrency = new list<string>();
                    for(Currency__c currency1 : listCurrency){
                        listselectOptionsforCurrency.add(currency1.name);
                    }
                }

                // This below code is to get the list of price types and display the in the filter currency picklist
                Schema.DescribeFieldResult fieldResult = Product_Rate_Plan_Charge__c.Price_Type__c.getDescribe();
                list<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                listPriceType = new  list<string>();       
                for( Schema.PicklistEntry f : ple) {
                    listPriceType.add(f.getValue());
                }       

                productClass = new ProductClass();
                // if create product then execute if condition else if edit then go to else condition
                if(product.id == null) {
                    product.Name = ''; 
                    product.Valid_From_Date__c = system.Today();
                    sProductActionString = system.label.LabelcreateProduct;
                } 
                else {
                    sProductActionString = system.Label.LabelEditProduct;
                    this.product = ProductCreationUtil.getProduct(product.id); 
                    customIterableForRatePlanObj = new CustomIterableForRatePlan(product.Id);
                    listOfratePlan = customIterableForRatePlanObj.first();
                    intilizeRatePlans();
                }
            } catch(Exception ex) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            } 
        }

        // on click of new Rate plan this method will be called
        public Pagereference newRatePlan() {
            sProductColumnsWidth = getColumnWidths(sProductLabel);
            sRateplanColumnsWidth = getColumnWidths(sRatePlanLabel);
            sChargeColumnsWidth =  getColumnWidths(sChargeLabel);
            displayRatePlanPopUp = true;
            sRatePlanActionString = system.Label.LabelNewRatePlan;
            ratePlan = new Product_Rate_Plan__c();
            ratePlan.Name = '';

            // Modified by Dev M INVOICEIT-533 This works properly for new customer's
            ratePlan.Sequence_Number__c = productRPSequenceNumber();
            productRatePlanClass = new  ProductRatePlanClass();
            productRatePlanClass.productRatePlan = ratePlan;
            productRatePlanClass.productRatePlanCounter = ++productRatePlanCounter;
            productClass.productRatePlans.add(productRatePlanClass);
            currentRPCounter = productRatePlanCounter;
            // modified by Laxman:March 11
            mapCounterProdRatePlanClass.put(productRatePlanCounter, productRatePlanClass);
            return null;
        }

        public decimal productRPSequenceNumber() {
           
            AggregateResult[] groupedResults = [SELECT max(Sequence_Number__c) maxSequenceNumber FROM Product_Rate_Plan__c WHERE Product__c =: product.Id AND Sequence_Number__c != null];
            decimal maxSequenceNumber = (decimal) groupedResults.get(0).get('maxSequenceNumber');

            if( maxSequenceNumber == null ) {
                   return 1;
            } else {
                 return maxSequenceNumber+1;
            }
        }
        // on click of Save button on create Product this method will be called
        public PageReference saveProduct() {  
            displayProductPopUp = false;
            string productFirstFifteenCharacters;
            displayProductPopUp = false;
            PageReference secondPage;
            try { 
                if(product != null){
                    upsert product;
                    productFirstFifteenCharacters = product.Id;
                    productFirstFifteenCharacters = productFirstFifteenCharacters.subString(0,15);
                    secondPage = new  PageReference('/apex/createProductStep2New?id='+productFirstFifteenCharacters);
                    secondPage.setRedirect(true);
                }
                return secondPage;
            } catch(DMLException dMlEx){
                // Added by Mani:INVOICEIT-310
                Apexpages.Message errorMessage; 
                for (Integer i = 0; i < dMlEx.getNumDml(); i++)
                { 
                    errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(i));
                    Apexpages.addMessage(errorMessage);      
                } 
                return null; 
            } catch(Exception ex) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
                return null;
            }
        }

        // on click of Del link to delete a Product this method will be called
        public PageReference deleteProduct() {
            string productFirstThreeCharacters;

            try {
                productFirstThreeCharacters = product.Id;
                productFirstThreeCharacters = productFirstThreeCharacters.subString(0,3) + '/o';
                delete product;    
            } catch(Exception ex) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
                return null;
            }
            return new PageReference('/' + productFirstThreeCharacters);
        }

        // on click of Save button while editing a Product this method will be called
        public PageReference updateProduct() {  
            displayProductPopUp = false;
            savepoint sp;
            try { 
                String sProductValiddate ='';
                upsert product;
                product = ProductCreationUtil.getProduct(product.id);
            } catch(DMLException dMlEx){ 
                // Added by Mani:INVOICEIT-310
                Apexpages.Message errorMessage; 
                for (Integer i = 0; i < dMlEx.getNumDml(); i++)
                { 
                    errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(i));
                    Apexpages.addMessage(errorMessage);      
                } 
                return null; 
            } catch(Exception ex) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            }

            return null;
        }  

        // on click of edit link a pop up will be opened for editing product when this method will be called
        public PageReference editProduct(){
            sProductColumnsWidth = getColumnWidths(sProductLabel);
            displayProductPopUp = true;
            return null;
        }

        // on click of clone link a pop up will be opened for cloning product when this method will be called
        public void cloneProduct() { 
            sProductColumnsWidth = getColumnWidths(sProductLabel);
            displayCloneProductPopUp = true;
            sProductActionString = system.Label.LabelCloneProduct;
        }

        // on click of Save button while cloning a Product this method will be called
        public Pagereference saveClonedProduct(){
            displayCloneProductPopUp = false;
            savepoint sp;
            Product_Rate_Plan__c productRatePlanTobeClone;
            Product_Rate_Plan_Charge__c productRatePlanchargeTobeClone;
            Product_Rate_Plan_Charge_Tier__c tierTobeClone;
            Product_Rate_Plan_Charge_Tier__c productTierTobeClone;
            try { 
                sp = DataBase.SetSavePoint();
                productData();
                newProductTobeClone = product.clone(false);
                newProductTobeClone.OwnerId = UserInfo.getUserId();
                if(newProductTobeClone != null){
                    upsert newProductTobeClone;
                }

                productClass.product = newProductTobeClone;
                product = productClass.product;

                for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                    productRatePlanTobeClone = prpclass.productRatePlan.clone(false);
                    productRatePlanTobeClone.Product__c = null;
                    prpclass.productRatePlan = productRatePlanTobeClone;
                } 

                for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                    for(ProductRatePlanChargeClass prpcclass : prpclass.productRatePlanChargeClass) {
                        productRatePlanchargeTobeClone = prpcclass.productRatePlancharge.clone(false);
                        productRatePlanchargeTobeClone.Product_Rate_Plan__c = null;
                        prpcclass.productRatePlancharge = productRatePlanchargeTobeClone;
                    }
                }

                for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                    for(ProductRatePlanChargeClass prpcclass : prpclass.productRatePlanChargeClass) {
                        for(ProductRatePlanChargeTierClass tierclass : prpcclass.ProductRatePlanChargeTierClass) {
                            tierTobeClone = tierclass.productRatePlanChargeTier.clone(false);
                            tierTobeClone.Product_Rate_Plan_Charge__c = null;
                            tierclass.productRatePlanChargeTier = tierTobeClone;
                        }
                    }
                }

                list<Product_Rate_Plan__c> listProductRatePlan = new list<Product_Rate_Plan__c>();        
                for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                    if(prpclass.productRatePlan.Product__c == null) {
                        prpclass.productRatePlan.Product__c = product.Id;
                    }
                    listProductRatePlan.add(prpclass.productRatePlan);
                } 

                if(!listProductRatePlan.isEmpty()){
                    upsert listProductRatePlan;
                }

                list<Product_Rate_Plan_Charge__c> listProductRatePlanCharges = new list<Product_Rate_Plan_Charge__c>();
                for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                    for(ProductRatePlanChargeClass prpcclass : prpclass.productRatePlanChargeClass) {
                        if(prpcclass.productRatePlancharge.Product_Rate_Plan__c == null) {
                            prpcclass.productRatePlancharge.Product_Rate_Plan__c = prpclass.productRatePlan.Id;
                        }
                        listProductRatePlanCharges.add(prpcclass.productRatePlancharge);
                    }
                }

                if(!listProductRatePlanCharges.isEmpty()){
                    upsert listProductRatePlanCharges;
                }

                list<Product_Rate_Plan_Charge_Tier__c> listTiers = new list<Product_Rate_Plan_Charge_Tier__c>();
                for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                    for(ProductRatePlanChargeClass prpcclass : prpclass.productRatePlanChargeClass) {
                        for(ProductRatePlanChargeTierClass tierclass : prpcclass.ProductRatePlanChargeTierClass) {
                            if(tierclass.productRatePlanChargeTier.Product_Rate_Plan_Charge__c == null) {
                                tierclass.productRatePlanChargeTier.Product_Rate_Plan_Charge__c = prpcclass.productRatePlancharge.Id;
                            }
                            listTiers.add(tierclass.productRatePlanChargeTier);
                        }
                    }
                }

                if(!listTiers.isEmpty()){
                    upsert listTiers;   
                } 
                Pagereference ref = new Pagereference('/apex/createProductStep2New?id='+newProductTobeClone.id);
                ref.setRedirect(true);
                return ref;
            }  catch(DMLException dMlEx){
                // Added by Mani:INVOICEIT-310
                Apexpages.Message errorMessage; 
                for (Integer i = 0; i < dMlEx.getNumDml(); i++)
                { 
                    errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(i));
                    Apexpages.addMessage(errorMessage);      
                } 
                return null; 
            }  catch(Exception ex) {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,ex.getMessage());
                Apexpages.addMessage(errorMessage);
                DataBase.RollBack(sp);  
                return null;
            }
        }

        // on click of Save button while cloning a rateplan this method will be called
        public Pagereference saveClonedRatePlan(){
            displayClonedRatePlanPopUp = false;
            Integer iClonedRatePlanCounter;
            Product_Rate_Plan_Charge__c productRatePlanchargeTobeClone;
            savepoint sp;
            try { 
                sp = DataBase.SetSavePoint();
                upsert productRatePlanTobeClone;

                product = ProductCreationUtil.getProduct(product.id);

                list<ProductRatePlanChargeTierClass> listTierClass = new list<ProductRatePlanChargeTierClass>();
                list<Product_Rate_Plan_Charge_Tier__c> listTiers = new list<Product_Rate_Plan_Charge_Tier__c>();  
                list<Product_Rate_Plan__c> listProductRatePlan = new list<Product_Rate_Plan__c>();  
                list<ProductRatePlanChargeClass> listProductRatePlanChargeClass = new list<ProductRatePlanChargeClass>();
                if(sClonedButtonOption== ProductCreationUtil.CLONE_RATEPLAN) {

                    for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                        prpclass.productRatePlanChargeClass = new list<ProductRatePlanChargeClass>();
                    }

                    ProductRatePlanClass productRatePlanClass = new ProductRatePlanClass();
                    productRatePlanClass.productRatePlan = productRatePlanTobeClone;
                    productRatePlanClass.productRatePlanCounter = ++productRatePlanCounter;
                    productClass.productRatePlans.add(productRatePlanClass); 

                    // modified by Laxman:March 11
                    mapCounterProdRatePlanClass.put(productRatePlanCounter, productRatePlanClass);
                }
                else if(sClonedButtonOption== ProductCreationUtil.CLONE_WITH_CHARGES) {
                    string sRateplnId;
                    // get the rateplan id 
                    for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                        if(prpclass.productRatePlanCounter == currentRPCounter) {
                            sRateplnId = prpclass.productRatePlan.id;
                            break;
                        }
                    }
                    listProductRatePlanChargeClasses = new list<ProductRatePlanChargeClass>();
                    set<Id> setOfRatePlanChargesIds = new set<Id>();

                    list<Product_Rate_Plan_Charge__c> listcharges = ProductCreationUtil.getProductRatePlanCharges(sRateplnId);
                    // add the charges to list on selection of clone rate plan
                    for(ProductRatePlanClass prpc : productClass.productRatePlans) {
                        if(prpc.productRatePlanCounter == currentRPCounter) {
                            prpc.productRatePlanChargeClass = new list<ProductRatePlanChargeClass>();
                            for(Product_Rate_Plan_Charge__c charge : listcharges) {
                                productRatePlanChargeClass = new ProductRatePlanChargeClass();
                                productRatePlanChargeClass.productRatePlancharge = charge;
                                productRatePlanChargeClass.productRatePlanChargeCounter = ++productRateplanChargeCounter;
                                prpc.productRatePlanChargeClass.add(productRatePlanChargeClass);
                                setOfRatePlanChargesIds.add(charge.id);
                            }
                        }else{
                            prpc.productRatePlanChargeClass = new list<ProductRatePlanChargeClass>();
                        }
                    }                     
                    list<Product_Rate_Plan_Charge_Tier__c> listOfTiers = ProductCreationUtil.getListOfTiers(setOfRatePlanChargesIds);
                    // add the tiers
                    for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                        for(ProductRatePlanChargeClass prpcclass : prpclass.productRatePlanChargeClass) {
                            for(Product_Rate_Plan_Charge_Tier__c tier : listOfTiers) {
                                if(prpcclass.productRatePlancharge.Id == tier.Product_Rate_Plan_Charge__c) {
                                    productRatePlanChargeTierClass = new ProductRatePlanChargeTierClass();
                                    productRatePlanChargeTierClass.productRatePlanChargeTierCounter = ++productRateplanChargeTierCounter;
                                    productRatePlanChargeTierClass.productRatePlanChargeTier = tier;
                                    prpcclass.ProductRatePlanChargeTierClass.add(productRatePlanChargeTierClass);
                                }
                            }
                        }
                    }
                    // upto above line

                    ProductRatePlanClass productRatePlanClass = new ProductRatePlanClass();
                    productRatePlanClass.productRatePlan = productRatePlanTobeClone;
                    productRatePlanClass.productRatePlanCounter = ++productRatePlanCounter;
                    iClonedRatePlanCounter = productRatePlanClass.productRatePlanCounter;
                    productClass.productRatePlans.add(productRatePlanClass);

                    // modified by Laxman:March 11
                    mapCounterProdRatePlanClass.put(productRatePlanCounter, productRatePlanClass);

                    for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                        if(prpclass.productRatePlanCounter == currentRPCounter) {
                            for(ProductRatePlanChargeClass prpcclass : prpclass.productRatePlanChargeClass) {
                                productRatePlanchargeTobeClone = prpcclass.productRatePlancharge.clone(false);
                                productRatePlanchargeTobeClone.Product_Rate_Plan__c = null;
                                ProductRatePlanChargeClass productRatePlanChargeClass = new ProductRatePlanChargeClass();
                                productRatePlanChargeClass.productRatePlancharge = productRatePlanchargeTobeClone;
                                productRatePlanChargeClass.productRatePlanChargeCounter = ++productRateplanChargeCounter;

                                for(ProductRatePlanChargeTierClass tierclass : prpcclass.ProductRatePlanChargeTierClass) {
                                    productTier = new Product_Rate_Plan_Charge_Tier__c();
                                    productTier = tierclass.productRatePlanChargeTier.clone(false);
                                    productTier.Product_Rate_Plan_Charge__c = null;
                                    productRatePlanChargeTierClass = new ProductRatePlanChargeTierClass();
                                    productRatePlanChargeTierClass.productRatePlanChargeTier = productTier;
                                    productRatePlanChargeTierClass.productRatePlanChargeTierCounter = ++productRateplanChargeTierCounter;
                                    productRatePlanChargeClass.ProductRatePlanChargeTierClass.add(productRatePlanChargeTierClass);
                                } 
                                listProductRatePlanChargeClass.add(productRatePlanChargeClass);
                            }
                            break;
                        }
                    }

                    for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                        if(prpclass.productRatePlanCounter == iClonedRatePlanCounter) {
                            for(ProductRatePlanChargeClass prpcclass : listProductRatePlanChargeClass) {
                                prpclass.productRatePlanChargeClass.add(prpcclass);
                            }
                            break;
                        }
                    }
                }  

                String sQuery = ProductCreationUtil.getObjectSelectQuery(sPrefix+'Product_Rate_Plan__c') + ' WHERE Id =' + '\'' + String.escapeSingleQuotes(productRatePlanTobeClone.id) + '\'';
                Product_Rate_Plan__c productRatePlan  = Database.query(sQuery);
                list<Product_Rate_Plan_Charge__c> listProductRatePlanCharges = new list<Product_Rate_Plan_Charge__c>();
                for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                    if(prpclass.productRatePlan == productRatePlanTobeClone){
                        prpclass.productRatePlan = productRatePlan;
                        for(ProductRatePlanChargeClass prpcclass : prpclass.productRatePlanChargeClass) {
                            if(prpcclass.productRatePlancharge.Product_Rate_Plan__c == null) {
                                prpcclass.productRatePlancharge.Product_Rate_Plan__c = productRatePlanTobeClone.Id;
                            }
                            listProductRatePlanCharges.add(prpcclass.productRatePlancharge);
                        }
                        break;
                    }
                }

                if(!listProductRatePlanCharges.isEmpty()){
                    upsert listProductRatePlanCharges;
                }

                sQuery = ProductCreationUtil.getObjectSelectQuery(sPrefix+'Product_Rate_Plan__c') + ' where Id =' + '\'' + String.escapeSingleQuotes(productRatePlanTobeClone.id) + '\'';
                Product_Rate_Plan__c productRatePlanLatest  = Database.query(sQuery);
                // Adding the element to the list
                customIterableForRatePlanObj.listofRatePlans.add(productRatePlanLatest);

                for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                    if(prpclass.productRatePlan == productRatePlan){
                        prpclass.productRatePlan = productRatePlanLatest;
                        for(ProductRatePlanChargeClass prpcclass : prpclass.productRatePlanChargeClass) {
                            for(ProductRatePlanChargeTierClass tierClass : prpcclass.ProductRatePlanChargeTierClass) {
                                tierClass.productRatePlanChargeTier.Product_Rate_Plan_Charge__c = prpcclass.productRatePlancharge.Id;
                                listTiers.add(tierClass.productRatePlanChargeTier);
                            }
                        }
                        break;
                    }
                }

                if(!listTiers.isEmpty()){
                    upsert listTiers;
                }

                if(sClonedButtonOption== ProductCreationUtil.CLONE_WITH_CHARGES) {
                    listProductRatePlanChargeClasses = new list<ProductRatePlanChargeClass>();
                    for(ProductRatePlanClass prpc : productClass.productRatePlans) {
                        productRatePlanChargeClass = new ProductRatePlanChargeClass();
                    }
                    system.currentPageReference().getParameters().put('counterForRatePlan',string.valueof(iClonedRatePlanCounter));
                    system.currentPageReference().getParameters().put('ratePlanId',productRatePlanTobeClone.id);
                    onClickRatePlan();
                } else{
                    system.currentPageReference().getParameters().put('counterForRatePlan',string.valueof(productRatePlanCounter));
                    system.currentPageReference().getParameters().put('ratePlanId',productRatePlanTobeClone.id);
                    onClickRatePlan();
                }     

                if(productClass.productRatePlans.size() > customIterableForRatePlanObj.setPageSize) {
                    productClass.productRatePlans.remove(0);
                }else{
                    customIterableForRatePlanObj.i++;
                }

                if(customIterableForRatePlanObj.listofRatePlans.size() >= customIterableForRatePlanObj.setPageSize) {
                    hasNext = customIterableForRatePlanObj.hasNext();
                    hasPrevious = customIterableForRatePlanObj.hasPrevious();
                }
                return null;
            }  catch(DMLException dMlEx){ 
                // Added by Mani:INVOICEIT-310
                Apexpages.Message errorMessage; 
                for (Integer i = 0; i < dMlEx.getNumDml(); i++)
                { 
                    errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(i));
                    Apexpages.addMessage(errorMessage);      
                } 
                return null; 
            }  catch(Exception ex) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
                DataBase.RollBack(sp);  
                return null;
            }
        }

        // on click of Save button while edit or create a rateplan this method will be called
        public Pagereference saveRatePlan() {
            displayRatePlanPopUp = false;
            savepoint sp;
            try { 
                sp = DataBase.SetSavePoint();
                map<Id,Product_Rate_Plan__c> mapProductRatePlan = new map<Id,Product_Rate_Plan__c>();
                list<Product_Rate_Plan__c> listProductRatePlan = new list<Product_Rate_Plan__c>();
                list<Id> listProductRatePlanId = new list<Id>();

                for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                    if(prpclass.productRatePlan.Product__c == null) {
                        prpclass.productRatePlan.Product__c = product.Id;
                        sCurrentRatePlanId = null;
                    }
                    listProductRatePlan.add(prpclass.productRatePlan);
                } 

                if(!listProductRatePlan.isEmpty()) {
                    upsert listProductRatePlan;
                }

                product = ProductCreationUtil.getProduct(product.id);

                for(Product_Rate_Plan__c  productRatePlan: listProductRatePlan) {
                    listProductRatePlanId.add(productRatePlan.Id);
                } 
                // removing the element from the list if the size of the list is more than navigation page size
                if(listProductRatePlan.size() > customIterableForRatePlanObj.setPageSize) {
                    customIterableForRatePlanObj.listofRatePlans.add(listProductRatePlan[listProductRatePlan.size()-1]);
                    listProductRatePlanId.remove(1);
                    productClass.productRatePlans.remove(1);
                }else if(sCurrentRatePlanId == null){
                    customIterableForRatePlanObj.listofRatePlans.add(listProductRatePlan[listProductRatePlan.size()-1]);
                    customIterableForRatePlanObj.i++;
                }

                String sQuery = ProductCreationUtil.getObjectSelectQuery(sPrefix+'Product_Rate_Plan__c') + ' where Id in: listProductRatePlanId ';
                sQuery = String.escapeSingleQuotes(sQuery);
                list<Product_Rate_Plan__c>  listProductRatePlan1  = Database.query(sQuery);

                for(Product_Rate_Plan__c productRatePlan : listProductRatePlan1) {
                    mapProductRatePlan.put(productRatePlan.id,productRatePlan);
                }

                for(ProductRatePlanClass productRatePlanClass : productClass.productRatePlans) {
                    if(mapProductRatePlan.containsKey(productRatePlanClass.productRatePlan.id)) {
                        productRatePlanClass.productRatePlan = mapProductRatePlan.get(productRatePlanClass.productRatePlan.id);
                    }
                } 

                if(productClass.productRatePlans.size() >= 1) {
                    if(sCurrentRatePlanId == null) {
                        sCurrentRatePlanId = productClass.productRatePlans[productClass.productRatePlans.size() - 1].productRatePlan.Id;
                        currentRatePlanCounter = productClass.productRatePlans[productClass.productRatePlans.size() - 1].productRatePlanCounter;
                        prodRatePlanClassToDisplay = new ProductRatePlanClass();
                        customIterableForRatePlanChargesObj = new CustomIterableForRatePlanCharges(sCurrentRatePlanId);
                        hasNext = customIterableForRatePlanObj.hasNext();
                        hasPrevious = customIterableForRatePlanObj.hasPrevious();
                        listchargesLocal = customIterableForRatePlanChargesObj.first();
                        hasNextCharge = customIterableForRatePlanChargesObj.hasNext();  
                        hasPreviousCharge = customIterableForRatePlanChargesObj.hasPrevious();
                        sFilterString = '';
                    }   
                } 

                if(!renderRatePlan) {
                    renderRatePlan = true;
                }
                string sSaveAndNewButton = system.currentPageReference().getParameters().get('SaveandNewRateplan');
                if(sSaveAndNewButton == ProductCreationUtil.SAVE_AND_NEW_RATEPLAN) {
                    sSaveAndNewButton = null;
                    newRatePlan();
                }  

                if(customIterableForRatePlanObj.listofRatePlans.size() >= customIterableForRatePlanObj.setPageSize) {
                    hasNext = customIterableForRatePlanObj.hasNext();
                    hasPrevious = customIterableForRatePlanObj.hasPrevious();
                }

                return null;
            }   catch(DMLException dMlEx){
                // Added by Mani ticket : INVOICEIT-310
                Apexpages.Message errorMessage; 
                for (Integer i = 0; i < dMlEx.getNumDml(); i++)
                { 
                    errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(i));
                    Apexpages.addMessage(errorMessage);      
                } 
                return null; 
            }   catch(Exception ex) {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.Exception_Message + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber());
                Apexpages.addMessage(errorMessage);
                DataBase.RollBack(sp);  
                return null;
            }
        }

        // on click of Cancel button on the product pop up while create,edit or clone this method will be called
        public void closeProductPopup() {
            displayProductPopUp = false;
            displayCloneProductPopUp = false;
        }

        // on click of Cancel button on the rateplan create,edit and clone pop up this method will be called
        public void closeRatePlanPopup() {
            displayRatePlanPopUp = false;
            displayClonedRatePlanPopUp = false;

            if(sRatePlanActionString == system.Label.LabelNewRatePlan) {
                integer productrateplansize = productClass.productRatePlans.size();
                for(Integer i = 0; i < productrateplansize; i++) {
                    if(productClass.productRatePlans.get(i).productRatePlanCounter == currentRPCounter) {
                        productClass.productRatePlans.remove(i);     
                        break;                
                    }
                }
            }
        }

        // on click of edit link a pop up will be opened for editing Rateplan when this method will be called
        public Pagereference editRatePlan() {
            displayRatePlanPopUp = true;
            sFilterString = '';
            sRatePlanActionString = system.Label.LabelEditRatePlan;
            currentRPCounter = integer.ValueOf(system.currentPageReference().getParameters().get('ratePlanCounter'));
            sProductColumnsWidth = getColumnWidths(sProductLabel);
            sRateplanColumnsWidth = getColumnWidths(sRatePlanLabel);
            sChargeColumnsWidth =  getColumnWidths(sChargeLabel);
            return null;
        }

        // on click of clone button on a pop up this method will be called
        public Pagereference cloneRatePlan() {
            displayClonedRatePlanPopUp = true;
            displayOptionPopup = false;
            sRatePlanActionString = system.Label.LabelCloneRatePlan;
            sProductColumnsWidth = getColumnWidths(sProductLabel);
            sRateplanColumnsWidth = getColumnWidths(sRatePlanLabel);
            sChargeColumnsWidth =  getColumnWidths(sChargeLabel);
            sClonedButtonOption = system.currentPageReference().getParameters().get('cloneRatePlan');
            if(sClonedButtonOption == ProductCreationUtil.CLONE_RATEPLAN) {
                for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                    if(prpclass.productRatePlanCounter == currentRPCounter) {
                        productRatePlanTobeClone = prpclass.productRatePlan.clone(false);
                        break;
                    } 
                }
            } else if(sClonedButtonOption == ProductCreationUtil.CLONE_WITH_CHARGES) {
                for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                    if(prpclass.productRatePlanCounter == currentRPCounter) {
                        productRatePlanTobeClone = prpclass.productRatePlan.clone(false);
                        break;
                    }
                }
            }

            productRatePlanTobeClone.Sequence_Number__c = productRPSequenceNumber();
            return null;
        }

        // on click of clone link a pop up will be opened with options for clone Rateplan  when this method  is called
        public Pagereference cloneRatePlanPopup(){
            displayOptionPopup = true;
            sFilterString = '';
            currentRPCounter = integer.ValueOf(system.currentPageReference().getParameters().get('ratePlanCounter'));
            sRatePlanName = system.currentPageReference().getParameters().get('ratePlanName');
            return null;
        }

        // on click of Cancel button on the rateplan option pop up  this method is called
        public void closeOptionPopup(){
            displayOptionPopup = false;
        } 

        // on click of Cancel button on the charge option pop up  this method is called
        public void closeChargeOptionPopup(){
            displaychargeOptionPopup = false;
        } 

        // on click of Del link to delete a Rateplan this method is called
        public Pagereference removeRatePlan() {  
            try {
                sProductColumnsWidth = getColumnWidths(sProductLabel);
                sRateplanColumnsWidth = getColumnWidths(sRatePlanLabel);
                sChargeColumnsWidth =  getColumnWidths(sChargeLabel);
                string productRatePlanId = system.currentPageReference().getParameters().get('productrateplanidtodelete');
                Integer productrateplancounterval = Integer.valueOf(system.currentPageReference().getParameters().get('productrateplancountertodelete'));

                if(productRatePlanId.Length() > 0) {         
                    Product_Rate_Plan__c prpToDelete = new Product_Rate_Plan__c(Id = productRatePlanId);
                    delete prpToDelete;
                    mapCounterProdRatePlanClass.remove(productrateplancounterval);
                    for(integer i=0; i<customIterableForRatePlanObj.listofRatePlans.size(); i++) {
                        if(customIterableForRatePlanObj.listofRatePlans[i].Id == productRatePlanId)  {
                            customIterableForRatePlanObj.listofRatePlans.remove(i);
                            break;
                        }
                    }
                }

                product = ProductCreationUtil.getProduct(product.id);
                integer productrateplansize = productClass.productRatePlans.size();
                integer IteratorlistofRatePlansize = customIterableForRatePlanObj.listofRatePlans.size();

                set<Id> setOfRatePlanAlreadyAdded = new set<Id>();
                for(Integer i = 0; i < productrateplansize; i++) {
                    setOfRatePlanAlreadyAdded.add(productClass.productRatePlans.get(i).productRatePlan.Id);
                }

                for(Integer i = 0; i < productrateplansize; i++) {
                    if(productClass.productRatePlans.get(i).productRatePlanCounter == productrateplancounterval) {
                        if((productrateplansize <= customIterableForRatePlanObj.setPageSize) && (IteratorlistofRatePlansize > 0 && productrateplansize > 1) &&(productrateplansize <= IteratorlistofRatePlansize) && !setOfRatePlanAlreadyAdded.contains(customIterableForRatePlanObj.listofRatePlans[IteratorlistofRatePlansize -1].Id)) {
                            productClass.productRatePlans[i].productRatePlan = customIterableForRatePlanObj.listofRatePlans[IteratorlistofRatePlansize -1]; 
                            mapCounterProdRatePlanClass.put(productrateplancounterval, productClass.productRatePlans[i]);
                        } else {
                            productClass.productRatePlans.remove(i);
                        }     
                        break;                
                    }
                }

                integer productRatePlansSize1 = productClass.productRatePlans.size();
                if(productRatePlansSize1 > 0) {
                    currentRatePlanCounter = productClass.productRatePlans.get(productRatePlansSize1 - 1).productRatePlanCounter;
                    sCurrentRateplanId = productClass.productRatePlans.get(productRatePlansSize1 - 1).productRatePlan.Id;
                    system.currentPageReference().getParameters().put('counterForRatePlan',string.valueof(currentRatePlanCounter));
                    system.currentPageReference().getParameters().put('ratePlanId',sCurrentRateplanId);
                    onClickRatePlan();
                } else {
                    prodRatePlanClassToDisplay = new ProductRatePlanClass();
                }
                if(customIterableForRatePlanObj.listofRatePlans.size() >= customIterableForRatePlanObj.setPageSize) {
                    hasNext = customIterableForRatePlanObj.hasNext();
                    hasPrevious = customIterableForRatePlanObj.hasPrevious();
                }
            } catch(Exception ex) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,ex.getMessage() + ex.getLinenumber()));
            }   
            return null;
        }

        public Pagereference updateRateplan() {
            return null;
        }

        // on click of new charge this method will be called
        public Pagereference newCharge() {
            sFilterString = '';
            displayChargesPopUp = true;
            sRateplanColumnsWidth = getColumnWidths(sRatePlanLabel);
            sChargeColumnsWidth =  getColumnWidths(sChargeLabel);
            Integer lastChargeSequenceNumber ; 
            map<Id,list<Product_Rate_Plan_Charge__c>> mapId_Charges = ProductCreationUtil.getMapId_Charges(product.Id);
            sChargesActionString = system.Label.LabelNewCharge;
            for(ProductRatePlanClass prpc : productClass.productRatePlans) {
                if(prpc.productRatePlanCounter == currentRatePlanCounter) {
                    productRatePlanChargeClass = new ProductRatePlanChargeClass();
                    ratePlanCharge = new Product_Rate_Plan_Charge__c();
                    // Modified by DEV M:INVOICEIT-534
                    String objectName= sPrefix+'Product_Rate_Plan_Charge__c';
                    Map<String, Schema.SObjectField> objectFieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
                    for(Schema.SObjectField column: objectFieldMap.values()) {
                        if(''+column.getDescribe().getType() == 'PICKLIST') {
                        List<Schema.PicklistEntry> picklistValues = objectFieldMap.get(''+column).getDescribe().getPickListValues();
                        for (Schema.PicklistEntry pickValue : picklistValues ) {
                            if (pickValue.isDefaultValue()) {
                                 ratePlanCharge.put(''+column, ''+pickValue.getValue());
                                 break;  
                            }    
                        }
                      }
                    } 

                    lastChargeSequenceNumber = getLastChargeSequenceNumber(mapId_Charges,prpc.productRatePlan.Id);
                    productRatePlanChargeClass.productRatePlanChargeCounter = ++productRateplanChargeCounter;
                    productRatePlanChargeClass.productRatePlancharge = ratePlanCharge;
                    ratePlanCharge.Charge_Sequence_Number__c = ++lastChargeSequenceNumber;
                    prpc.productRatePlanChargeClass.add(productRatePlanChargeClass);
                    currentRatePlanChargeCounter = productRateplanChargeCounter;
                    //modified by Laxman:March 11
                    mapCounterProdRatePlanChargeClass.put(productRateplanChargeCounter, productRatePlanChargeClass);
                }
            } 

            prodRatePlanChargeClassToDisplay = mapCounterProdRatePlanChargeClass.get(productRateplanChargeCounter);
            return null;    
        }

        // on click of a rateplan row this method will be called
        public Pagereference onClickRatePlan() {
            sFilterString = '';
            sRateplanColumnsWidth = getColumnWidths(sRatePlanLabel);
            sChargeColumnsWidth =  getColumnWidths(sChargeLabel);
            listProductRatePlanChargeClasses = new list<ProductRatePlanChargeClass>();
            currentRatePlanCounter = integer.ValueOf(system.currentPageReference().getParameters().get('counterForRatePlan'));
            sCurrentRatePlanId = system.currentPageReference().getParameters().get('ratePlanId');
            set<Id> setOfRatePlanChargesIds = new set<Id>();

            if(sCurrentRatePlanId != null) {
                customIterableForRatePlanChargesObj = new CustomIterableForRatePlanCharges(sCurrentRatePlanId);
                list<Product_Rate_Plan_Charge__c> listcharges = customIterableForRatePlanChargesObj.first();
                for(ProductRatePlanClass prpc : productClass.productRatePlans) {
                    prpc.productRatePlanChargeClass = new list<ProductRatePlanChargeClass>();
                    if(prpc.productRatePlanCounter == currentRatePlanCounter) {
                        if(!renderCharge) {
                            renderCharge = true;
                        }
                        prpc.productRatePlanChargeClass = new list<ProductRatePlanChargeClass>();
                        for(Product_Rate_Plan_Charge__c charge : listcharges) {
                            productRatePlanChargeClass = new ProductRatePlanChargeClass();
                            productRatePlanChargeClass.productRatePlancharge = charge;
                            productRatePlanChargeClass.productRatePlanChargeCounter = ++productRateplanChargeCounter;
                            prpc.productRatePlanChargeClass.add(productRatePlanChargeClass);
                            setOfRatePlanChargesIds.add(charge.id);
                        }
                        mapCounterProdRatePlanClass.put(currentRatePlanCounter,prpc);
                    } else{
                        prpc.productRatePlanChargeClass = new list<ProductRatePlanChargeClass>();
                    }
                }  
                prodRatePlanClassToDisplay = mapCounterProdRatePlanClass.get(currentRatePlanCounter);     
            } 

            if(customIterableForRatePlanChargesObj != null) {
                hasNextCharge = customIterableForRatePlanChargesObj.hasNext();  
                hasPreviousCharge = customIterableForRatePlanChargesObj.hasPrevious();
            }
            return null;
        }

        // on click of Save button while edit or create a charge this method will be called
        public Pagereference saveCharge(){
            saveNewChargeDisabled= true;
            displayChargesPopUp = false;
            displaySelectedCharges = false;
            isTierErrorMsg = false;
            SavePoint sp;
            String sValidateTier ='';
            try { 
                sp = DataBase.SetSavePoint();
                list<Product_Rate_Plan_Charge__c> listCharge = new list<Product_Rate_Plan_Charge__c>();
                list<Product_Rate_Plan_Charge_Tier__c> listTiers = new list<Product_Rate_Plan_Charge_Tier__c>();
                boolean isNew = false;
                if(customIterableForRatePlanChargesObj == null) {
                    customIterableForRatePlanChargesObj = new CustomIterableForRatePlanCharges(sCurrentRatePlanId);
                }
                for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                    for(ProductRatePlanChargeClass prpcclass : prpclass.productRatePlanChargeClass) {
                        if(prpcclass.productRatePlancharge.Product_Rate_Plan__c == null) {
                            prpcclass.productRatePlancharge.Product_Rate_Plan__c = sCurrentRatePlanId;
                            isNew = true;
                        }
                        listCharge.add(prpcclass.productRatePlancharge);
                    }
                }

                if(!listCharge.isEmpty()){
                    if(sEditSelected == null) {
                        sValidateTier = validateTiers();
                        if(sValidateTier == ProductCreationUtil.ERROR) {
                            displayChargesPopUp = true;
                            isTierErrorMsg = true;
                            return null;
                        }   
                    } 
                    upsert listCharge;      
                }

                for(ProductRatePlanClass prpc : productClass.productRatePlans) {
                    for(ProductRatePlanChargeClass prpcc : prpc.productRatePlanChargeClass) {
                        if(prpcc.productRatePlanChargeCounter == currentRatePlanChargeCounter) {
                            for(ProductRatePlanChargeTierClass tierclass : prpcc.ProductRatePlanChargeTierClass) {
                                if(tierclass.productRatePlanChargeTier.Product_Rate_Plan_Charge__c == null) {
                                    tierclass.productRatePlanChargeTier.Product_Rate_Plan_Charge__c = prpcc.productRatePlancharge.Id;
                                }
                                listTiers.add(tierclass.productRatePlanChargeTier);
                            }
                            if(isNew) {
                                customIterableForRatePlanChargesObj.listofCharges.add(prpcc.productRatePlancharge);
                                customIterableForRatePlanChargesObj.i++;
                            }
                        } 
                    }
                }

                // This is to remove one charge from the page, if exceeds the pageset size
                for(ProductRatePlanClass prpc : productClass.productRatePlans) {
                    for(ProductRatePlanChargeClass prpcc : prpc.productRatePlanChargeClass) {
                        if(prpc.productRatePlanChargeClass.size() > customIterableForRatePlanChargesObj.setPageSize) {
                            if(prpcc.productRatePlanChargeCounter != currentRatePlanChargeCounter) {
                                prpc.productRatePlanChargeClass.remove(0);
                                break;
                            } 
                        } 
                    }
                }


                if(!listTiers.isEmpty()){
                    upsert listTiers;      
                }

                map<Id,Product_Rate_Plan__c> mapId_ProductRatePlan = ProductCreationUtil.getProductRatePlans(product.Id);
                for(ProductRatePlanClass prpc : productClass.productRatePlans) {
                    if(prpc.productRatePlanCounter == currentRatePlanCounter) {
                        if(mapId_ProductRatePlan.containsKey(prpc.productRatePlan.Id)) {
                            prpc.productRatePlan = mapId_ProductRatePlan.get(prpc.productRatePlan.Id);
                        }
                    }
                }

                if(!renderCharge) {
                    renderCharge = true;
                }
                //Modified by Laxman:March 11
                prodRatePlanClassToDisplay = mapCounterProdRatePlanClass.get(currentRatePlanCounter);

                if(customIterableForRatePlanChargesObj.listofCharges.size() >= customIterableForRatePlanChargesObj.setPageSize) {
                    hasNextCharge = customIterableForRatePlanChargesObj.hasNext();  
                    hasPreviousCharge = customIterableForRatePlanChargesObj.hasPrevious();
                }else {
                    hasNextCharge = false;
                    hasPreviousCharge = false;
                }
            }  catch(DMLException dMlEx){ 
                // Added by Mani:INVOICEIT-310
                Apexpages.Message errorMessage; 
                for (Integer i = 0; i < dMlEx.getNumDml(); i++)
                { 
                    errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(i));
                    Apexpages.addMessage(errorMessage);      
                } 
                return null; 
            }   catch(Exception ex) {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber());
                Apexpages.addMessage(errorMessage);
                DataBase.RollBack(sp);  
                return null;
            }
            displayTierSection = false;
            sEditSelected = null;
            string sSaveAndNewButton = system.currentPageReference().getParameters().get('SaveandNew');
            if(sSaveAndNewButton== ProductCreationUtil.SAVE_AND_NEW) {
                sSaveAndNewButton = null;
                newCharge();
            }
            return null;
        }

        // on click of Cancel button on the charge pop up while create,edit this method will be called
        public void closeChargePopup(){
            displayChargesPopUp = false;
            displayTierSection = false;
            if(sChargesActionString == system.Label.LabelNewCharge) {
                for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                    if(prpclass.productRatePlanCounter == currentRatePlanCounter) {
                        for(Integer i = 0; i < prpclass.productRatePlanChargeClass.size() ; i++) {
                            if(prpclass.productRatePlanChargeClass.get(i).productRatePlanChargeCounter == currentRatePlanChargeCounter) {
                                prpclass.productRatePlanChargeClass.remove(i);
                                break;
                            }
                        }
                        break;
                    }
                }
            }
            sCurrentChargeId = null;
        }

        // on click of Del link to delete a charge this method is called
        public Pagereference removeRatePlanCharges() { 
            try { 
                sChargeColumnsWidth =  getColumnWidths(sChargeLabel);
                string productRateChargePlanId = system.currentPageReference().getParameters().get('chargeidtodelete');
                Integer productrateplanChargecounterval = Integer.valueOf(system.currentPageReference().getParameters().get('chargecountertodelete'));
                Integer productrateplancounter = Integer.valueOf(system.currentPageReference().getParameters().get('rateplancountertodelete'));

                Product_Rate_Plan_Charge__c prpcDelete;
                if(productRateChargePlanId.Length() > 0) {
                    prpcDelete = new Product_Rate_Plan_Charge__c(Id = productRateChargePlanId);
                    delete prpcDelete;
                    for(integer i =0; i< customIterableForRatePlanChargesObj.listofCharges.size(); i++) {
                        if( customIterableForRatePlanChargesObj.listofCharges[i].Id == productRateChargePlanId) {
                            customIterableForRatePlanChargesObj.listofCharges.remove(i);
                            break;
                        }
                    }
                }

                map<Id,Product_Rate_Plan__c> mapId_ProductRatePlan = ProductCreationUtil.getProductRatePlans(product.Id);
                Integer productrateplanChargesize;
                integer IteratorlistofChargesize = customIterableForRatePlanChargesObj.listofCharges.size();
                set<Id> setOfChargesAlreadyAdded = new set<Id>();

                for(ProductRatePlanClass prpclass : productClass.productRatePlans) {   
                    if(prpclass.productRatePlanCounter == productrateplancounter) {
                        productrateplanChargesize = prpclass.productRatePlanChargeClass.size();
                        for(Integer i = 0; i < productrateplanChargesize; i++) {
                            setOfChargesAlreadyAdded.add(prpclass.productRatePlanChargeClass[i].productRatePlancharge.Id);
                        }
                        break;
                    }
                }       

                for(ProductRatePlanClass prpclass : productClass.productRatePlans) {   
                    if(prpclass.productRatePlanCounter == productrateplancounter) {
                        for(Integer i = 0; i < productrateplanChargesize; i++) {
                            if(prpclass.productRatePlanChargeClass.get(i).productRatePlanChargeCounter == productrateplanChargecounterval) {
                                if((productrateplanChargesize <= customIterableForRatePlanChargesObj.setPageSize) && (IteratorlistofChargesize > 0 && productrateplanChargesize >1) && !setOfChargesAlreadyAdded.contains(customIterableForRatePlanChargesObj.listofCharges[IteratorlistofChargesize - 1].Id) ) {
                                    prpclass.productRatePlanChargeClass[i].productRatePlancharge = customIterableForRatePlanChargesObj.listofCharges[IteratorlistofChargesize - 1]; 
                                } else {
                                    prpclass.productRatePlanChargeClass.remove(i);
                                }   

                                if(mapId_ProductRatePlan.containsKey(prpclass.productRatePlan.Id)) {
                                    prpclass.productRatePlan = mapId_ProductRatePlan.get(prpclass.productRatePlan.Id);
                                }
                                break;
                            }
                        }
                    } 
                }
                if(customIterableForRatePlanChargesObj.listofCharges.size() >= customIterableForRatePlanChargesObj.setPageSize) {
                    hasNextCharge = customIterableForRatePlanChargesObj.hasNext();  
                    hasPreviousCharge = customIterableForRatePlanChargesObj.hasPrevious();
                }else {
                    hasNextCharge = false;
                    hasPreviousCharge = false;
                }
            } catch(Exception ex) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,ex.getMessage() + ex.getLinenumber()));
            }   
            return null;
        }

        // on click of edit link on charge this method will be called
        public Pagereference editCharges() {
            sChargeColumnsWidth =  getColumnWidths(sChargeLabel);
            displayChargesPopUp = true;
            sChargesActionString = system.Label.LabelEditCharge;
            currentRatePlanChargeCounter = integer.ValueOf(system.currentPageReference().getParameters().get('chargeCounter'));
            set<id> setOfRatePlanChargesIds = new set<id>();
            //Uncommented by Laxman:march 11  
            for(ProductRatePlanClass prpc : productClass.productRatePlans) {
                if(prpc.productRatePlanCounter == currentRatePlanCounter) {
                    for(ProductRatePlanChargeClass prpcclass : prpc.productRatePlanChargeClass) {
                        if(prpcclass.productRatePlanChargeCounter == currentRatePlanChargeCounter) {
                            sPriceFormat = prpcclass.productRatePlancharge.Price_Format__c;
                            setOfRatePlanChargesIds.add(prpcclass.productRatePlancharge.id);
                            prpcclass.ProductRatePlanChargeTierClass = new List<ProductRatePlanChargeTierClass>();
                            mapCounterProdRatePlanChargeClass.put(currentRatePlanChargeCounter,prpcclass);
                            break;
                        }
                    }
                }
            }  

            displayTierSection = false;
            if(sPriceFormat == ProductCreationUtil.PRICE_FORMAT_TIERED || sPriceFormat == ProductCreationUtil.PRICE_FORMAT_VOLUME || sPriceFormat == ProductCreationUtil.PRICE_FORMAT_FLAT_FEE) {
                list<Product_Rate_Plan_Charge_Tier__c> listOfTiers = ProductCreationUtil.getListOfTiers(setOfRatePlanChargesIds);
                for(ProductRatePlanClass prpc : productClass.productRatePlans) {
                    if(prpc.productRatePlanCounter == currentRatePlanCounter) {
                        for(ProductRatePlanChargeClass prpcclass : prpc.productRatePlanChargeClass) {
                            if(prpcclass.productRatePlanChargeCounter == currentRatePlanChargeCounter) {
                                for(Product_Rate_Plan_Charge_Tier__c tier : listOfTiers) {
                                    if(prpcclass.productRatePlancharge.Id == tier.Product_Rate_Plan_Charge__c) {
                                        productRatePlanChargeTierClass = new ProductRatePlanChargeTierClass();
                                        productRatePlanChargeTierClass.productRatePlanChargeTierCounter = ++productRateplanChargeTierCounter;
                                        productRatePlanChargeTierClass.productRatePlanChargeTier = tier;
                                        prpcclass.ProductRatePlanChargeTierClass.add(productRatePlanChargeTierClass);
                                    }
                                }
                                // modified by Laxman:March 11
                                if(mapCounterTierClass.ContainsKey(currentRatePlanChargeCounter)){
                                    prodTierDisplay = mapCounterTierClass.get(currentRatePlanChargeCounter);  
                                }else{
                                    prodTierDisplay = new list<productRatePlanChargeTierClass>();
                                }  
                                prodTierDisplay = prpcclass.ProductRatePlanChargeTierClass; 
                                mapCounterProdRatePlanChargeClass.put(currentRatePlanChargeCounter,prpcclass); 
                            }else{
                                prpcclass.ProductRatePlanChargeTierClass = new List<ProductRatePlanChargeTierClass>();
                                prodTierDisplay = prpcclass.ProductRatePlanChargeTierClass;
                            }
                        }
                    }
                }
                mapCounterTierClass.put(currentRatePlanChargeCounter,prodTierDisplay); 
                displayTierSection = true;
            } 
            prodRatePlanChargeClassToDisplay = mapCounterProdRatePlanChargeClass.get(currentRatePlanChargeCounter);
            return null;
        }

        // on click of search button, filter currency and filter Price type in Charge section this method will be called
        public Pagereference filterCharges() {   
            try {
                sChargeColumnsWidth =  getColumnWidths(sChargeLabel);
                string sQuery;
                sFilterString = '';
                list<Id>  listChargeIds = new  list<Id>();
                productrateplanchargeCounterfortier = 0;
                String sChargeName = Apexpages.currentPage().getParameters().get('Name');
                String sSelectedCurrency= Apexpages.currentPage().getParameters().get('selectedCurrency');
                String sSelectedPriceType= Apexpages.currentPage().getParameters().get('selectedPriceType');
                sQuery =  'SELECT ' + ProductCreationUtil.getObjectFields(sPrefix+'Product_Rate_Plan_Charge__c') +
                        + ' from Product_Rate_Plan_Charge__c ' 
                        + ' Where name != null and Product_Rate_Plan__c =' + '\'' + String.escapeSingleQuotes(sCurrentRatePlanId) + '\'';     

                if (!sChargeName.equals('')) {
                    sQuery += ' and Name LIKE \''+String.escapeSingleQuotes(sChargeName)+'%\''; 
                }       
                if (sSelectedCurrency!=system.Label.LabelFilterCurrency && !sSelectedCurrency.equals('')) {
                    sQuery += ' and CurrencyL__r.Name LIKE \''+String.escapeSingleQuotes(sSelectedCurrency)+'%\'';          
                } 
                if (sSelectedPriceType!=system.Label.LabelFilterPriceType && !sSelectedPriceType.equals('')) {
                    sQuery += ' and  Price_Type__c LIKE \''+String.escapeSingleQuotes(sSelectedPriceType)+'%\'';          
                }
                sQuery += ' Order by Charge_Sequence_Number__c ';
                listchargesLocal = Database.query(sQuery); 
                customIterableForRatePlanChargesObj.listofCharges.clear();
                customIterableForRatePlanChargesObj.listofCharges.addAll(listchargesLocal);

                if(listchargesLocal!= null && !listchargesLocal.isEmpty()){
                    firstCharges();  
                } 
                else {
                    firstCharges();
                    hasNextCharge = false;
                    hasPreviousCharge = false;   
                    sFilterString = system.Label.MessageSearchResults;
                }
                // modified by Laxman:March 11
                prodRatePlanClassToDisplay = mapCounterProdRatePlanClass.get(currentRatePlanCounter);

            } catch (Exception e) {
                if(sCurrentRatePlanId == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,system.Label.MessageSelectRatePlan));
                }       
                else {
                    //Added by Shruthi:INVOICEIT-200
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.Label.ContactAdministrator +e.getTypeName()+':'+e.getMessage() + ':LINE ' + e.getLineNumber()));
                }

            }
            return null;
        }

        // on click of edit layout link in Product section this method is called
        public void editProductLayout() {
            displayProductLayout = true;
            setLayoutFields(ProductCreationUtil.PRODUCT_OBJECT_NAME,setIgnoreFields);
        }

        // on click of cancel button on product layout pop up this method is called
        public void closeProductLayout() {
            displayProductLayout = false;
        }

        // on click of Save button on the product layout pop up this method will be called
        public Pagereference saveProductLayout() {
            displayProductLayout = false;
            String sSelectedFields='';
            String finalSelectedFields = '';
            sProductColumnsWidth = '';
            String sFinalFields_Width = '';
            finalSelectedProductFields = '';
            listProductLabels = new list<String>();
            listProductFields = new list<String>();
            mapProductFields_Labels = new  map<String,String>();
            map<Integer,String> mapCounter_Width = new  map<Integer,String>();

            try {
                for(SelectOption selectOptionProduct : selectedProductFields) {
                    sSelectedFields += selectOptionProduct.getValue()+',';
                    listProductLabels.add(selectOptionProduct.getLabel());
                    listProductFields.add(selectOptionProduct.getValue());
                    finalSelectedFields = finalSelectedFields + selectOptionProduct.getValue() + ',';
                    mapProductFields_Labels.put(selectOptionProduct.getValue(),selectOptionProduct.getLabel());
                }
                finalSelectedFields =  finalSelectedFields.substring(0, finalSelectedFields.length()- 1);
                finalSelectedProductFields = finalSelectedFields;
                sSelectedFields = sSelectedFields.substring(0, sSelectedFields.length()-1);
                if(sSelectedFields != '' && sSelectedFields.length() > 0) {
                    list<string> listSelectedFields  = sSelectedFields.split(',');
                    for(Integer iCounter1 = 0; iCounter1 < listSelectedFields.size(); iCounter1++) {
                        String  sColumnWidth = '100';
                        String sFieldName = listSelectedFields.get(iCounter1);
                        if(sFieldName == sPrefix+'Description__c') {
                            sColumnWidth = '125';
                        }
                        if(sFieldName == 'Name') {
                            sColumnWidth = '120';
                        }
                        sFinalFields_Width = sFinalFields_Width + listSelectedFields.get(iCounter1) +'-'+sColumnWidth + ',';
                    }
                    sFinalFields_Width = sFinalFields_Width.substring(0, sFinalFields_Width.length()-1);    
                }
                layoutProductFields.Selected_Fields__c = sFinalFields_Width;
                upsert layoutProductFields;
            }  catch(DMLException dMlEx){
                // Added by Mani:INVOICEIT-310
                Apexpages.Message errorMessage; 
                for (Integer i = 0; i < dMlEx.getNumDml(); i++)
                { 
                    errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(i));
                    Apexpages.addMessage(errorMessage);      
                } 
                return null; 
            }   catch(Exception e) {
                //Added by Shruthi:INVOICEIT-200
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.Label.ContactAdministrator +e.getTypeName()+':'+e.getMessage() + ':LINE ' + e.getLineNumber()));
            }
            return null;
        }

        // on click of edit layout link in Rateplan section this method is called
        public void editRatePlanLayout() {
            displayRatePlanLayout = true;
            setLayoutFields(ProductCreationUtil.RATEPLAN_OBJECT_NAME,setIgnoreFields);
        }

        // on click of cancel button on rateplan layout pop up this method is called
        public void closeRatePlanLayout() {
            displayRatePlanLayout = false;
        }

        // on click of Save button on the Rateplan layout pop up this method will be called
        public Pagereference saveRatePlanLayout() {
            displayRatePlanLayout = false;
            String sSelectedFields='';
            String finalSelectedFields = '';
            sRateplanColumnsWidth = '';
            finalSelectedRatePlanFields = '';
            map<Integer,String> mapCounter_Width = new  map<Integer,String>();
            String sFinalFields_Width = '';
            listRatePlanLabels = new list<String>();
            listRatePlanFields = new list<String>();
            set<String>  setLabels = new set<String>();
            set<String>  setFields = new set<String>();

            try {

                for(SelectOption selectOptionRatePlan : selectedRatePlanFields) {
                    sSelectedFields += selectOptionRatePlan.getValue()+',';
                    listRatePlanLabels.add(selectOptionRatePlan.getLabel());
                    listRatePlanFields.add(selectOptionRatePlan.getValue());
                    setLabels.add(selectOptionRatePlan.getLabel());
                    setFields.add(selectOptionRatePlan.getValue());
                    finalSelectedFields = finalSelectedFields + selectOptionRatePlan.getValue() + ',';
                    mapRateplanFields_Labels.put(selectOptionRatePlan.getValue(),selectOptionRatePlan.getLabel());
                }

                finalSelectedFields =  finalSelectedFields.substring(0, finalSelectedFields.length()- 1);
                finalSelectedRatePlanFields = finalSelectedFields;
                sSelectedFields = sSelectedFields.substring(0, sSelectedFields.length()-1);
                if(sSelectedFields != '' && sSelectedFields.length() > 0) {
                    list<string> listSelectedFields  = sSelectedFields.split(',');
                    for(Integer iCounter1 = 0; iCounter1 < listSelectedFields.size(); iCounter1++) {
                        String  sColumnWidth = '100';
                        String sFieldName = listSelectedFields.get(iCounter1);
                        if(sFieldName == sPrefix+'Description__c') {
                            sColumnWidth = '125';
                        }
                        if(sFieldName == 'Name') {
                            sColumnWidth = '120';
                        }
                        sFinalFields_Width = sFinalFields_Width + listSelectedFields.get(iCounter1) +'-'+sColumnWidth + ',';
                    }
                    sFinalFields_Width = sFinalFields_Width.substring(0, sFinalFields_Width.length()-1);    
                }
                layoutRatePlanFields.Selected_Fields__c = sFinalFields_Width;
                upsert layoutRatePlanFields;   

            }  catch(DMLException dMlEx){ 
                // Added by Mani:INVOICEIT-310
                Apexpages.Message errorMessage; 
                for (Integer i = 0; i < dMlEx.getNumDml(); i++)
                { 
                    errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(i));
                    Apexpages.addMessage(errorMessage);      
                } 
                return null; 
            }   catch(Exception e) {
                //Added by Shruthi:INVOICEIT-200
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.Label.ContactAdministrator +e.getTypeName()+':'+e.getMessage() + ':LINE ' + e.getLineNumber()));
            }

            return null;
        }

        // on click of edit layout link in Charges section this method is called
        public void editChargesLayout() {
            displayChargesLayout = true;
            setLayoutFields(ProductCreationUtil.CHARGE_OBJECT_NAME,setIgnoreFields);
        }

        // on click of cancel button on Charges layout pop up this method is called
        public void closeChargesLayout() {
            displayChargesLayout = false;
        }

        // on click of Save button on the Charge layout pop up this method will be called
        public Pagereference saveChargesLayout() {
            displayChargesLayout = false;
            String sSelectedFields='';
            String finalSelectedFields = '';
            sChargeColumnsWidth = '';
            finalSelectedChargeFields  = '';
            listChargeLabels = new list<String>();
            listChargeFields = new list<String>();
            map<Integer,String> mapCounter_Width = new  map<Integer,String>();
            String sFinalFields_Width = '';
            try {
                for(SelectOption selectOptionCharge : selectedChargeFields) {
                    sSelectedFields += selectOptionCharge.getValue()+',';
                    listChargeLabels.add(selectOptionCharge.getLabel());
                    listChargeFields.add(selectOptionCharge.getValue());
                    finalSelectedFields = finalSelectedFields + selectOptionCharge.getValue() + ',';
                }
                finalSelectedFields =  finalSelectedFields.substring(0, finalSelectedFields.length()- 1);       
                finalSelectedChargeFields = finalSelectedFields;
                sSelectedFields = sSelectedFields.substring(0, sSelectedFields.length()-1);
                if(sSelectedFields != '' && sSelectedFields.length() > 0) {
                    list<string> listSelectedFields  = sSelectedFields.split(',');
                    for(Integer iCounter1 = 0; iCounter1 < listSelectedFields.size(); iCounter1++) {
                        String  sColumnWidth = '80';
                        String sFieldName = listSelectedFields.get(iCounter1);
                        if(sFieldName == 'Name') {
                            sColumnWidth = '100';
                        }
                        sFinalFields_Width = sFinalFields_Width + listSelectedFields.get(iCounter1) +'-'+sColumnWidth + ',';
                    }
                    sFinalFields_Width = sFinalFields_Width.substring(0, sFinalFields_Width.length()-1);            
                }
                layoutChargeFields.Selected_Fields__c = sFinalFields_Width;
                upsert layoutChargeFields;             
            }  catch(DMLException dMlEx){   
                // Added by Mani:INVOICEIT-310
                Apexpages.Message errorMessage; 
                for (Integer i = 0; i < dMlEx.getNumDml(); i++)
                { 
                    errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(i));
                    Apexpages.addMessage(errorMessage);      
                } 
                return null; 
            }  catch (Exception e) {
                //Added by Shruthi:INVOICEIT-200
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.Label.ContactAdministrator +e.getTypeName()+':'+e.getMessage() + ':LINE ' + e.getLineNumber()));
            }

            return null;
        }

        // setting the layout fields for all the sections saved in the DB when this method is called 
        public void setLayoutFields(String sObjectName, set<String> setIgnoreFields) {
            String sObjectLabel;
            list<String> listlayoutWidth ;
            String sExistingFields='';
            String finalSelectedFields = '';
            if(sObjectName==ProductCreationUtil.PRODUCT_OBJECT_NAME) {
                sObjectLabel = ProductCreationUtil.PRODUCT_OBJECT_NAME;
                sProductLabel = sObjectLabel;
                mapProductFields_Labels = new  map<String,String>();
            }
            else if(sObjectName==ProductCreationUtil.RATEPLAN_OBJECT_NAME) {
                sObjectLabel = ProductCreationUtil.RATEPLAN_OBJECT_NAME;
                sRatePlanLabel = sObjectLabel;
                mapRateplanFields_Labels = new map<String,String>();
            }
            else if(sObjectName==ProductCreationUtil.CHARGE_OBJECT_NAME) {
                sObjectLabel = ProductCreationUtil.CHARGE_OBJECT_NAME;
                sChargeLabel = sObjectLabel;
            }
            selectedFields  = new List<SelectOption>();
            listLabels = new list<String>();
            listFields = new list<String>();
            list<map<String,String>> listMaps = new list<map<String,String>>();
            map<String,String>  mapLabel_Field ;
            map<String,String>  mapField_Label ;
            layoutFields = [Select Name,Selected_Fields__c from Layout_Fields__c where Name=:sObjectLabel ];
            listMaps = ProductCreationUtil.getObjectLabelNFields(sObjectName);
            Integer i = 0;
            for(map<String,String> maps : listMaps){
                if(i == 0) {
                    mapLabel_Field = maps;
                }
                else{
                    mapField_Label = maps;
                }
                ++i;
            }

            if(layoutFields.Selected_Fields__c != null){
                list<String> listlayoutFields = new list<String>();
                listlayoutWidth = new list<String>();
                list<String> listlayoutFields_width =  layoutFields.Selected_Fields__c.split(',');
                for(String sLayoutField : listlayoutFields_width) {
                    list<String> listColumn_width = sLayoutField.split('-');
                    if(listColumn_width != null &&  !listColumn_width.isEmpty()) {
                        if(mapField_Label.containsKey(listColumn_width.get(0))){
                            listlayoutFields.add(listColumn_width.get(0));
                            sExistingFields = sExistingFields + listColumn_width.get(0) + ',';
                            listlayoutWidth.add(listColumn_width.get(1));       
                        }
                    }
                }

                sExistingFields = sExistingFields.substring(0, sExistingFields.length()- 1);

                for (String fieldName : listlayoutFields) {
                    selectedFields.add(new SelectOption(fieldName, mapField_Label.get(fieldName)));
                    listLabels.add(mapField_Label.get(fieldName));
                    listFields.add(fieldName);
                    finalSelectedFields = finalSelectedFields + fieldName + ',';
                    if(sObjectName==ProductCreationUtil.PRODUCT_OBJECT_NAME) {
                        mapProductFields_Labels.put(fieldName,mapField_Label.get(fieldName));
                    }
                    else if(sObjectName==ProductCreationUtil.RATEPLAN_OBJECT_NAME) {
                        mapRateplanFields_Labels.put(fieldName,mapField_Label.get(fieldName));
                    }
                }
                finalSelectedFields =  finalSelectedFields.substring(0, finalSelectedFields.length()- 1);   
            }
            availableFields = new List<SelectOption>();
            if(sExistingFields != null && sExistingFields != '') {
                for(String fieldName : mapField_Label.keyset()) {
                    if(!sExistingFields.contains(fieldName) && !setIgnoreFields.contains(fieldName)) {
                        if(mapField_Label.containsKey(fieldName)) {
                            availableFields.add(new SelectOption(fieldName, mapField_Label.get(fieldName)));        
                        }
                    }
                }    
            }
            else {
                for(String fieldName : mapField_Label.keyset()) {
                    if(!setIgnoreFields.contains(fieldName)) {
                        if(mapField_Label.containsKey(fieldName)) {
                            availableFields.add(new SelectOption(fieldName, mapField_Label.get(fieldName)));        
                        }
                    }
                }    
            }

            if(sObjectName==ProductCreationUtil.PRODUCT_OBJECT_NAME) {
                sProductColumnsWidth = '';
                finalSelectedProductFields = '';
                layoutProductFields =layoutFields;
                listProductLabels = listLabels;
                listProductFields = listFields;
                finalSelectedProductFields = finalSelectedFields;
                selectedProductFields = selectedFields;
                availableProductFields = availableFields;
                if(listlayoutWidth != null && !listlayoutWidth.isEmpty()) {
                    for(String sWidth : listlayoutWidth) {
                        sProductColumnsWidth = sProductColumnsWidth + sWidth + ',';
                    }
                    sProductColumnsWidth = sProductColumnsWidth.substring(0, sProductColumnsWidth.length()- 1); 
                }
            } else if(sObjectName==ProductCreationUtil.RATEPLAN_OBJECT_NAME) {
                finalSelectedRatePlanFields = '';
                sRateplanColumnsWidth = '';
                layoutRatePlanFields =layoutFields;
                listRatePlanLabels = listLabels;
                listRatePlanFields = listFields;
                finalSelectedRatePlanFields = finalSelectedFields;
                selectedRatePlanFields = selectedFields;
                availableRatePlanFields = availableFields;
                if(listlayoutWidth != null && !listlayoutWidth.isEmpty()) {
                    for(String sWidth : listlayoutWidth) {
                        sRateplanColumnsWidth = sRateplanColumnsWidth + sWidth + ',';
                    }
                    sRateplanColumnsWidth = sRateplanColumnsWidth.substring(0, sRateplanColumnsWidth.length()- 1);  
                }
            } else if(sObjectName==ProductCreationUtil.CHARGE_OBJECT_NAME) {
                finalSelectedChargeFields  = '';
                sChargeColumnsWidth = '';
                layoutChargeFields =layoutFields;
                listChargeLabels = listLabels;
                listChargeFields = listFields;
                finalSelectedChargeFields = finalSelectedFields;
                selectedChargeFields = selectedFields;
                availableChargeFields = availableFields;
                if(listlayoutWidth != null && !listlayoutWidth.isEmpty()) {
                    for(String sWidth : listlayoutWidth) {
                        sChargeColumnsWidth = sChargeColumnsWidth + sWidth + ',';
                    }
                    sChargeColumnsWidth = sChargeColumnsWidth.substring(0, sChargeColumnsWidth.length()- 1);    
                }
            }
        }

        // onclick of clone link the charges option pop up is displayed when this method is called
        public Pagereference cloneChargesPopup(){
            displaychargeOptionPopup = true;
            currentRatePlanChargeCounter = integer.ValueOf(system.currentPageReference().getParameters().get('chargeCloneCounter'));
            sChargeCloneName = system.currentPageReference().getParameters().get('chargeName');
            set<id> setOfRatePlanChargesIds = new set<id>();
            for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                if(prpclass.productRatePlanCounter == currentRatePlanCounter){
                    for(ProductRatePlanChargeClass prpcclass : prpclass.productRatePlanChargeClass) {
                        if(prpcclass.productRatePlanChargeCounter == currentRatePlanChargeCounter) {
                            sPriceFormat = prpcclass.productRatePlancharge.Price_Format__c;
                            setOfRatePlanChargesIds.add(prpcclass.productRatePlancharge.id);
                            prpcclass.ProductRatePlanChargeTierClass = new List<ProductRatePlanChargeTierClass>();
                            break;
                        }
                    }
                }
            }

            displayTierSection = false;

            if(sPriceFormat == ProductCreationUtil.PRICE_FORMAT_TIERED || sPriceFormat == ProductCreationUtil.PRICE_FORMAT_VOLUME || sPriceFormat == ProductCreationUtil.PRICE_FORMAT_FLAT_FEE) {
                list<Product_Rate_Plan_Charge_Tier__c> listOfTiers = ProductCreationUtil.getListOfTiers(setOfRatePlanChargesIds);
                for(ProductRatePlanClass prpc : productClass.productRatePlans) {
                    if(prpc.productRatePlanCounter == currentRatePlanCounter) {
                        for(ProductRatePlanChargeClass prpcclass : prpc.productRatePlanChargeClass) {
                            if(prpcclass.productRatePlanChargeCounter == currentRatePlanChargeCounter) {
                                for(Product_Rate_Plan_Charge_Tier__c tier : listOfTiers) {
                                    if(prpcclass.productRatePlancharge.Id == tier.Product_Rate_Plan_Charge__c) {
                                        productRatePlanChargeTierClass = new ProductRatePlanChargeTierClass();
                                        productRatePlanChargeTierClass.productRatePlanChargeTierCounter = ++productRateplanChargeTierCounter;
                                        productRatePlanChargeTierClass.productRatePlanChargeTier = tier;
                                        prpcclass.ProductRatePlanChargeTierClass.add(productRatePlanChargeTierClass);
                                    }
                                }
                                // modified by Laxman:March 11   
                                if(mapCounterTierClass.ContainsKey(currentRatePlanChargeCounter)){
                                    prodTierDisplay = mapCounterTierClass.get(currentRatePlanChargeCounter);  
                                }else{
                                    prodTierDisplay = new list<productRatePlanChargeTierClass>();
                                }  
                                prodTierDisplay = prpcclass.ProductRatePlanChargeTierClass;   
                            }else{
                                prpcclass.ProductRatePlanChargeTierClass = new List<ProductRatePlanChargeTierClass>();
                                //modified by Laxman:March 11
                                prodTierDisplay = prpcclass.ProductRatePlanChargeTierClass;
                            }
                        }
                    }
                }
                // modified by Laxman:March 11
                mapCounterTierClass.put(currentRatePlanChargeCounter,prodTierDisplay);
                displayTierSection = true;
            }
            return null;
        }

        // onclick of any clone button the charges clone pop up is displayed when this method is called
        public Pagereference cloneCharge() {
            sRateplanColumnsWidth = getColumnWidths(sRatePlanLabel);
            sChargeColumnsWidth =  getColumnWidths(sChargeLabel);
            displayClonedChargePopUp = true;
            displaychargeOptionPopup = false;
            Integer lastChargeSequenceNumber ; 
            sChargesActionString = system.Label.LabelCloneCharge;
            list<ProductRatePlanChargeTierClass> listTierClass = new list<ProductRatePlanChargeTierClass>();
            sClonedChargeButtonOption = system.currentPageReference().getParameters().get('cloneCharge');
            map<Id,list<Product_Rate_Plan_Charge__c>> mapId_Charges = ProductCreationUtil.getMapId_Charges(product.Id);
            if(sClonedChargeButtonOption== ProductCreationUtil.CLONE_CHARGE) {
                for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                    if(prpclass.productRatePlanCounter == currentRatePlanCounter){
                        lastChargeSequenceNumber = getLastChargeSequenceNumber(mapId_Charges,prpclass.productRatePlan.Id);
                        for(ProductRatePlanChargeClass prpcclass : prpclass.productRatePlanChargeClass) {
                            if(prpcclass.productRatePlanChargeCounter == currentRatePlanChargeCounter) {
                                ProductRatePlanChargeClass productRatePlanChargeClass = new ProductRatePlanChargeClass();
                                ratePlanCharge = prpcclass.productRatePlancharge.clone(false);
                                ratePlanCharge.Charge_Sequence_Number__c = ++lastChargeSequenceNumber;
                                productRatePlanChargeClass.productRatePlancharge = ratePlanCharge;
                                productRatePlanChargeClass.productRatePlanChargeCounter = ++productRateplanChargeCounter;
                                prpclass.productRatePlanChargeClass.add(productRatePlanChargeClass);
                                currentRatePlanChargeCounter = productRatePlanChargeClass.productRatePlanChargeCounter;
                                // modified by Laxman:March 11
                                mapCounterProdRatePlanChargeClass.put(currentRatePlanChargeCounter, productRatePlanChargeClass);
                                break;
                            }
                        }
                        break;
                    }
                }
            }
            else if(sClonedChargeButtonOption== ProductCreationUtil.CLONE_WITH_TIERS) {
                for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                    if(prpclass.productRatePlanCounter == currentRatePlanCounter){
                        lastChargeSequenceNumber = getLastChargeSequenceNumber(mapId_Charges,prpclass.productRatePlan.Id);
                        for(ProductRatePlanChargeClass prpcclass : prpclass.productRatePlanChargeClass) {
                            if(prpcclass.productRatePlanChargeCounter == currentRatePlanChargeCounter) {
                                ProductRatePlanChargeClass productRatePlanChargeClass = new ProductRatePlanChargeClass();
                                ratePlanCharge = prpcclass.productRatePlancharge.clone(false);
                                ratePlanCharge.Charge_Sequence_Number__c = ++lastChargeSequenceNumber;
                                productRatePlanChargeClass.productRatePlancharge = ratePlanCharge;
                                productRatePlanChargeClass.productRatePlanChargeCounter = ++productRateplanChargeCounter;
                                prpclass.productRatePlanChargeClass.add(productRatePlanChargeClass);
                                currentRatePlanChargeCounter = productRatePlanChargeClass.productRatePlanChargeCounter;

                                // modified by Laxman:March 11
                                mapCounterProdRatePlanChargeClass.put(currentRatePlanChargeCounter, productRatePlanChargeClass);
                                prodTierDisplay = new list<productRatePlanChargeTierClass>();
                                for(ProductRatePlanChargeTierClass tierclass : prpcclass.ProductRatePlanChargeTierClass) {
                                    productTier = new Product_Rate_Plan_Charge_Tier__c();
                                    productTier = tierclass.productRatePlanChargeTier.clone(false);
                                    productTier.Product_Rate_Plan_Charge__c = null;
                                    productRatePlanChargeTierClass = new ProductRatePlanChargeTierClass();
                                    productRatePlanChargeTierClass.productRatePlanChargeTier = productTier;
                                    ProductRatePlanChargeTierClass.productRatePlanChargeTierCounter = ++productRateplanChargeTierCounter;
                                    ProductRatePlanChargeTierClass.productRatePlanChargeTier = productTier;
                                    listTierClass.add(productRatePlanChargeTierClass);
                                }
                                break;
                            }
                        }
                        break;
                    }
                }

                for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                    if(prpclass.productRatePlanCounter == currentRatePlanCounter){
                        for(ProductRatePlanChargeClass prpcclass : prpclass.productRatePlanChargeClass) {
                            if(prpcclass.productRatePlanChargeCounter == currentRatePlanChargeCounter) {
                                for(ProductRatePlanChargeTierClass tierclass : listTierClass) {
                                    prpcclass.ProductRatePlanChargeTierClass.add(tierclass);
                                }
                                prodTierDisplay = prpcclass.ProductRatePlanChargeTierClass;
                                mapCounterTierClass.put(currentRatePlanChargeCounter,prodTierDisplay); 
                                mapCounterProdRatePlanChargeClass.put(currentRatePlanChargeCounter,prpcclass);
                                break; 
                            }
                        }
                    }
                }
            }

            prodRatePlanChargeClassToDisplay = mapCounterProdRatePlanChargeClass.get(currentRatePlanChargeCounter);
            return null;
        }

        // on click of Save button on the clone charge pop up this method will be called
        public Pagereference saveClonedCharge() {
            displayClonedChargePopUp = false;
            isTierErrorMsg = false;
            String sValidateTier ='';
            SavePoint sp;
            list<ProductRatePlanChargeClass> listProductRatePlanChargeClass = new list<ProductRatePlanChargeClass>();
            list<ProductRatePlanChargeTierClass> listTierClass = new list<ProductRatePlanChargeTierClass>();
            list<Product_Rate_Plan_Charge__c> listCharges = new list<Product_Rate_Plan_Charge__c>();
            list<Product_Rate_Plan_Charge_Tier__c> listTiers = new list<Product_Rate_Plan_Charge_Tier__c>();
            Product_Rate_Plan_Charge_Tier__c tierTobeClone;
            try { 
                sp = DataBase.SetSavePoint();
                if(sClonedChargeButtonOption == ProductCreationUtil.CLONE_CHARGE) {
                    for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                        if(prpclass.productRatePlanCounter == currentRatePlanCounter){
                            for(ProductRatePlanChargeClass prpcclass : prpclass.productRatePlanChargeClass) {
                                if(prpcclass.productRatePlanChargeCounter == currentRatePlanChargeCounter) {
                                    listProductRatePlanChargeClass.add(prpcclass);
                                    break;
                                }
                            }
                            break;
                        }
                    }
                }
                else if(sClonedChargeButtonOption == ProductCreationUtil.CLONE_WITH_TIERS) {
                    for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                        if(prpclass.productRatePlanCounter == currentRatePlanCounter){
                            for(ProductRatePlanChargeClass prpcclass : prpclass.productRatePlanChargeClass) {
                                if(prpcclass.productRatePlanChargeCounter == currentRatePlanChargeCounter) {
                                    listProductRatePlanChargeClass.add(prpcclass);
                                    break;
                                }
                            }
                            break;
                        }
                    }

                }

                for(ProductRatePlanChargeClass prpcclass : listProductRatePlanChargeClass) {
                    listCharges.add(prpcclass.productRatePlancharge);
                    for(ProductRatePlanChargeTierClass tierClass : prpcclass.ProductRatePlanChargeTierClass) {
                        listTierClass.add(tierClass);
                    } 
                }

                if(!listCharges.isEmpty()){
                    sValidateTier = validateTiers();
                    if(sValidateTier == ProductCreationUtil.ERROR) {
                        displayClonedChargePopUp = true;
                        isTierErrorMsg = true;
                        return null;
                    } 
                    upsert listCharges;
                    customIterableForRatePlanChargesObj.listofCharges.addAll(listCharges);
                    if(customIterableForRatePlanChargesObj.listofCharges.size() > customIterableForRatePlanChargesObj.setPageSize)
                        customIterableForRatePlanChargesObj.i++; 
                }

                for(Product_Rate_Plan_Charge__c charge : listCharges) {
                    for(ProductRatePlanChargeTierClass tierClass : listTierClass) {
                        tierClass.productRatePlanChargeTier.Product_Rate_Plan_Charge__c = charge.Id;
                        listTiers.add(tierClass.productRatePlanChargeTier); 
                    }
                }

                if(!listTiers.isEmpty()){
                    upsert listTiers;
                }

                map<Id,Product_Rate_Plan__c> mapId_ProductRatePlan = ProductCreationUtil.getProductRatePlans(product.Id);
                for(ProductRatePlanClass prpc : productClass.productRatePlans) {
                    if(prpc.productRatePlanCounter == currentRatePlanCounter) {
                        if(mapId_ProductRatePlan.containsKey(prpc.productRatePlan.Id)) {
                            prpc.productRatePlan = mapId_ProductRatePlan.get(prpc.productRatePlan.Id);
                        }
                    }
                }

                // This is to remove one charge from the page, if exceeds the pageset size
                for(ProductRatePlanClass prpc : productClass.productRatePlans) {
                    for(ProductRatePlanChargeClass prpcc : prpc.productRatePlanChargeClass) {
                        if(prpc.productRatePlanChargeClass.size() > customIterableForRatePlanChargesObj.setPageSize) {
                            if(prpcc.productRatePlanChargeCounter != currentRatePlanChargeCounter) {
                                prpc.productRatePlanChargeClass.remove(0);
                                break;
                            } 
                        } 
                    }
                }
                if(customIterableForRatePlanChargesObj.listofCharges.size() >= customIterableForRatePlanChargesObj.setPageSize) {
                    hasNextCharge = customIterableForRatePlanChargesObj.hasNext();  
                    hasPreviousCharge = customIterableForRatePlanChargesObj.hasPrevious();
                }else {
                    hasNextCharge = false;
                    hasPreviousCharge = false;
                }
            } catch(DMLException dMlEx){
                // Added by Mani:INVOICEIT-310
                Apexpages.Message errorMessage; 
                for (Integer i = 0; i < dMlEx.getNumDml(); i++)
                { 
                    errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(i));
                    Apexpages.addMessage(errorMessage);      
                } 
                return null; 
            }  catch(Exception ex) {
                if(sCurrentRatePlanId == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,system.Label.MessageSelectRatePlan));
                } 
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber());
                Apexpages.addMessage(errorMessage);
                DataBase.RollBack(sp);  
                return null;
            }
            displayTierSection = false;
            return null;
        }

        // on click of Cancel button on the clone charge pop up  this method will be called
        public void closeCloneChargePopup(){
            displayClonedChargePopUp = false;

            for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                if(prpclass.productRatePlanCounter == currentRatePlanCounter) {
                    for(Integer i = 0; i < prpclass.productRatePlanChargeClass.size() ; i++) {
                        if(prpclass.productRatePlanChargeClass.get(i).productRatePlanChargeCounter == currentRatePlanChargeCounter) {
                            prpclass.productRatePlanChargeClass.remove(i);
                            break;
                        }
                    }
                    break;
                }
            }
        }

        // on click of the checkboxes and click on the Edit Selected link on the charge section this method will be called
        public Pagereference editSelectedCharges() {
            sChargeColumnsWidth =  getColumnWidths(sChargeLabel);
            boolean isChargeSelected = false;
            sEditSelected = system.currentPageReference().getParameters().get('editSelected');
            for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                if(prpclass.productRatePlanCounter == currentRatePlanCounter) {
                    for(ProductRatePlanChargeClass prpcclass : prpclass.productRatePlanChargeClass) {
                        if(prpcclass.isSelected != null && prpcclass.isSelected){
                            isChargeSelected = true;
                        }       
                    }       
                }
            }

            if(!isChargeSelected) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, system.Label.MessageSelectCharges));
                return null;
            }
            sChargesActionString = system.Label.LabelEditCharges;
            displaySelectedCharges = true;
            return null;
        }

        // on click of Cancel button on the Edit Selected charge pop up  this method will be called
        public Pagereference closeSelectedChargesPopup() {
            displaySelectedCharges = false;
            sEditSelected = null;

            for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                for(ProductRatePlanChargeClass prpcclass : prpclass.productRatePlanChargeClass) {
                    if(prpcclass.isSelected != null && prpcclass.isSelected){
                        prpcclass.isSelected = false;
                    }       
                }
            }

            return null;
        }

        // onchange of Price type field in the charges pop up this method is called
        public Pagereference onChangePriceFormat() {
            for(ProductRatePlanClass prpc : productClass.productRatePlans) {
                if(prpc.productRatePlanCounter == currentRatePlanCounter) {
                    for(ProductRatePlanChargeClass prpcclass : prpc.productRatePlanChargeClass) {
                        if(prpcclass.productRatePlanChargeCounter == currentRatePlanChargeCounter) {
                            sPriceFormat = prpcclass.productRatePlancharge.Price_Format__c;
                        }
                    }
                }
            }  

            if(sPriceFormat == ProductCreationUtil.PRICE_FORMAT_TIERED || sPriceFormat == ProductCreationUtil.PRICE_FORMAT_VOLUME || sPriceFormat == ProductCreationUtil.PRICE_FORMAT_FLAT_FEE) {
                displayTierSection = true;
                newTier();
            }
            else {
                displayTierSection = false;
            }

            return null;
        }

        // on click of new Tier Link on the charges pop up this method will be called
        public void newTier() {
            for(ProductRatePlanClass prpc : productClass.productRatePlans) {
                for(ProductRatePlanChargeClass prpcc : prpc.productRatePlanChargeClass) {
                    if(prpcc.productRatePlanChargeCounter == currentRatePlanChargeCounter) {
                        productRatePlanChargeTierClass = new ProductRatePlanChargeTierClass();
                        productTier = new Product_Rate_Plan_Charge_Tier__c();
                        ProductRatePlanChargeTierClass.productRatePlanChargeTierCounter = ++productRateplanChargeTierCounter;
                        ProductRatePlanChargeTierClass.productRatePlanChargeTier = productTier;
                        prpcc.ProductRatePlanChargeTierClass.add(productRatePlanChargeTierClass);
                        if(mapCounterTierClass.ContainsKey(currentRatePlanChargeCounter)){
                            prodTierDisplay = mapCounterTierClass.get(currentRatePlanChargeCounter);  
                        }else{
                            prodTierDisplay = new list<productRatePlanChargeTierClass>();
                        }
                        prodTierDisplay = prpcc.ProductRatePlanChargeTierClass;
                        mapCounterTierClass.put(currentRatePlanChargeCounter,prodTierDisplay);
                        mapCounterProdRatePlanChargeClass.put(currentRatePlanChargeCounter,prpcc);
                    }
                }
            }
        }

        // on click of Delete button to delete the tiers on charges pop up this method will be called
        public void removeTiers() {        
            string tierIdToDelete = system.currentPageReference().getParameters().get('tieridtodelete');
            Integer tierCounterToDelete = Integer.valueOf(system.currentPageReference().getParameters().get('tiercountertodelete'));

            if(tierIdToDelete.Length() > 0) {
                Product_Rate_Plan_Charge_Tier__c prpcTierToDelete = new Product_Rate_Plan_Charge_Tier__c(Id = tierIdToDelete);
                delete prpcTierToDelete;
            }

            Integer productrateplansize = productClass.productRatePlans.size();
            for(ProductRatePlanClass prpclass : productClass.productRatePlans) {   
                for(ProductRatePlanChargeClass  prpChargeClass : prpclass.productRatePlanChargeClass) {
                    if(prpChargeClass.productRatePlanChargeCounter == currentRatePlanChargeCounter) {
                        for(integer i = 0; i < prpChargeClass.ProductRatePlanChargeTierClass.size(); i++) {
                            if(prpChargeClass.ProductRatePlanChargeTierClass.get(i).productRatePlanChargeTierCounter == tierCounterToDelete) {
                                prpChargeClass.ProductRatePlanChargeTierClass.remove(i);
                                break;
                            }
                        }
                    }
                }
            }    
        }

        public String validateTiers() {
            //Modified By: Lopamudra Guru:27-06-14:SUP-278
            integer i = 1;
            for(ProductRatePlanClass prpc : productClass.productRatePlans) {
                if(prpc.productRatePlanCounter == currentRatePlanCounter) {
                    for(ProductRatePlanChargeClass prpcc : prpc.productRatePlanChargeClass) {
                        if(prpcc.productRatePlanChargeCounter == currentRatePlanChargeCounter) {
                            if(prpcc.ProductRatePlanChargeTierClass.size() > 1){
                                Product_Rate_Plan_Charge_Tier__c productRatePlanChargeTier =null;
                                if(prpcc.ProductRatePlanChargeTierClass.get(0).productRatePlanChargeTier.Start_Unit__c < 0){
                                    // the start unit should start from 1
                                    if(prpcc.productRatePlancharge.Id != null) {
                                        sCurrentChargeId = prpcc.productRatePlancharge.Id;        
                                    }
                                    Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.StartUnitCannotHaveNegativeValue );
                                    Apexpages.addMessage(errorMessage);
                                    return ProductCreationUtil.ERROR;
                                }
                                for(ProductRatePlanChargeTierClass productRatePlanChargeTierClass : prpcc.ProductRatePlanChargeTierClass){
                                    if(productRatePlanChargeTier == null){
                                        productRatePlanChargeTier = productRatePlanChargeTierClass.productRatePlanChargeTier;
                                    }
                                    else{
                                        
                                        decimal iExactValue = productRatePlanChargeTier.Start_Unit__c;
                                        decimal iNewStartUnitValue = productRatePlanChargeTierClass.productRatePlanChargeTier.Start_Unit__c;
                                        if(productRatePlanChargeTierClass.productRatePlanChargeTier.End_Unit__c < iNewStartUnitValue){
                                            // throw error msg
                                            Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.EndUnitShouldNotBeLessThanStartUnit );
                                            Apexpages.addMessage(errorMessage);
                                            return ProductCreationUtil.ERROR;
                                        }else if(!prpcc.ProductRatePlanChargeTierClass.isEmpty() && prpcc.ProductRatePlanChargeTierClass.get(0).productRatePlanChargeTier.End_Unit__c!=null && prpcc.ProductRatePlanChargeTierClass.get(0).productRatePlanChargeTier.End_Unit__c < prpcc.ProductRatePlanChargeTierClass.get(0).productRatePlanChargeTier.Start_Unit__c){
                                            Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.EndUnitShouldNotBeLessThanStartUnit );
                                                    Apexpages.addMessage(errorMessage);
                                                    return ProductCreationUtil.ERROR;
                                        }else if(productRatePlanChargeTierClass.productRatePlanChargeTier.Start_Unit__c < 0){
                                                    Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.StartUnitCannotHaveNegativeValue);
                                                    Apexpages.addMessage(errorMessage);
                                                    return ProductCreationUtil.ERROR;
                                        }else if(productRatePlanChargeTier.End_Unit__c != null){
                                            decimal iPrevoiusEndUnitValue = productRatePlanChargeTier.End_Unit__c;
                                            if(iNewStartUnitValue <= iPrevoiusEndUnitValue){
                                                Apexpages.Message errorMessage1 = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.TierStartUnit );
                                                Apexpages.addMessage(errorMessage1);
                                                return ProductCreationUtil.ERROR;
                                            }
                                        }
                                    }  
                                    productRatePlanChargeTier = productRatePlanChargeTierClass.productRatePlanChargeTier;
                                    i = i+ 1; 
                                }       
                            }
                            else{
                                if(!prpcc.ProductRatePlanChargeTierClass.isEmpty() && prpcc.ProductRatePlanChargeTierClass.get(0).productRatePlanChargeTier.Start_Unit__c < 0){
                                    // the start unit should start from 1
                                    if(prpcc.productRatePlancharge.Id != null) {
                                        sCurrentChargeId = prpcc.productRatePlancharge.Id;        
                                    }
                                    Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.StartUnitCannotHaveNegativeValue );
                                    Apexpages.addMessage(errorMessage);
                                    return ProductCreationUtil.ERROR;
                                }else if(!prpcc.ProductRatePlanChargeTierClass.isEmpty() && (prpcc.ProductRatePlanChargeTierClass.get(0).productRatePlanChargeTier.End_Unit__c < prpcc.ProductRatePlanChargeTierClass.get(0).productRatePlanChargeTier.Start_Unit__c)){
                                    //throw error message if end unit is less than start unit of first tier
                                    if(prpcc.productRatePlancharge.Id != null) {
                                        sCurrentChargeId = prpcc.productRatePlancharge.Id;        
                                    }
                                    Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.EndUnitShouldNotBeLessThanStartUnit )); 
                                    return ProductCreationUtil.ERROR;
                                }
                            }
                        }
                    }
                }       
            }
            return '';   
        }

        // on click of a main checkbox on the top of the charges section to select all checkboxes this method will be called
        public Pagereference onSelectAll() {
            sChargeColumnsWidth =  getColumnWidths(sChargeLabel);
            for(ProductRatePlanClass prpclass : productClass.productRatePlans) {   
                if(prpclass.productRatePlanCounter == currentRatePlanCounter) {
                    for(ProductRatePlanChargeClass prpcclass : prpclass.productRatePlanChargeClass) {
                        if(isSelectAll != null && isSelectAll) {
                            prpcclass.isSelected = true;
                        }
                        else {
                            prpcclass.isSelected = false;
                        }
                    }
                }
            } 

            return null;   
        }

        //  get the last charge sequence number of the rateplan
        public Integer getLastChargeSequenceNumber(map<Id,list<Product_Rate_Plan_Charge__c>> mapId_Charges, Id rateplanId) {
            Integer lastChargeSequenceNumber= 0;
            if(mapId_Charges != null && !mapId_Charges.values().isEmpty() &&  mapId_Charges.ContainsKey(rateplanId)) {
                list<Product_Rate_Plan_Charge__c> listChargeFromMap = mapId_Charges.get(rateplanId);
                if(listChargeFromMap != null && !listChargeFromMap.isEmpty()) {
                    lastChargeSequenceNumber = Integer.valueOf(listChargeFromMap.get(0).Charge_Sequence_Number__c);
                }
            }
            return lastChargeSequenceNumber;
        }

        public String getColumnWidths(String sLabel) {
            String sColumnsWidth = '';
            Layout_Fields__c layoutFields1 = [Select Name,Selected_Fields__c from Layout_Fields__c where Name=:sLabel ];    
            list<String> listFieldWidth =  layoutFields1.Selected_Fields__c.split(',');
            for(String fieldWidth : listFieldWidth) {
                list<String>  listInnerFieldWidth = fieldWidth.split('-');
                sColumnsWidth = sColumnsWidth + listInnerFieldWidth.get(1) + ',';
            }
            sColumnsWidth = sColumnsWidth.substring(0, sColumnsWidth.length()- 1);  
            return sColumnsWidth;
        }

        public void productData() {
            productClass = new ProductClass();
            ApexPages.Standardcontroller productController = new Apexpages.Standardcontroller(product);
            CreateProductsController controller = new CreateProductsController(productController);
            ProductClass = controller.productClass; 
        }

        // This will display the next set of records for ratePlan
        public void next() {
            listOfratePlan = customIterableForRatePlanObj.next();
            intilizeRatePlans();
        } 

        // This will display the previous set of records for ratePlan
        public void previous() {
            listOfratePlan = customIterableForRatePlanObj.previous();
            intilizeRatePlans();
        }   

        // This will display the first set of records for ratePlan
        public void first() {
            listOfratePlan = customIterableForRatePlanObj.first();
            intilizeRatePlans();
        }   

        // This will display the last set of records for ratePlan
        public void last() {
            listOfratePlan = customIterableForRatePlanObj.last();
            intilizeRatePlans();
        } 

        // This will intilize RatePlans & Charges for particular set of records
        public void intilizeRatePlans() {
            set<Id> setOfRatePlanChargesIds = new set<Id>();
            currentRatePlanCounter = 1;
            currentRatePlanChargeCounter = 1;
            Integer iratePlanCounter = 0;
            productRatePlanCounter = 0;
            productClass.productRatePlans.clear();
            if(listOfratePlan != null && listOfratePlan.size() > 0) {
                productRatePlanClass = new ProductRatePlanClass();
                for(Product_Rate_Plan__c pr : listOfratePlan){
                    if(!renderRatePlan) {
                        renderRatePlan = true;
                    } 
                    ++iratePlanCounter;
                    if(iratePlanCounter == 1) {
                        sCurrentRatePlanId = pr.Id;
                    }
                    productRatePlanClass = new ProductRatePlanClass();
                    productRatePlanClass.productRatePlan = pr;
                    productRatePlanClass.productRatePlanCounter = ++productRatePlanCounter;
                    productClass.productRatePlans.add(productRatePlanClass); 
                    mapCounterProdRatePlanClass.put(productRatePlanCounter, productRatePlanClass);
                    if(iratePlanCounter == 1) {
                        prodRatePlanClassToDisplay = productRatePlanClass;
                    }

                }
                // below logic is to display the default rateplan with charges.
                customIterableForRatePlanChargesObj = new CustomIterableForRatePlanCharges(sCurrentRatePlanId);
                listchargesLocal = customIterableForRatePlanChargesObj.first();
                for(ProductRatePlanClass prpc : productClass.productRatePlans) {
                    if(prpc.productRatePlanCounter == currentRatePlanCounter) {
                        prpc.productRatePlanChargeClass = new list<ProductRatePlanChargeClass>();
                        for(Product_Rate_Plan_Charge__c charge : listchargesLocal) {
                            if(!renderCharge) {
                                renderCharge = true;
                            }
                            productRatePlanChargeClass = new ProductRatePlanChargeClass();
                            productRatePlanChargeClass.productRatePlancharge = charge;
                            productRatePlanChargeClass.productRatePlanChargeCounter = ++productRateplanChargeCounter;
                            prpc.productRatePlanChargeClass.add(productRatePlanChargeClass);

                            // modified by Laxman:March 11
                            mapCounterProdRatePlanChargeClass.put(productRateplanChargeCounter, productRatePlanChargeClass);
                            setOfRatePlanChargesIds.add(charge.id);
                        }
                        break;
                    }
                } 
            } else if(prodRatePlanClassToDisplay != null){
                prodRatePlanClassToDisplay.productRatePlanChargeClass = new list<ProductRatePlanChargeClass>();
            }

            if(customIterableForRatePlanObj != null) {
                hasNext = customIterableForRatePlanObj.hasNext();
                hasPrevious = customIterableForRatePlanObj.hasPrevious();
            }
            if(customIterableForRatePlanChargesObj != null) {
                hasNextCharge = customIterableForRatePlanChargesObj.hasNext();  
                hasPreviousCharge = customIterableForRatePlanChargesObj.hasPrevious();
            }
            sFilterString = '';
        }

        // This will display the next set of records for charges
        public void nextCharges() {
            listchargesLocal = customIterableForRatePlanChargesObj.next();
            intilizeCharges();
        }    

        // This will display the previous set of records for charges
        public void previousCharges() {
            listchargesLocal = customIterableForRatePlanChargesObj.previous();
            intilizeCharges();
        }   

        // his will display the first set of records for charges
        public void firstCharges() {
            listchargesLocal = customIterableForRatePlanChargesObj.first();
            intilizeCharges();
        }    

        // This will display the last set of records for charges
        public void lastCharges() {
            listchargesLocal = customIterableForRatePlanChargesObj.last();
            intilizeCharges();
        } 

        // This will intilizeCharges for particular set of records
        public void intilizeCharges() {
            isSelectAll = false;
            for(ProductRatePlanClass prpc : productClass.productRatePlans) {
                if(prpc.productRatePlanCounter == currentRatePlanCounter) {
                    prpc.productRatePlanChargeClass = new list<ProductRatePlanChargeClass>();
                    for(Product_Rate_Plan_Charge__c charge : listchargesLocal) {
                        productRatePlanChargeClass = new ProductRatePlanChargeClass();
                        productRatePlanChargeClass.productRatePlancharge = charge;
                        productRatePlanChargeClass.productRatePlanChargeCounter = ++productRateplanChargeCounter;
                        prpc.productRatePlanChargeClass.add(productRatePlanChargeClass);
                        // modified by Laxman:March 11
                        mapCounterProdRatePlanChargeClass.put(productRateplanChargeCounter, productRatePlanChargeClass);
                    }
                    break;
                }
            } 
            if(customIterableForRatePlanChargesObj.listofCharges.size() >= customIterableForRatePlanChargesObj.setPageSize) {
                hasNextCharge = customIterableForRatePlanChargesObj.hasNext();  
                hasPreviousCharge = customIterableForRatePlanChargesObj.hasPrevious();
            }else {
                hasNextCharge = false;
                hasPreviousCharge = false;
            }
        }

        // on click of search button,in Rate plan section this method will be called
        public void filterRatePlan() {   
            try {
                string sQuery;
                String sRatePlanName = Apexpages.currentPage().getParameters().get('RatePlanName');

                sQuery =  'SELECT ' + ProductCreationUtil.getObjectFields(sPrefix+'Product_Rate_Plan__c') 
                        + ' from Product_Rate_Plan__c ' 
                        + ' Where name != null  and Product__c =' + '\'' + String.escapeSingleQuotes(product.Id) + '\'';     

                if (!sRatePlanName.equals('')) {
                    sQuery += ' and Name LIKE \''+String.escapeSingleQuotes(sRatePlanName)+'%\'';     
                    listOfratePlan = Database.query(sQuery);
                    if(listOfratePlan!= null && !listOfratePlan.isEmpty()){
                        intilizeRatePlans();       
                    }else {
                        customIterableForRatePlanObj.listofRatePlans.clear();
                        customIterableForRatePlanObj.i = 0;
                        customIterableForRatePlanChargesObj.listofCharges.clear();
                        intilizeRatePlans();
                        sFilterString = system.Label.MessageSearchResults;
                    } 
                }   else {
                    customIterableForRatePlanObj = new CustomIterableForRatePlan(product.Id);
                    first();
                }    

            } catch (Exception e) {
                //Added by Shruthi:INVOICEIT-200
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.Label.ContactAdministrator +e.getTypeName()+':'+e.getMessage() + ':LINE ' + e.getLineNumber()));
            }
        }

        @RemoteAction
        public static list<Product_Rate_Plan_Charge_Tier__c> getChargeTiers(String sChargeId) {

            list<Product_Rate_Plan_Charge_Tier__c> listOfProductRatePlanChargeTier = new list<Product_Rate_Plan_Charge_Tier__c>();

            If(sChargeId != null && sChargeId != '') {
                listOfProductRatePlanChargeTier = [SELECT End_Unit__c,Product_Rate_Plan_Charge__c,Start_Unit__c,Unit_Cost_Price__c,Unit_Price__c,Name FROM Product_Rate_Plan_Charge_Tier__c WHERE Product_Rate_Plan_Charge__c =: sChargeId];    
            }

            return listOfProductRatePlanChargeTier;
        } 

        @RemoteAction
        public static list<Product_Rate_Plan__c> getProductRatePlan(String sRatePlanId) {

            list<Product_Rate_Plan__c> listOfProductRatePlan = new list<Product_Rate_Plan__c>();

            If(sRatePlanId != null && sRatePlanId != '') {
                listOfProductRatePlan = [SELECT Valid_From_Date__c,Valid_To_Date__c,Status__c,Name FROM Product_Rate_Plan__c WHERE Id =: sRatePlanId];    
            }

            return listOfProductRatePlan ;
        }

        @RemoteAction
        public static list<Product__c> getProductDetails(String sProductId) {

            list<Product__c> listOfProduct = new list<Product__c>();

            If(sProductId != null && sProductId != '') {
                listOfProduct = [SELECT Valid_From_Date__c,Effective_Period__c,Valid_To_Date__c,Product_Code__c,Product_Family__c,Status__c,Name FROM Product__c WHERE Id =: sProductId];    
            }

            return listOfProduct ;
        }

    }