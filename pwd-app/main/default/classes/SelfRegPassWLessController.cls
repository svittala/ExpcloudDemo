public without sharing class SelfRegPassWLessController {
     @AuraEnabled
    public static String sendEmail(String email) {
    //Create Account
    //Create Contact
    
    user targetUser;
    return System.UserManagement.initSelfRegistration(Auth.VerificationMethod.EMAIL, targetUser);
    }
    
    @AuraEnabled
    public static String verifyCodeforReg(String code, String verificationId) {
    Auth.VerificationResult result = System.UserManagement.verifySelfRegistration(Auth.VerificationMethod.EMAIL, verificationId, code, 'commStartURL');
    if (result.success == true) {
    aura.redirect(result.redirect);
    return result.message;
    }
    else{
    return result.message;
    }
    }
    @AuraEnabled
    public static String passlesslogin(String userid) {
    return System.UserManagement.initPasswordlessLogin(userid, Auth.VerificationMethod.EMAIL);
    }
    @AuraEnabled
    public static String verifyCodeforLogin(String userid, String code, String verificationId) {
    Auth.VerificationResult result = System.UserManagement.verifyPasswordlessLogin(userid, Auth.VerificationMethod.EMAIL, verificationId, code, '/comm1/s');
    if (result.success == true) {
    aura.redirect(result.redirect);
    return result.message;
    }
    else{
    return result.message;
    }
    }
    }