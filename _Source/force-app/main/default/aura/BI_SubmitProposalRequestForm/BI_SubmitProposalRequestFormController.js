({
    doInit: function(component, event, helper) {
        helper.onUpdateProposalRequestForm(component, event, helper);
    },
    onclickOkButton: function(component, event, helper) {
        if (component.get('v.isError')) {
            $A.get("e.force:closeQuickAction").fire();
        } else {
            window.location.hash = '#/sObject/' + component.get('v.parentOpportunityId') + '/view';
            window.location.reload();
        }
    }
})