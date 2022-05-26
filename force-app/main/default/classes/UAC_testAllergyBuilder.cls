/**
 * @File Name         : UAC_testAllergyBuilder.cls
 * @Description       : Test builder class to build Allergy records for test instance
 * @Group             : UAC_testBuilder
 * @Author            : Sachet Khanal (Deloitte)
 * @Last Modified By  : Karthi Subramanian (Deloitte)
 * @Last Modified On  : 11-03-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   07-23-2020   Sachet Khanal (Deloitte)   Initial Version
 * 1.1   11-03-2020   Karthi Subramanian (Deloitte) Update Test Factory class with @isTest annotation
 **/
@isTest
public
with sharing class UAC_testAllergyBuilder {
  public
  String strAllergen = 'Peanut';
  public
  String strAllergyType = 'Food';
  public
  String strReaction = 'Difficulty breathing';
  public
  Id idHealthEvaluation;
  public
  Id idUAC;

  /**
   * @description Method to set associated Health Evaluation record
   * @author Sachet Khanal (Deloitte) | 07-23-2020
   * @param idHealthEvaluation Id of health evaluation record
   * @return UAC_testAllergyBuilder
   */
  public
  UAC_testAllergyBuilder setHealthEvaluation(Id idHealthEvaluation) {
    this.idHealthEvaluation = idHealthEvaluation;
    return this;
  }

  /**
   * @description Method to set associated UAC record
   * @author Sachet Khanal (Deloitte) | 07-23-2020
   * @param idUAC Id of UAC contact record
   * @return UAC_testAllergyBuilder
   */
  public
  UAC_testAllergyBuilder setUAC(Id idUAC) {
    this.idUAC = idUAC;
    return this;
  }

  /**
   * @description Method to set allergen name
   * @author Sachet Khanal (Deloitte) | 07-23-2020
   * @param strAllergen String value for allergen
   * @return UAC_testAllergyBuilder
   */
  public
  UAC_testAllergyBuilder setAllergen(String strAllergen) {
    this.strAllergen = strAllergen;
    return this;
  }

  /**
   * @description Method to set allergy type
   * @author Sachet Khanal (Deloitte) | 07-23-2020
   * @param strAllergyType String value for allergy type
   * @return UAC_testAllergyBuilder
   */
  public
  UAC_testAllergyBuilder setAllergyType(String strAllergyType) {
    this.strAllergyType = strAllergyType;
    return this;
  }

  /**
   * @description Method to set allergy reaction
   * @author Sachet Khanal (Deloitte) | 07-23-2020
   * @param strReaction String value for allergy reaction
   * @return UAC_testAllergyBuilder
   */
  public
  UAC_testAllergyBuilder setReaction(String strReaction) {
    this.strReaction = strReaction;
    return this;
  }

  /**
   * @description Method to build shell record for Allergy
   * @author Sachet Khanal (Deloitte) | 07-23-2020
   * @return UAC_allergy__c
   */
  public
  UAC_allergy__c build() {
    return new UAC_allergy__c(UAC_associatedHealthEvaluation__c = idHealthEvaluation,
        UAC_associatedUAC__c = idUAC,
        UAC_allergen__c = strAllergen,
        UAC_allergyType__c = strAllergyType,
        UAC_reaction__c = strReaction);
  }

  /**
   * @description Method to create Allergy record
   * @author Sachet Khanal (Deloitte) | 07-23-2020
   * @return UAC_allergy__c
   */
  public
  UAC_allergy__c buildAndSave() {
    UAC_allergy__c objAllergy = this.build();
    insert objAllergy;
    return objAllergy;
  }
}