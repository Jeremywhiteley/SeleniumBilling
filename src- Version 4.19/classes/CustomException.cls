public with sharing class CustomException extends Exception {
        public static string handleError(String sClassName, String sMethodName, String sCustomMessage, Exception ex) {
            String sMessage = system.Label.ExceptionMessage;
            
            if(sCustomMessage == null) {
                sMessage +=    ' Exception type:' + ex.getTypeName()
                            +  ' Class Name:' + sClassName
                            +  ' Method Name:' + sMethodName
                            +  ' Line No:' + ex.getLineNumber()
                            +  ' Error message:' + ex.getMessage();
            } else {
                sMessage +=    ' Exception type:' + ex.getTypeName()
                            +  ' Class Name:' + sClassName
                            +  ' Method Name:' + sMethodName
                            +  ' Line No:' + ex.getLineNumber()
                            +  ' Error message:' + sCustomMessage;
            }
            return sMessage;
        }
        
        public static void populateApexMessage(String sMessage, String sSeverity) {
            if(sSeverity == 'ERROR') {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, sMessage));
            } else if(sSeverity == 'WARNING') {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.WARNING, sMessage));
            } else if(sSeverity == 'INFO') {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, sMessage));
            }
        }
    }