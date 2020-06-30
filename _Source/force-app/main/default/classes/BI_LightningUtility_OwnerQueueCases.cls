/**************************************************************************************************
* Name           : BI_LightningUtility_OwnerQueueCases
* Object         : Case
* Refer          : Used as controller for lightning components a) BI_LightningUtility_QueueCases and b) BI_Lightning_Utility_OwnerCases
* Author         : Yolande Anjargholi
* Create Date    : 2020 - 03
* Modify History :
********************************************************************************************/

public class BI_LightningUtility_OwnerQueueCases {
    
     @AuraEnabled
    public static List<Object> getQueueCases(Integer LimitSize, List<String> recIdList, String Orderby, String OrderDir){
        Set<Id> IdSet = new Set<Id>();
        
        if(Orderby == 'linkname'){
            Orderby = 'CaseNumber';
        }        
                
        if(recIdList.size() > 0){
            IdSet = new Map<Id, Case>([Select Id From Case Where Id In : recIdList]).keySet();
        }
        
		Id userId = UserInfo.getUserId();        
        Set<String> QueueMemSet = new Set<String>();
        OrderDir = String.isBlank(OrderDir) ? 'desc' : OrderDir;
        
        for(User us : [Select BI_Cases_Queue_Membership__c From User Where Id = :userId Limit 1]){
            //QueueMemSet.add(us.BI_Cases_Queue_Membership__c);
             IF(!string.isBlank(us.BI_Cases_Queue_Membership__c)) QueueMemSet.addAll(us.BI_Cases_Queue_Membership__c.split(';')); 
        }
        String query = 'SELECT Id,CaseNumber, CreatedDate, Subject, BI_Subject_Category__c, Description, BI_Account__c, BI_Record_Type__c, BI_Logged_By__c, BI_Owner__c FROM Case Where BI_Owner__c in :QueueMemSet';
        
        if(IdSet.size() > 0){
            query += ' and Id NOT IN : IdSet ';
        }                
       
        query += ' ORDER BY '+Orderby+' '+ OrderDir;        
        
        if(LimitSize != null && Integer.valueOf(LimitSize) > 0){
            LimitSize = Integer.valueOf(LimitSize);
            query += ' Limit ' +LimitSize;             
        }        
        
       return Database.query(query);
    }
    
    @AuraEnabled
    public static List<Object> getOwnerCases(Integer LimitSize, List<String> recIdList, String Orderby, String OrderDir){
        Set<Id> IdSet = new Set<Id>();
        Id userId = UserInfo.getUserId();
        String excludedRecType = 'SIP Beverage Coupon';
        
        if(Orderby == 'linkname'){
            Orderby = 'CaseNumber';
        }
        
        if(recIdList.size() > 0){
            IdSet = new Map<Id, Case>([Select Id From Case Where Id In : recIdList]).keySet();
        }
        
        OrderDir = String.isBlank(OrderDir) ? 'desc' : OrderDir;
        
        String query = 'SELECT CaseNumber, CreatedDate, Subject, BI_Subject_Category__c,Description, BI_Account__c, BI_Record_Type__c, BI_Logged_By__c, Status, BI_Auto_Notification_In_Progress__c, BI_Auto_Notification_Closed__c, BI_Planned_Release_Date__c, BI_Close_Comments__c FROM Case Where BI_Record_Type__c != :excludedRecType and isClosed = false and ownerId = :userId';
        
        if(IdSet.size() > 0){
            query += ' and Id NOT IN : IdSet ';
        } 
        
        query += ' ORDER BY '+Orderby+' '+ OrderDir;
        
        if(LimitSize != null && Integer.valueOf(LimitSize) > 0){
            LimitSize = Integer.valueOf(LimitSize);
            query += ' Limit ' +LimitSize;            
        }
        system.debug('*****the query is ' +query);
        return Database.query(query);
    }
    
     @AuraEnabled
    public static boolean updateCases(List<Case> editedCaseList){
        try{
            update editedCaseList;
            return true;
        } catch(Exception e){
            system.debug('Error in BI_LightningUtility_OwnerCases - updateCases method ' + e);
            return false;
        }
    }
    
    @AuraEnabled
    public static boolean ownCases(List<String> myCaseList){
        try{
            Id userId = UserInfo.getUserId();
            List<Case> updateList = new List<Case>();
            
            For(Case ca : [Select Id, OwnerId From Case Where Id in :myCaseList]){
                ca.OwnerId = userId;
                updateList.add(ca);
            }
            update updateList;
            return true;
        } catch(Exception e){
            return false;
        }
    }
    
    @AuraEnabled
    public static String getCasesRecType(List<String> theCaseList, String selectedRowId){
        system.debug('the list is ' + theCaseList);
        string recType = '';
        string validType = '';
        String returnString = '';        
        List<String> returnList = new List<String>();
        
        For(Case c : [Select Id, Status, BI_Record_Type__c From Case Where Id in :theCaseList]){
            If(returnString == ''){
                returnString = c.BI_Record_Type__c;                
            } else {
                if(returnString != c.BI_Record_Type__c){
                returnString = 'invalid';  
                }            
            }
        }
         return returnString;
    }  



}