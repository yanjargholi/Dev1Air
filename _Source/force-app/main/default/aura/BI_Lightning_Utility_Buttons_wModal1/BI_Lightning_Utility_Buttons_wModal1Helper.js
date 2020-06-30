({
    getRecords : function(component, event, helper) {
        var action = component.get("c.getObjectives");
    action.setParams({
         recordId : component.get('v.recordId'),
      });    
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var records=response.getReturnValue();
                 records.forEach(function(record){
                    record.linkName = '/'+record.Id;
                });
                component.set("v.data", records);
                //component.set("v.dataList", records);
            }
        });
        $A.enqueueAction(action);
    },

    /*
     * This function get called when user clicks on Save button
     * user can get all modified records
     * and pass them back to server side controller
     * */
    saveDataTable : function(component, event, helper) {
        
        var editedRecords =  component.find("objDataTable").get("v.draftValues");
        var totalRecordEdited = editedRecords.length;
        var action = component.get("c.updateObjectives");
        action.setParams({
            'editedObjList' : editedRecords
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //if update is successful
                if(response.getReturnValue() === true){
                    helper.showToast({
                        "title": "Records Updated Successfully",
                        "type": "success",
                        "message": totalRecordEdited+" Objectiv Records Updated"
                    });
                    //helper.reloadDataTable(); xxxx
                    component.find("objDataTable").set("v.draftValues", []);
                    $A.enqueueAction(component.get('c.doInit'));
                    
                } else{ //if update got failed
                    helper.showToast({
                        "title": "Error!!",
                        "type": "error",
                        "message": "Error in update"
                    });
                }
            }
        });
        $A.enqueueAction(action);        
    },

    /*
     * Show toast with provided params
     * */
    showToast : function(params){
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent){
            toastEvent.setParams(params);
            toastEvent.fire();
        } else{
            alert(params.message);
        }
    },

    /*
     * reload data table xxxx can remove
     * */
    reloadDataTable : function(){
    var refreshEvent = $A.get("e.force:refreshView");
        if(refreshEvent){
            refreshEvent.fire();
        }
    },
    
 
    
})