public with sharing class JobProductClass {
    public Job_Product__c jobproduct {get;set;}
    public JobRatePlanClass [] jobRatePlans = new List<JobRatePlanClass>();
    public Integer jobProductCounter {get;set;}
    public List<JobRatePlanClass> getJobRatePlans() {
        return jobRatePlans;
    }
    
}