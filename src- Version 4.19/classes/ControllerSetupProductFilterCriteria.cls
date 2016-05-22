public with sharing class ControllerSetupProductFilterCriteria {
        public list<Product_Catalog_Filter_Criteria__c> filters {get; set;}
        
        public ControllerSetupProductFilterCriteria() {
            filters = Product_Catalog_Filter_Criteria__c.getAll().values();
        }
        
        public PageReference addRow() {
            upsert filters;
            
            Product_Catalog_Filter_Criteria__c filter = new Product_Catalog_Filter_Criteria__c();
            filters.add(filter);
            
            return null;
        }
        
        public PageReference save(){
            upsert filters;
            
            Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.Info,System.Label.SavedSucessfully);
            Apexpages.addMessage(infoMessage);
            
            return null;
        }
        
        public PageReference deleteRow(){
            String id = System.currentPageReference().getParameters().get('id');
            if(id != null){
                Product_Catalog_Filter_Criteria__c filter = new Product_Catalog_Filter_Criteria__c(id = id);
                delete filter;
                Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.Info,System.Label.DeletedSuccessfully);
                Apexpages.addMessage(infoMessage);
                filters = Product_Catalog_Filter_Criteria__c.getAll().values();
            }
            
            return null;
        }
    }