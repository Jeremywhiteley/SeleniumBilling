public with sharing class ControllerInsertOptionalExtra {

    private map<String, Configuration__c> mapConfiguration;
    public String searchstring {get;set;}
    public String displayfields {get; set;}
    public String objectname {get; set;}
    public String orderfield {get; set;}
    public String searchfields {get; set;}
    public String sProductsLimit {get; set;}

    public List<Product_Rate_Plan__c> listProductRatePlans {get;set;}
    public List<Product_Rate_Plan_Charge__c> listProductRatePlanCharges {get;set;}
    public List<Product_Rate_Plan_Charge__c> listSelectedProductRatePlanCharges {get;set;}
    public String selectedProductId {get;set;}
    public String selectedProductName {get;set;} 
    public boolean isMultipleRatePlans {get; set;}
    public boolean isRatePlanChargesExists {get; set;}
    public Quote__c quote {get;set;}

    private Optional_Extra__c optionalExtra;
    private list<Optional_Extra__c> listoptionalExtra;

    public ControllerInsertOptionalExtra(ApexPages.StandardController controller) {
        this.quote = (Quote__c)controller.getRecord();      
        mapConfiguration = Configuration__c.getAll();
        listSelectedProductRatePlanCharges = new List<Product_Rate_Plan_Charge__c>();
        displayfields = mapConfiguration.get('PRODUCT_DISPLAYFIELDS').String_Value__c; 
        objectname = mapConfiguration.get('PRODUCT_OBJECTNAME').String_Value__c;
        orderfield = mapConfiguration.get('PRODUCT_ORDERFIELD').String_Value__c;
        searchfields = mapConfiguration.get('PRODUCT_SEARCHFIELDS').String_Value__c;
        sProductsLimit = '' + (mapConfiguration.get('PRODUCT_SEARCH_LIMIT').Number_Value__c).intValue(); 
    }

    /**
     * This method returns ProductRatePlans of the SelectedProduct
     * @return PageReference
     */
    public PageReference getRatePlansForProduct() {
        try{
            selectedProductId = System.currentPageReference().getParameters().get('productId');
            selectedProductName = System.currentPageReference().getParameters().get('productName');
            if(selectedProductId != null) {
                map<String,String> searchMap = new map<String,String>();              
                DateTime dt = DateTime.Now();
                listProductRatePlans = QuoteCreationUtil.getProductRatePlans(selectedProductId,dt.Date(),searchMap);
            }
            if(listProductRatePlans.size() == 1) {
                isMultipleRatePlans = false;
                string selectedRatePlanId = listProductRatePlans.get(0).id;
                System.currentPageReference().getParameters().put('ratePlanId',selectedRatePlanId);
                getRatePlanChargesForRatePlan();
            }
            else if(listProductRatePlans.size() > 1) {
                isMultipleRatePlans = true;
            }
            else {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.INFO,System.Label.Product_ProductRatePlan);
                Apexpages.addMessage(errorMessage);
            }            

        }catch(Exception ex) {
            Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,System.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber());
            Apexpages.addMessage(errorMessage);
        }

        return null;
    }

    /**
     * This method returns ProductRatePlanCharges of the SelectedRatePlan
     * @return PageReference
     */  
    public PageReference getRatePlanChargesForRatePlan() {
        try {
            string selectedRatePlanId = System.currentPageReference().getParameters().get('ratePlanId'); 
            map<String,String> searchMap = new map<String,String>();   
            listProductRatePlanCharges = JobCreationUtil.getProductRatePlanCharges(selectedRatePlanId, quote.CurrencyL__c, searchMap);
            if(listProductRatePlanCharges.size() > 0) {
                boolean isExists = true;   
                for(Product_Rate_Plan_Charge__c prpc : listSelectedProductRatePlanCharges) {
                    if(prpc.Product_Rate_Plan__c == selectedRatePlanId){
                        Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.WARNING,system.Label.ProductRatePlanExist);
                        Apexpages.addMessage(errorMessage); 
                        isExists = false;
                        break;
                    }
                }
                if(isExists) {
                    isRatePlanChargesExists = true;
                    listSelectedProductRatePlanCharges.addAll(listProductRatePlanCharges);
                }
            }          
            else {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.WARNING,System.Label.Product_ProductRatePlan);
                Apexpages.addMessage(errorMessage);
            }
        }
        catch(Exception ex) {
            Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,System.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber());
            Apexpages.addMessage(errorMessage);
        }
        return null;
    }

    public PageReference removeCharges(){  
        String sRatePlanChargeId = System.currentPageReference().getParameters().get('ratePlanChargeId');
        Integer iCount = 0;
        for(Product_Rate_Plan_Charge__c prpc: listSelectedProductRatePlanCharges) {
            if(prpc.Id == sRatePlanChargeId) {
                listSelectedProductRatePlanCharges.remove(iCount);
                break;
            }
            iCount++;
        }
        return null;
    }

    public PageReference InsertOptionalExtras(){
        listoptionalExtra = new  list<Optional_Extra__c>();
        if(listSelectedProductRatePlanCharges.size() == 0) {
            Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.INFO,system.Label.OptionalExtrasNotSelected);
            Apexpages.addMessage(errorMessage); 
            return null;
        }
        else {
            try { 
                for(Product_Rate_Plan_Charge__c prpc: listSelectedProductRatePlanCharges) {
                    //This adjustment was done for Touchmore 07 April 2013 by MG
                    //Get the unit price populated by checking the price type for tiered, flat pricing, volume pricing etc
                    optionalExtra = new Optional_Extra__c();
                    optionalExtra.Quantity__c = prpc.Default_Quantity__c;
                    optionalExtra.Invoice_IT_Product__c = prpc.Product_Rate_Plan__r.Product__r.Id;
                    optionalExtra.Product_Rate_Plan__c = prpc.Product_Rate_Plan__c;
                    optionalExtra.Product_Rate_Plan_Charge__c = prpc.Id;
                    optionalExtra.Quote__c = quote.Id;
                    optionalExtra.Name = prpc.Product_Rate_Plan__r.Product__r.Name;
                    
                    if(prpc.Price_Format__c == CommonUtilClass.PRICE_FORMAT_TIERED){
                        populateOptionalExtraForTieredPricing(prpc, optionalExtra);
                        //If the unit price is null then this could have been beyond the available tiers. So throw an exception
                        if(optionalExtra.Unit_Selling_Price2__c == null)
                        {
                            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.WARNING,system.Label.Tieredlimit + ' -- "' + prpc.Product_Rate_Plan__r.Product__r.Name + '"'));
                            return null;    
                        }
                    }
                    if(prpc.Price_Format__c == CommonUtilClass.PRICE_FORMAT_VOLUME || prpc.Price_Format__c == CommonUtilClass.PRICE_FORMAT_FLAT_FEE){
                        populateOptionalExtraForVolumeOrFlatFeePricing(prpc, optionalExtra);
                        if(optionalExtra.Unit_Selling_Price2__c == null)
                        {
                            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.Tieredlimit + ' -- "' + prpc.Product_Rate_Plan__r.Product__r.Name + '"'));
                            return null;    
                        }
                    }
        
                    listoptionalExtra.add(optionalExtra);          
                }
                insert listoptionalExtra;
                listSelectedProductRatePlanCharges.clear();
                isRatePlanChargesExists = false;
                return new PageReference('/' + quote.Id);
            } catch(DMLException dMlEx){
                // Added by Naveen M ticket : INVOICEIT-310 
                Apexpages.Message errorMessage; 
                for (Integer i = 0; i < dMlEx.getNumDml(); i++)
                { 
                      errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(i));
                      Apexpages.addMessage(errorMessage);      
                } 
                return null; 
            } catch(Exception ex) {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,System.Label.ExceptionMessage + ex.getTypeName() + ':'+ex.getMessage() + ':'  + ex.getLineNumber());
                Apexpages.addMessage(errorMessage);
                return null;
            }
        }
    }
    
    public static void populateOptionalExtraForVolumeOrFlatFeePricing(Product_Rate_Plan_Charge__c  prpc, Optional_Extra__c optionalExtra)
    {
        if(optionalExtra.Quantity__c > 0) {
            list<Product_Rate_Plan_Charge_Tier__c> tempTiers = prpc.Product_Rate_Plan_Charge_Tiers__r;
            
            Product_Rate_Plan_Charge_Tier__c productChargeTier;
            integer iSize = tempTiers.Size();
            
            for(integer i = 0; i < iSize; i++) {
                productChargeTier = tempTiers[i];
                
                if( (productChargeTier.Start_Unit__c < = optionalExtra.Quantity__c && productChargeTier.End_Unit__c > = optionalExtra.Quantity__c)
                    ||
                    (productChargeTier.Start_Unit__c < = optionalExtra.Quantity__c && productChargeTier.End_Unit__c == null))
                {
                    optionalExtra.Unit_Cost_Price__c = productChargeTier.Unit_Cost_Price__c;
                    optionalExtra.Unit_Selling_Price2__c = productChargeTier.Unit_Price__c;
                    
                    if(prpc.Price_Format__c == CommonUtilClass.PRICE_FORMAT_VOLUME){
                        optionalExtra.Subtotal__c = optionalExtra.Quantity__c * optionalExtra.Unit_Selling_Price2__c;
                        if(optionalExtra.Unit_Cost_Price__c != null){
                            optionalExtra.Total_Cost__c = optionalExtra.Quantity__c * optionalExtra.Unit_Cost_Price__c;                         
                        }
                    }
                    else if(prpc.Price_Format__c == CommonUtilClass.PRICE_FORMAT_FLAT_FEE)
                    {
                        optionalExtra.Subtotal__c = optionalExtra.Unit_Selling_Price2__c;
                        optionalExtra.Total_Cost__c = optionalExtra.Unit_Cost_Price__c;
                    }
                }
            }
        }
    }
    public static void populateOptionalExtraForTieredPricing(Product_Rate_Plan_Charge__c  prpc, Optional_Extra__c optionalExtra) 
    {
        if(optionalExtra.Quantity__c > 0) {
            
            decimal usageAmount = 0;
            decimal costPrice = 0;
            integer remaningUsage = integer.ValueOf(optionalExtra.Quantity__c);
            integer usageQuantity = integer.ValueOf(optionalExtra.Quantity__c);
            boolean isTierExists = false;
            integer iSize;
           
            list<Product_Rate_Plan_Charge_Tier__c> tempTiers = prpc.Product_Rate_Plan_Charge_Tiers__r;
            Product_Rate_Plan_Charge_Tier__c productChargeTier;
            iSize = tempTiers.Size();
            
            for(integer i = 0; i < iSize; i++) {
                productChargeTier = tempTiers[i];
                if(usageQuantity >=  productChargeTier.Start_Unit__c) {
                    isTierExists = true;
                    integer diff;
                    
                    if(productChargeTier.End_Unit__c != null){
                        diff = integer.ValueOf(productChargeTier.End_Unit__c - productChargeTier.Start_Unit__c + 1);
                    }else{
                        diff = remaningUsage;
                    }
                    
                    if(remaningUsage <= diff) {
                        //calculate the sp
                        usageAmount +=  (decimal) (remaningUsage * productChargeTier.Unit_Price__c);
                        //calculate the cp
                        if(productChargeTier.Unit_Cost_Price__c != null && productChargeTier.Unit_Cost_Price__c > 0) {
                            costPrice +=  (decimal) (remaningUsage * productChargeTier.Unit_Cost_Price__c);
                        }
                    } else {
                        //calculate the sp
                        usageAmount +=  (decimal) (diff * productChargeTier.Unit_Price__c); 
                        //calculate the cp
                        if(productChargeTier.Unit_Cost_Price__c != null && productChargeTier.Unit_Cost_Price__c > 0) {
                            costPrice +=  (decimal) (diff * productChargeTier.Unit_Cost_Price__c); 
                        }
                    }
                    remaningUsage = remaningUsage - diff;
    
                    //this means it has reached end tier and remaning Usage is still present
                    if(i == tempTiers.Size() - 1 && remaningUsage > 0) {
                        //calculate the sp
                        usageAmount += (remaningUsage * productChargeTier.Unit_Price__c);
                        //calculate the cp
                        if(productChargeTier.Unit_Cost_Price__c != null && productChargeTier.Unit_Cost_Price__c > 0) {
                            costPrice +=  (remaningUsage * productChargeTier.Unit_Cost_Price__c);
                        }
                    }
               }
               
               if(i == (iSize - 1) && !isTierExists) {
                    Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.WARNING,system.Label.Tieredlimit));
               }
            }
            
            optionalExtra.Unit_Selling_Price2__c = usageAmount/optionalExtra.Quantity__c;
            optionalExtra.Unit_Cost_Price__c = costPrice/optionalExtra.Quantity__c;
            optionalExtra.Total_Cost__c = costPrice;
            optionalExtra.Subtotal__c = usageAmount;
        } else {
            optionalExtra.Unit_Selling_Price2__c = 0;
            optionalExtra.Unit_Cost_Price__c = 0;
            optionalExtra.Total_Cost__c = 0;
            optionalExtra.Subtotal__c = 0;
            optionalExtra.Total_Cost__c = 0;
        }
    }
}