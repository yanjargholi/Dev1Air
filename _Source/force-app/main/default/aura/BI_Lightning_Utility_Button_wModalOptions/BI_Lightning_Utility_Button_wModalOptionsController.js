({
    /*
     * This finction defined column header
     * and calls getAccounts helper method for column data
     * editable:'true' will make the column editable
     * */
    doInit : function(component, event, helper) {        
        
        
        
    },
    
    createCase : function(component, event, helper) {        
        alert('button clicked');
        var createRecordEvent = $A.get("e.force:createRecord");
        
        createRecordEvent.setParams({
            "entityApiName": "Case",
            
        });
        createRecordEvent.fire(); 
    },

    
})