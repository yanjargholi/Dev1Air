/**********************************************************************
   Name:  BI_TaskTriggerHandler
   ======================================================
   ======================================================
   Purpose:
   -------
   Auto set the Related to field for a task if the relatedto whatid 
   and related to whoid is blank when the task is created. We are setting
   related to field to a generic account so that activities are visible
   to users instead of just the owner, and will therefor show up in activity 
   reporting and the bi-weekly reports

   Invoked by Trigger: BI_TaskTrigger

   ======================================================
   ======================================================
   History
   -------
   VERSION  AUTHOR            DATE              DETAIL                  
   1.0     YOLANDE ANJ	     04/10/2018         Initial Development
 ***********************************************************************/

public class BI_TaskTriggerHandler implements SIP_Triggers.Handler {
    
    List<Task> NewTaskTriggerContextList = new List<Task>();
    
    public void handle(){
        
        if(Trigger.isBefore && Trigger.isInsert){
            For(Task newTask : (List<Task>)Trigger.new){
                if(newTask.WhatId == null && newTask.WhoId == null && newTask.TaskSubtype != 'Email'){
                    NewTaskTriggerContextList.add(newTask);
                }
            } 
        }
        
        if(NewTaskTriggerContextList.size() > 0){
            UpdateTasks();
        }
        
    }//end handle 
    
    private void UpdateTasks(){
        try{
            //get the id from custom labels for the account used for activity sharing
            Id accId = system.Label.BI_Activity_Sharing_Account_ID;
            //Use the Id to retrieve the account id 
            Id SharingAccountId = [Select Id From Account Where Id  = :accId limit 1].Id;
            
            List<Task> insertTasks = new List<Task>();
            
            if(SharingAccountId != null){
                
                For(Task trec : NewTaskTriggerContextList){
                    //trec.Whatid = '001m000000diZZRAA2'; crmdev3
                    trec.Whatid = SharingAccountId;
                    insertTasks.add(trec);
            	}
            }
            
            if(insertTasks.size() > 0){
                insert insertTasks;
            }
            
        }//end try
        catch(Exception e){system.debug('error ' +e);
                          }
        
    }//end method
    

} //end class