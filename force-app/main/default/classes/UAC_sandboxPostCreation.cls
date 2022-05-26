/**
 * @File Name          : UAC_sandboxPostCreation.cls
 * @Description        : Sets custom settings for UAC Path
 * @Author             : James Qian (Deloitte)
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    10/7/2020    James Qian (Deloitte)     Initial Implementation.
 **/
global without sharing class UAC_sandboxPostCreation implements SandboxPostCopy {
  /**
   * @description Calls setAppSettings method
   * @author James Qian (Deloitte) | 10/7/2020
   * @param SandboxContext objContext
   **/
  global void runApexClass(SandboxContext objContext) {
    UAC_appSettingsService.setAppSettings();
  }
}