@isTest
private class PEG_CallOut_CTL_TST {

    @isTest
    static void testExecuteRequest () {
        System.debug('testExecuteRequest START');
        
        String targetURL = 'https://www.google.com/';
        String httpMethod = 'GET';
        Map<String,String> headerParams = new Map<String,String>{'key1' => 'value1', 'key2' => 'value2'};
        String requestBody = '{"key":"value"}';
        
        String result = PEG_Callout_CTL.executeRequest(targetURL,httpMethod,headerParams,requestBody);
        System.debug('testExecuteRequest result received ' + result);
        System.assertEquals('OK',result);
                               
        System.debug('testExecuteRequest END');
    }
}