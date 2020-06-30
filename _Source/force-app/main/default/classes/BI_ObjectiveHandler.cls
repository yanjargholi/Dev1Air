/**********************************************************************
Purpose:
-------
Deal with the DML for Objective

History
-------
VERSION  AUTHOR            DATE              DETAIL                              Description
1.0     Sasi Naik        22/05/2017          INITIAL DEVELOPMENT                 CSR:
2.0     Yolande Anjar    2019-11             Sales Planning Enhancement          Functionality to auto populate fields from type template when obj is manually created
***********************************************************************/
public class BI_ObjectiveHandler implements SIP_Triggers.Handler{
    public List<BI_Objectives__c> Newobj;
    public List<BI_Objectives__c> Oldobj;
    public Map<Id, BI_Objectives__c> mapNewobj;
    public Map<Id, BI_Objectives__c> mapOldobj;
    public Set<Id> objTypeIDSet;
    //New Objective List to collect the inserted objective records.
    List<BI_Objectives__c> newinsertobjectivelist = new List<BI_Objectives__c>();
    
    //New Objective List to collect the updated objective records.
    List<BI_Objectives__c> newupdateobjectivelist = new List<BI_Objectives__c>();
    
    //This method will initiate the trigger on which event the method need to call
    public void handle() {
        
        if(Trigger.isInsert) {
            Newobj = (List<BI_Objectives__c>)Trigger.new;
            //mapNewobj = (Map<Id, BI_Objectives__c>)Trigger.newMap;
        } else if (Trigger.isUpdate) {
            Newobj = (List<BI_Objectives__c>)Trigger.new;
            mapNewobj = (Map<Id, BI_Objectives__c>)Trigger.newMap;
        } 
        
        if(Trigger.isInsert && Trigger.isBefore) {
            System.debug(LoggingLevel.INFO, '*** Newobj: ' + Newobj);
            
            for (BI_Objectives__c obj : Newobj){
                newinsertobjectivelist.add(obj);  
            }
            
            if(newinsertobjectivelist.size()>0){
                ValidateDuplication(newinsertobjectivelist,false);
                AutoPopulateFromTypeTemplate(newinsertobjectivelist);
            }
        }
        
        if(Trigger.isUpdate && Trigger.isBefore) {
            System.debug(LoggingLevel.INFO, '*** Newobj: ' + Newobj);
            
            for (BI_Objectives__c obj : mapNewobj.values()){
                newupdateobjectivelist.add(obj);                    
            }
            
            if(newupdateobjectivelist.size()>0){
                ValidateDuplication(newupdateobjectivelist,true);
            } 
        } 
    }
    

    /*
* Purpose : To auto populate objective fields if the objective is manually created by the user
*/
    private static void AutoPopulateFromTypeTemplate(List<BI_Objectives__c> Newobj) {
        system.debug('************* in auto pop method');
        Set<Id> objTypeIds = new Set<Id>();
        List<BI_Objectives__c> obsUpdateList = new List<BI_Objectives__c>();
        Map <Id, BI_Objective_Type__c> planIdTypemap = new Map<Id, BI_Objective_Type__c>();
        
        For(BI_Objectives__c ob : Newobj){
            If(ob.BI_Auto_Created__c == false & ob.BI_Objective_Type__c != null){
                objTypeIds.add(ob.BI_Objective_Type__c);
                obsUpdateList.add(ob);
            }
        }
        
        
        If(obsUpdateList.size() > 0){
            List<BI_Objective_Type__c> obTyperecs = new List<BI_Objective_Type__c>([Select Id, Name, BI_Objective_Name__c, BI_Description__c, BI_Measure__c,
                                                                                    BI_Target_Value__c, BI_Target_Date__c, BI_Focus_Accounts__c From BI_Objective_Type__c 
                                                                                    Where ID IN :objTypeIds]);   
            
            For(BI_Objectives__c ob : obsUpdateList){
                For(BI_Objective_Type__c obtype : obTyperecs) {
                    If(ob.BI_Objective_Type__c == obtype.Id){
                        planIdTypemap.put(ob.Id, obtype);                  
                    }
                }             
            }
            
            For(BI_Objectives__c ob : obsUpdateList){
                BI_Objective_Type__c obTyp = planIdTypemap.get(ob.Id);
                ob.Name = obTyp.BI_Objective_Name__c + ' (' + ob.BI_Objective_Owner_Employee_Id__c + ', ' + ob.BI_RelatedPlan_Plan_Year__c + ')';  
                ob.BI_Template_Description__c = obTyp.BI_Description__c;
                ob.BI_Focus_Accounts__c = obTyp.BI_Focus_Accounts__c;
                ob.BI_Measure__c = obTyp.BI_Measure__c;
                ob.BI_Target_Value__c = obTyp.BI_Target_Value__c;
                ob.BI_End_Date__c = obTyp.BI_Target_Date__c;
            }

        }   
        
    }
    
    /*
* Purpose : To Validate the Duplicate Records not to enter into the Objectives Object
*/
    
    private static void ValidateDuplication(List<BI_Objectives__c> Newobj,boolean oflag) {
        system.debug('********* in validate duplication - new objectives inserted or updated ' + Newobj);
        //To Collect the Objective Category Ids into the set
        Set<Id> ObjectiveCategoryIds = new Set<Id>();
        //To Collect the Objaective Type Ids into the set
        Set<Id> ObjectiveTypeIds = new Set<Id>();
        //To Collect the Divisional Plan Ids into the set
        Set<Id> Divisionalplansids = new Set<Id>();
        //To Collect the Territory Plan Ids into the set
        Set<Id> Territoryplansids = new Set<Id>();	
        //To Collect the Regional Plan Ids into the set
        Set<Id> Regionalplansids = new Set<Id>();
        // //To Collect the Account Plan Ids into the set
        // Set<Id> Accountplansids = new Set<Id>();
        
        Set<Id> Objectivesids = new Set<Id>();
        // To Collect the List of Objectives
        List<BI_Objectives__c> listBIsObjective = new List<BI_Objectives__c>();
        
        //For loop to collect the objectives records values into the set and list 
        for (BI_Objectives__c obj : Newobj){
            ObjectiveCategoryIds.add(obj.BI_Objective_Category__c);
            ObjectiveTypeIds.add(obj.BI_Objective_Type__c);
            if(obj.BI_Divisional_Plan__c !=null){
                Divisionalplansids.add(obj.BI_Divisional_Plan__c);
            }
            if(obj.BI_Territory_Plan__c !=null){
                Territoryplansids.add(obj.BI_Territory_Plan__c);
            }
            if(obj.BI_Regional_Plan__c !=null){
                Regionalplansids.add(obj.BI_Regional_Plan__c);
            }
            //Accountplansids.add(obj.BI_Account_Plan__c);
            if(obj.Id != null){
                Objectivesids.add(obj.Id);
            }
        }
        
        System.debug(LoggingLevel.DEBUG, '*** : ComeToValidatation' );
        
        //Checking the Objecitveids has the value into the set then only we are process to do the other operation. 
        //if(Objectivesids.size()>0){
        listBIsObjective = [ Select Id,
                            Name,
                            BI_Objective_Category__c,
                            BI_Objective_Type__c,
                            BI_Divisional_Plan__c,
                            BI_Territory_Plan__c ,
                            BI_Regional_Plan__c,
                            BI_Account__c
                            FROM BI_Objectives__c 
                            WHERE BI_Objective_Category__c IN:ObjectiveCategoryIds 
                            AND BI_Objective_Type__c IN:ObjectiveTypeIds
                            //AND Id NOT IN:Objectivesids
                            AND (BI_Divisional_Plan__c IN:Divisionalplansids
                                 OR BI_Territory_Plan__c IN:Territoryplansids
                                 OR BI_Regional_Plan__c IN:Regionalplansids)
                            //OR BI_Account_Plan__c IN:Accountplansids)
                            Limit 10000];
        // }    
        
        
        System.debug(LoggingLevel.DEBUG, '********** existing objectives found : listBIsObjective' + listBIsObjective);
        //Checking the listBIsObjective has the value into the list then only we are process to do the other operation.      
        if(listBIsObjective.size()>0){
            system.debug('YYYY the oflag is ' + oflag);
            for(BI_Objectives__c obj : Newobj){
                system.debug('1a *************** now evaluating new objective: ' + obj + 'with type' + obj.BI_Objective_Type__c + 'and category ' + obj.BI_Objective_Category__c +  'for: ');
                system.debug('          1b*** NEW OBJ PLAN IS ' + obj.BI_Territory_Plan__c);
                for(BI_Objectives__c oldobj : listBIsObjective){
                    system.debug('                     2a---------existing objective found ' + oldobj + ' type is ' + oldobj.BI_Objective_Type__c + ' cat is ' + oldobj.BI_Objective_Category__c);
                    system.debug('                             2b  -- existing obj found plan is ' + oldobj.BI_Territory_Plan__c);
                    // check the condition when the record is getting inserted
                    if(!oflag){
                        system.debug('+++ ready for if to compare ids which are NEW: ' + obj.BI_Territory_Plan__c + ' OLD: ' + oldobj.BI_Territory_Plan__c);
                        if(obj.BI_Divisional_Plan__c == oldobj.BI_Divisional_Plan__c &&  obj.BI_Divisional_Plan__c != BI_UtilityCls.NULLVALUE){
                            obj.addError(System.Label.BI_ObjectiveDivisionDuplicateErrorMSG); 
                        } else if(obj.BI_Regional_Plan__c == oldobj.BI_Regional_Plan__c &&  obj.BI_Regional_Plan__c != BI_UtilityCls.NULLVALUE){
                            obj.addError(System.Label.BI_ObjectiveRegionalDuplicateErrorMSG); 
                        } else if(obj.BI_Territory_Plan__c == oldobj.BI_Territory_Plan__c &&  obj.BI_Territory_Plan__c != BI_UtilityCls.NULLVALUE){
                            obj.addError(System.Label.BI_ObjectiveTerritoryDuplicateErrorMSG); 
                        } 
                    }
                    
                    // check the condition when the record is getting Updated
                    if(oflag){
                        system.debug('+++== ready for if to compare ids which are NEW: ' + obj.BI_Territory_Plan__c + ' OLD: ' + oldobj.BI_Territory_Plan__c);
                        system.debug('=== objective ids include ' + Objectivesids);
                        system.debug('#### and it should not contain ' + obj.Id);
                        if(obj.BI_Divisional_Plan__c == oldobj.BI_Divisional_Plan__c && obj.BI_Divisional_Plan__c != BI_UtilityCls.NULLVALUE && !Objectivesids.contains(obj.Id)){
                            obj.addError(System.Label.BI_ObjectiveDivisionDuplicateErrorMSG); 
                        } else if(obj.BI_Regional_Plan__c == oldobj.BI_Regional_Plan__c && obj.BI_Regional_Plan__c != BI_UtilityCls.NULLVALUE && !Objectivesids.contains(obj.Id)){
                            obj.addError(System.Label.BI_ObjectiveRegionalDuplicateErrorMSG); 
                        } else if(obj.BI_Territory_Plan__c == oldobj.BI_Territory_Plan__c && obj.BI_Territory_Plan__c != BI_UtilityCls.NULLVALUE && !Objectivesids.contains(obj.Id)){
                            system.debug('EEEEEEEEEEk Sad face');
                            obj.addError(System.Label.BI_ObjectiveTerritoryDuplicateErrorMSG); 
                        } 
                    }
                }		
            } 	 
        }
        System.debug(LoggingLevel.DEBUG, '*** IsEnd: ');   
    }
    
    
}