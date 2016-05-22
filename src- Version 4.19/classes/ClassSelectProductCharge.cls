public class ClassSelectProductCharge {
	    public boolean isSelected {get; set;}   
	    public Product_Rate_Plan_Charge__c productCharge {get; set;}
	    public ClassSelectProductCharge(boolean isSelected, Product_Rate_Plan_Charge__c productCharge) {
	        this.productCharge = productCharge;
	        this.isSelected = isSelected;   
	    }
	}