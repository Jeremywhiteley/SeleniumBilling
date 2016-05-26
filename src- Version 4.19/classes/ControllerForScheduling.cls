public with sharing class ControllerForScheduling {

        public Invoice_RunScheduler__c invoiceRunScheduler {get; set;}
        public Boolean isEditMode {get; set;} 
        public string str {get; set;} 
        public ControllerForScheduling(ApexPages.StandardController stdController) {
            this.invoiceRunScheduler = (Invoice_RunScheduler__c)stdController.getRecord();

            if(invoiceRunScheduler.Id != null) {
                invoiceRunScheduler = CommonUtilClass.getinvoiceRunScheduler(invoiceRunScheduler.Id);   
                isEditMode = true;
            }
            else {
                invoiceRunScheduler.Type__c = System.Label.OptionOnce;
            }
        }

        public PageReference onChangeOfType() {
            if(invoiceRunScheduler.Type__c == System.Label.OptionDaily) {
                invoiceRunScheduler.Start_date_and_time__c = system.Now();
                invoiceRunScheduler.Invoice_Date__c = invoiceRunScheduler.Start_date_and_time__c.Date();
                invoiceRunScheduler.Target_Date__c = invoiceRunScheduler.Start_date_and_time__c.Date();
                Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.INFO,System.Label.DailyDateMessage);
                Apexpages.addMessage(infoMessage);
            } 
            return null;
        }

        public void onChangeStartDate() {
            if(invoiceRunScheduler.Type__c == System.Label.OptionDaily) {
                invoiceRunScheduler.Invoice_Date__c = invoiceRunScheduler.Start_date_and_time__c.Date();
                invoiceRunScheduler.Target_Date__c = invoiceRunScheduler.Start_date_and_time__c.Date();
            }
        }

        public PageReference saveInvoiceRunScheduler() {
            SavePoint sp;
            boolean isValidations = validations();
            if(!isValidations) {
                try {            
                    sp = DataBase.setSavePoint();
                    if(isEditMode == true) {
                        System.abortJob(invoiceRunScheduler.JobId__c);
                    }

                    String cronExpr = null;
                    String jobId  = null;           
                    Date startDate =  invoiceRunScheduler.Start_date_and_time__c.Date();
                    Integer hours =  invoiceRunScheduler.Start_date_and_time__c.Hour();
                    Integer minutes = invoiceRunScheduler.Start_date_and_time__c.Minute();            
                    String schedulerType  = invoiceRunScheduler.Type__c;
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
                    
                    jobId = System.schedule(invoiceRunScheduler.name,cronExpr,new RunScheduler());
                    invoiceRunScheduler.JobId__c = jobId;
                    upsert invoiceRunScheduler;
                }
                catch(system.AsyncException asyncException) {
                    Database.rollback(sp);
                    Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.INFO,asyncException.getMessage());
                    Apexpages.addMessage(errorMessage);  
                    return null;
                }
                catch(system.DmlException dmlException) {
                    Database.rollback(sp);
                    Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dmlException.getMessage());
                    Apexpages.addMessage(errorMessage);  
                    return null;
                }
                catch(system.Exception ex) {
                    Database.rollback(sp);
                    Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,ex.getMessage());
                    Apexpages.addMessage(errorMessage);  
                    return null;
                }
                return new PageReference('/' + invoiceRunScheduler.Id);
            }
            else {
                return null;
            }
        }

        public boolean validations() {
            if(invoiceRunScheduler.Start_date_and_time__c == null) {
                invoiceRunScheduler.Start_date_and_time__c.addError(system.Label.Thisfieldisrequired);  
                return true;    
            } else if(invoiceRunScheduler.Name == null) {
                invoiceRunScheduler.Name.addError(system.Label.Thisfieldisrequired);    
                return true;
            } else if(invoiceRunScheduler.Invoice_Currency__c == null) {
                invoiceRunScheduler.Invoice_Currency__c.addError(system.Label.Thisfieldisrequired); 
                return true;
            } else if(invoiceRunScheduler.Type__c == System.Label.OptionWeekly) {
                if(invoiceRunScheduler.Invoice_Day_of_week__c == null) { 
                    invoiceRunScheduler.Invoice_Day_of_week__c.addError(system.Label.Thisfieldisrequired);
                    return true;
                } else if(invoiceRunScheduler.Target_Day_of_week__c == null) {
                    invoiceRunScheduler.Target_Day_of_week__c.addError(system.Label.Thisfieldisrequired);
                    return true;
                }

            } else if(invoiceRunScheduler.Type__c == System.Label.OptionMonthly) {
                if(invoiceRunScheduler.Invoice_Day_Of_Month__c == null) { 
                    invoiceRunScheduler.Invoice_Day_Of_Month__c.addError(system.Label.Thisfieldisrequired);
                    return true;
                } else if(invoiceRunScheduler.Target_Day_Of_Month__c == null) {
                    invoiceRunScheduler.Target_Day_Of_Month__c.addError(system.Label.Thisfieldisrequired);
                    return true;
                }
            } else if(invoiceRunScheduler.Start_date_and_time__c <= system.Now()) {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.Startdatehaspassed);
                Apexpages.addMessage(errorMessage);
                return true;
            }
            
            /*
                    Modified By     : Devender M 03 Sept 2013 INVOICEIT-224/SUP-39
                    
                    INVOICEIT-374
            */
            if(invoiceRunScheduler.Start_date_and_time__c != null && invoiceRunScheduler.Type__c == System.Label.OptionDaily && invoiceRunScheduler.Start_date_and_time__c > system.now() + 1) {
                invoiceRunScheduler.Start_date_and_time__c.addError(system.Label.DailySchedulerError);  
                return true;    
            }
            
            return false;
        }
        
        //Please do not move this test method to anywhere because this code will also call RunScheduler
      
    }