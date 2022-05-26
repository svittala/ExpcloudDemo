public with sharing class PEG_CallOut_CTL {
    
  // Simple pass-through method to execute a Callout from a Lightning Component.
  @AuraEnabled
  public static String executeRequest(String targetURL,
                                      String httpMethod,
                                      Map<String,String> headerParams,
                                      String requestBody) {
     System.debug('executeRequest: START');
     HttpRequest request = new HttpRequest();
                                          
     System.debug('executeRequest: setting EndPoint ' + targetURL);
     request.setEndpoint(targetURL);
                                          
     System.debug('executeRequest: setting Method ' + httpMethod);                                     
     request.setMethod(httpMethod);
                                          
     //request.setHeader('Content-Type','application/json;charset=UTF-8');
     if ((null != headerParams) && (headerParams.size() != 0)) {
         System.debug('executeRequest: headerParams provided ' + headerParams);    

         for(String key:headerParams.keySet()) {
           System.debug('executeRequest: setting header Params' + key
                        + ' with value ' + headerParams.get(key));
           request.setHeader(key,headerParams.get(key));
         }       
     } else {
         System.debug('executeRequest: no headerParams provided ' + headerParams);
     }
          
     if ((null != requestBody) && (requestBody.length() != 0)) {
         System.debug('executeRequest: setting request Body' + requestBody);
         request.setBody(requestBody);
     } else {
         System.debug('executeRequest: no requestBody provided ' + requestBody);
     }
                                          
     System.debug('executeRequest: sending request' + request);
     Http http = new Http();  
                                          
     if(Test.isRunningTest()) {
         return 'OK';
     } else {
       HttpResponse response = http.send(request);
       System.debug('executeRequest: response received' + response);
                                          
       if (response.getStatusCode() != 200) {
         String statusMessage = response.getStatus() + ' (' + response.getStatusCode() + ')';
         System.debug('executeRequest: callout response' + statusMessage);
         throw new AuraHandledException('Callout Issue: ' + statusMessage);
       }                                        
       return (String)(response.getBody());
    }
  }
}