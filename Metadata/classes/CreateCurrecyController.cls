public with sharing class CreateCurrecyController {

        public Currency__c currencyObject {get; set;}
        public boolean isViewMode {get; set;}
        public CreateCurrecyController(ApexPages.StandardController stdController) {
            this.currencyObject = (Currency__c)stdController.getRecord();
            if(currencyObject.Id == null) {
                currencyObject.Currency_Symbol__c = '';
                isViewMode = true;
            }
            else {
                currencyObject = [  SELECT Name,Currency_Symbol__c,Currency_Name__c 
                                    FROM Currency__c 
                                    WHERE Id =: currencyObject.Id]; 
            }
        }

        public void edit() {
            isViewMode = true;
        }
        
        public PageReference save() {
            upsert currencyObject;
            return new PageReference('/' + currencyObject.Id);
        }
    }