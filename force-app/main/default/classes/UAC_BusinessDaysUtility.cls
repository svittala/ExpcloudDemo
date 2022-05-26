/**
* @File Name          : UAC_BusinessDaysUtility.cls
* @Description        : Handles all Business Hour related logic
* @Author             : Ankur Aggarwal (Deloitte)
* @Group              : UAC_BusinessDaysUtility
* @Last Modified By   : Ankur Aggarwal (Deloitte)
* @Last Modified On   : 5/29/2020
* @Modification Log   :
* Ver       Date            Author      		    Modification
* 1.0    5/29/2020   Ankur Aggarwal (Deloitte)     Initial Implementation.
**/
public with sharing class UAC_BusinessDaysUtility {
    public BusinessHours bHours;
    /**
     * Constructor to set business hours name
     * */
    public UAC_BusinessDaysUtility(String businessHoursName){
        //get business hours
        bHours = [SELECT Id FROM BusinessHours WHERE Name =: businessHoursName];
    }
     
    public UAC_BusinessDaysUtility(){
        //If no business hours name provided in paramaterized constructor, use deafault hours
        bHours = [SELECT Id FROM BusinessHours WHERE IsDefault = true];
    }
    

    /**
     * Add number of working days in a date
     * @param - startDate - date to operate on
     * @param - days - number of days to add
     * @author - Ankur Aggarwal
     * */
    public Datetime addDays(Datetime startDate, Integer days)
    {
        //If startdate is not within working days, take next working day
        startDate = BusinessHours.nextStartDate(bHours.Id, startDate);
		
        for (Integer elapsed = 0; elapsed < days; elapsed++)
        {
            //Add 1 day
            startDate = startDate.addDays(1);
            
            //Check if new date is within working days
            if (!BusinessHours.isWithin(bHours.Id, startDate))
            { 
                //If new date is not within working days, get new working day
                startDate = BusinessHours.nextStartDate(bHours.Id, startDate);
            }
        }
        return startDate;
    }
    
    /**
     * Subtract number of working days in a date
     * @param - startDate - date to operate on
     * @param - days - number of days to subtract
     * @author - Ankur Aggarwal
     * */
    public Datetime subtractDays(Datetime startDate, Integer days)
    {
        //If startdate is not within working days, take previous working day
        startDate = getPreviousWorkingDay(startDate);
        for (Integer elapsed = 0; elapsed < days; elapsed++)
        {
            //Subtract 1 day
            startDate = startDate.addDays(-1);
            //Check if new date is within working days
            if (!BusinessHours.isWithin(bHours.Id, startDate))
            { 
                //If new date is not within working days, get previous working day
            	startDate = getPreviousWorkingDay(startDate);
            }
        }
        return startDate;
    }
    
    /**
     * Recursive function to get previous working day
     * If date passed to this function is on a working day, this will return same date
     * If date passed to this function is not on a working day, this will return previous working day
     * *********************
     * For Example, if day passed to this function is Monday, this will return Monday
     * but if day passed to the function is Sunday, then this will return Friday
     * *********************
     * @param - d - Date to operate on
     * @author - Ankur Aggarwal
     * */
    public Datetime getPreviousWorkingDay(Datetime d){
        
        
         //Check if new date is within working days
        if (!BusinessHours.isWithin(bHours.Id, d))
        {
            //New date is not within working days, recursively call same function to get previous date by subtracting 1 day
            d = d.addDays(-1);
            return getPreviousWorkingDay(d);
        } else{
            //New date is within working days, return this date
            return d;
        }
    }
    
    /**
     * Function to get next working day
     * If date passed to this function is on a working day, this will return same date
     * If date passed to this function is not on a working day, this will return next working day
     * *********************
     * For Example, if day passed to this function is Monday, this will return Monday
     * but if day passed to the function is Sunday, then this will return Monday
     * *********************
     * @param - d - Date to operate on
     * @author - Ankur Aggarwal
     * */
    public Datetime getNextWorkingDay(Datetime d){
        return BusinessHours.nextStartDate(bHours.Id, d);
    }
    
    
    /**
     * Check if supplied date is working day or not
     * @author - Ankur Aggarwal
     * */
    public Boolean isWorkingDay(Datetime d){
        return BusinessHours.isWithin(bHours.Id, d);
    }
    
    /*
     * Get numbe of business days between two dates
	 * @author - Ankur Aggarwal
	 * */
    public Integer getNoOfBusinessDaysBetweenDates(DateTime startDate, DateTime endDate){
        Integer count = 0;
        while(startDate <= endDate){
            if(BusinessHours.isWithin(bHours.Id, startDate)){
                count++;
            }
            startDate = startDate.addDays(1);
        }
        return count;
    }
}