({
	doInit : function(component, event, helper) {
        var orgEvent = $A.get("e.force:navigateToObjectHome");
        orgEvent.setParams({
            "scope": "BI_Divisional_Plan__c"
        });
        orgEvent.fire();
	}
})