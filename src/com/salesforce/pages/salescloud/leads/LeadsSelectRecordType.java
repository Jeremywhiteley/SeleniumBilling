package com.salesforce.pages.salescloud.leads;

import java.util.List;
import java.util.Set;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.CommonMethods;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class LeadsSelectRecordType extends PageBase
{

	 
	private static LeadsSelectRecordType instance;
	public static LeadsSelectRecordType Instance = (instance != null) ? instance : new LeadsSelectRecordType();
	
		
	/**UI Mappings */

	By recordTypeLocator = By.xpath("//td/label[contains(text(), 'Record Type')]/following::td[1]/div/select");
	By continueLocator = By.cssSelector("input[title='Continue']");
	By leadRecordTypeLocator = By.xpath("//label[text()='Record Type of new record']/../following::select");

	
	
	
	/**Page Methods*/

	public LeadsSelectRecordType verifyPageLoad()
	{
		pagelogger.debug("Waiting for page to load");

		SalesforcePageExtensions.waitForPageToLoad(driver);

		return this;
	}
	
	public LeadsEdit selectRecordType(String recordType)
	{
		pagelogger.debug("Selecting the account record type: "  + recordType);
		
		String id = getAttributeID(recordTypeLocator);
		
		SalesforcePageExtensions.selectOption(driver, id, recordType);
		clickOnElement(continueLocator);
		
		return LeadsEdit.Instance;
	}
	
	public boolean verifyRecordTypeValues(String passedInOptions)
	{
		pagelogger.debug("Comparing Lead select options with the passed in values: "				+ passedInOptions);
		boolean rtrn = false;

		List<String> foundOptions = SalesforcePageExtensions.returnSelectOptionsAsList(driver, leadRecordTypeLocator);
		
		pagelogger.debug("Found the following options on the page:"  + foundOptions.toString());
		
		String[] foundOptionsArray = (String[]) foundOptions.toArray();
		String[] passedInOptionsAsArray = passedInOptions.split(",");
		Set<String> fieldDifference = CommonMethods.getArrayDifference(passedInOptionsAsArray, foundOptionsArray);

		if (fieldDifference.size() == 0) 
		{
			pagelogger.debug("No differences were found between the passed in options and the found options");
			rtrn = true;
		} 
		else 
		{
			pagelogger.debug("Differences were found between the passed in options and found options: "							+ fieldDifference.toString());
		}

		return rtrn;
	
	}
	
}
