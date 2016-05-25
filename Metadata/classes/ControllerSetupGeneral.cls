public with sharing class ControllerSetupGeneral {
            public list<Configuration__c> configurations {get; set;}
            
            public ControllerSetupGeneral() {
            configurations = Configuration__c.getAll().values();
        }
        
        public PageReference save(){
            update configurations;
            
            Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.Info,System.Label.SavedSucessfully);
            Apexpages.addMessage(infoMessage);
            
            return null;
        }
    }