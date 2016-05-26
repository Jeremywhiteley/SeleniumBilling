public with sharing class ProductClass {
	    public Product__c product {get; set;}
	    public ProductRatePlanClass [] productRatePlans = new List<ProductRatePlanClass>();
	    public List<ProductRatePlanClass> getProductRatePlans() {
	        return productRatePlans;
	    }
	}