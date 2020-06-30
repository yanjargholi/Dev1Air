({
   
    onLoad: function(component, event, sortField) {
      //call apex class method
      var action = component.get("c.getObjectivesList");
 
      // pass the apex method parameters to action 
      action.setParams({
         'sortField': sortField,
         'isAsc': component.get("v.isAsc"),
		 recordId : component.get('v.recordId'),
		 initflag : true
      });
      action.setCallback(this, function(a) {
         //store state of response
         var rtnValue = a.getReturnValue();
         if (rtnValue != null) {
            //set response value in ListOfContact attribute on component.
            component.set('v.listLiew', rtnValue);
         }
      });
      $A.enqueueAction(action);
   },
    
   sortHelper: function(component, event, sortFieldName) {
      var currentDir = component.get("v.arrowDirection");
 
      if (currentDir == 'arrowdown') {
         // set the arrowDirection attribute for conditionally rendred arrow sign  
         component.set("v.arrowDirection", 'arrowup');
         // set the isAsc flag to true for sort in Assending order.  
         component.set("v.isAsc", true);
      } else {
         component.set("v.arrowDirection", 'arrowdown');
         component.set("v.isAsc", false);
      }
      // call the onLoad function for call server side method with pass sortFieldName 
      this.onLoad(component, event, sortFieldName);
   },
 
})