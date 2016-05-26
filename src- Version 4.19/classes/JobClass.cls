public with sharing class JobClass {
	    public Job__c job;
	    public JobProductClass [] jobProducts = new List<JobProductClass>();

	    public List<JobProductClass> getJobProducts() {
	        return jobProducts;
	    }
	    public Job__c getJob() {
	        return job;
	    }
	    
	    
	}