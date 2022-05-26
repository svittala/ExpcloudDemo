//ORRUAC-User Onboarding
public class UAC_UserTriggerHandler {

    public static void onafterInsertusers(List<user> Newusers)
    {
        Id myTrailheadProfile = [Select Id From Profile Where Name='Read Only' LIMIT 1].Id;
      for (User userupdate : Newusers) 
      {
          if(userupdate.ProfileId == myTrailheadProfile)
          {
          System.resetPassword(userupdate.Id,true);
          }
      }
    }
}