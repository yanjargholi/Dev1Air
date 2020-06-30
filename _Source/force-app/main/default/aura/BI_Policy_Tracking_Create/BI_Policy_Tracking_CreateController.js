({
    doInit : function(component, event, helper) {        

    },
    
    handleClick : function(component, event, helper) {        
       var userId = $A.get("$SObjectType.CurrentUser.Id");        
       //var buttonClicked = event.getSource().get("v.label");
        var whichOne = event.getSource().getLocalId();
                
         switch (whichOne){
            case '1':
                var createRecordEvent = $A.get("e.force:createRecord");
                 createRecordEvent.setParams({
                     "entityApiName": "BI_Tracked_Policy__c"           
                 });
                 createRecordEvent.fire(); 
                break;
            case '2':
                var navEvent = $A.get("e.force:navigateToList");
                 navEvent.setParams({
                "listViewId": "00B190000020Dc1EAE",
                "listViewName": "All",
                "scope": "BI_Tracked_Policy__c"
            });
            navEvent.fire();
                 
                break;    
            case '3':
                var urlEvent = $A.get("e.force:navigateToURL");
                 urlEvent.setParams({
                     "url": "/01Z0d0000013WflEAE"
                 });
                 urlEvent.fire();
                break; 
            case '4':
                var urlEvent = $A.get("e.force:navigateToURL");
                 urlEvent.setParams({
                     "url": "/00l19000000KBOiAAO"
                 });
                 urlEvent.fire();
                break;  
           
        }
        
    },
    
    
    
})