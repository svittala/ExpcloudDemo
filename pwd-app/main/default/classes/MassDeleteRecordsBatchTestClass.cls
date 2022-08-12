@isTest
public class MassDeleteRecordsBatchTestClass
{
    static testMethod void testMethod1()
    {
        Account acc = new Account();
        acc.name='MassDeleteRecordsBatchTestClass1';
        insert acc;
        Test.startTest();
        String str = 'select id from Account where Name = \'' + acc.Name + '\'';
            MassDeleteRecordsBatchClass obj = new MassDeleteRecordsBatchClass(str);
            DataBase.executeBatch(obj);
        Test.stopTest();
    }
}