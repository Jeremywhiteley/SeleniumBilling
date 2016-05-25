public with sharing class ProductRatePlanClass {
	    public Product_Rate_Plan__c productRatePlan {get;set;}
	    public ProductRatePlanChargeClass [] productRatePlanChargeClass = new List<ProductRatePlanChargeClass>();
	    public Integer productRatePlanCounter {get; set;}
	    
	    public List<ProductRatePlanChargeClass> getProductRatePlanChargeClass(){
	        return productRatePlanChargeClass;
	    }
	}