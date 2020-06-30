({
	navTasks : function(component, event, helper) {
        var orgEvent = $A.get("e.force:navigateToObjectHome");
        orgEvent.setParams({
            "scope": "Task"
        });
        orgEvent.fire();
	},
    
    navEvents : function(component, event, helper) {
        var orgEvent = $A.get("e.force:navigateToObjectHome");
        orgEvent.setParams({
            "scope": "Event"
        });
        orgEvent.fire();
	},
    
    navReports : function(component, event, helper) {
        var orgEvent = $A.get("e.force:navigateToObjectHome");
        orgEvent.setParams({
            "scope": "Report"
        });
        orgEvent.fire();
	},
    navDashboards : function(component, event, helper) {
        var orgEvent = $A.get("e.force:navigateToObjectHome");
        orgEvent.setParams({
            "scope": "Dashboard"
        });
        orgEvent.fire();
	},
    
    navChatter : function(component, event, helper) {
        var navService = component.find("navService");
        // Sets the route to /lightning/o/Account/home
        var pageReference = {
            type: 'standard__namedPage',
            attributes: {
                pageName: 'chatter',
            }
        };
        component.set("v.pageReference", pageReference);
        // Set the URL on the link or use the default if there's an error
        var defaultUrl = "#";
        navService.generateUrl(pageReference)
            .then($A.getCallback(function(url) {
                component.set("v.url", url ? url : defaultUrl);
                 window.open('https:'+url,
                    '_top' // <- This is what makes it open in a new window.
                   );
            }), $A.getCallback(function(error) {
                component.set("v.url", defaultUrl);
            }));
	},
    
    navOnes : function(component, event, helper) {
        var orgEvent = $A.get("e.force:navigateToObjectHome");
        orgEvent.setParams({
            "scope": "BI_One_on_One__c"
        });
        orgEvent.fire();
	},
    
    
})