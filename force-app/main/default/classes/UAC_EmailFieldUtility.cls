public without sharing class UAC_EmailFieldUtility {
    //List<String> roleList = new List<String>{'Case Manager', 'Clinician'};

    // objList - list of child records of contacts. eg: UAC_Diagnosis__c, UAC_Health_Evaluation__c, UAC_Test__c
    // contactFieldName - name of the lookup/master field on the child - eg: UAC_associatedUAC__c
    // roleList - list of role names - eg: {'Case Manager', 'Clinician'}
    // roleToEmailFieldMap - map of role to email field for role in object - eg: 
    // {'Case Manager' => 'UAC_Case_Manager_Email__c',
    // 'Clinician' => 'UAC_Clinician_Email__c'}
    // output - populates the email fields within the child records with values obtained from the
    // Account Team Member via User.Email
    public static void mapEmailFieldsFromAccountTeamRoles(List<SObject> objList, 
                                    String contactFieldName, 
                                    List<String> roleList,
                                    Map<String, String> roleToEmailFieldMap) {
        // no roles specified? nothing to do                                        
        if ((roleList == null) || (roleList.size() == 0)) return;       
        // roleToEmailFieldMap null or empty?                                       
        if ((roleToEmailFieldMap == null) || (roleToEmailFieldMap.keySet().size() == 0)) return;  

        // contactIds List of contact ids related to the child records
        List<Id> contactIds = new List<Id>();        
        // collect the contact Ids into a list
        for (SObject obj : objList) { 
            contactIds.add((String)obj.get(contactFieldName));
        }
        // get list of accounts connected to Contacts                                       
        List<Contact> contactList = [select Id, Name, AccountId from Contact where id in : contactIds];

        List<Id> acctIdList = new List<Id>();

        Map<Id, Id> contactIdToAccountIdMap = new Map<Id, Id>();
        // loop through contacts
        // create a list of account ids for querying of Account Team Members
        // create a map of contact ids to account ids
        for (Contact c : contactList) {
            acctIdList.add(c.AccountId);
            contactIdToAccountIdMap.put(c.id, c.AccountId);
        }
        // get all Account Team members in specified roles and tied to account ids in acctIdList
        List<AccountTeamMember> acctTeamMembers = [select id, TeamMemberRole, User.Name, User.Email, AccountId 
                                                    from AccountTeamMember
                                                where AccountId in :acctIdList and 
                                                TeamMemberRole in :roleList];

        Map<String, AccountTeamMember> acctIdRoleToMember = new Map<String, AccountTeamMember>();
        // loop through team members and create a map of id + role to Team Member record
        for (AccountTeamMember teamMember : acctTeamMembers) {

            System.debug(teamMember + ' email:' + teamMember.User.Email);
            acctIdRoleToMember.put(teamMember.AccountId + teamMember.TeamMemberRole, teamMember);


        }

        // loop through object list


        for (SObject obj : objList) {
            // get account for contact
            String accountId = contactIdToAccountIdMap.get((String)obj.get(contactFieldName));
            if (accountId != null) {
                // loop through roles 
                for (String role : roleList) {
                    // get team member with specified role and accountId
                    // get their user email
                    String roleEmail = acctIdRoleToMember.get(accountId + role)?.User.Email;
                    // got an email and also have field name to map to?
                    if ((roleEmail != null) && (roleToEmailFieldMap.get(role) != null)) {
                        // populate email field with email value
                        obj.put(roleToEmailFieldMap.get(role), roleEmail);
                    }
                }
            }
        }

    }
/**
   * @description ORRUAC-498 - Method to Auto Populate Medical Team Email from Program of  UAC
   *record
   * @author Ram Josyer - Creative 12/24/2020
   * @param
   * @return void
   **/
  public
  static void populateMedicalTeamEmail(List<SObject> lstHealthEvalRelatedObject) {

        if ((lstHealthEvalRelatedObject == null) || (lstHealthEvalRelatedObject.size() == 0))
            return;
        List<id> lstOfHealthEvalId = new List<Id>();
        Map<id, UAC_healthEvaluation__c> mapHealthEval = new Map<id, UAC_healthEvaluation__c>();

        for (SObject healthEvalRelatedObject : lstHealthEvalRelatedObject) {
        lstOfHealthEvalId.add((String)healthEvalRelatedObject.get('UAC_associatedHealthEvaluation__c'));
        }

        for (UAC_healthEvaluation__c objHealthEval :
            [select id, UAC_lookupAssociatedProgram__c,
            UAC_lookupAssociatedProgram__r.UAC_programMedicalTeamEmail__c,
            UAC_lookupAssociatedProgram__r.UAC_FFSEmail__c 
            from UAC_healthEvaluation__c where Id
            in:lstOfHealthEvalId]) {
                if (!mapHealthEval.containsKey(objHealthEval.id))
                    mapHealthEval.put(objHealthEval.id, objHealthEval);
        }

        if (!mapHealthEval.isEmpty()) {
            for (SObject healthEvalRelatedObject : lstHealthEvalRelatedObject) {
                UAC_healthEvaluation__c healthEval = 
                    mapHealthEval.get((String)healthEvalRelatedObject.get('UAC_associatedHealthEvaluation__c'));
                if ((healthEval != null) && (healthEval.UAC_lookupAssociatedProgram__c != null)) {
                    healthEvalRelatedObject.put('UAC_programMedicalTeamEmail__c', 
                        healthEval.UAC_lookupAssociatedProgram__r.UAC_programMedicalTeamEmail__c);
                    healthEvalRelatedObject.put('UAC_FFSEmail__c', 
                        healthEval.UAC_lookupAssociatedProgram__r.UAC_FFSEmail__c);
            
                }
            }
        }
    }    
    /**
     * @description ORRUAC-498 - Method to Auto Populate Medical Team Email from Program of  UAC
     *record
    * @author RJ CreativeSysCon 
    * @param
    * @return void
    **/
    public
    static void populateMedicalTeamEmailHealthEval(List<UAC_HealthEvaluation__c> lstNewHealthEvaluation) {

        List<id> lstOfAccounts = new List<Id>();

        for (UAC_HealthEvaluation__c objHealthEvaluation : lstNewHealthEvaluation) {
        lstOfAccounts.add(objHealthEvaluation.UAC_lookupAssociatedProgram__c);

        }
        // query list of programs and build a map from id to program
        Map<id, Account> mapPrograms = new Map<id, Account>();
        for (Account program :
            [select id, UAC_programMedicalTeamEmail__c, UAC_FFSEmail__c 
            from Account where Id in:lstOfAccounts]) {
                if(!mapPrograms.containsKey(program.id))
                    mapPrograms.put(program.id, program);
        }

        if (!mapPrograms.isEmpty()) {
            for (UAC_healthEvaluation__c newobjHealthEval : lstNewHealthEvaluation) {
                Account healthEvalProgram = mapPrograms.get(newobjHealthEval.UAC_lookupAssociatedProgram__c);
                if (healthEvalProgram != null) {
                    newobjHealthEval.UAC_programMedicalTeamEmail__c = healthEvalProgram.UAC_programMedicalTeamEmail__c;
                    newobjHealthEval.UAC_FFSEmail__c = healthEvalProgram.UAC_FFSEmail__c;
                }
            }
        }  
    }
}