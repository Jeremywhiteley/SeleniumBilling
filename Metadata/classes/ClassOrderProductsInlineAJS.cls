global with sharing class ClassOrderProductsInlineAJS {

        public string sCharges {get; set;}
        public string sortingOrder{get; set;}
        public string sPrefix {get; set;}
        public ClassOrderProductsInlineAJS(ApexPages.StandardController controller) {
            Job__c orderObj = (Job__c)controller.getRecord();
            sCharges = getChargeFieldSetvalue(orderObj.Id);
            sPrefix = CommonUtilClass.getPrefix();
        }

        Global string getChargeFieldSetvalue(Id OrderId) {
            list<string> chargesFields = new list<string>();
            map<string,string> mapOfChargeFieldandLabel =  new map<string,string>();
            map<string,string> mapOfChargeFieldValues;
            list<sobject> sObj = new list<sobject>();
            list<Object> listofCharge = new list<Object>(); 
            JSONGenerator generator = JSON.createGenerator(true);

            if(OrderId != null){
                String query = 'SELECT ';
                String apiName = '';

                //Getting the parent fields from the field set i.e, OrderProduct
                for(Schema.FieldSetMember orderProductFieldSet : SObjectType.Job_Product__c.FieldSets.ProductFieldsInline.getFields()) {
                    query += 'Job_Rate_Plan__r.Job_Product__r.'+orderProductFieldSet.getFieldPath() + ', ';
                    mapOfChargeFieldandLabel.put('Job_Rate_Plan__r.Job_Product__r.'+orderProductFieldSet.getFieldPath(),orderProductFieldSet.getLabel());
                    chargesFields.add('Job_Rate_Plan__r.Job_Product__r.'+orderProductFieldSet.getFieldPath());
                }

                //Getting the child fields from the field set i.e, Charges
                for(Schema.FieldSetMember chargeFieldSet : SObjectType.Job_Rate_Plan_Charge__c.FieldSets.Order_Detail_Page.getFields()) {
                    query += chargeFieldSet.getFieldPath() + ', ';
                    mapOfChargeFieldandLabel.put(chargeFieldSet.getFieldPath(),chargeFieldSet.getLabel());
                    chargesFields.add(chargeFieldSet.getFieldPath());
                }
                chargesFields.add('Id');
                chargesFields.add('Job_Rate_Plan__r.Job_Product__r.Product__r.Name');
                mapOfChargeFieldandLabel.put('Id','Id');
                mapOfChargeFieldandLabel.put('Job_Rate_Plan__r.Job_Product__r.Product__r.Name','pName');
                if(query.contains('Sequence_No__c'))
                    query += 'Id,Job_Rate_Plan__r.Job_Product__r.Product__r.Name FROM Job_Rate_Plan_Charge__c WHERE Order__c=:OrderId ORDER BY  Job_Rate_Plan__r.Job_Product__r.SequenceNumber__c,Sequence_No__c ';
                else
                    query += 'Id,Sequence_No__c,Job_Rate_Plan__r.Job_Product__r.Product__r.Name FROM Job_Rate_Plan_Charge__c WHERE Order__c=:OrderId ORDER BY  Job_Rate_Plan__r.Job_Product__r.SequenceNumber__c,Sequence_No__c ';
                sObj = Database.query(query);

                generator.writeStartArray();
                for(sobject obj : sObj) {
                    generator.writeStartObject();   
                    for(string api : chargesFields) {
                        // If it contains the Job_Rate_Plan__r in the API that means it is the parent fields
                        if(api.contains('Job_Rate_Plan__r')) {
                            apiName = api.replace('Job_Rate_Plan__r.Job_Product__r.', '');
                            if(string.valueOf(obj.get('Sequence_No__c')) != null && string.valueOf(obj.get('Sequence_No__c')) == '1' && apiName.contains('Product__r') && string.valueOf(obj.getSobject('Job_Rate_Plan__r').getSobject('Job_Product__r').get('Product__c')) != null) {
                                generator.writeStringField(mapOfChargeFieldandLabel.get(api), string.valueOf(obj.getSobject('Job_Rate_Plan__r').getSobject('Job_Product__r').getSobject('Product__r').get('Name')));
                            } else if(!apiName.contains('Product__r') && string.valueOf(obj.get('Sequence_No__c')) != null && string.valueOf(obj.get('Sequence_No__c')) == '1' && string.valueOf(obj.getSobject('Job_Rate_Plan__r').getSobject('Job_Product__r').get(''+apiName)) != null) {
                                    generator.writeStringField(mapOfChargeFieldandLabel.get(api), string.valueOf(obj.getSobject('Job_Rate_Plan__r').getSobject('Job_Product__r').get(''+apiName)));
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
        Global static list<Job_Rate_Plan_Charge_Tier__c> getChargeTiers(String sChargeId) {
            list<Job_Rate_Plan_Charge_Tier__c> listOfProductRatePlanChargeTier = new list<Job_Rate_Plan_Charge_Tier__c>();
            if(sChargeId != null && sChargeId != '') {
                    listOfProductRatePlanChargeTier = [SELECT End_Unit__c,Start_Unit__c,Unit_Cost_Price__c,Unit_Price__c,Name FROM Job_Rate_Plan_Charge_Tier__c WHERE Job_Rate_Plan_Charge__c =: sChargeId];    
            }
            return listOfProductRatePlanChargeTier;
        } 
    }