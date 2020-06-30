({
	doInit : function(component, event, helper) {
        var orgEvent = $A.get("e.force:navigateToObjectHome");
        orgEvent.setParams({
            "scope": "BI_Territory_Plan__c"
        });
        orgEvent.fire();
	}
})