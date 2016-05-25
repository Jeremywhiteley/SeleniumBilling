/** Email services are automated processes that use Apex classes to process the contents, headers, and attachments of inbound email. */
    global with sharing class ClassQuoteEmailHandler implements Messaging.InboundEmailHandler {
        global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {       
            // Create an inboundEmailResult object for returning
            //the result of the Apex Email Service
            Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
            Messaging.SingleEmailMessage emailTobeSent = new Messaging.SingleEmailMessage();
            list<String> listEmailMembers = new list<String>();
            try {
                // Contact and Lead lists to hold all the updated records
                // Convert the subject line to lower case, so I can match on lower case            
                String sEmailSubject = email.subject;
                if(sEmailSubject != null){
                    integer iUpperIndex  = sEmailSubject.IndexOf('(');
                    integer iLowerIndex  = sEmailSubject.IndexOf(')');
                    sEmailSubject = sEmailSubject.substring(iUpperIndex + 1, iLowerIndex);
                }
                Quote__c quote = [SELECT (SELECT Id FROM Orders__r WHERE Status__c !=: CommonUtilClass.STATUS_CANCELLED) 
                                  FROM Quote__c 
                                  WHERE id =: sEmailSubject];
                if(quote.Orders__r.size() > 0) {
                    //means that the quote is already converted into order.Send an email saying that it is already converted
                    listEmailMembers.add(email.fromAddress);
                    emailTobeSent.setToAddresses(listEmailMembers);
                    emailTobeSent.setSubject(email.subject);
                    emailTobeSent.setHtmlBody(system.Label.Quoteisalreadyconverted);
                     if(!Test.isRunningTest()) {
                        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailTobeSent});   
                     }
                    return result;
                }
                else if(quote != null) {              
                    ApexPages.Standardcontroller controller = new Apexpages.Standardcontroller(quote);
                    createQuoteController createQuoteController = new CreateQuoteController(controller);
                    createQuoteController.convertQuote();
                    //means that the quote is converted into order.Send an email saying that it is converted
                    listEmailMembers.add(email.fromAddress);
                    emailTobeSent.setToAddresses(listEmailMembers);
                    emailTobeSent.setSubject(email.subject);
                    emailTobeSent.setHtmlBody(system.Label.Yourrequesthasbeenaccepted);
                    if(!Test.isRunningTest()) {
                        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailTobeSent});   
                    }
                    return result;       
                }
                // Return true and exit. True will confirm it is complete and no bounced email should be send the sender of the unsubscribe request.
                return result;
            }
            catch(Exception ex) {
                listEmailMembers.add(email.fromAddress);
                emailTobeSent.setToAddresses(listEmailMembers);
                emailTobeSent.setSubject(email.subject);
                emailTobeSent.setHtmlBody(system.Label.Wecannotprocessyourrequest);
                if(!Test.isRunningTest()) {
                    Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailTobeSent});   
                }
                return null;
            }
        }
    }