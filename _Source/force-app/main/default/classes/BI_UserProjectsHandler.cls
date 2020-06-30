/**********************************************************************
Name:  BI_UserProjectsHandler
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
1.0     Yolande Anjargholi        05/29/2018         INITIAL DEVELOPMENT          
***********************************************************************/
public without sharing class BI_UserProjectsHandler {
    
    
    private static List<String> ProjectFields = new List <String>();
    
    static {
        ProjectFields = BI_UtilityCls.getFieldSetAllFieldPaths(BI_UtilityCls.ProjectObject, BI_UtilityCls.PROJECT_MASS_FIELD_SET);
    }
    
    //Method used in the BI_DiscussionTopics Lighting Component to retrieve field labels for the 'BI_Conversation_Topic object
    @AuraEnabled
    public static BI_Result getProjectsFieldInfo(){
        BI_Result ret = new BI_Result();
        try{
            List<BI_RemoteModel.ObjectFieldWrapper> fieldWrapperList = new List<BI_RemoteModel.ObjectFieldWrapper>();
            Map<String, Schema.SObjectField> ProjectMap = Schema.SObjectType.BI_Project__c.fields.getMap();
            
            for (String fieldToCheck : ProjectFields){
                if(ProjectMap.get(fieldToCheck).getDescribe().isAccessible()){
                    Schema.DescribeFieldResult dfr = ProjectMap.get(fieldToCheck).getDescribe();
                    String fieldLabel = dfr.getLabel() == null? '' : dfr.getLabel();
                    String apiName = dfr.getName() == null? '' : dfr.getName();
                    String type = dfr.getType() == null? '' : String.valueOf(dfr.getType());
                    List <String> fieldOptions = new List <String>();
                    if(type == 'PICKLIST')
                        fieldOptions = BI_UtilityCls.getPicklistValues(BI_UtilityCls.ProjectObject, apiName);
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
    public static String queryProjectAPIFieldNames(){
        String queryApiName = '';
        try{
            Map < String, Schema.SObjectField > ProjectMap = Schema.SObjectType.BI_Project__c.fields.getMap();
            Integer count = 0;
            for(String fieldToCheck : ProjectFields) {
                if(ProjectMap.get(fieldToCheck).getDescribe().isAccessible()){
                    Schema.DescribeFieldResult dfr = ProjectMap.get(fieldToCheck).getDescribe();
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
    
    //**used on One-On-One add/update projects lightning action button
    @AuraEnabled
    public static BI_Result getProjectRecords(string oneONoneId){
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
            String queryAPIFieldNames = queryProjectAPIFieldNames();
            String Completed = 'Completed';
        	String Cancelled = 'Cancelled';
            
            if(queryAPIFieldNames == ''){
                errorMessage = 'Unable to find a valid field set';
                ret.Result = False;
                ret.Errors.add(errorMessage);
                return ret;
            } else {
                BI_One_on_One__c OneOnOne = [Select BI_Participant_ID__c From BI_One_on_One__c Where Id = :oneONoneId limit 1];
                String ParticipantId = OneOnOne.BI_Participant_ID__c;
                system.debug('projects for owner id ' +ParticipantId);
                
                String query = 'SELECT ' + queryAPIFieldNames + ' FROM BI_Project__c WHERE BI_Project_Status__c != : Completed AND BI_Project_Status__c != : Cancelled AND BI_Owner_Id__c = : ParticipantId ORDER BY NAME ASC';
                system.debug('the query will be this ' + query);
                List <BI_Project__c> ProjectList = Database.query(query);               
                
                ret.Result = ProjectList;
            }
            
        } catch (Exception e){
            ret.Result = False;
            ret.Errors.add(e.getMessage());
        }
        return ret;
    }
    
    //**used on One-On-One Projects tab to show listview of participant projects
    @AuraEnabled
    public static List<BI_Project__c> getProjectRecordsView(string recordId ,Boolean initflag, String sortField, boolean isAsc) {
        List<BI_Project__c> listProject = new List<BI_Project__c>();
        
        if(recordId != null){
            BI_One_on_One__c OneOnOne = [Select BI_Participant_ID__c From BI_One_on_One__c Where Id = :recordId limit 1];
            String ParticipantId = OneOnOne.BI_Participant_ID__c;
        }
                
        String soql = '';
        String Completed = 'Completed';
        String Cancelled = 'Cancelled';

        //SOQL Dynamic to pass the caluses
        soql = 'Select Id, Name, BI_Project_Status__c, BI_Comments__c  FROM BI_Project__c WHERE BI_Project_Status__c != : Completed AND BI_Project_Status__c != : Cancelled AND BI_Owner_Id__c = : ParticipantId ORDER BY NAME ASC';       
        
        if(initflag == true){
			soql=soql + ' limit 25';
		} else {
			soql=soql + ' limit 10000';
		 
		}
        
        list <BI_Project__c> lstResult;
        try {
            lstResult = Database.Query(soql);
            //System.debug(LoggingLevel.INFO, '*** lstResult: ' + lstResult);
            List <BI_Project__c> returnProjList = new List <BI_Project__c> ();
            
            for (BI_Project__c a : lstResult){
                returnProjList.add(a);
            }
            return returnProjList;
        }
        catch (Exception c){
            return null;
        }
        
        
    } //end method
    
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
    public static BI_Result saveProjects(string oneOnOneId, List<BI_Project__c> ProjectList) {
        
        system.debug('****the one on one rec id is ' + oneOnOneId);
        List<BI_Project__c> insertprojectlist = new List<BI_Project__c>();
        BI_Result ret = new BI_Result();
        List<String> insertedprojectlist = new List<String>();
        List<BI_Project__c> updateProjectList = new List<BI_Project__c>();
        List<BI_Project__c> toInsertProjectList = new List<BI_Project__c>();     
        
        system.debug('*** ProjectList is ' +ProjectList);
        try{
            if(ProjectList.size() > 0){
                
                BI_One_on_One__c OneOnOne = [Select BI_Participant_ID__c From BI_One_on_One__c Where Id = :oneONoneId limit 1];
                String ParticipantId = OneOnOne.BI_Participant_ID__c;
                system.debug('project owner id ' +ParticipantId);
                
                
                for(BI_Project__c projRecord: ProjectList){
                    system.debug('***** loop through ProjectList - ' +projRecord);
                    system.debug('*******check for ID ' +projRecord.Id);
                    if(projRecord.Id != null){
                        updateProjectList.add(projRecord);                        
                    } else {
                        projRecord.Ownerid = Id.ValueOf(ParticipantId);
                        toInsertProjectList.add(projRecord);
                    }                        
                }
                
                if(updateProjectList.size() > 0){
                    Database.SaveResult[]  updateResult = Database.update(updateProjectList);
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
                
                Database.SaveResult[] results = Database.insert(toInsertProjectList, BI_UtilityCls.FALSEVALUE);
                System.debug(LoggingLevel.DEBUG, '*** results: ' + results);
                System.debug(LoggingLevel.DEBUG, '*** results.size(): ' + results.size());
                for(Database.SaveResult result : results){
                    if(!result.isSuccess()){
                        for(Database.Error err: result.getErrors()){
                            ret.Result = False;
                            ret.Errors.add(err.getMessage());
                            return ret;
                        }
                    } else {
                        insertedprojectlist.add(result.getId());                        
                    }
                }
                /***************
for(String ctop: insertedconvotopiclist) {
system.debug('***ctop is ' +ctop);
system.debug('****now in insert the one on one rec id is ' + oneOnOneId);
BI_Conversation_Topic__c ctopRec = new BI_Conversation_Topic__c();
ctopRec.Id = ctop;
ctopRec.BI_One_on_One__c = oneOnOneId;
insertconvolist.add(ctopRec);                    
}

if(insertconvolist.size() > 0){
database.update(insertconvolist, False);
} *************/
                
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
    
}