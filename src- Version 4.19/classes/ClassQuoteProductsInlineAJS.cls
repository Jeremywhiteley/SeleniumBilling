global with sharing class ClassQuoteProductsInlineAJS {
            public string sCharges {get; set;}
            public string sortingOrder{get; set;}
            public String sPrefix {get; set;}
            public ClassQuoteProductsInlineAJS(ApexPages.StandardController controller) {
                    sPrefix = CommonUtilClass.getPrefix();
                    Quote__c quoteObj = (Quote__c)controller.getRecord();
                    sCharges = getChargeFieldSetvalue(quoteObj.Id);
            }
            Global string getChargeFieldSetvalue(Id QuoteId) {
                    list<string> chargesFields = new list<string>();
                    map<string,string> mapOfChargeFieldandLabel =  new map<string,string>();
                    map<string,string> mapOfChargeFieldValues;
                    list<sobject> sObj = new list<sobject>();
                    list<Object> listofCharge = new list<Object>(); 
                    JSONGenerator generator = JSON.createGenerator(true);
                    if(QuoteId != null){
                            String query = 'SELECT ';
                            String apiName = '';
                            //Getting the parent fields from the field set i.e, QuoteProduct
                            for(Schema.FieldSetMember quoteProductFieldSet : SObjectType.Quote_Product__c.FieldSets.ProductFieldsInline.getFields()) {
                                    query += 'Quote_Rate_Plan__r.Quote_Product__r.'+quoteProductFieldSet.getFieldPath() + ', ';
                                    mapOfChargeFieldandLabel.put('Quote_Rate_Plan__r.Quote_Product__r.'+quoteProductFieldSet.getFieldPath(),quoteProductFieldSet.getLabel());
                                    chargesFields.add('Quote_Rate_Plan__r.Quote_Product__r.'+quoteProductFieldSet.getFieldPath());
                            }
                            //Getting the child fields from the field set i.e, Charges
                            for(Schema.FieldSetMember chargeFieldSet : SObjectType.Quote_Rate_Plan_Charge__c.FieldSets.Quote_Detail_Page.getFields()) {
                                    query += chargeFieldSet.getFieldPath() + ', ';
                                    mapOfChargeFieldandLabel.put(chargeFieldSet.getFieldPath(),chargeFieldSet.getLabel());
                                    chargesFields.add(chargeFieldSet.getFieldPath());
                            }
                            chargesFields.add('Id');
                            chargesFields.add('Quote_Rate_Plan__r.Quote_Product__r.Product__r.Name');
                            mapOfChargeFieldandLabel.put('Id','Id');
                            mapOfChargeFieldandLabel.put('Quote_Rate_Plan__r.Quote_Product__r.Product__r.Name','pName');
                            if(query.contains('Sequence_No__c'))
                                query += 'Id,Quote_Rate_Plan__r.Quote_Product__r.Product__r.Name FROM Quote_Rate_Plan_Charge__c WHERE Quote__c=:QuoteId ORDER BY  Quote_Rate_Plan__r.Quote_Product__r.SequenceNumber__c,Sequence_No__c';
                            else
                                query += 'Id,Sequence_No__c,Quote_Rate_Plan__r.Quote_Product__r.Product__r.Name FROM Quote_Rate_Plan_Charge__c WHERE Quote__c=:QuoteId ORDER BY  Quote_Rate_Plan__r.Quote_Product__r.SequenceNumber__c,Sequence_No__c';
                            sObj = Database.query(query);
                            generator.writeStartArray();
                            for(sobject obj : sObj) {
                                    generator.writeStartObject();   
                                    for(string api : chargesFields) {                       
                                            // If it contains the Quote_Rate_Plan__r in the API that means it is the parent fields
                                            if(api.contains('Quote_Rate_Plan__r')) {
                                                            apiName = api.replace('Quote_Rate_Plan__r.Quote_Product__r.', '');
                                                     
                                                            if(string.valueOf(obj.get('Sequence_No__c')) != null && string.valueOf(obj.get('Sequence_No__c')) == '1' && apiName.contains('Product__r') && string.valueOf(obj.getSobject('Quote_Rate_Plan__r').getSobject('Quote_Product__r').get('Product__c')) != null) {
                                                                generator.writeStringField(mapOfChargeFieldandLabel.get(api), string.valueOf(obj.getSobject('Quote_Rate_Plan__r').getSobject('Quote_Product__r').getSobject('Product__r').get('Name')));
                                                            } else if(!apiName.contains('Product__r') && string.valueOf(obj.get('Sequence_No__c')) != null && string.valueOf(obj.get('Sequence_No__c')) == '1' && string.valueOf(obj.getSobject('Quote_Rate_Plan__r').getSobject('Quote_Product__r').get(''+apiName)) != null) {
                                                                    generator.writeStringField(mapOfChargeFieldandLabel.get(api), string.valueOf(obj.getSobject('Quote_Rate_Plan__r').getSobject('Quote_Product__r').get(''+apiName)));
                                                            } else {
                                                                    generator.writeStringField(mapOfChargeFieldandLabel.get(api),'');
                                                            }  
                                                            
                                            } else {
                                                    if(string.valueOf(obj.get(api)) != null) 
                                                            generator.writeStringField(mapOfChargeFieldandLabel.get(api),string.valueOf(obj.get(api)));
                                                    else 
                                                            generator.writeStringField(mapOfChargeFieldandLabel.get(api),'');             
                                            }
                                    }
                                    generator.writeEndObject();
                            }
                            generator.writeEndArray(); 
                    }
                    String jsonString = generator.getAsString();
                    return jsonString;
            }
            @RemoteAction
            Global static list<Quote_Rate_Plan_Charge_Tier__c> getChargeTiers(String sChargeId) {
                    list<Quote_Rate_Plan_Charge_Tier__c> listOfProductRatePlanChargeTier = new list<Quote_Rate_Plan_Charge_Tier__c>();
                    if(sChargeId != null && sChargeId != '') {
                            listOfProductRatePlanChargeTier = [SELECT End_Unit__c,Start_Unit__c,Unit_Cost_Price__c,Unit_Price__c,Name FROM Quote_Rate_Plan_Charge_Tier__c WHERE Quote_Rate_Plan_Charge__c =: sChargeId];    
                    }
                    return listOfProductRatePlanChargeTier;
            } 
    }