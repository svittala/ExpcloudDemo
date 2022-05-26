public with sharing class PEG_SoslOperation_CTL {

  // ------------------------------------------------------------------------  
  @AuraEnabled
  public static List<List<sObject>> executeQuery(String queryString) {
     System.debug('executeQuery : query requested '  + queryString);
     
     try {
         List<List<sObject>> sobjList = Search.query(queryString);
         System.debug('executeQuery : query executed ' + sobjList);
         return sobjList;
     } catch (Exception e) {
         System.debug('executeQuery : returning error ' + e.getMessage());
         throw new AuraHandledException(e.getMessage());
     }
  } 
    
  // ------------------------------------------------------------------------  
  @AuraEnabled(cacheable=true)
  public static List<List<sObject>> executeQueryStorable(String queryString) {
      System.debug('executeQueryStorable: START');
      System.debug('executeQueryStorable : query requested '  + queryString);
      return PEG_SoslOperation_CTL.executeQuery(queryString);  
  }
}