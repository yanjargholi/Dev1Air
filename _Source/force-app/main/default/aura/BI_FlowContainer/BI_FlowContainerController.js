({
    doInit : function( component, event, helper ) {

        console.log( '************ FLOW CONTAINER INIT' );
        helper.startFlow( component );

    },

    handleFlowStatusChange : function( component, event, helper ) {

        console.log( '*********** flow updates' );
        console.log( event.getParams() );

        // refresh the record if details changes in the flow
        if ( event.getParam( 'status' ) === 'FINISHED' ) {
            $A.get( 'e.force:refreshView' ).fire();
        }

    },

    handleRecordUpdated : function( component, event, helper ) {

        console.log( '********* record updates' );
		//refresh the flow if details changed in the record
        helper.startFlow( component );

    }
})