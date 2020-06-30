/**********************************************************************
Purpose:
-------
Deal with the DML for Regional  Plan

History
-------
VERSION       AUTHOR            DATE              DETAIL               
1.0          Sasi Naik          15/05/2017        INITIAL DEVELOPMENT 
2.0          Yolande Anja       2019 - 11         - populate additional obj type fields for created objectives
                                                  - deal with update obj owner and name when plan owner changes
***********************************************************************/
public class BI_TerritoryPlanHandler implements SIP_Triggers.Handler {
    public static boolean skipErrorMessage = false;
    public List<BI_Territory_Plan__c> Newdp;
    public List<BI_Territory_Plan__c> Oldodp;
    public Map<Id, BI_Territory_Plan__c> mapNewdp;
    public Map<Id, BI_Territory_Plan__c> mapOlddp;
    Map < Id, Id > oldPlanOwners = new Map < Id, Id > (); //map for holding the old plan ownerId 
    Map < Id, Id > newPlanOwners = new Map < Id, Id > (); //map for holding the new plan ownerId

    //This method will initiate the trigger on which event the method need to call
    public void handle() {
        
        if(Trigger.isInsert) {
            Newdp = (List<BI_Territory_Plan__c>)Trigger.new;
            mapNewdp = (Map<Id, BI_Territory_Plan__c>)Trigger.newMap;
        } else if (Trigger.isUpdate) {
            Newdp = (List<BI_Territory_Plan__c>)Trigger.new;
            mapNewdp = (Map<Id, BI_Territory_Plan__c>)Trigger.newMap;
        } 
        
        if(Trigger.isInsert && Trigger.isAfter) {
            //Passing the newmap values to the method to create the plans record in the objective 
            CreateRegplanObjectiveRecord(mapNewdp);
        }
        
        if (Trigger.isUpdate && Trigger.isAfter){
            For(BI_Territory_Plan__c dp : Newdp){
                BI_Territory_Plan__c oldPlan = (BI_Territory_Plan__c)Trigger.oldMap.get(dp.Id);
                Id oldownerId = oldPlan.OwnerId;
                
                if(dp.OwnerId != oldownerId){
                    oldPlanOwners.put(dp.Id, oldownerId);
                    newPlanOwners.put(dp.Id, dp.OwnerId);                    
                }
            }
        }
        
        if(!oldPlanOwners.isEmpty() && !newPlanOwners.isEmpty()){
            system.debug('--------old owner map is ' + oldPlanOwners);
            system.debug('----------new owner map is ' + newPlanOwners);
             reassignRelatedObjectiveRecords(oldPlanOwners, newPlanOwners);
        }
    }
    
    //This method will create the Objective plans when the Quick Action in the OT is hit.
    private void CreateRegplanObjectiveRecord(Map<Id, BI_Territory_Plan__c> mapNewdp) {
        
        //To Collect the Objective Category Ids into the set
        Set<Id> ObjectiveCategoryIds = new Set<Id>();
        //To Collect the Objective Type Ids into the set
        Set<Id> ObjectiveTypeIds = new Set<Id>();
        List<String> ObjYear = new List<String>();
        List<BI_Objectives__c> listBIsObjective = new List<BI_Objectives__c>();
        Set<String> uRegional = new Set<String>();
        Set<String> uDivision = new Set<String>();
        
        for (BI_Territory_Plan__c dp : mapNewdp.values()){
            if(dp.BI_Region__c !=null){
                ObjYear.add(dp.BI_Territory_Plan_Year__c);
                uRegional.add(dp.BI_Region__c);
                uDivision.add(dp.BI_Division__c);
            }
        }
        
        String newUDiv = String.valueOf(uDivision);
        newUDiv = newUDiv.replace('{', '');
        newUDiv = newUDiv.replace('}', '');
        
        String newUReg = String.valueOf(uRegional);
        newUReg = newUReg.replace('{', '');
        newUReg = newUReg.replace('}', '');
        //colelct eh objectives type record form the SOQL by passing the vlaues
        if(uRegional.size()>0){
            List<BI_Objective_Type__c> listobjtype = [Select Id,BI_Objective_Name__c,BI_Description__c, BI_Focus_Accounts__c,BI_Measure__c, BI_Target_Value__c, BI_Target_Date__c,BI_Objective_Category__c from BI_Objective_Type__c
                                                      where (BI_Region__c INCLUDES(:newUReg) 
                                                             OR BI_Division__c INCLUDES(:newUDiv))
                                                      AND BI_Active__c = :BI_UtilityCls.TRUEVALUE
                                                      AND BI_Auto_Create_Objective__c =:BI_UtilityCls.TRUEVALUE
                                                      AND BI_Relevant_Plans__c INCLUDES(:BI_UtilityCls.TERRITORYPLAN)
                                                      Limit 10000];
            //System.debug(LoggingLevel.INFO, '*** listobjtypelistobjtype: ' + listobjtype);                                                
            
            if(listobjtype.size()>0){  
                for(BI_Territory_Plan__c dp : mapNewdp.values()){
                    for(BI_Objective_Type__c objtype:listobjtype){
                        BI_Objectives__c biObj = new BI_Objectives__c();
                        biObj.RecordTypeId = BI_UtilityCls.getRecordTypeIdByAPIName(BI_UtilityCls.OBJACTIVES,BI_UtilityCls.TERRITORYOBJECTIVE);     
                        biObj.BI_Objective_Category__c = objtype.BI_Objective_Category__c;
                        biObj.BI_Objective_Type__c = objtype.Id;
                        biObj.BI_Territory_Plan__c = dp.Id;
                        biObj.Name = objtype.BI_Objective_Name__c + ' (' + dp.BI_Plan_Owner_Employee_Id__c + ', ' + dp.BI_Territory_Plan_Year__c + ')';
                        biObj.BI_Template_Description__c = objtype.BI_Description__c;
                        biObj.BI_Measure__c = objtype.BI_Measure__c;
                        biObj.BI_Target_Value__c = objtype.BI_Target_Value__c;
                        biObj.BI_End_Date__c = objtype.BI_Target_Date__c;
                        biObj.BI_Focus_Accounts__c = objtype.BI_Focus_Accounts__c;
                        biObj.BI_Auto_Created__c = true;
                        
                        //Adding all the new records into the list
                        listBIsObjective.add(biObj);
                    }
                }
                //check if the list is not empty else insert the records
                if(listBIsObjective.size()>0){
                    DataBase.insert(listBIsObjective,BI_UtilityCls.FALSEVALUE);
                }
            }
        }
    }
    
     private void reassignRelatedObjectiveRecords(Map < Id, Id > oldPlanOwners, Map < Id, Id > newPlanOwners) {
     
        List<BI_Objectives__c> updateObjList = new List<BI_Objectives__c>();
        List<BI_Territory_Plan__c> planList = new List<BI_Territory_Plan__c>([Select Id, OwnerId,BI_Plan_Owner_Employee_Id__c, BI_Territory_Plan_Year__c, (Select Id, Name, OwnerId, BI_Template_Objective_Name_From_Type__c From Objectives__r) 
                                                                                From BI_Territory_Plan__c Where Id in :oldPlanOwners.keyset()]);
        try {
            if(planList.size() > 0){
                for(BI_Territory_Plan__c pl : planList){
                    if(pl.Objectives__r != null){
                        for(BI_Objectives__c obj : pl.Objectives__r){
                            obj.OwnerId = pl.OwnerId;
                            obj.Name = obj.BI_Template_Objective_Name_From_Type__c + ' (' + pl.BI_Plan_Owner_Employee_Id__c + ', ' + pl.BI_Territory_Plan_Year__c + ')';
                            updateObjList.add(obj);
                        }
                    }
                }
                
            } //end if
            
            if(updateObjList.size() > 0){
                update updateObjList;
            }
            
        } catch (Exception ex){
            system.debug('Error occurred in BI_Territory_Plan_Handler reassignRelatedObjectiveRecords method:  ' +ex);
        }

    }
    
}