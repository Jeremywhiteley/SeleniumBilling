public with sharing class ControllerForSchedulingPayments {

        public Payment_Scheduler__c paymentScheduler {get; set;}
        public Boolean isEditMode {get; set;}
        
        public ControllerForSchedulingPayments(ApexPages.StandardController stdController) {
            this.paymentScheduler = (Payment_Scheduler__c) stdController.getRecord();
             
            if(paymentScheduler.Id != null) {
                paymentScheduler = CommonUtilClass.getPaymentScheduler(paymentScheduler.Id);   
                isEditMode = true;
            }
            else {
                paymentScheduler.Type__c = System.Label.OptionOnce; 
            }
        }
        
        public PageReference onChangeOfType() {
            if(paymentScheduler.Type__c == System.Label.OptionDaily) {
                paymentScheduler.Start_date_and_time__c = system.Now();
                paymentScheduler.Target_Date__c = paymentScheduler.Start_date_and_time__c.Date();
                Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.INFO,System.Label.DailyDateMessage);
                Apexpages.addMessage(infoMessage);
            }
            return null;
        }

        public void onChangeStartDate() {
            if(paymentScheduler.Type__c == System.Label.OptionDaily) {
                paymentScheduler.Target_Date__c = paymentScheduler.Start_date_and_time__c.Date();
            }
        }
        
        public PageReference savePaymentScheduler() {
            SavePoint sp;
            boolean isValidations = validations();
            if(!isValidations) {
                try {            
                    sp = DataBase.setSavePoint();
                    if(isEditMode == true) {
                        System.abortJob(paymentScheduler.JobId__c);
                    }

                    String cronExpr = null;
                    String jobId  = null;           
                    Date startDate =  paymentScheduler.Start_date_and_time__c.Date();
                    Integer hours =  paymentScheduler.Start_date_and_time__c.Hour();
                    Integer minutes = paymentScheduler.Start_date_and_time__c.Minute();            
                    String schedulerType  = paymentScheduler.Type__c;
                    Integer seconds = 0;
                    Integer dayOfMonth = startDate.day();
                    Integer month =  startDate.month(); 
                    Integer year =  startDate.year();
                    Date weekStart = startDate.toStartofWeek();
                    Integer dayOfWeek = weekStart.daysBetween(startDate);
                    String space = ' ';
                    String questionMark = '?';
                    String repeat  = '*';
                    String comma = ',';
                    dayOfWeek = dayOfWeek + 2;
                    if(System.Label.OptionOnce == schedulerType)
                    {
                        cronExpr = seconds+ space  + minutes+ space + hours + space +dayOfMonth+ space +month +space+ questionMark + space+  year;              
                    }  
                    else if(System.Label.OptionWeekly == schedulerType)
                    {
                        cronExpr = seconds+ space  + minutes+ space + hours + space + questionMark + space + repeat +space+ dayOfWeek + space+  repeat;
                    }
                    else if(System.Label.OptionMonthly == schedulerType)
                    {
                        cronExpr = seconds+ space  + minutes+ space + hours + space +dayOfMonth+ space +month + comma + repeat +space+  questionMark + space+  year + comma + repeat;
                    }
                    else if(System.Label.OptionDaily == schedulerType)
                    {
                        cronExpr = seconds+ space  + minutes+ space + hours + space +dayOfMonth+ comma +repeat + space + repeat +space+ questionMark  + space+  repeat;
                    }

                    jobId = System.schedule(paymentScheduler.Name, cronExpr, new RunSchedulerPayment());
                    paymentScheduler.JobId__c = jobId;
                    upsert paymentScheduler;
                }
                catch(DMLException dMlEx){
                // Added by Mani ticket : INVOICEIT-310
                    Apexpages.Message errorMessage; 
                    for (Integer i = 0; i < dMlEx.getNumDml(); i++)
                    { 
                        errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(i));
                        Apexpages.addMessage(errorMessage);      
                    } 
                    return null; 
                }
                catch(system.Exception ex) {
                    Database.rollback(sp);
                    Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,ex.getMessage());
                    Apexpages.addMessage(errorMessage);  
                    return null;
                }
                return new PageReference('/' + paymentScheduler.Id);
            }
            else {
                return null;
            }
        }

        public boolean validations() {
            if(paymentScheduler.Start_date_and_time__c == null) {
                paymentScheduler.Start_date_and_time__c.addError(system.Label.Thisfieldisrequired);  
                return true;    
            } else if(paymentScheduler.Name == null) {
                paymentScheduler.Name.addError(system.Label.Thisfieldisrequired);    
                return true;
            } else if(paymentScheduler.Currency__c == null) {
                paymentScheduler.Currency__c.addError(system.Label.Thisfieldisrequired); 
                return true;
            } else if(paymentScheduler.Type__c == System.Label.OptionWeekly && paymentScheduler.Target_Day_of_week__c == null) {
                paymentScheduler.Target_Day_of_week__c.addError(system.Label.Thisfieldisrequired);
                return true;
            } else if(paymentScheduler.Type__c == System.Label.OptionMonthly && paymentScheduler.Target_Day_Of_Month__c == null) {
                paymentScheduler.Target_Day_Of_Month__c.addError(system.Label.Thisfieldisrequired);
                return true;
            } else if(paymentScheduler.Start_date_and_time__c <= system.Now()) {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.Startdatehaspassed);
                Apexpages.addMessage(errorMessage);
                return true;
            }

            return false;
        }
        
    }