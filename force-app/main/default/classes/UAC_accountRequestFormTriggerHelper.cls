/**
 * @File Name          : UAC_accountRequestFormTriggerHelper.cls
 * @Description        : Helper method for UAC_AccountRequestFormTriggerHandler
 * @Author             : Abhisek Pati (Deloitte)
 * @Group              : UAC_triggerHelper
 * @Modification Log   :
 *
 * Ver       Date            Author                      Modification
 * 1.0    11/19/2020    Abhisek Pati(Deloitte)     Initial Implementation.
 * 1.1    3/11/2021     Abhisek Pati(Deloitte)     ORRUAC-5391 Added filter for Existing User.
 * 1.2    03/19/2021	  Karthi Subramanian(Deloitte) Existing user record status update
 * 1.3    03/24/2021	  Nithin Malla(Deloitte) 			  ORRUAC-5540: Calling Async process for TrailMix 
 * 														                        Assignment based on Profile
 * 1.4    03/25/2021	  Nithin Malla(Deloitte) 			  ORRUAC-5651: Existing User ARF Update for 
 * 1.5    03/26/2021	  Nithin Malla(Deloitte) 			  ORRUAC-5651: Updating DHS and other 
 *                                                    Profile Status Updates
 * **/
public
with Sharing class UAC_accountRequestFormTriggerHelper {

  /**
   * @description Method to create users on status ready for user provisioning and setting User Map
   * @author Abhisek Pati (Deloitte)
   * @param newitems Map of new records,olditems Map of old records
   * @return void
   **/
  public
  static void createUserrecords(
      Map<Id, UAC_AccountRequestForm__c> newItems, Map<Id, UAC_AccountRequestForm__c> oldItems) {

    list<User> lstObjUser = new list<User>();
    list<UAC_AccountRequestForm__c> lstObjARFUpdate = new list<UAC_AccountRequestForm__c>();
    Map<id, User> mapARFUser = new Map<id, User>();
    Map<String, String> mapUserNametoId = new Map<String, String>();
    Map<String, String> mapARFIdtoUserId = new Map<String, String>();
    Set<String> setUsernames = new Set<String>();
    Set<Id> setARFId = new Set<Id>();
    // Get Profile Id
    Profile objProfile = [SELECT Id FROM Profile WHERE Name =:Label.UAC_myTrailhead LIMIT 1];

    try {
      for (UAC_AccountRequestForm__c objAccountRequestForm : newItems.values()) {
        UAC_AccountRequestForm__c objOldAccountRequestForm = oldItems.get(objAccountRequestForm.Id);

        if (objOldAccountRequestForm.UAC_Status__c != objAccountRequestForm.UAC_Status__c
            && objAccountRequestForm.UAC_Status__c == Label.UAC_arfStatusApproved
            && objOldAccountRequestForm.UC_existingUser__c == false) {
          User objUser = new User();
          // Add User Information
          objUser.FirstName = objAccountRequestForm.First_Name__c;
          objUser.LastName = objAccountRequestForm.Last_Name__c;
          objUser.Alias = objAccountRequestForm.First_Name__c.substring(0, 1)
              + objAccountRequestForm.Last_Name__c.left(7);
          objUser.Email = objAccountRequestForm.User_Email__c;
          objUser.Username = objAccountRequestForm.User_Email__c + Label.UAC_arfUsernameExtension;
          setUsernames.add(objUser.Username);
          objUser.ProfileId = objProfile.id;
          objUser.TimeZoneSidKey = 'America/New_York';
          objUser.LanguageLocaleKey = 'en_US';
          objUser.EmailEncodingKey = 'ISO-8859-1';
          objUser.LocaleSidKey = 'en_US';
          objUser.UserPermissionsSupportUser = true;
          objUser.UserPermissionsInteractionUser = true;
          objUser.UAC_ORRAuthorizedUser__c = true;
          lstObjUser.add(objUser);
          mapARFUser.put(objAccountRequestForm.id, objUser);
        }
      }
      if (!lstObjUser.isEmpty()) {
        Database.insert(lstObjUser);
      }

      for (User objUser : [Select Id, Username from User where Username IN:setUsernames]) {
        mapUserNametoId.put(objUser.Username, objUser.Id);
      }

      for (Id objARFId : mapARFUser.keyset()) {
        mapARFIdtoUserId.put(objARFId, mapUserNametoId.get(mapARFUser.get(objARFId).Username));
      }

      for (UAC_AccountRequestForm__c objAccountRequestForm : newItems.values()) {
        UAC_AccountRequestForm__c objOldAccountRequestForm = oldItems.get(objAccountRequestForm.Id);
        if (objOldAccountRequestForm.UAC_Status__c != objAccountRequestForm.UAC_Status__c
            && objAccountRequestForm.UAC_Status__c == Label.UAC_arfStatusApproved) {
          UAC_AccountRequestForm__c ObjARF =
              new UAC_AccountRequestForm__c(Id = objAccountRequestForm.Id);
          ObjARF.User_map__c = mapARFIdtoUserId.get(objAccountRequestForm.Id);
          ObjARF.UAC_Status__c = Label.UAC_arfUserProvisioned;
          ObjARF.UAC_userProvisioned__c = true;
          lstObjARFUpdate.add(ObjARF);
          setARFId.add(objAccountRequestForm.Id);
        }
      }

      if (!lstObjARFUpdate.isEmpty() && !setARFId.isEmpty()) {
        Update lstObjARFUpdate;

        //ORRUAC-5540: Calling Async process for TrailMix Assignment based on Profile  
        UAC_asyncUserProfileTrailmixAssignment profileTrailMixAss = new UAC_asyncUserProfileTrailmixAssignment(setARFId);
        system.enqueueJob(profileTrailMixAss);
      }
    } catch (Exception e) {
      UAC_errorLog.platformEventErrorLog(e.getMessage(), '',
          'CreateUserRecords in Account Request Form',
          newItems.keySet().toString() + e.getStackTraceString());
    }
  }
  /**
   * @description Method to validate that on initial creation of ARF record, Status = "In Progress"
   *or "Initiate Form Completion Request"
   * @author Issam Awwad (Deloitte)
   * @param newitems Map of new records
   * @return void
   **/
  public
  static void setUserType(List<UAC_AccountRequestForm__c> newItems) {
    for (UAC_AccountRequestForm__c objAccountRequestForm : newItems) {
      String strEmail = objAccountRequestForm.User_Email__c.substringAfterLast('.').toLowerCase();
      if (strEmail == 'gov') {
        objAccountRequestForm.UC_userType__c = Label.UC_accountRequestFormInternalUserType;
      } else {
        objAccountRequestForm.UC_userType__c = Label.UC_accountRequestFormGranteeUserType;
      }
    }
  }
  /**
   * @description Method to update status to Initate Form Completion Request for existing users once they uploaded forms
   * @author Karthi Subramanian (Deloitte)
   * @param newitems Map of new records 
   * @param OldItems Map of old records
   * @return void
   **/
  public
  static void setStatusInitiateFormForExistingSvcUsers(Map<Id, UAC_AccountRequestForm__c> newItems, Map<Id, UAC_AccountRequestForm__c> oldItems) {
    List<String> profileNameSet = label.UAC_trailMixProfileNames.split(',');

    for (UAC_AccountRequestForm__c objAccountRequestForm : newItems.values()) {
          String strUserType = objAccountRequestForm.UC_userType__c;
          if(strUserType == Label.UC_accountRequestFormGranteeUserType && objAccountRequestForm.UAC_ROB_Uploaded__c && 
            objAccountRequestForm.UAC_Privacy_101_Uploaded__c && objAccountRequestForm.UAC_Cyber_Security_Uploaded__c &&
            (objAccountRequestForm.UAC_ROB_Uploaded__c != oldItems.get(objAccountRequestForm.Id).UAC_ROB_Uploaded__c ||
            objAccountRequestForm.UAC_Privacy_101_Uploaded__c != oldItems.get(objAccountRequestForm.Id).UAC_Privacy_101_Uploaded__c ||
            objAccountRequestForm.UAC_Cyber_Security_Uploaded__c != oldItems.get(objAccountRequestForm.Id).UAC_Cyber_Security_Uploaded__c)){
              setStatusBasedOnProfile(objAccountRequestForm);
            }
          if(strUserType == Label.UC_accountRequestFormInternalUserType && objAccountRequestForm.UAC_ROB_Uploaded__c &&
            (objAccountRequestForm.UAC_ROB_Uploaded__c != oldItems.get(objAccountRequestForm.Id).UAC_ROB_Uploaded__c)){
              setStatusBasedOnProfile(objAccountRequestForm);
          }
      }
  }

  /**
   * @description Method to set status to Initate Form Completion Request or Ready for Profile Update
   * @author Nithin Malla(Deloitte)
   * @param UAC_AccountRequestForm__c record
   * @return void
   **/  
  Private 
  static void setStatusBasedOnProfile(UAC_AccountRequestForm__c objAccountRequestForm){
        List<String> profileNameSet = label.UAC_trailMixProfileNames.split(',');
        
        if(profileNameSet.contains(objAccountRequestForm.User_Profile__c)){
            objAccountRequestForm.UAC_Status__c = Label.UC_accountRequestFormIFCRStatus;
        }else{
            objAccountRequestForm.UAC_Status__c = Label.UAC_readyForProfileUpdate;
        }
  }

  /**
   * @description Method to update Users with ORR Auth User Flag once they uploaded forms
   * @author Karthi Subramanian (Deloitte)
   * @param newitems Map of new records 
   * @param OldItems Map of old records
   * @return void
   **/
  public
  static void updUsrORRAuthFlag(Map<Id, UAC_AccountRequestForm__c> newItems, Map<Id, UAC_AccountRequestForm__c> oldItems) {
      
      Set<Id> setUserId = new Set<Id>();
      
       for (UAC_AccountRequestForm__c objAccountRequestForm : newItems.values()) {
          String strUserType = objAccountRequestForm.UC_userType__c;
          if(strUserType == Label.UC_accountRequestFormGranteeUserType && objAccountRequestForm.UAC_ROB_Uploaded__c && 
            objAccountRequestForm.UAC_Privacy_101_Uploaded__c && objAccountRequestForm.UAC_Cyber_Security_Uploaded__c &&
            (objAccountRequestForm.UAC_ROB_Uploaded__c != oldItems.get(objAccountRequestForm.Id).UAC_ROB_Uploaded__c ||
            objAccountRequestForm.UAC_Privacy_101_Uploaded__c != oldItems.get(objAccountRequestForm.Id).UAC_Privacy_101_Uploaded__c ||
            objAccountRequestForm.UAC_Cyber_Security_Uploaded__c != oldItems.get(objAccountRequestForm.Id).UAC_Cyber_Security_Uploaded__c
           )){
              if(objAccountRequestForm.User_map__c!=null)
              setUserId.add(objAccountRequestForm.User_map__c);
          }
          if(strUserType == Label.UC_accountRequestFormInternalUserType && objAccountRequestForm.UAC_ROB_Uploaded__c &&
            (objAccountRequestForm.UAC_ROB_Uploaded__c != oldItems.get(objAccountRequestForm.Id).UAC_ROB_Uploaded__c)){
              if(objAccountRequestForm.User_map__c!=null)
              setUserId.add(objAccountRequestForm.User_map__c);
          }
      }

      if(!setUserId.isEmpty()){
        System.enqueueJob(new UC_asyncQueueORRAuthUserUpdate(setUserId));
      }
  }    
}