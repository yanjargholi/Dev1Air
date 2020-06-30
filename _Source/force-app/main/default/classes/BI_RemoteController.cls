/**********************************************************************
   Name:  BI_RemoteController
   ======================================================
   ======================================================
   Purpose:
   -------
   Deal with the DML for Objective ,price grid
   ======================================================
   ======================================================
   History
   -------
   VERSION  AUTHOR            DATE              DETAIL            Description
   1.0     Danni Xi        15/05/2017      INITIAL DEVELOPMENT          CSR:
 ***********************************************************************/
public with sharing class BI_RemoteController {
    /*
     * Method : Submit Proposal Request Form
     * Purpose : Submit Proposal Request Form
     * Params : String proposalRequestFormId   - ID of the object of pricing grid         
     */
    @AuraEnabled
    public static BI_Result submitProposalRequestForm(Id proposalRequestFormId) {
        //System.debug(LoggingLevel.DEBUG, '*** start ');
        BI_Result ret = new BI_Result();
        //System.debug(LoggingLevel.DEBUG, '*** ===proposalRequestFormId: ' + proposalRequestFormId);
        try {
      
            List < BI_Proposal_Request_Form__c > objs = [SELECT Id, 
                                                                BI_Stage__c,
                                                                BI_Legal_Review_Required__c,
                                                                BI_Opportunity__c,
                                                                RecordTypeId
                                                                FROM BI_Proposal_Request_Form__c
                                                                WHERE Id = : proposalRequestFormId
                                                                LIMIT 1
            ];
            //System.debug(LoggingLevel.DEBUG, '*** objs: ' + objs);
            if (objs.size() > 0) {
                BI_Proposal_Request_Form__c obj = objs[0];
                String Idstr = BI_UtilityCls.getRecordTypeIdByAPIName(BI_UtilityCls.OBJPRICINGREQUEST, BI_UtilityCls.PRICINGREQPASSPLUSRECORDTYPE);
                if (obj.BI_Stage__c == BI_UtilityCls.DRF_STAGE && obj.RecordTypeId != Idstr) {
                    obj.BI_Stage__c = BI_UtilityCls.SUBMIT;
                    database.update(obj);
                    ret.Result = obj.BI_Opportunity__c; 
                    // ret.Result = True;
                } else {
                    database.update(obj); // Do not remoove this line, in case cannot refresh value on page
                    
                    String errorMessage = '';
                    ret.Errors.add(errorMessage);
                }
            } else {
                String errorMessage = BI_UtilityCls.NOTVALIDPRF;
                ret.Errors.add(errorMessage);
            }

        } catch (Exception e) {
            ret.Errors.add(e.getMessage());
        }
        //System.debug(LoggingLevel.DEBUG, '*** ret===: ' + ret);
        return ret;
    }

}