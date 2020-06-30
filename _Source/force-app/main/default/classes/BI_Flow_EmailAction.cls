Global  class BI_Flow_EmailAction {
   
     Global class VariableOptions {
         //for linking email to the related record
        @InvocableVariable(label='Related To ID' description='' required=false)
        Global  Id RelatedToId;
        @InvocableVariable(label='Contact/Lead/User ID' description='Required if you use an email template' required=false)
        Global  Id PersonID;
        @InvocableVariable(label='Save As Activity' description='' required=false)
        Global  Boolean SaveAsActivity;
        @InvocableVariable(label='TreatTargetObjectAsRecipient' description='' required=false)
        Global  Boolean TreatTargetObjectAsRecipient;
        
        //sender and recipient info
        @InvocableVariable(label='ToAddresses' description='' required=false)
        Global  String ToAddresses;
        @InvocableVariable(label='ccAddresses' description='' required=false)
        Global  String ccAddresses;
        @InvocableVariable(label='bccAddresses' description='' required=false)
        Global  String bccAddresses;
        @InvocableVariable(label='replyAddress' description='Who is sending the Email. IF specified, senderDisplayName must be specified and OrgWideEmailAddress must remain blank.' required=false)
        Global  String replyAddress;
        @InvocableVariable(label='senderDisplayName' description='Email display Name for Sender. IF specified, replyAddress must be specified and OrgWideEmailAddress must remain blank.' required=false)
        Global  String senderDisplayName;
        @InvocableVariable(label='OrgWideEmailAddress' description='Must be specified if replyAddress and senderDisplayName was not set' required=false)
        Global  String OrgWideEmailAddress;
        @InvocableVariable(label='Use Signature' description='Set to either true or false' required=false)
        Global  Boolean UseSignature;
        
        //email content
        @InvocableVariable(label='subject' description='' required=false)
        Global  String subject;
        @InvocableVariable(label='plainTextBody' description='' required=false)
        Global  String plainTextBody;
        @InvocableVariable(label='HtmlBody' description='' required=false)
        Global  String HtmlBody;
        
        @InvocableVariable(label='Email Template Id' description='Contact/Lead/User ID required if you use this' required=false)
        Global  Id EmailTemplateId;   
        @InvocableVariable(label='TreatBodiesAsTemplate' description='' required=false)
        Global  Boolean TreatBodiesAsTemplate;
        @InvocableVariable(label='Attachment - ContentDocument' description='ContentDocumentId' required=false)
        Global  String ContentDocumentId;
        @InvocableVariable(label='Attachment - ContentVersion' description='ContentVersionId' required=false)
        Global  String ContentVersionId;

     }
    
    @InvocableMethod
    
    public static void biSendEmail(List<VariableOptions> designVariables)
    {
        Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage> {};
        
            for (VariableOptions request : designVariables){
                system.debug('hi');
                //Empty var
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          			String messageBody;			
 
                    //if valid email is not specified then set variables back to null
                    if(request.ccAddresses != null && !request.ccAddresses.contains('@'))	request.ccAddresses=null;
          			if(request.bccAddresses != null && !request.bccAddresses.contains('@'))	request.bccAddresses=null;
          			if(request.ToAddresses != null && !request.ToAddresses.contains('@'))	request.ToAddresses=null; 
          			if(request.replyAddress != null && !request.replyAddress.contains('@'))	request.replyAddress=null; 
          
          
          			//Create list for multiple values entered
          			String[] bccAddressesSplit = request.bccAddresses == null 	? null : request.bccAddresses.split(',');
          			String[] ccAddressesSplit = request.ccAddresses == null 	? null : request.ccAddresses.split(',');
          			String[] ToAddressesSplit = request.ToAddresses == null 	? null : request.ToAddresses.split(',');                
                	
                	//Set mail parameters to use based on variables
                    if(request.RelatedToId != null) 			
                        mail.setWhatId(request.RelatedToId);
          
          			mail.SaveAsActivity = true;
          			if(request.SaveAsActivity == false || request.PersonID == null) 		mail.SaveAsActivity = false;
          
          			//Save as activty  must be false if sending to users
          			if(request.PersonID != null && String.valueOf(request.PersonID).startsWithIgnoreCase('005')){
          				mail.SaveAsActivity = false;
     				}	
                
                	//Sender details
          			if(request.replyAddress != null)  		
                        mail.setReplyTo(request.replyAddress);	
          			if(request.senderDisplayName != null)  		
                        mail.setSenderDisplayName(request.senderDisplayName);
          			if(request.UseSignature != null) 			
                        mail.setUseSignature(request.UseSignature);
          
                    if(request.OrgWideEmailAddress  != null){
                        OrgWideEmailAddress[] OrgWideEmail = [select Id from OrgWideEmailAddress where Address = :request.OrgWideEmailAddress ];
                        if(OrgWideEmail.size()>0) 				
                            mail.setOrgWideEmailAddressId(OrgWideEmail[0].Id);                       
                                }
                
                	//Recipient details
          			if(request.TreatTargetObjectAsRecipient  != null) 	
                        mail.setTreatTargetObjectAsRecipient(request.TreatTargetObjectAsRecipient );  
          
          			if(request.PersonID != null)  		
                        mail.setTargetObjectId(request.PersonID);
                    
          			if(ToAddressessplit != null && ToAddressessplit.size()>0 )
                        										mail.setToAddresses( ToAddressessplit);
          			
          			if(request.bccAddresses != null	 && bccAddressessplit.size()>0)
                        										mail.setBccAddresses(bccAddressessplit);
          			if(request.ccAddresses != null && ccAddressessplit.size()>0)
                        										mail.setCcAddresses(ccAddressessplit);
                	
                	//Email content details
                    if(request.EmailTemplateId != null) 		mail.setTemplateId(request.EmailTemplateId);

          				
                    if(request.subject != null && request.EmailTemplateId == null) 					
                        mail.setSubject(request.subject);
                    if(request.plainTextBody  != null&& request.EmailTemplateId == null) 			
                        mail.setplainTextBody(request.plainTextBody );            
          			
          			if(request.HtmlBody  != null&& request.EmailTemplateId == null) 				
          				mail.setHtmlBody(request.HtmlBody );
          
          			if(request.TreatBodiesAsTemplate  != null) 	
                        mail.setTreatTargetObjectasRecipient(request.TreatBodiesAsTemplate );  
          			
          			if(request.ContentVersionId == null && request.ContentDocumentId != null){
                        // get the version
                        request.ContentVersionId = [select Id from ContentVersion where ContentDocumentId = :request.ContentDocumentId].ID;
                    }

          			if(request.ContentVersionId != null  && request.ContentVersionId != ''){
                        ContentVersion cv = [select Id,VersionData, PathOnClient from ContentVersion where ID = :request.ContentVersionId];
                    	// Create the email attachment
                        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                        efa.setFileName(cv.pathOnClient); 
                        efa.setBody(cv.versionData);
                        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                    }
          
				mails.add(mail);
                
            } // end loop   
        
        //sending the email message
                    
        			Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
                    if (results[0].success) {
                        System.debug('The email was sent successfully.');
                    } else {
                        System.debug('The email failed to send: ' + results[0].errors[0].message);
                    }
    }
    
}