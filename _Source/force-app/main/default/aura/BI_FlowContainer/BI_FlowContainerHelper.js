({
    startFlow : function( component ) {

        var flowName = component.get( 'v.flowName' );

        // if flow not set
        if ( $A.util.isEmpty( flowName ) ) {
            return;
        }

        var p = new Promise( function( resolve, reject ) {

            // https://developer.salesforce.com/docs/atlas.en-us.210.0.lightning.meta/lightning/js_cb_dynamic_cmp_async.htm

            $A.createComponent(
                'lightning:flow',
                {
                    'aura:id' : 'flow',
                    'onstatuschange' : component.getReference( 'c.handleFlowStatusChange' )
                },
                function( newCmp, status, errorMessage ) {
                    if ( status === 'SUCCESS' ) {
                        resolve( newCmp );
                    } else {
                        reject( errorMessage || status );
                    }
                }
            );

        }).then( $A.getCallback( function( newFlowCmp ) {

            var flowContainer = component.find( 'flowContainer' );

            flowContainer.get( 'v.body' ).forEach( function( cmp, idx ) {
                cmp.destroy();
            });

            flowContainer.set( 'v.body', newFlowCmp );

            // flow input variables this is where we pass the record id to the flow
            // the flow must have a text variable called recordId
            var inputVariables = [
                {
                    name : 'recordId',
                    type : 'String',
                    value : component.get( 'v.recordId' )
                }
            ];

            newFlowCmp.startFlow( flowName, inputVariables );

        })).catch( $A.getCallback( function( err ) {

            console.error( 'An error occured loading this screen. Please contact businessInsight@united.com for assistance' );
            console.error( err );

        }));

    }
})