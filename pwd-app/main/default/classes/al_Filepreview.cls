public without sharing class al_Filepreview {
    @AuraEnabled(cacheable=true)
    //WHERE FILEEXTENSION IN ('docx', 'pdf')
    public static list<ContentVersion> retriveFiles(){
        return [SELECT Id, Title, FileExtension, ContentDocumentId From ContentVersion  LIMIT 17];
    }
}