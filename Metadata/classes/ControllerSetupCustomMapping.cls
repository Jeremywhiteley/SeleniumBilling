public with sharing class ControllerSetupCustomMapping {
        public list<Custom_Mappings__c> mappings {get; set;}
        
        public ControllerSetupCustomMapping() {
            mappings = Custom_Mappings__c.getAll().values();
        }
        
        public PageReference addRow() {
            upsert mappings;
            
            Custom_Mappings__c mapping = new Custom_Mappings__c();
            mappings.add(mapping);
            
            return null;
        }
        
        public PageReference save(){
            upsert mappings;
            
            Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.Info,system.Label.SavedSucessfully);
            Apexpages.addMessage(infoMessage);
            
            return null;
        }
        
        public PageReference deleteRow(){
            String id = System.currentPageReference().getParameters().get('id');
            if(id != null){
                Custom_Mappings__c mapping = new Custom_Mappings__c(id = id);
                delete mapping;
                Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.Info,system.Label.DeletedSuccessfully);
                Apexpages.addMessage(infoMessage);
                mappings = Custom_Mappings__c.getAll().values();
            }
            
            return null;
        }
    }