/***
* @author P-E GROS
* @date   August 2019
* @description Lightning controller to execute custom apex actions.
*
* Legal Notice
* This code is the property of Salesforce.com and is protected by U.S. and International
* copyright laws. Reproduction, distribution without written permission of Salesforce is
* strictly prohibited. In particular this code has been delivered by Salesforce.com for
* its Client’s internal purposes pursuant to specific terms and conditions, and cannot be
* re-used, reproduced or distributed for any other purposes.
***/

public with sharing class PEG_Action_CTL {
    
/***
* @description Simple pass-through method to execute an action from a Lightning Component.
*              Version with SObject output.
* @param       action         Apex handler class of which the 'executeAction' method should
*                             be executed. 
* @param       target         Target SObject of the action (may be any of the supported ones
*                             but depends on the action)
* @return      SObject        Sobject returned by the action.
* @Exception   none really specific.
* @author      P-E GROS
* @date        August 2019
***/
    
  @AuraEnabled
  public static Object executeAction(String action, Object target) {
      System.debug('executeAction : START for action ' + action + ' and target ' + target);
      
      if (String.isEmpty(action)) throw new PEG_ActionHandler_SVC.PEG_ActionException('No action name provided!');
      String className = action;
      String methodName = null;
      if (action.contains('.')) {
          System.debug('executeAction : splitting action in class and method');
          String[] parts = action.split('\\.');
          className = parts[0];
          methodName = parts[1];
      }
      System.debug(LoggingLevel.FINEST,'executeAction : className set '  + className);
      System.debug(LoggingLevel.FINEST,'executeAction : methodName set ' + methodName);
      
      Type actionHandlerClass = Type.forName(className);
      if (null == actionHandlerClass) {
          System.debug('executeAction : END action handler not found');
          throw new PEG_ActionHandler_SVC.PEG_ActionException('Handler class for action ' + action + ' not found!');
      }
      else {
          System.debug('executeAction : action handler found');
          PEG_ActionHandler_SVC actionHandlerInstance = (PEG_ActionHandler_SVC) actionHandlerClass.newInstance();
          
          if (methodName == null) {
              System.debug('executeAction : END invoking handler action for class');
              return actionHandlerInstance.executeAction(target);
          }
          else {
              System.debug('executeAction : END invoking handler action for method ' + methodName);
              return actionHandlerInstance.executeActionMethod(methodName, target);
          }
      }
  }
    
}