global class POC_PasswordLessLogin_Init {
    @InvocableMethod(label='initPasswordlessLogin' description='sample description here' category='User')
    public static list<string> initPasswordlessLogin(list<string> userId) {
        list<string>authCodeList = new list<string>();
        
        string emailChallengeId = System.UserManagement.initPasswordlessLogin(userid[0], Auth.VerificationMethod.EMAIL);
        authCodeList.add(emailChallengeId);
        return authCodeList;
    }
}