/**
 * Created by lzhang283 on 8/16/2018.
 */

global without sharing class Sip_RemotingResult extends Sip_RemotingResultAbstract{
    @AuraEnabled
	global Object result;
    global Object agreementVM;

    global Sip_RemotingResult() {
        super();
    }

    global Sip_RemotingResult(Boolean success, String message) {
    	super.success = success;
    	super.messages = new List<String>{message};
    }

    global Sip_RemotingResult(Boolean success, List<String> messages) {
    	super.success = success;
    	super.messages = messages != null ? messages : new List<String>();
    }

    global Sip_RemotingResult(Object result, Boolean success, String message) {
    	this(success, message);
    	this.result = result;
    }

    global Sip_RemotingResult(Object result, Boolean success, List<String> messages) {
    	this(success, messages);
    	this.result = result;
    }

    global Sip_RemotingResult(Object result, Object agreementVM, Boolean success, List<String> messages) {
        this(success, messages);
        this.result = result;
        this.agreementVM = agreementVM;
    }
}