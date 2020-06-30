({
    handleToggleSpinnerEvent : function(component, event) {
        var spinner = component.find("bi-spinner");        
        if(!spinner||!spinner.getElement() || !spinner.getElement().style) {
            return;
        }
        var currentStatus = event.getParam("currentStatus");
        
        if (currentStatus == "show") {
            spinner.getElement().style.display = "none";
        } else {
            spinner.getElement().style.display = "block";
        }
    }
})