/**********************************************************************
   Name:  BI_OpportunityTriggerHandler
   ======================================================
   ======================================================
   Purpose:
   -------
   Deal with the DML for Opportuntiy
   ======================================================
   ======================================================
   History
   -------
   VERSION  AUTHOR               DATE              DETAIL            
   1.0     Sasi Naik             20/06/2017        INITIAL DEVELOPMENT          
   2.0     Yolande Anjargholi    09/25/2017        TMC Tactical added
 ***********************************************************************/
public class BI_OpportunityTriggerHandler implements SIP_Triggers.Handler {
    private static boolean rflag = BI_UtilityCls.TRUEVALUE;
    private static boolean aflag = BI_UtilityCls.TRUEVALUE;
    private static boolean uflag = BI_UtilityCls.TRUEVALUE;
    private static boolean birflag = BI_UtilityCls.TRUEVALUE;
    public List < Opportunity > Newopty;
    public List < Opportunity > Oldopty;
    public Map < Id, Opportunity > mapNewopty;
    public Map < Id, Opportunity > mapOldopty;
    //This method will initiate the trigger on which event the method need to call
    public void handle() {
        if (Trigger.isInsert) {
            Newopty = (List < Opportunity > ) Trigger.new;
            mapNewopty = (Map < Id, Opportunity > ) Trigger.newMap;
        } else if (Trigger.isUpdate) {
            Newopty = (List < Opportunity > ) Trigger.new;
            mapNewopty = (Map < Id, Opportunity > ) Trigger.newMap;
            mapOldopty = (Map < Id, Opportunity > ) Trigger.oldMap;
           
        }

        if (Trigger.isUpdate && Trigger.isAfter) {
            //passing the newmpa and oldmap values to the method
            if (Test.isRunningTest()){
                rflag = true;
            }
            if (rflag) {
             
                CreateOpportunityStageNameHistoryRecord(mapNewopty, mapOldopty);

                rflag = BI_UtilityCls.FALSEVALUE;
            }
        }

        if (Trigger.isInsert && Trigger.isAfter) {
            //passing the newmpa and oldmap values to the method
            if (aflag) {
                CreatePRRecord(mapNewopty);

                aflag = BI_UtilityCls.FALSEVALUE;
            }
        }


        if (Trigger.isInsert && Trigger.isBefore) {
            //passing the newmpa and oldmap values to the method
            List < Opportunity > insertoptylist = new List < Opportunity > ();
            for (Opportunity op: Newopty) {
                insertoptylist.add(op);
            }

            if (insertoptylist.size() > 0) {
                //if(BI_CheckRecursive.runOnce()){
                AssignVlauesBeforeInsertRecord(insertoptylist);
                // }
            }
        }

        if (Trigger.isUpdate && Trigger.isBefore) {
            if (uflag) {
                CreatePRRecord(mapNewopty);
                //ValidateTMCContactPRRecord(mapNewopty,mapOldopty);
                uflag = BI_UtilityCls.FALSEVALUE;
            }
        }
    }

    //This method will create the Pricing status vlaue change history into the object.Like tracking the time and to know more information about the status.
    private void AssignVlauesBeforeInsertRecord(List < Opportunity > newlist) {
      Set<String> accoutnids = new Set<String>();
      List<Account> newacclist = new List<Account>();
      List < User > loginuserinfo = [Select Id, Name, Email, Sales_Region__c, User_Region__c, SIP_Country__c From User where Id =: UserInfo.getUserId() limit 1];
      for (user u: loginuserinfo) {
        for(Opportunity opp:newlist){
            opp.Name = opp.BI_Opportunity_Name__c;
            accoutnids.add(opp.AccountId);
              if(String.isBlank(opp.BI_Sales_Organization__c)){
                    opp.BI_Sales_Organization__c = u.User_Region__c;
                }
          }
      }
      if(accoutnids.size()>0){
        newacclist = [Select Id,Name,RecordType.DeveloperName From Account Where Id IN:accoutnids 
                        AND (RecordType.DeveloperName =:BI_UtilityCls.CORPORATE
                        OR  RecordType.DeveloperName =:BI_UtilityCls.AGENCY_BRANCH
                        OR RecordType.DeveloperName =:BI_UtilityCls.AGENCY)
                        LIMIT 50000];
      }

      if(newacclist.size()>0){
        for(Opportunity op:newlist){
            if(accoutnids.contains(op.AccountId) && 
                (op.RecordTypeId == BI_UtilityCls.getRecordTypeIdByAPIName(BI_UtilityCls.OPPORTUNTIYOBJ, BI_UtilityCls.CORPORATEOPTYRECORDTYPE) ||
                 op.RecordTypeId == BI_UtilityCls.getRecordTypeIdByAPIName(BI_UtilityCls.OPPORTUNTIYOBJ, BI_UtilityCls.GLOBALCONTRACTOPTYRECORDTYPE))){
                    op.BI_Primary_Opportunity_Inbox_Email__c = System.label.BI_Opportunity_Non_UCS_Account_Inbox_Email;
                }
            }
        }

    }

      //This method will create the Pricing status vlaue change history into the object.Like tracking the time and to know more information about the status.
    private void CreatePRRecord(Map < Id, Opportunity > mapNewopty) {
        List < BI_Proposal_Request_Form__c > insertlistPricingReuest = new List < BI_Proposal_Request_Form__c > ();
        List < Opportunity > newlostopty = new List < Opportunity > ();
        for (Opportunity opp: mapNewopty.values()) {
            if((opp.BI_Tactical_Request_Form_Attached__c && !mapOldopty.get(opp.Id).BI_Tactical_Request_Form_Attached__c) ||
               (opp.BI_Travel_Agency_Request_Form_Attached__c && !mapOldopty.get(opp.Id). BI_Travel_Agency_Request_Form_Attached__c) ||
               (opp.BI_Tactical_Request_Form_TMC_Attached__c && !mapOldopty.get(opp.Id). BI_Tactical_Request_Form_TMC_Attached__c)){
            if (opp.BI_Tactical_Request_Form_Attached__c || opp.BI_Travel_Agency_Request_Form_Attached__c || opp.BI_Tactical_Request_Form_TMC_Attached__c) {
                BI_Proposal_Request_Form__c preq = new BI_Proposal_Request_Form__c();
                preq.BI_Opportunity__c = opp.Id;
                preq.BI_Legal_Review_Required__c = BI_UtilityCls.YES;
                if (opp.BI_Tactical_Request_Form_Attached__c) {
                    preq.RecordTypeId = BI_UtilityCls.getRecordTypeIdByAPIName(BI_UtilityCls.OBJPRICINGREQUEST, BI_UtilityCls.PRICINGRETACINCRECORDTYPE);
                    preq.BI_Stage__c = BI_UtilityCls.SUBMIT;
                } else if (opp.BI_Travel_Agency_Request_Form_Attached__c) {
                    preq.RecordTypeId = BI_UtilityCls.getRecordTypeIdByAPIName(BI_UtilityCls.OBJPRICINGREQUEST, BI_UtilityCls.PRICINGREQTMCCONTRACTRECORDTYPE);
                    preq.BI_Stage__c = BI_UtilityCls.SUBMITFORBUILD;
                } else if (opp.BI_Tactical_Request_Form_TMC_Attached__c) {
                	preq.RecordTypeId = BI_UtilityCls.getRecordTypeIdByAPIName(BI_UtilityCls.OBJPRICINGREQUEST, BI_UtilityCls.PRICINGRETACINCTMCRECORDTYPE);
                    preq.BI_Stage__c = BI_UtilityCls.SUBMITFORBUILD;
                }
                insertlistPricingReuest.add(preq);
            } //end  1st if
               } // end 2nd if
        } //end for

        if (insertlistPricingReuest.size() > 0) {
            Database.insert(insertlistPricingReuest, BI_UtilityCls.FALSEVALUE);
        }
    } //end method

    //This method will create the Pricing status vlaue change history into the object.Like tracking the time and to know more information about the status.
    private void CreateOpportunityStageNameHistoryRecord(Map < Id, Opportunity > mapNewopty, Map < Id, Opportunity > mapOldopty) {
        //To Collect the Pricing Request Ids into the set
        Set < Id > OpportuntiyIds = new Set < Id > ();
        //List < Opportunity > updateopty = new List < Opportunity > ();
        // Setting default value to 0 in the intial
        String Dayss = '0';
        String Hourss = '0';
        String Minutess = '0';

        Set < Id > legalset = new Set < Id > ();
        Set < Id > signatoryset = new Set < Id > ();
        Set < Id > contractleadset = new Set < Id > ();

        List < BI_Stage_Or_Status_History__c > listprireqhis = new List < BI_Stage_Or_Status_History__c > ();
        List < Opportunity > newlistpricingrequest = new List < Opportunity > ();

        for (Opportunity prireq: mapNewopty.values()) {           
            if (prireq.StageName != mapOldopty.get(prireq.Id).StageName) {
                            
                Datetime startDate = mapOldopty.get(prireq.Id).BI_Stage_Last_Modified_Date__c;
                if (mapOldopty.get(prireq.Id).BI_Stage_Last_Modified_Date__c == null) {
                    startDate = mapOldopty.get(prireq.Id).LastModifiedDate; // Start date
                }
                //Datetime startDate = mapOldopty.get(prireq.Id).LastModifiedDate; // Start date
                Datetime endDate = system.now(); //End Date

                integer Days = math.round(math.floor(Double.valueOf((endDate.getTime() - startDate.getTime()) / (1000 * 60 * 60 * 24))));
                integer Hours = math.mod(integer.valueOf((endDate.getTime() - startDate.getTime()) / (1000 * 60 * 60)), 24);
                integer Minutes = math.mod(Integer.valueOf((endDate.getTime() - startDate.getTime()) / (1000 * 60)), 60);

                BI_Stage_Or_Status_History__c prirqhis = new BI_Stage_Or_Status_History__c();
                prirqhis.BI_Opportunity_Status_From__c = String.valueOf(mapOldopty.get(prireq.Id).StageName);
                prirqhis.BI_Opportunity_Status_To__c = prireq.StageName;
                prirqhis.BI_Stage_Or_Status_Changed_By__c = UserInfo.getUserId();
                prirqhis.BI_Opportunity__c = prireq.Id;
                prirqhis.RecordTypeId = BI_UtilityCls.getRecordTypeIdByAPIName(BI_UtilityCls.STAGEORSTATUSHISTORYOBJAPI, BI_UtilityCls.OPTYSTAGEHISTORYRECORDTYPE);
               

                if (Integer.valueOf(Days) > 1) {
                    Dayss = String.valueOf(Days) + ' ' + BI_UtilityCls.DAYS;
                } else {
                    Dayss = String.valueOf(Days) + ' ' + BI_UtilityCls.DAY;
                }

                Hourss = '(' + String.valueOf(Hours) + ' H' + ')';
                Minutess = '(' + String.valueOf(Minutes) + ' M' + ')';

                prirqhis.BI_Duration__c = Dayss + ' ' + Hourss + ' ' + Minutess;
                listprireqhis.add(prirqhis);
               
            }
            //if condition to check the listprireqhis size greater than 0 to insert the record.
            if (listprireqhis.size() > 0) {
                Database.insert(listprireqhis, BI_UtilityCls.FALSEVALUE);
            }
        }
    }
}