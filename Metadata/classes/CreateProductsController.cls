public with sharing class CreateProductsController {

        public Product__c product {get; set;}
        public Product_Rate_Plan__c ratePlan {get; set;}
        public Product_Rate_Plan_Charge__c ratePlanCharge {get; set;}
        public list<Product_Rate_Plan__c> listOfratePlan {get; set;}
        public list<Product_Rate_Plan_Charge__c> listOfratePlanCharges {get; set;}

        public  ProductClass productClass {get; set;}
        public  ProductRatePlanClass productRatePlanClass {get; set;}
        public  ProductRatePlanChargeClass productRatePlanChargeClass = new ProductRatePlanChargeClass();
        public  ProductRatePlanChargeTierClass productRatePlanChargeTierClass = new ProductRatePlanChargeTierClass();

        private Integer productRatePlanCounter = 0;
        private Integer productRateplanChargeCounter = 0;
        private Integer productRateplanChargeTierCounter = 0;
        public Integer currentRatePlanCounter {get; set;}
        public Integer currentRatePlanChargeCounter {get; set;}
        public boolean isViewMode {get;set;}    
        public Product_Rate_Plan_Charge_Tier__c productTier{get; set;}
        public boolean displayPopup {get; set;}
        public integer productrateplanchargeCounterfortier {get; set;}    

        public CreateProductsController(ApexPages.StandardController stdController) {
            if(system.currentPageReference().getParameters().get('retURL') == null) {
                isViewMode = true;
            } else {
                isViewMode = false;
            }

            this.product = (Product__c)stdController.getRecord();
            productClass = new ProductClass();
            if(product.id == null) {
                product.Name = 'Default'; 
                product.Valid_From_Date__c = system.Today();
                newRatePlan();
            } 
            else {
                this.product = JobCreationUtil.getProduct(product.id); 
                listOfratePlan = JobCreationUtil.getListOfRatePlans(product.Id);
                set<Id> setOfRatePlanChargesIds = new set<Id>();

                currentRatePlanCounter = 1;
                currentRatePlanChargeCounter = 1;

                if(listOfratePlan != null) {
                    for(Product_Rate_Plan__c pr : listOfratePlan){
                        productRatePlanClass = new  ProductRatePlanClass();
                        productRatePlanClass.productRatePlan = pr;

                        for(Product_Rate_Plan_Charge__c prpc : pr.ProductRatePlanCharge__r) {
                            productRatePlanChargeClass = new ProductRatePlanChargeClass();
                            productRatePlanChargeClass.productRatePlancharge = prpc;
                            productRatePlanChargeClass.productRatePlanChargeCounter = ++productRateplanChargeCounter;
                            productRatePlanClass.productRatePlanChargeClass.add(productRatePlanChargeClass);
                            setOfRatePlanChargesIds.add(prpc.id);
                        }
                        productRatePlanClass.productRatePlanCounter = ++productRatePlanCounter;
                        productClass.productRatePlans.add(productRatePlanClass);
                    }                    

                    list<Product_Rate_Plan_Charge_Tier__c> listOfTiers = JobCreationUtil.getListOfTiers(setOfRatePlanChargesIds);

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
                } 
            }
        }

        public void onClickRatePlan() {
            currentRatePlanCounter = integer.ValueOf(system.currentPageReference().getParameters().get('ratePlanCounter'));
        }

        public void newRatePlan() {
            ratePlan = new Product_Rate_Plan__c();
            ratePlan.Name = system.Label.EnterDetails + string.ValueOf(productRatePlanCounter);
            productRatePlanClass = new  ProductRatePlanClass();
            productRatePlanClass.productRatePlan = ratePlan;
            productRatePlanClass.productRatePlanCounter = ++productRatePlanCounter;
            productClass.productRatePlans.add(productRatePlanClass);
            currentRatePlanCounter = productRatePlanCounter;

            //once if a user clicks on new rate plan,poulate new productrateplancharge
            productRatePlanChargeClass = new ProductRatePlanChargeClass();
            ratePlanCharge = new Product_Rate_Plan_Charge__c();
            ratePlanCharge.Name = system.Label.EnterChargeDetails + integer.ValueOf(productRateplanChargeCounter);
            productRatePlanChargeClass.productRatePlanChargeCounter = ++productRateplanChargeCounter;
            productRatePlanChargeClass.productRatePlancharge = ratePlanCharge;
            productRatePlanClass.productRatePlanChargeClass.add(productRatePlanChargeClass);
            currentRatePlanChargeCounter = productRateplanChargeCounter;
        }

        public void newRatePlanCharge() {       
            for(ProductRatePlanClass prpc : productClass.productRatePlans) {
                if(prpc.productRatePlanCounter == currentRatePlanCounter) {
                    productRatePlanChargeClass = new ProductRatePlanChargeClass();
                    ratePlanCharge = new Product_Rate_Plan_Charge__c();
                    ratePlanCharge.Name = system.Label.EnterChargeDetails + integer.ValueOf(productRateplanChargeCounter);
                    productRatePlanChargeClass.productRatePlanChargeCounter = ++productRateplanChargeCounter;
                    productRatePlanChargeClass.productRatePlancharge = ratePlanCharge;
                    prpc.productRatePlanChargeClass.add(productRatePlanChargeClass);
                    currentRatePlanChargeCounter = productRateplanChargeCounter;
                }
            }  
        }

        public PageReference saveProduct() {  
            savepoint sp;
            try { 
                sp = DataBase.SetSavePoint();
                upsert product;

                map<Integer,Product_Rate_Plan__c> mapProductRatePlan = new map<Integer,Product_Rate_Plan__c>();        
                for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                    if(prpclass.productRatePlan.Product__c == null) {
                        prpclass.productRatePlan.Product__c = product.Id;
                    }
                    mapProductRatePlan.put(prpclass.productRatePlanCounter,prpclass.productRatePlan);
                } 
                upsert mapProductRatePlan.Values();

                for(ProductRatePlanClass prpc : productClass.productRatePlans) {
                    prpc.productRatePlan = mapProductRatePlan.get(prpc.productRatePlanCounter);
                }

                map<Integer,Product_Rate_Plan_Charge__c> mapProductRatePlanCharges = new map<Integer,Product_Rate_Plan_Charge__c>();
                for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                    for(ProductRatePlanChargeClass prpcclass : prpclass.productRatePlanChargeClass) {
                        if(prpcclass.productRatePlancharge.Product_Rate_Plan__c == null) {
                            prpcclass.productRatePlancharge.Product_Rate_Plan__c = prpclass.productRatePlan.Id;
                        }
                        mapProductRatePlanCharges.put(prpcclass.productRatePlanChargeCounter,prpcclass.productRatePlancharge);
                    }
                }
                upsert mapProductRatePlanCharges.Values();

                for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                    for(ProductRatePlanChargeClass prpcclass : prpclass.productRatePlanChargeClass) {
                        prpcclass.productRatePlancharge = mapProductRatePlanCharges.get(prpcclass.productRatePlanChargeCounter);
                    }
                }

                map<Integer,Product_Rate_Plan_Charge_Tier__c> mapIntegerAndTier = new map<Integer,Product_Rate_Plan_Charge_Tier__c>();
                for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                    for(ProductRatePlanChargeClass prpcclass : prpclass.productRatePlanChargeClass) {
                        for(ProductRatePlanChargeTierClass tierclass : prpcclass.ProductRatePlanChargeTierClass) {
                            if(tierclass.productRatePlanChargeTier.Product_Rate_Plan_Charge__c == null) {
                                tierclass.productRatePlanChargeTier.Product_Rate_Plan_Charge__c = prpcclass.productRatePlancharge.Id;
                            }
                            mapIntegerAndTier.put(tierclass.productRatePlanChargeTierCounter,tierclass.productRatePlanChargeTier);
                        }
                    }
                }
                upsert mapIntegerAndTier.Values();

                return new PageReference('/' + product.Id);
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
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber());
                Apexpages.addMessage(errorMessage);
                DataBase.RollBack(sp);  
                return null;
            }
        } 

        public void removeRatePlan() {  
            string productRatePlanId = system.currentPageReference().getParameters().get('productrateplanidtodelete');
            Integer productrateplancounterval = Integer.valueOf(system.currentPageReference().getParameters().get('productrateplancountertodelete'));

            if(productRatePlanId.Length() > 0) {         
                Product_Rate_Plan__c prpToDelete = new Product_Rate_Plan__c(Id = productRatePlanId);
                delete prpToDelete;
            }
            integer productrateplansize = productClass.productRatePlans.size();
            for(Integer i = 0; i < productrateplancounterval; i++) {
                if(productClass.productRatePlans.get(i).productRatePlanCounter == productrateplancounterval) {
                    productClass.productRatePlans.remove(i);     
                    break;                
                }
            }

            integer productRatePlansSize = productClass.productRatePlans.size();
            if(productRatePlansSize > 0) {
                currentRatePlanCounter = productClass.productRatePlans.get(productRatePlansSize - 1).productRatePlanCounter;
            }
        }

        public void removeRatePlanCharges() {  
            string productRateChargePlanId = system.currentPageReference().getParameters().get('productrateplanchargeidtodelete');
            Integer productrateplanChargecounterval = Integer.valueOf(system.currentPageReference().getParameters().get('productrateplanchargecountertodelete'));
            Integer productrateplancounter = Integer.valueOf(system.currentPageReference().getParameters().get('rateplanchargecounterfromcharges'));

            if(productRateChargePlanId.Length() > 0) {
                Product_Rate_Plan_Charge__c prpcDelete = new Product_Rate_Plan_Charge__c(Id = productRateChargePlanId);
                delete prpcDelete;
            }

            Integer productrateplansize = productClass.productRatePlans.size();
            for(ProductRatePlanClass prpclass : productClass.productRatePlans) {   
                if(prpclass.productRatePlanCounter == productrateplancounter) {
                    for(Integer i = 0; i < productrateplanChargecounterval; i++) {
                        if(prpclass.productRatePlanChargeClass.get(i).productRatePlanChargeCounter == productrateplanChargecounterval) {
                            prpclass.productRatePlanChargeClass.remove(i);
                            break;
                        }
                    }
                } 
            }
        }

        public void addTier() {
            productrateplanchargeCounterfortier = integer.ValueOf(system.currentPageReference().getParameters().get('productrateplanchargeCounterfortier'));
            showPopup();
        }

        public void newTier() {
            for(ProductRatePlanClass prpc : productClass.productRatePlans) {
                for(ProductRatePlanChargeClass prpcc : prpc.productRatePlanChargeClass) {
                    if(prpcc.productRatePlanChargeCounter == productrateplanchargeCounterfortier) {
                        productRatePlanChargeTierClass = new ProductRatePlanChargeTierClass();
                        productTier = new Product_Rate_Plan_Charge_Tier__c();
                        ProductRatePlanChargeTierClass.productRatePlanChargeTierCounter = ++productRateplanChargeTierCounter;
                        ProductRatePlanChargeTierClass.productRatePlanChargeTier = productTier;
                        prpcc.ProductRatePlanChargeTierClass.add(productRatePlanChargeTierClass);
                    }
                }
            }
        }

        public void removeTiers() {        
            string tierIdToDelete = system.currentPageReference().getParameters().get('tieridtodelete');
            Integer tierCounterToDelete = Integer.valueOf(system.currentPageReference().getParameters().get('tiercountertodelete'));
            Integer productrateplancounter = Integer.valueOf(system.currentPageReference().getParameters().get('productRatePlanChargeCounterfromtier'));

            if(tierIdToDelete.Length() > 0) {
                Product_Rate_Plan_Charge_Tier__c prpcTierToDelete = new Product_Rate_Plan_Charge_Tier__c(Id = tierIdToDelete);
                delete prpcTierToDelete;
            }

            Integer productrateplansize = productClass.productRatePlans.size();
            for(ProductRatePlanClass prpclass : productClass.productRatePlans) {   
                for(ProductRatePlanChargeClass  prpChargeClass : prpclass.productRatePlanChargeClass) {
                    if(prpChargeClass.productRatePlanChargeCounter == productrateplancounter) {
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

        public void closePopup() {        
            displayPopup = false;    
        } 

        /*
        Modified By : Anil Pinto: 13-06-2013: INVOICEIT-61
        Comments    : This new method is created as a validations required while saving the tiers
        */
        public Pagereference saveAndClosePopup() {
            //Modified By Lopamudra Guru:25-06-14:SUP-278
            //Comments : Removed some validation and modified existing validations on customer requirement.
            integer i = 1;
            for(ProductRatePlanClass prpc : productClass.productRatePlans) {
                for(ProductRatePlanChargeClass prpcc : prpc.productRatePlanChargeClass) {
                   Product_Rate_Plan_Charge_Tier__c productRatePlanChargeTier = null;
                    if(prpcc.ProductRatePlanChargeTierClass.size() > 1){
                        for(ProductRatePlanChargeTierClass productRatePlanChargeTierClass : prpcc.ProductRatePlanChargeTierClass){
                            
                            if(productRatePlanChargeTier == null){
                                productRatePlanChargeTier = productRatePlanChargeTierClass.productRatePlanChargeTier;
                            }
                            else{
                                if(!prpcc.ProductRatePlanChargeTierClass.isEmpty() && prpcc.ProductRatePlanChargeTierClass.get(0).productRatePlanChargeTier.Start_Unit__c < 0){
                                    Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.StartUnitCannotHaveNegativeValue);
                                    Apexpages.addMessage(errorMessage);
                                    return null;
                                }else if(!prpcc.ProductRatePlanChargeTierClass.isEmpty() && prpcc.ProductRatePlanChargeTierClass.get(0).productRatePlanChargeTier.End_Unit__c!=null && prpcc.ProductRatePlanChargeTierClass.get(0).productRatePlanChargeTier.End_Unit__c < prpcc.ProductRatePlanChargeTierClass.get(0).productRatePlanChargeTier.Start_Unit__c){
                                    Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.EndUnitShouldNotBeLessThanStartUnit );
                                    Apexpages.addMessage(errorMessage);
                                    return null;
                                }
                                else if(productRatePlanChargeTierClass.productRatePlanChargeTier.Start_Unit__c < 0){
                                    Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.StartUnitCannotHaveNegativeValue);
                                    Apexpages.addMessage(errorMessage);
                                    return null;
                                }else if(productRatePlanChargeTierClass.productRatePlanChargeTier.End_Unit__c!=null && productRatePlanChargeTierClass.productRatePlanChargeTier.End_Unit__c < productRatePlanChargeTierClass.productRatePlanChargeTier.Start_Unit__c){
                                    Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.EndUnitShouldNotBeLessThanStartUnit );
                                        Apexpages.addMessage(errorMessage);
                                        return null;
                                }else if(productRatePlanChargeTier.End_Unit__c != null){
                                    decimal iEndUnitValue = productRatePlanChargeTier.End_Unit__c;
                                    if(productRatePlanChargeTierClass.productRatePlanChargeTier.Start_Unit__c <= iEndUnitValue){
                                        Apexpages.Message errorMessage1 = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.TierStartUnit);
                                            Apexpages.addMessage(errorMessage1);
                                            return null;
                                    }
                                }
                                
                                
                            /*Modified By : Rama Krishna.v:Modified Date: 06-11-13: SUP-134
                              Comments    : If an End Unit is entered, it must be less than the subsequent Start Unit. If an End Unit is not entered,
                                           there will be no validation and the tier will be determined up to the subsequent Start Unit.
                            */
                            }  
                            productRatePlanChargeTier = productRatePlanChargeTierClass.productRatePlanChargeTier; 
                            i = i+ 1;
                        }               
                    }else{
                        if(!prpcc.ProductRatePlanChargeTierClass.isEmpty() && prpcc.ProductRatePlanChargeTierClass.get(0).productRatePlanChargeTier.Start_Unit__c < 0){
                            Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.StartUnitCannotHaveNegativeValue);
                            Apexpages.addMessage(errorMessage);
                            return null;
                        }else if(!prpcc.ProductRatePlanChargeTierClass.isEmpty() && (prpcc.ProductRatePlanChargeTierClass.get(0).productRatePlanChargeTier.End_Unit__c!=null && prpcc.ProductRatePlanChargeTierClass.get(0).productRatePlanChargeTier.End_Unit__c < prpcc.ProductRatePlanChargeTierClass.get(0).productRatePlanChargeTier.Start_Unit__c)){
                            //throw error message if end unit is less than start unit of first tier
                            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,  system.Label.EndUnitShouldNotBeLessThanStartUnit));   
                            return null;
                        }
                    }
                }
            }
            displayPopup = false;  
            return null;  
        }


        public void showPopup() {        
            displayPopup = true;    
        }

        public PageReference deleteProduct() {
            string productFirstThreeCharacters = product.Id;
            productFirstThreeCharacters = productFirstThreeCharacters.subString(0,3) + '/o';
            delete product;     
            return new PageReference('/' + productFirstThreeCharacters);
        }

        public PageReference cloneProduct() { 
            savepoint sp;
            try { 
                Product__c newProductTobeCone;
                Product_Rate_Plan__c productRatePlanTobeCone;
                Product_Rate_Plan_Charge__c productRatePlanchargeTobeCone;
                Product_Rate_Plan_Charge_Tier__c TierTobeCone;

                sp = DataBase.SetSavePoint();
                newProductTobeCone = product.clone(false);
                newProductTobeCone.OwnerId = UserInfo.getUserId();
                productClass.product = newProductTobeCone;
                product = productClass.product;

                for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                    productRatePlanTobeCone = prpclass.productRatePlan.clone(false);
                    productRatePlanTobeCone.Product__c = null;
                    prpclass.productRatePlan = productRatePlanTobeCone;
                } 

                for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                    for(ProductRatePlanChargeClass prpcclass : prpclass.productRatePlanChargeClass) {
                        productRatePlanchargeTobeCone = prpcclass.productRatePlancharge.clone(false);
                        productRatePlanchargeTobeCone.Product_Rate_Plan__c = null;
                        prpcclass.productRatePlancharge = productRatePlanchargeTobeCone;
                    }
                }

                for(ProductRatePlanClass prpclass : productClass.productRatePlans) {
                    for(ProductRatePlanChargeClass prpcclass : prpclass.productRatePlanChargeClass) {
                        for(ProductRatePlanChargeTierClass tierclass : prpcclass.ProductRatePlanChargeTierClass) {
                            TierTobeCone = tierclass.productRatePlanChargeTier.clone(false);
                            TierTobeCone.Product_Rate_Plan_Charge__c = null;
                            tierclass.productRatePlanChargeTier = TierTobeCone;
                        }
                    }
                }

                isViewMode = false;
                return new PageReference('/apex/createProduct');
            } catch(Exception ex) {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber());
                Apexpages.addMessage(errorMessage);
                DataBase.RollBack(sp);  
                return null;
            }
        }

        // this method added by anil on  september 4 for new button view Product in Beta
        public Pagereference viewProductNewScreen() {
            PageReference secondPage;
            string productFirstFifteenCharacters;
            if(product != null && product.Id != null) {
                productFirstFifteenCharacters = product.Id;
                productFirstFifteenCharacters = productFirstFifteenCharacters.subString(0,15);
                secondPage = new  PageReference('/apex/createProductStep2New?id='+productFirstFifteenCharacters);
                secondPage.setRedirect(true);
            }
            return secondPage;
        }
    }