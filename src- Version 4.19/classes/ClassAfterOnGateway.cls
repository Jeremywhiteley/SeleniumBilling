public with sharing class ClassAfterOnGateway {
            public static boolean GATEWAY_AFTER_PROCESSING_COMPLETE = false;

            public void setGatewayAfterProcessingComplete() {
                GATEWAY_AFTER_PROCESSING_COMPLETE = true;
            }

            public Boolean getGatewayAfterProcessingComplete() {
                return GATEWAY_AFTER_PROCESSING_COMPLETE;
            }
            
            public void handleBeforeOnGateway(list<Gateway__c> listOfGateways, map<Id, Gateway__c> newMap, map<Id, Gateway__c> oldMap)
            {
                list<Gateway__c> listOfDefaultGateways = new list<Gateway__c>();
                boolean isDefaultGatewayInserted = false;
                
                if(trigger.isInsert) {
                    listOfDefaultGateways = [SELECT Id
                                              FROM Gateway__c
                                              WHERE Default__c = true];
                } else {
                    listOfDefaultGateways = [SELECT Id
                                              FROM Gateway__c
                                              WHERE Default__c = true
                                              AND
                                              Id Not In: newMap.keySet()];
                }
                
                if(!listOfDefaultGateways.isEmpty()) {
                    for(Gateway__c gateway : listOfGateways) {
                        if(gateway.Default__c) {
                            //gateway.addError('Their can be only one default Payment Gateway in organization');
                            //Added by Shruthi related to INVOICEIT-200
                            gateway.addError(system.Label.DefaultPaymentGateway);
                        }
                    }
                } else {
                    for(Gateway__c gateway : listOfGateways) {
                        if(gateway.Default__c) {
                            if(isDefaultGatewayInserted) { 
                                //gateway.addError('Their can be only one default Payment Gateway in organization');
                                //Added by Shruthi related to INVOICEIT-200
                                 gateway.addError(system.Label.DefaultPaymentGateway);
                            } else {
                                isDefaultGatewayInserted = true;
                            }
                        }
                    }
                }                                        
            }

        }