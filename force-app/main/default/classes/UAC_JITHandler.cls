global with sharing class UAC_JITHandler implements Auth.SamlJitHandler {
  private
  with sharing class JitException extends Exception {
  }

  global User
  createUser(Id samlSsoProviderId,
      Id communityId,
      Id portalId,
      String federationIdentifier,
      Map<String, String> attributes,
      String assertion) {
    User userRec;
    try {
      userRec = [select id, federationIdentifier from user where email
        =:attributes.get('email')and isactive = true and UAC_ORRAuthorizedUser__c = true];

      if (userRec.federationIdentifier == null || userRec.federationIdentifier == '') {
        userRec.federationIdentifier = attributes.get('XID');
      }
      if (userRec.federationIdentifier != attributes.get('XID')) {
        throw new JitException('Federation Ids do not match. Please contact your administrator.');
      }
      if (userRec != null) update userRec;
    } catch (Exception dml) {
      throw dml;
    }
    return userRec;
  }

  global void updateUser(Id userId,
      Id samlSsoProviderId,
      Id communityId,
      Id portalId,
      String federationIdentifier,
      Map<String, String> attributes,
      String assertion) {
    User userRec =
        [select id, isactive, UAC_ORRAuthorizedUser__c from user where federationIdentifier
          =:federationIdentifier];
    if (userRec.isactive == false || userRec.UAC_ORRAuthorizedUser__c == false) {
      throw new JitException('User is not active or not ORR Authorized');
    }
  }
}