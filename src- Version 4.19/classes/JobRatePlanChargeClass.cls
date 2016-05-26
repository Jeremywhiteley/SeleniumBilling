public with sharing class JobRatePlanChargeClass {
        public Job_Rate_Plan_Charge__c jobrateplancharge {get;set;}
        public Integer jobRatePlanChargeCounter {get;set;}
        
        //Below are used in product bundle concept
        public Boolean displayRemove  {get;set;}
        public Boolean isQuantityEditable  {get;set;}
        
        public JobRatePlanChargeClass() {
            isQuantityEditable = true;
        }
        
        public JobRatePlanChargeTierClass[] jobRatePlanChargeTiers = new List<JobRatePlanChargeTierClass>();
        public List<JobRatePlanChargeTierClass> getJobRatePlanChargeTiers()
        {
            return jobRatePlanChargeTiers;
        }
        
    }