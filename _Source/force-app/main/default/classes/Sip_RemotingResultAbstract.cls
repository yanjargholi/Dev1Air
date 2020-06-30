/**
    @Author  : Natic
    @Created : 20170327
    @Propose : format of remote action's result.
    @Notice  : return type for remote action should be "Sip_RemotingResultAbstract"
    e.g.     : @RemoteAction
               public static Sip_RemotingResultAbstract exampleRemoting() { ... }
               public class ExampleResult extends Sip_RemotingResultAbstract { ... }
 */

global abstract class Sip_RemotingResultAbstract {
    @AuraEnabled
    global Boolean      success;
    @AuraEnabled
    global List<String> messages;

    global Sip_RemotingResultAbstract() {
        messages = new List<String>();
        success = true;
    }

}