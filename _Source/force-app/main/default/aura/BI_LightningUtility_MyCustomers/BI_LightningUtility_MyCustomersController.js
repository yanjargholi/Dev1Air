({
	navLeads : function(component, event, helper) {
        var orgEvent = $A.get("e.force:navigateToObjectHome");
        orgEvent.setParams({
            "scope": "Lead"
        });
        orgEvent.fire();
	},
    
    navAccounts : function(component, event, helper) {
        var orgEvent = $A.get("e.force:navigateToObjectHome");
        orgEvent.setParams({
            "scope": "Account"
        });
        orgEvent.fire();
	},
    
    navContacts : function(component, event, helper) {
        var orgEvent = $A.get("e.force:navigateToObjectHome");
        orgEvent.setParams({
            "scope": "Contact"
        });
        orgEvent.fire();
	},
    
    
})