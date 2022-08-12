global class POC_PasswordLessLogin_Email {
    @InvocableMethod(label='emailPasswordlessLogin' description='sample description here' category='User')
    public static list<boolean> POC_PasswordLessLogin_Email(list<string> userId) {
        list<boolean> returnList = new list<boolean>();
        TwoFactorMethodsInfo tf = [SELECT id, userid, hasuserverifiedemailaddress, hasuserverifiedmobilenumber 
                                    FROM TwoFactorMethodsInfo where userid =:userid];
        
        if (!tf.hasuserverifiedemailaddress){
            id networkid = Network.getNetworkId();
            id emailTemplateid = '00X3S000000Y3eB';
            string startURL = '/s/login';
            boolean flag = system.UserManagement.sendAsyncEmailConfirmation(userId[0], emailTemplateId, networkId, startURL);
            system.debug('sendAsyncEmailConfirmation = ' + flag);
            returnList.add(false);
            return returnList;
        }
        else {
            returnList.add(true);
            return returnList;
        }
    }
}