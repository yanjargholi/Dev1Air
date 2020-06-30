/**********************************************************************
Name:  BI_ConversationTopicsHandler
======================================================
======================================================
Purpose:
-------
Deal with the DML for Lightning Component: BI_ConverSationTopics.cmp
======================================================
======================================================
History
-------
VERSION  AUTHOR                    DATE              DETAIL            
1.0     Yolande Anjargholi        05/17/2018         INITIAL DEVELOPMENT 
1.1     Yolande Anjargholi        03/25/2019         UPDATED for better sorting
***********************************************************************/
public without sharing class BI_ConversationTopicsHandler {
    
    private static List<String> DiscussionTopicFields = new List <String>();
    
    static {
        DiscussionTopicFields = BI_UtilityCls.getFieldSetAllFieldPaths(BI_UtilityCls.CONVOTOPIC, BI_UtilityCls.CONVOTOPIC_MASS_FIELD_SET);
    }
    
    //Method used in the BI_DiscussionTopics Lighting Component to retrieve field labels for the 'BI_Conversation_Topic object
    @AuraEnabled
    public static BI_Result getDiscussionTopicFieldInfo(){
        BI_Result ret = new BI_Result();
        try{
            List<BI_RemoteModel.ObjectFieldWrapper> fieldWrapperList = new List<BI_RemoteModel.ObjectFieldWrapper>();
            Map<String, Schema.SObjectField> convoTopicMap = Schema.SObjectType.BI_Conversation_Topic__c.fields.getMap();
            
            for (String fieldToCheck : DiscussionTopicFields){
                if(convoTopicMap.get(fieldToCheck).getDescribe().isAccessible()){
                    Schema.DescribeFieldResult dfr = convoTopicMap.get(fieldToCheck).getDescribe();
                    String fieldLabel = dfr.getLabel() == null? '' : dfr.getLabel();
                    String apiName = dfr.getName() == null? '' : dfr.getName();
                    String type = dfr.getType() == null? '' : String.valueOf(dfr.getType());
                    List <String> fieldOptions = new List <String>();
                    if(type == 'PICKLIST')
                        fieldOptions = BI_UtilityCls.getPicklistValues(BI_UtilityCls.CONVOTOPIC, apiName);
                    BI_RemoteModel.ObjectFieldWrapper fieldWrapper = new BI_RemoteModel.ObjectFieldWrapper(fieldLabel, apiName, type, fieldOptions);
                    fieldWrapperList.add(fieldWrapper);
                    
                }
            }
            ret.Result = fieldWrapperList;
            
        } catch (Exception e) {
            ret.Result = False;
            ret.Errors.add(e.getMessage());
        }
        return ret;
    }
    
    @AuraEnabled
    public static String queryConvoTopicAPIFieldNames(){
        String queryApiName = '';
        try{
            Map < String, Schema.SObjectField > convoTopicMap = Schema.SObjectType.BI_Conversation_Topic__c.fields.getMap();
            Integer count = 0;
            for(String fieldToCheck : DiscussionTopicFields) {
                if(convoTopicMap.get(fieldToCheck).getDescribe().isAccessible()){
                    Schema.DescribeFieldResult dfr = convoTopicMap.get(fieldToCheck).getDescribe();
                    String apiName = dfr.getName() == null? '' :dfr.getName();
                    if(count != 0){
                        queryApiName += ',';
                    }
                    queryApiName +=apiName;
                    count++;                    
                }
            }
            
        } catch(Exception e){}
        return queryApiName;
    }
    
    
    @AuraEnabled
    public static BI_Result getConvoTopicRecords(string oneONoneId){
        system.debug('*** One on One record Id we will use is ' + oneONoneId);
        BI_Result ret = new BI_Result();
        String errorMessage = '';
        if(oneONoneId == null){
            errorMessage = 'One-On-One Record Id is null';
            ret.Result = False;
            ret.Errors.add(errorMessage);
            return ret;
        }
        try{
            String queryAPIFieldNames = queryConvoTopicAPIFieldNames();
            if(queryAPIFieldNames == ''){
                errorMessage = 'Unable to find a valid field set';
                ret.Result = False;
                ret.Errors.add(errorMessage);
                return ret;
            } else {
                String query = 'SELECT ' + queryAPIFieldNames + ' FROM BI_Conversation_Topic__c WHERE BI_One_on_One__c = :oneONoneId ORDER BY CreatedDate ASC';
                system.debug('the query will be this ' + query);
                List <BI_Conversation_Topic__c> convoTopicList = Database.query(query);
                ret.Result = convoTopicList;
            }
            
        } catch (Exception e){
            ret.Result = False;
            ret.Errors.add(e.getMessage());
        }
        return ret;
    }
    
    @AuraEnabled
    public static BI_Result saveConvoTopics(string oneOnOneId, List<BI_Conversation_Topic__c> convoTopicList) {
        
        List<BI_Conversation_Topic__c> insertconvolist = new List<BI_Conversation_Topic__c>();
        BI_Result ret = new BI_Result();
        List<String> insertedconvotopiclist = new List<String>();
        List<BI_Conversation_Topic__c> updateConvoList = new List<BI_Conversation_Topic__c>();
        List<BI_Conversation_Topic__c> toInsertConvoList = new List<BI_Conversation_Topic__c>();
        List<ID> AllConvoTopicsList = new List<ID>();
        List<BI_Conversation_Topic__c> updateObjTypeList = new List<BI_Conversation_Topic__c>();
        List<BI_Conversation_Topic__Share> convoTopicShare = new List<BI_Conversation_Topic__Share>();
        
        try{
            if(convoTopicList.size() > 0){
                for(BI_Conversation_Topic__c ctop: convoTopicList){ 
                    
                    if(ctop.Id != null){                                  
                        updateConvoList.add(ctop); 
                        AllConvoTopicsList.Add(ctop.Id);
                        
                    } else {
                        ctop.BI_One_on_One__c = oneOnOneId;
                        toInsertConvoList.add(ctop);
                    }                        
                }
                
                if(updateConvoList.size() > 0){
                    Database.SaveResult[]  updateResult = Database.update(updateConvoList);
                    for(Database.SaveResult result: updateResult){
                        if(!result.isSuccess()){
                            for(Database.Error err: result.getErrors()){
                                ret.Result = False;
                                ret.Errors.add(err.getMessage());
                                return ret;
                            }
                        }
                    }                  
                }
                
                Database.SaveResult[] results = Database.insert(toInsertConvoList, BI_UtilityCls.FALSEVALUE);
                
                System.debug(LoggingLevel.DEBUG, '*** results.size(): ' + results.size());
                
                for(Database.SaveResult result : results){
                    if(!result.isSuccess()){
                        for(Database.Error err: result.getErrors()){
                            ret.Result = False;
                            ret.Errors.add(err.getMessage());
                            return ret;
                        }
                    } else {
                        AllConvoTopicsList.add(result.getId());
                        insertedconvotopiclist.add(result.getId());                        
                    }
                }
                
                /*  1 Update the Objective Type lookup field based on the Objective Type selector picklist value. 
Picklist value was used on lightning component as business did not want a lookup for quick capture
2 If the convo topic was added by someone other than the one-one-one owner, update convo topic owner by setting it to one on one owner
3 Convo topics is set to Private. Share with One on One Participant so one-on-one owner/manager and participant can view topics */
                
                for(BI_Conversation_Topic__c crec : [Select Id, OwnerId, BI_One_on_One_Owner_Id__c, Name, BI_Participant_ID__c, BI_Objective_Type__c, BI_Category__c From BI_Conversation_Topic__c Where BI_Category__c != null AND ID IN : AllConvoTopicsList]){                    
                    BI_Objective_Type__c obtyperec = [Select Id From BI_Objective_Type__c Where Name = : crec.BI_Category__c limit 1];
                    string obtid = obtyperec.Id;
                    string convoownerid = crec.OwnerId;
                    string oneononeownerid = crec.BI_One_on_One_Owner_Id__c;
                    
                    if(obtid != '' || convoownerid != oneononeownerid){
                        //1
                        if(obtid != ''){
                            crec.BI_Objective_Type__c = obtid;
                        }
                        //2
                        if(convoownerid != oneononeownerid){
                            crec.OwnerId = oneononeownerid;
                        } 
                        
                        updateObjTypeList.add(crec);
                    } 
                    
                    //3
                    If(crec.BI_Participant_ID__c != ''){
                        
                        BI_Conversation_Topic__Share participantShare = new BI_Conversation_Topic__Share();
                        participantShare.ParentId = crec.Id;
                        participantShare.UserOrGroupId = crec.BI_Participant_ID__c;
                        participantShare.AccessLevel = 'edit';
                        participantShare.RowCause = Schema.BI_Conversation_Topic__Share.RowCause.Participant_Access__c;
                        convoTopicShare.add(participantShare);                        
                    }
                    
                }
                
                if(updateObjTypeList.size() > 0){
                    system.debug('in update operation');
                    update updateObjTypeList;
                } 
                if(convoTopicShare.size() > 0){
                    Database.insert(convoTopicShare);                 
                }
                
                ret.Result = True;
                
            } else {
                ret.Result = False;
            }
            
        } catch (Exception e){
            ret.Result = False;
            ret.Errors.add(e.getMessage());
        }
        return ret;
    }
    
    @AuraEnabled
    public static BI_Result getObjectiveTypeName(){
        BI_Result ret = new BI_Result();
        List<String> objectiveTypeNames = new List<String>();
        String errorMessage = '';
        
        try{
            List<BI_Objective_Type__c> objectiveTypes = new List<BI_Objective_Type__c>([Select Name From BI_Objective_Type__c Where BI_Active__c = True and BI_Available_for_Conversation_Topics__c = True]);
            
            For(BI_Objective_Type__c obtype : objectiveTypes){
                objectiveTypeNames.add(obtype.Name);
            }            
            
            if(objectiveTypeNames.size() >0){
                ret.Result = objectiveTypeNames;
            }             
															  
            
        } catch (Exception e){
            ret.Result = False;
            ret.Errors.add(e.getMessage());
        }
        return ret;
    }
    
    @AuraEnabled
    public static BI_Result checkForParticipant(string oneONoneId){
        system.debug('*** One on One record Id we will use is ' + oneONoneId);
        BI_Result ret = new BI_Result();
        
        String errorMessage = '';
        if(oneONoneId == null){
            errorMessage = 'One-On-One Record Id is null';
            ret.Result = False;
            ret.Errors.add(errorMessage);
            return ret;
        }
        try{
            BI_One_on_One__c onerectocheck = [Select Id, BI_Participant__c From BI_One_on_One__c Where Id = : oneONoneId limit 1];
            String participantFound = '';
            
            If(onerectocheck.BI_Participant__c != null){
                participantFound = 'True';
            } else{
                participantFound = 'False';
            }            
            ret.Result = participantFound;
            
            
        } catch (Exception e){
            ret.Result = False;
            ret.Errors.add(e.getMessage());
        }
        return ret;
    }
    
    @AuraEnabled
    public static BI_Result CreateOneonOne(string eventId){
        system.debug('***EVENT ID IS ' + eventId);
        BI_Result ret = new BI_Result();
        String errorMessage = '';
        
        
        if(eventId == null){
            errorMessage = 'Event Record Id is null';
            ret.Result = False;
            ret.Errors.add(errorMessage);
            return ret;
        }
        try {
            Event evt = [Select Subject, BI_Related_To_Object_Type__c, IsChild,OwnerId,Description,WhatId,StartDateTime From Event where Id = :eventId limit 1];            
            
            //**1 - check if event is already related to a 1/1 
            //  2 if it is, return that existing 1/1 to l-comp to be opened
            //  3 if not check event is a child - so event is organized by someone else and should be updated via its parent
            //  4 if it is find the parent and set the event record to the parent instead of the child
            //  5 use event record to locate invitee to set participant and other details when creating the one on one 

            // - 1- 
            String oType = evt.BI_Related_To_Object_Type__c;
            system.debug('--------------------------- ' +oType);
            
            if(oType != null && oType.contains('One')){
                // - 2 -
                ret.Result = evt.WhatId;                
            } else{
              
                String ParticipantId = '';
                Boolean childEvt = evt.IsChild;

                // - 3 -
                If(childEvt == true){
                    List<event> ParentevtList = new List<event>([Select Id,Subject, BI_Related_To_Object_Type__c, IsChild,OwnerId,Description,WhatId,StartDateTime 
                                         From Event where Subject = :evt.Subject and StartDateTime = :evt.StartDateTime AND isChild = False And IsRecurrence = false limit 1]);
                    
                    if(!ParentevtList.isEmpty()){
                        // - 4 - 
                        evt = ParentevtList[0];
                    }
 
                }
                // - 5 -                
                List<Event> LookForRelationIdList = new List<Event>([Select Id, Subject,(Select Id, RelationId From EventRelations) From Event Where Id = :evt.Id]);
                
                If(LookForRelationIdList.size() > 0){
                    For(Event evtt : LookForRelationIdList){
                        
                        If(evtt.EventRelations != null && ParticipantId == '') {
                            For(EventRelation er : evtt.EventRelations){                                
                                ParticipantId = er.RelationId;                                
                            }                    
                        }                        
                    }                    
                }
                
                BI_One_on_One__c oneRec = new BI_One_on_One__c(
                    Name = evt.Subject,
                    BI_Date__c = (evt.StartDateTime).date(),
                    OwnerId = evt.OwnerId                    
                );
                if(ParticipantId != ''){
                    oneRec.BI_Participant__c = ParticipantId ;
                }
                
                insert(oneRec);
                
                String oneRecID = oneRec.Id;
                evt.WhatId = oneRecID;
                update(evt);
                ret.Result = oneRec.Id;
 
            }
        }
        catch (Exception e){
            ret.Result = False;
            ret.Errors.add(e.getMessage());
        }
        return ret;
        
    } //end method
} //end class