trigger TriggerOnGateway on Gateway__c (before insert, before update) {
    ClassAfterOnGateway classAfterOnGateway = new ClassAfterOnGateway();
    if(!classAfterOnGateway.getGatewayAfterProcessingComplete()) {
        classAfterOnGateway.setGatewayAfterProcessingComplete();
        classAfterOnGateway.handleBeforeOnGateway(Trigger.new, Trigger.newMap, Trigger.oldMap);
    }
}