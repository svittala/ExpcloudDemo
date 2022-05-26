@isTest
private class PEG_SoslOperation_CTL_TST {
    
    @isTest
    static void testExecuteQuery () {
        system.debug('testExecuteQuery: standard execution');
        String testQuery = 'FIND \'TEST\' IN ALL FIELDS RETURNING Account (Name)';
        List<List <sObject>> sobjLists = PEG_SoslOperation_CTL.executeQuery(testQuery);
        System.assertEquals(1,sobjLists.size());
        System.assertEquals(0,sobjLists[0].size());
        system.debug('testExecuteQuery: standard execution OK');
        
        system.debug('testExecuteQuery: storable execution');
        sobjLists = PEG_SoslOperation_CTL.executeQueryStorable(testQuery);
        System.assertEquals(1,sobjLists.size());
        System.assertEquals(0,sobjLists[0].size());
        system.debug('testExecuteQuery: storable execution OK');
        
        system.debug('testExecuteQuery: wrong query');
        testQuery = 'FIND ERROR';
        try {
            sobjLists = PEG_SoslOperation_CTL.executeQuery(testQuery);
            System.assert(false);
        } catch (Exception error) {
            //OK
            System.assert(true);
        }
        system.debug('testExecuteQuery: wrong query OK');
        
    }

}