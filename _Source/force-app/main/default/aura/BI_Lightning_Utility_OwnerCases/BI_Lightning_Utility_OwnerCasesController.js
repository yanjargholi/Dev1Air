({
    init: function(component, event, helper){
        //console.log(component.get("v.data").length);
        helper.initData(component, event, component.get("v.data").length);         
    },
    
    loadMoreData: function(component, event, helper){
        var rowsToLoad = component.get('v.rowsToLoad');
        event.getSource().set("v.isLoading", true);
        component.set('v.loadMoreStatus', 'Loading');
        helper.getRecords(component, event, component.get("v.data").length);
     },
    
     onRefresh: function(component, event, helper){
        //helper.initData(component, event, component.get("v.data").length);
        $A.get('e.force:refreshView').fire();           
    },
            
    updateColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        //helper.sortData(cmp, fieldName, sortDirection); xx
        component.set('v.data', []);
        event.getSource().set("v.isLoading", true);
        component.set('v.loadMoreStatus', 'Loading');
        helper.initData(component, event, component.get("v.data").length);
    },
            
    onSave : function (component, event, helper) {
            var draftValues = event.getParam('draftValues');
            //alert('in Onsave - draftValues are ' + JSON.stringify(draftValues));
            
            var action = component.get("c.updateCases");
            action.setParams({
                "editedCaseList" : draftValues,
                //"impDate" : component.get('v.impDate'),
                //"cComments": component.get('v.cComments'),
            });
            action.setCallback(this, function(response) {
                var state = response.getState();            
                if(state === "SUCCESS"){
                if(response.getReturnValue() === true){
                    helper.showToast({
                    "title": "Success",
                    "type": "success",
                    "message": "Case Record(s) Updated Successfully"
                    });
                    $A.get('e.force:refreshView').fire();
                }            
                }            
            });
            $A.enqueueAction(action); 
    },
            
    handleRowAction: function (component, event, helper) {
            var actionName = event.getParam('action').name;
            component.set('v.rowActionName', actionName);
            var row = event.getParam('row');            
            var selectedRows = component.find("objDataTable").get("v.selectedRows"); 
            component.set('v.idCartListSize', selectedRows.length);
            var Idcart = []; 
            component.set('v.idCartList', []);
            component.set('v.idCartListType', '');
            component.set('v.applyCheck', false); 
        	//for update of Status or Category picklists row actions
            component.set('v.isClosedStatus', false); 
		    component.set('v.recordType', '');	
            component.set('v.getPickListCaseList', []);
            component.set('v.validPickListValues', []); //list of picklist values we will show for either status or category
            component.set('v.validPickListValuesNotify', []); //list of picklist values we will show for Auto Notifications In Progress and Closed
            component.set('v.status', row.Status);
            //yy - Get existing field values to show when modal screens render
            component.set('v.impDate', row.BI_Planned_Release_Date__c);
            component.set('v.selectedRowId', row.Id);
            component.set('v.cComments', row.BI_Close_Comments__c);     
            //yy end
            //alert('notify IP existing value is ' + row.BI_Auto_Notification_In_Progress__c);
            //alert('current var value in comp is  ' + component.get("v.notifyIP"));    
       
            component.set('v.notifyIP', row.BI_Auto_Notification_In_Progress__c); 
            component.set('v.notifyClosed', row.BI_Auto_Notification_Closed__c);
            component.set('v.category', row.BI_Subject_Category__c);            
       		var toUpdateList = component.get('v.getPickListCaseList'); //list for case IDs that we want to retrieve valid status options for
      
        if(selectedRows.length > 0 ){
            var addClickedRow = '';
                //alert('multiple');
                component.set('v.idCartListType', 'Id');
                selectedRows.forEach(function(record){                    
                        Idcart.push(record);
                        if(actionName == 'editStatus'|| actionName == 'editCategory'){
                            toUpdateList.push(record); 
                        }
                        if(record == row.Id){
                            addClickedRow = 'no';
                        }             
       			});
            
                if(addClickedRow != 'no'){
                    Idcart.push(row.Id);
                }

            } else {
                    if(selectedRows.length == 0 && row != ''){
                        component.set('v.idCartListType', 'Full'); 
                        Idcart.push(row); 
                        if(actionName == 'editStatus' || actionName == 'editCategory'){
                            toUpdateList.push(row.Id);                           
                        }
                    }
                }
            
            if(row != ''){
                //yy component.set('v.impDate', row.BI_Planned_Release_Date__c);
                //yy component.set('v.selectedRowId', row.Id);
            }
            
            if(toUpdateList.length > 0 && (actionName == 'editStatus' || actionName == 'editCategory')){
                component.set('v.getPickListCaseList', toUpdateList);
                helper.getCasePickLists(component, event, helper);                   
                }

            if(Idcart.length > 0){                
                component.set('v.idCartList', Idcart);
                component.set('v.descValue', row.Description);
            }
},
 
    saveDescEdit: function(component, event, helper) {
        var updateCart = [];
        var action = component.get('v.rowActionName');
        updateCart = component.get('v.idCartList'); 
        var updateCartType = component.get('v.idCartListType'); 
        var carSize = updateCart.length;
        var editedRecords =  component.find("objDataTable").get("v.draftValues");
        var edrSize = editedRecords.length; 
        var desc = component.get('v.descValue'); 
        var userSelection = component.get("v.selectedPickVal");  
        var userSelectionNotifyIP = component.get("v.selectedPickValNotifyIP");
        var notifyIP = component.get("v.notifyIP");
        var notifyClosed = component.get("v.notifyClosed");
        var userSelectionNotifyClosed = component.get("v.selectedPickValNotifyClosed");
        var applyCheck = component.get('v.applyCheck');
        var isSuccess = false;
        var cart = []; 
        
        //Status variables for validation rules
        component.set('v.getReqFieldsFlag', true);             
        var recType = component.get('v.recordType');
        var closedStatus = component.get('v.isClosedStatus');
        var cComments = component.get('v.cComments');
        var impDate = component.get('v.impDate');
        var clickedRowId = component.get('v.selectedRowId');
        var eRecsContainsClickedRow = '';
     
     for(var i = 0; i < carSize; i++){
         isSuccess = false;      
         //get the Id for current record
         var getId = '';
         
         if(updateCartType == 'Full'){
                 getId = updateCart[i].Id;              
             } else{
                 getId = updateCart[i];
                 if(applyCheck == false){
                     i = carSize;
                     getId = clickedRowId;
                 }
             }
             
         //alert('****** MAIN LOOP THROUGH CART ... id is ' + getId);
         
         if(edrSize == 0){
             //alert('no prior edits');
             var element = {};
             element.Id = "" + getId + "";
             if(action == 'editCategory' ){
                 var stringSelection = userSelection.toString();
                 element.BI_Subject_Category__c = "" + stringSelection + "";
             }
             if (action == 'editStatus'){
                 element.Status = "" + userSelection + ""; 
                 //*** VALIDATION RULES - check required fields based on status change 
				 helper.validation(component, event, helper); 
                 
                 //alert('cc is ' + cComments);
                if(cComments != null & cComments != ""){
                         element.BI_Close_Comments__c = "" + cComments + "";
                 }
                 
                 if(impDate != null & impDate != ""){
                         element.BI_Planned_Release_Date__c = "" + impDate + "";
                 }
                 
                 if(userSelectionNotifyIP != null & userSelectionNotifyIP != ""){
                         element.BI_Auto_Notification_In_Progress__c = "" + userSelectionNotifyIP + "";
                 } 
                 if(userSelectionNotifyClosed != null & userSelectionNotifyClosed != ""){
                         element.BI_Auto_Notification_Closed__c = "" + userSelectionNotifyClosed + "";
                 } 
             }
             cart.push(element);
             editedRecords.push(element);
             isSuccess = true;
             
         } else {
             //alert('prior edits editrecs are ' + JSON.stringify(editedRecords));
             for(var y = 0; y < edrSize; y++){
                 //alert('- PRIOR EDITS FOUND LOOPING: started for '  + editedRecords[y].Id);                 
                    if (editedRecords[y].Id == getId){
                     //alert('MATCH - a previously edit record matches our record');                         
                         if (action == 'editStatus'){
                             //*** VALIDATION RULES - check required fields based on status change 
				 			 helper.validation(component, event, helper); 
                             var selectionString = userSelection.toString();
                             editedRecords[y].Status = selectionString;
							 
                             if(cComments != null & cComments != ""){
                                 editedRecords[y].BI_Close_Comments__c = cComments;
                         	}                             
                             if(impDate != null & impDate != ""){
                                 editedRecords[y].BI_Planned_Release_Date__c = impDate; 
                        	 }                             
                             if(userSelectionNotifyIP != null & userSelectionNotifyIP != ""){
                                 editedRecords[y].BI_Auto_Notification_In_Progress__c = userSelectionNotifyIP;     
                             } 
            
                             if(userSelectionNotifyClosed != null & userSelectionNotifyClosed != ""){
                                 editedRecords[y].BI_Auto_Notification_Closed__c = userSelectionNotifyClosed;
                             } 
                         }

                         if (action == 'editCategory'){
                             var stringSelection = userSelection.toString();
                             editedRecords[y].BI_Subject_Category__c = stringSelection;                                             
                         }
                         
                         isSuccess = true;
                     } 
             }
             
             if(isSuccess == false){
                 //alert('PRIOR EDIT LOOP END: our record was not found');
                 var element = {};
             	 element.Id = "" + getId + "";
                 if (action == 'editStatus'){
                     //*** VALIDATION RULES - check required fields based on status change 
				 	 helper.validation(component, event, helper);     
                     element.Status = "" + userSelection + "";
                     if(cComments != null & cComments != ""){
                         element.BI_Close_Comments__c = "" + cComments + "";
                     }
                     if(impDate != null & impDate != ""){
                             element.BI_Planned_Release_Date__c = "" + impDate + "";
                     }
                     if(userSelectionNotifyIP != null & userSelectionNotifyIP != ""){
                             element.BI_Auto_Notification_In_Progress__c = "" + userSelectionNotifyIP + "";
                     } 
                     if(userSelectionNotifyClosed != null & userSelectionNotifyClosed != ""){
                             element.BI_Auto_Notification_Closed__c = "" + userSelectionNotifyClosed + "";
                     }  
                 }
                 
                 if (action == 'editCategory'){
                     var stringSelection = userSelection.toString();
                     element.BI_Subject_Category__c = "" + stringSelection + ""; 
                 }

             	 cart.push(element);
             	 editedRecords.push(element);
             	 isSuccess = true;
             }
         } 
         
     } //end cart loop
    
     if(isSuccess == true && (component.get("v.getReqFieldsFlag") == true)) {
         component.find("objDataTable").set("v.draftValues", editedRecords);
         //component.set('v.customEditList', editedRecords);
         component.set('v.showStatusEdit', false);  
         component.set('v.showCategoryEdit', false);
     }
        //alert('controller - edited records are ' + JSON.stringify(editedRecords));
        //alert('component - draft values in component is ' + JSON.stringify(component.find("objDataTable").get("v.draftValues")));
},
    
 	onPickListChangeNotifyClosed: function(component, event, helper){
        component.set("v.selectedPickValNotifyClosed", component.find("select_notifyClosed").get("v.value") );
    },
    onPickListChangeNotifyIP: function(component, event, helper){
        component.set("v.selectedPickValNotifyIP", component.find("select_notifyIP").get("v.value") );
    },
    
    onPickListChange: function(component, event, helper){
        var action = component.get('v.rowActionName');
        component.set('v.getReqFieldsFlag', true);
        component.set('v.isClosedStatus', false);
        
        if(action == 'editStatus'){
            component.set("v.selectedPickVal", component.find("select_status").get("v.value") );
        	var stat = component.get("v.selectedPickVal");
        
            if(stat == 'Closed - Implemented' || stat == 'Closed - Not Planned' || stat == 'Closed - Resolved' || stat == 'Closed - Resolved' || stat == 'Closed - Cancelled' || stat == 'Closed' || stat == 'Closed.' || stat == 'Cancelled'){
                component.set('v.isClosedStatus', true);                
            }
        }
        
        if(action == 'editCategory'){
            var selectedCategories = event.getParam("value");
            var selectString = selectedCategories.toString();            
            var selection = selectString.replace(/,/g,';');
            component.set("v.selectedPickVal", selection);
        }
    },
    
    onCancel: function(component, event, helper) {
            component.set('v.showStatusEdit', false);
            component.set('v.showCategoryEdit', false);
        },
    
    searchTable : function(component,event,helper) {         
        component.set("v.enableInfiniteLoading", true);
        var searchFilter = component.get("v.keyWord").toUpperCase();
        //alert('CONT: searchTabe - fired:' + searchFilter + 'INFINITE LOA: ' + component.get("v.enableInfiniteLoading"));
        if(searchFilter == ''){
            //alert('CONT: searchTabe - fire init: ' + searchFilter);
            helper.initData(component, event, component.get("v.data").length);
        } else {
            //alert('CONT: searchTabe - fire filterData: ' + searchFilter);
            helper.filterData(component, event, '');                          
        }
    },
    
    searchCleared: function(component, event, helper){
        var searchFilter = event.getSource().get("v.value").toUpperCase();       
        if(searchFilter == ''){   
            component.set("v.enableInfiniteLoading", true);
            helper.initData(component, event, component.get("v.data").length);            
        }
    }
    
})