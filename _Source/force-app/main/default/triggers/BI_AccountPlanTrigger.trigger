/**************************************************************************************************
 * Name           : BI_AccountPlanTrigger

 * Objective      : 1) When a new account plan is created with auto complete from prior year set to yes,
                       look for the prior year account plan for the account, and pre-populate certain fields with prior 
                       year values. Happens before insert only. Method is AutoComplete.

 * Target         : BI_Account_Plan__c

 * Refer Classes  : BI_AccountPlanTriggerHandler

 * History        :  VERSION    |     DATE       |        AUTHOR         |  DESCRIPTION
                     V1.0       |  Sept/05/2018  |   Yolande Anjargholi  |    Created 
               
 ********************************************************************************************/

trigger BI_AccountPlanTrigger on BI_Account_Plan__c (before insert) {
    new SIP_Triggers()
    // before insert
     .bind(SIP_Triggers.Evt.beforeinsert, new BI_AccountPlanTriggerHandler())
     .manage();   

}