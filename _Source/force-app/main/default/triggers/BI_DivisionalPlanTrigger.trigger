/**************************************************************************************
Apex Trigger Name  : BI_DivisionalPlanTrigger
Version          : 1.0 
Created Date     : 17 May 2017
Function         : Trigger on Divisional Plan
Modification Log :
-----------------------------------------------------------------------------
* Developer                       Date                       Description
* ----------------------------------------------------------------------------                 
* Sasi Naik                     17/05/2016                Original Version
***************************************************************************************/
trigger BI_DivisionalPlanTrigger on BI_Divisional_Plan__c(after insert, before update, after update) {
     new SIP_Triggers()
    // after insert
    .bind(SIP_Triggers.Evt.afterinsert, new BI_DivisionalPlanHandler())

    //After update
    .bind(SIP_Triggers.Evt.afterupdate, new BI_DivisionalPlanHandler())
    .manage();
}