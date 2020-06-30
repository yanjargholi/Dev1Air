/**************************************************************************

Name : BI_PushObjectives
===========================================================================
Purpose : This class is used to Push the Objecitves for particular Relevant Plan.
===========================================================================
History:
--------
VERSION    AUTHOR         DATE           DETAIL          DESCRIPTION
1.0       Sasi Naik    18/May/207        Created
***************************************************************************/
public class BI_PushObjectives{
    
    //This method is to createt he objecitves records when the user are selected the realted palns in the Objecitves Type record.
    @AuraEnabled
    public static String CreateRelevantPlanObjectives(String objectiveTypeid,String validyear) {
        String Successvalue = '';
        String DPRecordTypeId = '';
        String RPRecordTypeId = '';
        String TPRecordTypeId = '';
        String APRecordTypeId = '';
        
        //To Collect the Objective Category Ids into the set
        Set<Id> ObjectiveCategoryIds = new Set<Id>();
        Set<String> ObjectiveTypeNames = new Set<String>(); //added 2019-11 BI Sales Planning Enhancements
        //To Collect the Relevant Plans Ids into the set
        Set<String> relevantplanSet = new Set<String>();
        List<String> relevantplan = new List<String>();
        List<String> listregion = new List<String>();
        List<String> listdivisional = new List<String>();
        List<String> ObjYear = new List<String>();
        
        //those list will collect the records to process to functionalities
        List<BI_Objective_Type__c> listobjtype = new List<BI_Objective_Type__c>();
        List<BI_Divisional_Plan__c> listdivisionalPlan = new List<BI_Divisional_Plan__c>();
        List<BI_Regional_Plan__c> listRegionalPlan = new List<BI_Regional_Plan__c>();
        List<BI_Territory_Plan__c> listTerritoryPlan = new List<BI_Territory_Plan__c>();
        List<BI_Objectives__c> listBIsObjective = new List<BI_Objectives__c>();
        List<BI_Objectives__c> listOldBIsObjective = new List<BI_Objectives__c>();
        
        //string to collect the prefix of the oobject
        String DPlan_prefix = Schema.SObjectType.BI_Divisional_Plan__c.getKeyPrefix();
        String RPlan_prefix = Schema.SObjectType.BI_Regional_Plan__c.getKeyPrefix();
        String TPlan_prefix = Schema.SObjectType.BI_Territory_Plan__c.getKeyPrefix();
        List<BI_Objectives__c> insertnewObj = new List<BI_Objectives__c>();
        
        Set<String> uDivision = new Set<String>();
        Set<String> uRegional = new Set<String>();
        List<String> relatedplans = new List<String>();
        
        //SOQL to collect the Objective Type record information
        listobjtype = [Select Id,
                       Name,
                       BI_Objective_Name__c,
                       BI_Description__c,
                       BI_Focus_Accounts__c,
                       BI_Measure__c,
                       BI_Target_Date__c,
                       BI_Target_Value__c,
                       BI_Objective_Category__c,
                       BI_Relevant_Plans__c,
                       BI_Auto_Create_Objective__c,
                       BI_Active__c,
                       BI_Region__c,
                       BI_Division__c,
                       BI_Valid_Objective_Year__c,
                       OwnerId
                       FROM BI_Objective_Type__c
                       WHERE BI_Active__c =:BI_UtilityCls.TRUEVALUE
                       AND ID =:objectiveTypeid
                       LIMIT 1];
        
        
        for (BI_Objective_Type__c objtype : listobjtype){
            ObjectiveCategoryIds.add(objtype.BI_Objective_Category__c);
            ObjectiveTypeNames.add(objtype.BI_Objective_Name__c); //added 2019-11 BI Sales Planning Enhancements
            uDivision.add(objtype.BI_Division__c);
            uRegional.add(objtype.BI_Region__c);
            if(String.isNotBlank(objtype.BI_Region__c)){
                String[] selectedregionvalues = objtype.BI_Region__c.split(';');
                //System.debug(LoggingLevel.INFO, '*** selectedregionvalues: ' + selectedregionvalues);
                for(String sr:selectedregionvalues){
                    listregion.add(sr);
                    
                }
            }
            
            if(String.isNotBlank(objtype.BI_Division__c)){
                String[] selecteddivisionvalues = objtype.BI_Division__c.split(';');
                for(String sd:selecteddivisionvalues){
                    // if(sd == BI_UtilityCls.ALLVALUE){
                    //     AllDivisional = BI_UtilityCls.TRUEVALUE;
                    // }
                    listdivisional.add(sd);
                    //}
                }
            }   
            //relatedplans.add(objtype.BI_Relevant_Plans__c);
            if(String.isNotBlank(objtype.BI_Relevant_Plans__c)){
                relatedplans = objtype.BI_Relevant_Plans__c.split(';');
            }
        }
        
        
        String sDivisioanlPlan = '';
        String sRegionalPlan = '';
        String sTerritoryPlan = '';
        //Collecting the multi pick list values into the string for different selected plans
        for(String rp:relatedplans){
            if(rp == BI_UtilityCls.DIVISIONALPLAN){
                sDivisioanlPlan = rp;
                //System.debug(LoggingLevel.INFO, '*** sDivisioanlPlan: ' + sDivisioanlPlan);
            } else if(rp == BI_UtilityCls.REGIONALPLAN){
                sRegionalPlan = rp;
            } else if(rp == BI_UtilityCls.TERRITORYPLAN){
                sTerritoryPlan = rp;
            } 
        }
        
        Set<String> allPlansids= new Set<String>();
        Map<Id, String> divMap = new Map<Id, String>(); //added 2019-11 BI Sales Planning Enhancements
        Map<Id, String> regMap = new Map<Id, String>(); //added 2019-11 BI Sales Planning Enhancements
        Map<Id, String> terMap = new Map<Id, String>(); //added 2019-11 BI Sales Planning Enhancements
        //checking the divisional plan exisitng in the multi pick list vlaues
        if(String.isNotBlank(sDivisioanlPlan) && uDivision.size()>0){
            
            listdivisionalPlan = [Select Id, BI_Plan_Owner_Employee_Id__c from BI_Divisional_Plan__c //2019-11 BI Sales Planning Enhancements
                                  WHERE BI_Divisional_Plan_Year__c =:validyear 
                                  AND BI_Division__c IN:listdivisional
                                  Limit 10000];
            
            if(listdivisionalPlan.size()>0){ 
                Set<Id> divids = new Set<Id>();
                for(BI_Divisional_Plan__c div : listdivisionalPlan){
                    divids.add(div.Id);
                    divMap.put(div.Id, div.BI_Plan_Owner_Employee_Id__c); //added 2019-11 BI Sales Planning Enhancements
                }       
                List<BI_Objectives__c> divobjlist = new List<BI_Objectives__c>();
                divobjlist = [Select Id,
                              Name,
                              BI_Objective_Category__c,
                              BI_Objective_Type__c,
                              BI_Divisional_Plan__c
                              FROM BI_Objectives__c
                              WHERE BI_Objective_Category__c IN:ObjectiveCategoryIds
                              AND Name IN :ObjectiveTypeNames  //added 2019-11 BI Sales Planning Enhancements
                              AND BI_Objective_Type__c =:objectiveTypeid
                              AND BI_Divisional_Plan__c IN:divids
                              LIMIT 10000];
                Set<Id> odivids = new Set<Id>();
                for(BI_Objectives__c odiv : divobjlist){
                    odivids.add(odiv.BI_Divisional_Plan__c);
                }                               
                if(listdivisionalPlan.size()>0){
                    
                    DPRecordTypeId = BI_UtilityCls.getRecordTypeIdByAPIName(BI_UtilityCls.OBJACTIVES,BI_UtilityCls.DIVISIONALOBJECTIVE);
                    //Schema.SObjectType.BI_Objectives__c.getRecordTypeInfosByName().get(BI_UtilityCls.DIVISIONALOBJECTIVE).getRecordTypeId();
                    for(BI_Divisional_Plan__c dps:listdivisionalPlan){
                        if(!odivids.contains(dps.Id)){
                            allPlansids.add(dps.Id);
                        }   
                    }
                }
            }
        }
        
        //checking the Regional plan exisitng in the multi pick List vlaues
        if(String.isNotBlank(sRegionalPlan) && (listregion.size()>0 || listdivisional.size()>0)){
            
            listRegionalPlan = [Select Id, BI_Plan_Owner_Employee_Id__c from BI_Regional_Plan__c //2019-11 BI Sales Planning Enhancements
                                WHERE BI_Regional_Plan_Year__c =:validyear
                                AND  (BI_Division__c IN:listdivisional
                                      OR BI_Region__c IN: listregion)
                                Limit 10000];
            if(listRegionalPlan.size()>0){ 
                Set<Id> regids = new Set<Id>();
                for(BI_Regional_Plan__c reg : listRegionalPlan){
                    regids.add(reg.Id);
                    regMap.put(reg.Id, reg.BI_Plan_Owner_Employee_Id__c); //added 2019-11 BI Sales Planning Enhancements
                } 
                //System.debug(LoggingLevel.DEBUG, '*** regids: ' + regids);      
                List<BI_Objectives__c> regobjlist = new List<BI_Objectives__c>();
                regobjlist = [Select Id,
                              Name,
                              BI_Objective_Category__c,
                              BI_Objective_Type__c,
                              BI_Regional_Plan__c
                              FROM BI_Objectives__c
                              WHERE BI_Objective_Category__c IN:ObjectiveCategoryIds
                              AND Name IN :ObjectiveTypeNames  //added 2019-11 BI Sales Planning Enhancements
                              AND BI_Objective_Type__c =:objectiveTypeid
                              AND BI_Regional_Plan__c IN:regids
                              LIMIT 10000];
                // System.debug(LoggingLevel.DEBUG, '*** regobjlist.size(): ' + regobjlist.size());
                // System.debug(LoggingLevel.DEBUG, '*** regobjlist: ' + regobjlist);
                Set<Id> oregids = new Set<Id>();
                for(BI_Objectives__c oreg : regobjlist){
                    oregids.add(oreg.BI_Regional_Plan__c);
                }
                // System.debug(LoggingLevel.DEBUG, '*** oregids: ' + oregids);   
                
                if(listRegionalPlan.size()>0){
                    RPRecordTypeId = BI_UtilityCls.getRecordTypeIdByAPIName(BI_UtilityCls.OBJACTIVES,BI_UtilityCls.REGIONALOBJECTIVE);
                    //Schema.SObjectType.BI_Objectives__c.getRecordTypeInfosByName().get(BI_UtilityCls.REGIONALOBJECTIVE).getRecordTypeId();
                    for(BI_Regional_Plan__c rps:listRegionalPlan){
                        if(!oregids.contains(rps.Id)){
                            allPlansids.add(rps.Id);
                        }
                    }   
                }    
            }                   
        }
        
        //checking the Territory plan exisitng in the multi pickl vlaues
        if(String.isNotBlank(sTerritoryPlan) && (listregion.size()>0 || listdivisional.size()>0)){
            
            listTerritoryPlan = [Select Id, BI_Plan_Owner_Employee_Id__c from BI_Territory_Plan__c //2019-11 BI Sales Planning Enhancements
                                 WHERE BI_Territory_Plan_Year__c =:validyear 
                                 AND  (BI_Division__c IN:listdivisional
                                       OR BI_Region__c IN: listregion)
                                 Limit 10000];
            if(listTerritoryPlan.size()>0){ 
                Set<Id> terrids = new Set<Id>();
                for(BI_Territory_Plan__c terr : listTerritoryPlan){
                    terrids.add(terr.Id);
                    terMap.put(terr.Id, terr.BI_Plan_Owner_Employee_Id__c); //added 2019-11 BI Sales Planning Enhancements
                }       
                List<BI_Objectives__c> terrobjlist = new List<BI_Objectives__c>();
                terrobjlist = [Select Id,
                               Name,
                               BI_Objective_Category__c,
                               BI_Objective_Type__c,
                               BI_Territory_Plan__c
                               FROM BI_Objectives__c
                               WHERE BI_Objective_Category__c IN:ObjectiveCategoryIds
                               AND Name IN :ObjectiveTypeNames  //added 2019-11 BI Sales Planning Enhancements
                               AND BI_Objective_Type__c =:objectiveTypeid
                               AND BI_Territory_Plan__c IN:terrids
                               LIMIT 10000];
                //System.debug(LoggingLevel.DEBUG, '*** terrobjlist: ' + terrobjlist);
                Set<Id> oterrids = new Set<Id>();
                for(BI_Objectives__c oterr : terrobjlist){
                    oterrids.add(oterr.BI_Territory_Plan__c);
                }
                //System.debug(LoggingLevel.DEBUG, '*** oterrids: ' + oterrids);  
                
                if(listTerritoryPlan.size()>0){
                    TPRecordTypeId = BI_UtilityCls.getRecordTypeIdByAPIName(BI_UtilityCls.OBJACTIVES,BI_UtilityCls.TERRITORYOBJECTIVE);
                    for(BI_Territory_Plan__c tps:listTerritoryPlan){
                        if(!oterrids.contains(tps.Id)){
                            allPlansids.add(tps.Id);
                        }
                    }
                }   
            }                       
        }   
        
        Set<String> newObjTypeids = new Set<String>();
        Set<String> newObjCategids = new Set<String>();
        Set<String> newObjNames = new Set<String>(); //added 2019-11 BI Sales Planning Enhancements
        Set<String> newPlansids = new Set<String>();
        //System.debug(LoggingLevel.DEBUG, '*** allPlansids: ' + allPlansids);
        for(BI_Objective_Type__c objtype:listobjtype ){
            if(allPlansids.size()>0){
                for(String a:allPlansids){
                    
                    String myIdPrefix = String.valueOf(a).substring(0,3);
                    String empId = ''; //added 2019-11 BI Sales Planning Enhancements
                    // System.debug(LoggingLevel.DEBUG, '*** a: ' + a);
                    // System.debug(LoggingLevel.DEBUG, '*** myIdPrefix: ' + myIdPrefix);
                    BI_Objectives__c biObj = new BI_Objectives__c();
                    if(myIdPrefix == DPlan_prefix){
                        biObj.BI_Divisional_Plan__c = a;
                        biObj.RecordTypeId = DPRecordTypeId;
                        empId = divMap.get(a); //added 2019-11 BI Sales Planning Enhancements
                    } else if(myIdPrefix == RPlan_prefix){  
                        biObj.BI_Regional_Plan__c = a;
                        biObj.RecordTypeId = RPRecordTypeId;
                        empId = regMap.get(a); //added 2019-11 BI Sales Planning Enhancements
                    } else if(myIdPrefix == TPlan_prefix){
                        biObj.BI_Territory_Plan__c = a;
                        biObj.RecordTypeId = TPRecordTypeId;
                        empId = terMap.get(a); //added 2019-11 BI Sales Planning Enhancements
                    } 
                    biObj.BI_Auto_Created__c = BI_UtilityCls.TRUEVALUE;
                    biObj.BI_Objective_Category__c = objtype.BI_Objective_Category__c;
                    biObj.BI_Objective_Type__c = objectiveTypeid;
                    biObj.Name = objtype.BI_Objective_Name__c + ' (' + empId + ', ' + validyear + ')' ; //added 2019-11 BI Sales Planning Enhancements
                    biObj.BI_Template_Description__c = objtype.BI_Description__c;
                    biObj.BI_Focus_Accounts__c = objtype.BI_Focus_Accounts__c; //added 2019-11 BI Sales Planning Enhancements
                    biObj.BI_Measure__c = objtype.BI_Measure__c; //added 2019-11 BI Sales Planning Enhancements
                    biObj.BI_Target_Value__c = objtype.BI_Target_Value__c; //added 2019-11 BI Sales Planning Enhancements
                    biObj.BI_End_Date__c = objtype.BI_Target_Date__c; //added 2019-11 BI Sales Planning Enhancements
                    newObjTypeids.add(objtype.Id);
                    newObjCategids.add(objtype.BI_Objective_Category__c);
                    newObjNames.add(objtype.Name); //added 2019-11 BI Sales Planning Enhancements
                    newPlansids.add(a);
                    listBIsObjective.add(biObj);
                }
            }
        }
        
        //checking the listBIsObjective size greater than 0 to insert the records and also showinf the success or failure message
        if(listBIsObjective.size()>0){              
            DataBase.insert(listBIsObjective,BI_UtilityCls.FALSEVALUE);
            Successvalue = System.Label.BI_PushObjectiveSuccessMsg;
        } else {
            Successvalue = System.Label.BI_PushObjectiveFailureMsg;
        }
        
        return Successvalue;  
    }
    
    // to featch the Valid Objecttive year picklist values from Objectives Object and pass it to the UI 
    @AuraEnabled
    public static List<String> getValidObjectiveYearPickListvalues(){
        List<String> Vpickvalues = BI_UtilityCls.getPicklistValues(BI_UtilityCls.OBJACTIVESTYPE,BI_UtilityCls.VALIDOBJACTIVESYEAR);
        return Vpickvalues;
    }
}