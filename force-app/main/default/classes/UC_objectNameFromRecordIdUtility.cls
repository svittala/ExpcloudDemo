/**
 * @Description        : Rest Resource class to return Object API Name based on record Id
 * @Author             : Satish(Deloitte) 
 * @userStory          : Data Integration Audit Framework 
 * @Test Class         : UC_objectNameFromRecordIdUtilityTest
 * @Modification Log   : 10-29-2021 draft
 **/

@RestResource(urlMapping='/checkobjectname/*')
global class UC_objectNameFromRecordIdUtility {
    @HttpGet
    global Static String objectNameFromIdinURL(){
        RestRequest req = RestContext.request;
        String objectId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        if (objectId.length()==15 || objectId.length()==18){
            Id testid= objectId;
            system.debug( testid.getsObjectType().getDescribe().getName());
            return testid.getsObjectType().getDescribe().getName();
        }
        return 'invalid id';
    } 
    
    @HttpPost
    global Static String objectNameFromIdPost(){
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String requestString = body.toString();
        objectIdDetails rw = (objectIdDetails)JSON.deserialize(requestString, objectIdDetails.class);
        String objectId = rw.IdStr;
        
        if (objectId.length()==15 || objectId.length()==18){
            Id testid= objectId;
            return testid.getsObjectType().getDescribe().getName();
        }
        return 'invalid id';
    } 
    
    global class objectIdDetails {
        global String IdStr;
    }
}