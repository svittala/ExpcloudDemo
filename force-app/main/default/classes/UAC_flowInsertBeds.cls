/**
 * @File Name          : UAC_flowInsertBeds.cls
 * @Description        : Main class to create beds
 * @Author             : Issam Awwad (Deloitte)
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0     11/10/2020   Issam Awwad (Deloitte)     Initial Implementation.
 **/
public
without sharing class UAC_flowInsertBeds {

  /**
   * @description Invocable method to create Beds
   * @author Issam Awwad (Deloitte) | 11/10/2020
   * @param List<Request>
   * @return List<Response>
   **/
  @InvocableMethod(label = 'Create Beds') public static List<Response> insertBeds(
      List<Request> listInputRequest) {
    Request objRequest = listInputRequest[0];
    Response newResponse = new Response();
    newResponse.boolSuccess = true;
    newResponse.strError = 'Success';
    List<Asset> lstOfNewBeds = new List<Asset>();
    List<Asset> lstOfDeliveredMaleBeds = new List<Asset>();
    List<Asset> lstOfUndeliveredMaleBeds = new List<Asset>();
    List<Asset> lstOfDeliveredFemaleBeds = new List<Asset>();
    List<Asset> lstOfUndeliveredFemaleBeds = new List<Asset>();

    if (objRequest.intOfDeliveredMaleBeds > 0) {
      lstOfDeliveredMaleBeds =
          createBedsHelper(objRequest.intOfDeliveredMaleBeds, 'Male', 'Delivered', objRequest);
      lstOfNewBeds.addAll(lstOfDeliveredMaleBeds);
    }
    if (objRequest.intOfUndeliveredMaleBeds > 0) {
      lstOfUndeliveredMaleBeds =
          createBedsHelper(objRequest.intOfUndeliveredMaleBeds, 'Male', 'Undelivered', objRequest);
      lstOfNewBeds.addAll(lstOfUndeliveredMaleBeds);
    }
    if (objRequest.intOfDeliveredFemaleBeds > 0) {
      lstOfDeliveredFemaleBeds =
          createBedsHelper(objRequest.intOfDeliveredFemaleBeds, 'Female', 'Delivered', objRequest);
      lstOfNewBeds.addAll(lstOfDeliveredFemaleBeds);
    }
    if (objRequest.intOfUndeliveredFemaleBeds > 0) {
      lstOfUndeliveredFemaleBeds = createBedsHelper(
          objRequest.intOfUndeliveredFemaleBeds, 'Female', 'Undelivered', objRequest);
      lstOfNewBeds.addAll(lstOfUndeliveredFemaleBeds);
    }

    if (!lstOfNewBeds.isEmpty()) {
      try {
        insert lstOfNewBeds;
      } catch (Exception e) {
        UAC_errorLog.logError(e.getMessage(), '',
            'Error inserting new beds from Funded Capacity Manager',
            e.getStackTraceString());
            newResponse.boolSuccess = false;
            newResponse.strError = e.getdmlMessage(0);
      }
    }
    return new List<Response>{newResponse};
  }

  /**
   * @description Helper method to create beds
   * @author Issam Awwad (Deloitte) | 11-10-2020
   * @param Integer numberOfBeds, String strGender, String strStatus, Date proposedDeliveryDate
   * @return List<Asset>
   **/
  public
  static List<Asset> createBedsHelper(
      Integer numberOfBeds, String strGender, String strStatus, Request objRequest) {
    List<Asset> lstOfBeds = new List<Asset>();
    Integer iterator = 1;
    while (numberOfBeds > 0) {
      Asset objBed = new Asset();
      objBed.Name = 'Bed ' + iterator;
      objBed.UAC_overallStatus__c = strStatus;
      objBed.AccountId = objRequest.strEntityId;
      objBed.UAC_gender__c = strGender;
      objBed.UAC_minimumAge__c = objRequest.intOfMinimumAge;
      objBed.UAC_maximumAge__c = objRequest.intOfMaximumAge;
      objBed.Status = 'Available';
      objBed.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName()
                                .get('UAC_bed')
                                .getRecordTypeId();
      if (strStatus == 'Undelivered') {
        objBed.UAC_proposedDeliveryDate1__c = objRequest.dateProposedDelivery;
      }
      lstOfBeds.add(objBed);
      numberOfBeds -= 1;
    }

    return lstOfBeds;
  }

  /**
   * @description Request class to hold request data
   * Each @InvocableVariable defined in this class is an input variable you can populate when
   *calling this from Flow
   * @author Issam Awwad (Deloitte) | 11-10-2020
   **/
  public
  inherited sharing class Request {
    @InvocableVariable public Integer intOfDeliveredMaleBeds;
    @InvocableVariable public Integer intOfUndeliveredMaleBeds;
    @InvocableVariable public Integer intOfDeliveredFemaleBeds;
    @InvocableVariable public Integer intOfUndeliveredFemaleBeds;
    @InvocableVariable public Integer intOfMinimumAge;
    @InvocableVariable public Integer intOfMaximumAge;
    @InvocableVariable public String strEntityId;
    @InvocableVariable public String strEntityState;
    @InvocableVariable public Date dateProposedDelivery;
  }

  /**
   * @description Response class to hold response data
   * @author James Qian (Deloitte) | 7/13/2021
   **/
  public inherited sharing class Response {
    @InvocableVariable public Boolean boolSuccess;
    @InvocableVariable public String strError;
  }
}