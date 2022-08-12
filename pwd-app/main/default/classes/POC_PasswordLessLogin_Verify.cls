global class POC_PasswordLessLogin_Verify {
    @InvocableMethod(label='verifyPasswordlessLogin' description='sample description here' category='User')
    public static list<boolean> verifyPasswordlessLogin(list<list<string>> providedValuesList) { 
        system.debug('providedValues='+ providedValuesList[0]);
        list<string> providedValues = new list<string>(providedValuesList[0]);
        list<boolean> returnList = new list<boolean>();
        string userid = providedValues[0];
        string emailChallengeId = providedValues[1];
        string submittedCode = providedValues[2];
        string redirectURL = 'https://ssodev-acf-orr.cs133.force.com/discovery/s/';

        if (submittedCode != null) {
            Auth.VerificationResult res = System.UserManagement.verifyPasswordlessLogin(userid, Auth.VerificationMethod.EMAIL, emailChallengeId, submittedCode, redirectURL);
            if (res.success) {
                system.debug('email is success');
                returnList.add(true);
            } 
            else {
                string error = res.message;
                system.debug('email is failure: ' + error);
                returnList.add(false);
            }
        } 
        return returnList;
    }
}