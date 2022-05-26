/***
* @author P-E GROS
* @date :  August 2019
* @description Virtual Action handling class used by the PEG_Action_CTL generic controller.
*              Provides virtual default implementations of supported methods with 2 interfaces.
*              Default implementation throws exceptions to warn about possible issues.
*
* Legal Notice
* This code is the property of Salesforce.com and is protected by U.S. and International
* copyright laws. Reproduction, distribution without written permission of Salesforce is
* strictly prohibited. In particular this code has been delivered by Salesforce.com for
* its Client’s internal purposes pursuant to specific terms and conditions, and cannot be
* re-used, reproduced or distributed for any other purposes.
***/

public virtual class PEG_ActionHandler_SVC {

    public virtual Object executeAction(Object target) {
        System.debug(LoggingLevel.ERROR,'executeAction : PEG_ActionHandler_SVC default implementation called.');
        throw new PEG_ActionHandler_SVC.PEG_ActionException('Action not implemented (at least with Object interface)!');
        //return null;
    }
    
    public virtual Object executeActionMethod(String method, Object target) {
        System.debug(LoggingLevel.ERROR,'executeActionMethod : PEG_ActionHandler_SVC default implementation called.');
        throw new PEG_ActionHandler_SVC.PEG_ActionException('Action not implemented (at least with Object Method interface)!');
        //return null;
    }
   
    // Custom class to store serialized JSON for exception message  
    private class PEG_ActionOptions {
        public String       message;
        public List<Object> details;
        public List<Object> options;
        public PEG_ActionOptions(String message, List<Object> details, List<Object> options){
            this.message = message;
            this.details = details;
            this.options = options;
        }
    }
    
    // Custom exceptions for general processing errors
    public class PEG_ActionException extends Exception { 
        public PEG_ActionException(String message, List<Object> details) {
            this(JSON.serialize(new PEG_ActionHandler_SVC.PEG_ActionOptions(message,details,null),true));
        }
    }

    // Custom exceptions for warnings and options proposition 
    public class PEG_ActionOptionException extends Exception {
        public PEG_ActionOptionException(String message, List<Object> details, List<Object> options) {
            this(JSON.serialize(new PEG_ActionHandler_SVC.PEG_ActionOptions(message,details, options),true));
        }
    }
    
}