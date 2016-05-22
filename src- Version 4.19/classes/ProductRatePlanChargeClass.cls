public with sharing class ProductRatePlanChargeClass {
	    public Product_Rate_Plan_Charge__c productRatePlancharge {get; set;}
	    public Integer productRatePlanChargeCounter {get; set;}
	    public boolean isSelected {get; set;}
	    
	    public ProductRatePlanChargeTierClass [] ProductRatePlanChargeTierClass = new List<ProductRatePlanChargeTierClass>();
	    
	    public List<ProductRatePlanChargeTierClass> getProductRatePlanChargeTierClass(){
	        return ProductRatePlanChargeTierClass;
	    }
	}