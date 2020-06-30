({
	fetchAccountList : function(component, event,sortField) {
        component.set('v.sortColumn', sortField);
                //alert('fetchAccountList was called with a sortfield of ' + sortField + 'and a sortcolumn of ' + component.get('v.sortColumn'));
        var action = component.get("c.fetchAccounts");
        var checkedCount=0;
        //alert('include st account checkbox is ' +component.get('v.salesteamCheckBox'));
      action.setParams({
         'sortField': sortField,
         'isAsc': component.get("v.isAsc"),
		  recordId : component.get('v.recordId'),
          showSalesTeamAccounts: component.get('v.salesteamCheckBox'),
      });
        
      action.setCallback(this, function(a) {

         var rtnValue = a.getReturnValue();
          component.set('v.accountList', rtnValue);  
           var ls = component.get('v.accountList');
          if(ls.length > 0){
              component.set('v.showNoAccountsFound', false)
          } else {component.set('v.showNoAccountsFound', true)}
      });
      $A.enqueueAction(action);
	},
    
    
    fetchFocusList : function(component, event,sortField){
        var action = component.get("c.fetchFocusRecords");
        //alert('in the fetchFocus helper to go to the handler class the sort field is ' + sortField);
      action.setParams({
         'sortField': sortField,
         'isAsc': component.get("v.isAsc"),
		 recordId : component.get('v.recordId'),
      });
        
      action.setCallback(this, function(a) {

         var rtnValue = a.getReturnValue();
         if (rtnValue != null) {
             var defaultSortColumn = component.get('v.sortColumn');
             if(defaultSortColumn == 'Name'){
                 component.set('v.sortColumn', 'BI_Account__r.Name');
             }
             component.set('v.focusList', rtnValue);
              component.set('v.showFocusList', true);             
         }  
            	
          		
      });
      $A.enqueueAction(action); 
    },
    
    createFocusRecords: function(component, event, helper) {
        
        var focusAccountsCreateList = component.get('v.selectedAccountList');        
        
        if(focusAccountsCreateList.length == 0){
            //deal with error here and show message
            return;
        }
        
        var action = component.get("c.createFocusCustomerRecords");
       action.setParams({
		 objectiveId : component.get('v.recordId'),
           AccountIdList: focusAccountsCreateList
      });
        
      action.setCallback(this, function(response) {
          var state = response.getState();
          //alert('component controller to create focus records executed - return state to component was ' +state);
          if (state == 'SUCCESS'){
              //show toast that records were created with instructions
              //retrieve list of records / display created records
          }
            	
          		
      });
      $A.enqueueAction(action);
        
  },
    
    sortHelper: function(component, event, sortFieldName){
        var currentDir = component.get("v.arrowDirection");
        //alert('in the sortHelper - arrowDirection is ' + currentDir);
        
      if (currentDir == 'arrowdown') {
         // set the arrowDirection attribute for conditionally rendred arrow sign  
         component.set("v.arrowDirection", 'arrowup');
         // set the isAsc flag to true for sort in Assending order.  
         component.set("v.isAsc", true);
      } else {
         component.set("v.arrowDirection", 'arrowdown');
         component.set("v.isAsc", false);
      }
        var onAccTable = component.get('v.showAccountList');
        var onFocTable = component.get('v.showFocusList');
        
        if(onFocTable == true && onAccTable == false){
            this.fetchFocusList(component, event, sortFieldName);
        } else{
            if(onFocTable == false && onAccTable == true){
                this.fetchAccountList(component, event, sortFieldName);
            }
        }
        
    }
    
})