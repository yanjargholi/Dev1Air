({
	doInit : function(component, event, helper) {
        var orgEvent = $A.get("e.force:navigateToObjectHome");
        orgEvent.setParams({
            "scope": "BI_Objective_Type__c"
        });
        orgEvent.fire();
	}
})