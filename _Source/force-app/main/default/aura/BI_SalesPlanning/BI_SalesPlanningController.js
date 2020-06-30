({
	orgplans : function(component, event, helper) {
        var orgEvent = $A.get("e.force:navigateToObjectHome");
        orgEvent.setParams({
            "scope": "BI_Organizational_Plan__c"
        });
        orgEvent.fire();
	},
    
    divplans : function(component, event, helper) {
        var orgEvent = $A.get("e.force:navigateToObjectHome");
        orgEvent.setParams({
            "scope": "BI_Divisional_Plan__c"
        });
        orgEvent.fire();
	},
    
    regplans : function(component, event, helper) {
        var orgEvent = $A.get("e.force:navigateToObjectHome");
        orgEvent.setParams({
            "scope": "BI_Regional_Plan__c"
        });
        orgEvent.fire();
	},
    
    terplans : function(component, event, helper) {
        var orgEvent = $A.get("e.force:navigateToObjectHome");
        orgEvent.setParams({
            "scope": "BI_Territory_Plan__c"
        });
        orgEvent.fire();
	},
    
    acctplans : function(component, event, helper) {
        var orgEvent = $A.get("e.force:navigateToObjectHome");
        orgEvent.setParams({
            "scope": "BI_Account_Plan__c"
        });
        orgEvent.fire();
	},
    
    objcats : function(component, event, helper) {
        var orgEvent = $A.get("e.force:navigateToObjectHome");
        orgEvent.setParams({
            "scope": "BI_Objective_Category__c"
        });
        orgEvent.fire();
	},
    objtypes : function(component, event, helper) {
        var orgEvent = $A.get("e.force:navigateToObjectHome");
        orgEvent.setParams({
            "scope": "BI_Objective_Type__c"
        });
        orgEvent.fire();
	}    
    
})