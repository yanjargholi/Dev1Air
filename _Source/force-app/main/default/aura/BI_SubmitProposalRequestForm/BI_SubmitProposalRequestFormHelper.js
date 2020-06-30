({
    onUpdateProposalRequestForm: function(component, event, helper) {
        var action = component.get("c.submitProposalRequestForm");

        action.setParams({
            'proposalRequestFormId': component.get("v.recordId")
        });
   
        action.setCallback(this, function(response) {
            var state = response.getState();
            debugger;
            if (component.isValid() && state === 'SUCCESS') {
                var errors = response.getReturnValue().Errors;
                if (errors.length > 0) {

                    // var errorMessage = 'The Proposal Request has already been successfully submitted to the Pricing Team.  If you have any additional feedback for the Pricing Team, please use Chatter to send your message to them';
                    // component.set('v.message', errorMessage);
                    component.set('v.isError', true);

                    return;
                } else {
                    var result = response.getReturnValue().Result;
                    component.set('v.parentOpportunityId', result); 
                    component.set('v.isError', false);
                    // component.set('v.message', 'The Proposal Request has been successfully Submitted to the Pricing Team.');
                    // setTimeout(function() {
                    //     $A.get("e.force:closeQuickAction").fire();
                    // }, 1000);
                    // debugger;

                     // var urlEvent = $A.get("e.force:navigateToURL");
                     //   urlEvent.setParams({
                     //       "url": '/contract/' + id
                     //   });
                     //   urlEvent.fire(); 
                    
                     // $A.get('e.force:refreshView').fire();
                     // window.location.href = window.location.href;
                     // window.location.href = window.location.href;
                     // window.location.reload();
                }
            } else {
                component.set('v.isError', true);
                // var errorMessage = 'The Proposal Request has already been successfully submitted to the Pricing Team.  If you have any additional feedback for the Pricing Team, please use Chatter to send your message to them';
                //     component.set('v.message', errorMessage);
                    return;
            }

        });
        $A.enqueueAction(action);

    },
})