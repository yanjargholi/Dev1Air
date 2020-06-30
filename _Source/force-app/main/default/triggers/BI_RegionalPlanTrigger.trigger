/**************************************************************************************
Apex Trigger Name  : BI_RegionalPlanTrigger
Version          : 1.0 
Created Date     : 17 May 2017
Function         : Trigger on Regional Plan
Modification Log :
-----------------------------------------------------------------------------
* Developer                       Date                       Description
* ----------------------------------------------------------------------------                 
* Sasi Naik                     17/05/2016                Original Version
***************************************************************************************/
trigger BI_RegionalPlanTrigger on BI_Regional_Plan__c (after insert, before update, after update) {
     new SIP_Triggers()
    // after insert
    .bind(SIP_Triggers.Evt.afterinsert, new BI_RegionalPlanHandler())

    //After update
    .bind(SIP_Triggers.Evt.afterupdate, new BI_RegionalPlanHandler())
    .manage();
}