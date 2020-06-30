({
    initData : function(component, event, numberOfRecords) {          
        //alert('INITDATA fired: infini loading is ' + component.get("v.enableInfiniteLoading"));
        var actions = [
            { label: 'Edit', name: 'edit_details', iconName: 'utility:edit'}
        ];
        component.set('v.columns', [
            {label: '#', fieldName: 'linkName', type: 'url', disabled: 'true', sortable: 'true', initialWidth: 80, typeAttributes: {label: {fieldName: 'CaseNumber'}, target: '_self'}},
            {label: 'Opened', fieldName: 'CreatedDate', disabled: 'true', type: 'date', sortable: 'true', initialWidth: 130, typeAttributes: {
             	year: 'numeric',
             	month: 'numeric',
             	day: '2-digit',
                hour: '2-digit',
                minute: '2-digit',
            }},
            {label: 'Rec Type', fieldName: 'BI_Record_Type__c', sortable: 'true', disabled:'true', type: 'text'},
            {label: 'Logged By', fieldName: 'BI_Logged_By__c', sortable: 'true', disabled:'true', type: 'text'},
            {label: 'Account', fieldName: 'BI_Account__c', sortable: 'true', disabled:'true', type: 'lookup', sortable: 'true'},
            {label: 'Subject', fieldName: 'Subject', editable: 'true', type: 'text', sortable: 'true'},
            {label: 'Category', fieldName: 'BI_Subject_Category__c', sortable: 'true', disabled:'true', type: 'text'},
            {type: 'button', initialWidth: 10, typeAttributes: {
                iconName: 'utility:edit',
                label: '',
                variant: 'inverse',
                Id: 'editCategory',                
                name: 'editCategory',
                title: 'Edit Category',
                disabled: false,
                value: 'test',
                focusable: true,                
                class: "hoverWrapper slds-button slds-button_icon slds-button_icon-inverse slds-button_icon-container-more slds-button_icon-border-inverse slds-button_icon-small slds-hint-parent slds-cell-edit__button slds-cell-edit:hover"}
            },
            {label: 'Owner', fieldName: 'BI_Owner__c', disabled:'true', type: 'text', sortable: 'true'},
            {type: "button", initialWidth: 10, typeAttributes: {
                iconName: 'utility:change_owner',
                Id: 'Own',                
                name: 'Own',
                title: 'Own',
                disabled: false,
                value: 'Own',
                iconPosition: 'center',
                focusable: true,
                class: "slds-button slds-button_icon slds-cell-edit__button "
            }},
        ]);    
            //helper.getRecords(component, event, component.get("v.data").length);
            var action = component.get("c.getQueueCases"); 
            
            action.setParams({
            	LimitSize: 50, 
            	Orderby: component.get("v.sortedBy"),
            	OrderDir: component.get("v.sortedDirection")
            }); 
            action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                var records=response.getReturnValue();
            	records.forEach(function(record){
                  record.linkName = '/'+record.Id;
            	});
                component.set("v.data", records);
                component.set('v.loadMoreStatus', '');
                event.getSource().set("v.isLoading", false);
            
            }
        });
        $A.enqueueAction(action);             
    },

    getRecords : function(component, event, numberOfRecords) {        
        var data = component.get("v.data"); 
        var dataSize = component.get("v.data").length; 
        //var limit = component.get("v.totalNumberOfRows");         
        var searchTerm = component.get("v.keyWord"); 
        var searchLimit = 50;
            if(searchTerm != ''){searchLimit = 1000}  //alert('**HELP - getRecords: Shown Data Size: ' + dataSize);           
		
        //prepare ID List
		var yList = [];
        data.forEach(function(record){
                         yList.push(record.Id);
                     });

        var action = component.get("c.getQueueCases");
        action.setParams({
            LimitSize: searchLimit,            
            recIdList: yList, 
            Orderby: component.get("v.sortedBy"),
            OrderDir: component.get("v.sortedDirection")
        });    
        
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(component.get("v.data").length >= component.get("v.totalNumberOfRows")){
                    component.set("v.enableInfiniteLoading", false);
                    component.set("v.loadMoreStatus", 'No more data to load');
                } else {
                    var currentData = component.get("v.data");
                    var records = response.getReturnValue();
                    records.forEach(function(record){
                         record.linkName = '/'+record.Id; 
                     });                    
                    
                    var newData = currentData.concat(records);
                    var newDataSize = newData.length; 
                    component.set("v.getRecordsMonitor", newDataSize);
                   
                    
                    //check for active search terms and apply if needed
                    if(searchTerm != ''){
                        //alert('DO SEARCH - fire filterdata');
                        //alert('**HELP - getRecords: Fire filterData');
                         this.filterData(component, event, newData);    
                    } else {
                        //alert('**HELP - getRecords: DO NOT fire filterData');
                        component.set("v.data", newData);                        
                        //alert('compare sizes: dataSize is ' + dataSize + 'newDataSize is ' + newDataSize);
                        if(dataSize == newDataSize){
                            //alert('HELP - getRecords: MATCH, stop loading');
                            component.set("v.enableInfiniteLoading", false);
                        }
                    }
                    //search check end
                    component.set("v.loadMoreStatus", "");  
                    event.getSource().set("v.isLoading", false);
                }
                //event.getSource().set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);        
    },
    
    sortData : function(component, fieldName, sortDirection){
        var data = component.get("v.data");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse));
        component.set("v.data", data);
    },
    
	sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }, 

    updateCaseOwner : function(component, event, helper) {
        var action = component.get("c.ownCases");
        action.setParams({
             myCaseList : component.get('v.updateOwnerList'),
          });    
        action.setCallback(this,function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                if(response.getReturnValue() === true){
                    //alert('response was true');
                    helper.showToast({
                    "title": "Success",
                    "type": "success",
                    "message": "You are now the owner of selected case(s). Click on 'My Open Cases to view all your open cases"
                    });
                    $A.get('e.force:refreshView').fire();
                }            
                }   
        });
        $A.enqueueAction(action);        
    },

     getCasePickLists : function(component, event, helper) {
        //alert('START - in helper getting pick vals and defaults - ' + component.get('v.categoryList'))
        var pickValuestoShow = component.get('v.validPickListValues');
        var pickcart = [];
        var categoryList = [];
        var defCat = component.get('v.category');
        var defCatList = [];
        component.set('v.categoryList', '[]');
        //new line - set getstatus flag to true by default
        component.set('v.getStatusFlag', true);
        
        var rowAction = component.get('v.rowActionName');
        
        //alert('pickvalues to show is ' + pickValuestoShow);
        //alert('current record status is ' + defStat);
        //alert('xxxxx current record category is ' + defCat);
        //alert('row action clicked is ' +rowAction);
        
        var action = component.get("c.getCasesRecType");
        action.setParams({
            theCaseList : component.get('v.getPickListCaseList'),
            selectedRowId:   component.get('v.selectedRowId'),
        });    
        action.setCallback(this,function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnString=response.getReturnValue();
                //alert('returned status values are ' + returnString);                
                if(returnString == 'invalid'){
                    //alert('not valid for now');
                    component.set('v.getStatusFlag', false);
                    //component.set('v.showDescEdit', false);                  
                } else{                    
                    if(returnString == 'BI Release Request'){
                        //alert('it is a BI Release Request');
                        categoryList = ["Accounts and Contacts","Activities","Chatter","Data","Memberships", "Mobile Application", "Outlook Synchronization",
                                        "Pipeline", "Setup and Security", "Reports and Dashboards", "Sales Planning", "Other"];
                    }
                    if(returnString == 'BI Support Request'){
                        categoryList = ["Accounts and Contacts","Activities","Chatter","Data","Memberships", "Mobile Application", "Outlook Synchronization",
                                        "Pipeline", "Setup and Security", "Reports and Dashboards", "Sales Planning", "Other"];
                    }
                    if(returnString == 'Product'){
                        categoryList = ["Amenities","Jetstream Banking","Login / Password","Portal help","Pricing","Product Inquiry","PNR – General",
                                       "Reservation Help","United Meetings – Agreement","United PassPlus – Contract","United PassPlus – UATP (low on funds)",
                                       "United PassPlus – UATP (contacts)","United PassPlus – JP Morgan/PayConnexion","Other"];
                    }
                    if(returnString == 'Pre-Travel'){
                        categoryList = ["AO Support (Airport Support)","Baggage – General / Other", "Baggage – LOB (Lost on Board)","Baggage – Prepaid",
                                       "Corporate Security","ER","MileagePlus","NDC – Link","PNR – General / Other","PNR – Seats","PNR – Ticketing",
                                       "PNR – Upgrades","Policy and Procedure","Refunds – General / Other","Other"];
                    }
                    if(returnString == 'Post-Travel'){
                        categoryList = ["Baggage – Delayed","Baggage – General / Other ","Baggage – LOB (Lost on Board)","Baggage – Prepaid","Corporate Security",
                                       "Customer Care","Debit Memo","MileagePlus","PNR – General / Other","PNR – Seats","PNR – Upgrades","Refunds – Expired ticket",
                                       "Refunds – General / Other","Refunds – OA Escalation","Refunds – TAEX","Other"];
                    }
                    if(returnString == 'Jetstream Case'){
                        categoryList = ["Other"];
                    }
                    if(returnString == 'SIP Beverage Coupon'){
                        categoryList = ["Other"];
                    }

                    if(rowAction =="editCategory"){
                        if(categoryList.length > 0){
                            categoryList.forEach(function(record){
                                var element = {};
                                element.label = record;
                                element.value = record;
                                pickcart.push(element);                                          
                            });
                            component.set('v.validPickListValues', pickcart);                        
                        } 
                        
                        if(defCat != null){
                            var selectedCats = [];                            
                            selectedCats = defCat.split(";");
                            selectedCats.forEach(function(record){
                                component.get('v.categoryList').push(record);                                                                          
                            });
                        }
                    }
                    component.set('v.recordType', returnString);
                    component.set('v.getStatusFlag', true);   
                }                        
            }   
        });
        $A.enqueueAction(action);
                
        if(rowAction =="editCategory"){
            component.set('v.showCategoryEdit', true);   
        }
    },
    
    showToast : function(params){
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent){
            toastEvent.setParams(params);
            toastEvent.fire();
        } else{
            alert(params.message);
        }
    },
    
    filterData : function(component,event,loadMoreData) { 
        //alert('SEARCING.. filterData fired.');
        var dataSize = component.get("v.data").length;
        //alert('SEARCHING - shown data/dataSize ' + dataSize);
        if(loadMoreData == ''){
            var allRecords = component.get("v.data");
        } else {
            var allRecords = loadMoreData;
        }
        
        var searchFilter = component.get("v.keyWord").toUpperCase();    
        //alert('SEARCHING - search value is ' + searchFilter);
        if(searchFilter == ''){            
            helper.initData(component, event, component.get("v.data").length);
            component.set("v.enableInfiniteLoading", true);
        } else {
             var tempArray = [];
            var i;
            for(i=0; i < allRecords.length; i++){  
                //note: date in DB is stored differently than displayed. User will enter date filter as displayed and hence we manupulate it to match format of db format for the search               
                if((allRecords[i].CaseNumber && allRecords[i].CaseNumber.toUpperCase().indexOf(searchFilter) != -1) ||
                   (allRecords[i].CreatedDate && allRecords[i].CreatedDate.toUpperCase().indexOf(searchFilter.substring(6,10).concat('-',searchFilter.substring(0,2),'-',searchFilter.substring(3,5))) != -1) ||
               	   (allRecords[i].BI_Record_Type__c && allRecords[i].BI_Record_Type__c.toUpperCase().indexOf(searchFilter) != -1 ) ||
                   (allRecords[i].BI_Logged_By__c && allRecords[i].BI_Logged_By__c.toUpperCase().indexOf(searchFilter) != -1 ) ||
                   (allRecords[i].BI_Account__c && allRecords[i].BI_Account__c.toUpperCase().indexOf(searchFilter) != -1 ) ||
                   (allRecords[i].Subject && allRecords[i].Subject.toUpperCase().indexOf(searchFilter) != -1) ||
                   (allRecords[i].BI_Subject_Category__c && allRecords[i].BI_Subject_Category__c.toUpperCase().indexOf(searchFilter) != -1) ||
                   (allRecords[i].BI_Owner__c  && allRecords[i].BI_Owner__c .toUpperCase().indexOf(searchFilter) != -1))
                {
                tempArray.push(allRecords[i]);
                }
            }
            component.set("v.data",tempArray);          

            //alert('SEARCHING: allRecords count is ' + allRecords.length);
            //alert('SEARCHING - tempArray is ' + tempArray.length);
            //alert('SEARCHING - dataSize is ' + dataSize);
            
            if(dataSize == tempArray.length){
                //component.set("v.enableInfiniteLoading", false);
                //alert('MATCH');
                component.set("v.enableInfiniteLoading", false);
            }
            //alert('searching: newDataSize count is ' + component.get("v.getRecordsMonitor"));
            //component.set("v.loadMoreStatus", "");             
            //event.getSource().set("v.isLoading", false);
            //component.set("v.enableInfiniteLoading", false);            
        }
    }
   
})