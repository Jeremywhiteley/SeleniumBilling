package com.salesforce.pages.salescloud.accounts;

import java.util.List;
import java.util.Set;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.CommonMethods;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class AccountsSelectRecordType extends PageBase
{

	 
	private static AccountsSelectRecordType instance;
	public static AccountsSelectRecordType Instance = (instance != null) ? instance : new AccountsSelectRecordType();
	
	
	/** UI Mappings */

	By continueLocator = By.cssSelector("input[title='Continue']");
	By accountRecordTypeLocator = By.xpath("//label[text()='Record Type of new record']/../following::select");
	
	
	
	/** Page Methods */

	public AccountsSelectRecordType verifyPageLoad()
	{
		pagelogger.debug("Waiting for page to load");
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}
	
	public AccountsEdit selectRecordType(String recordType)
	{
		pagelogger.debug("Selecting the Account Record Type: "  + recordType);
		
		SalesforcePageExtensions.waitForPageToLoad(driver);
		String id = getAttributeID(accountRecordTypeLocator);

		SalesforcePageExtensions.selectOption(driver, id, recordType);
		clickOnElement(continueLocator);

		return AccountsEdit.Instance;
	}

	public boolean verifyRecordTypeValues(String passedInOptions)
	{
		pagelogger.debug("Comparing Account select options with the passed in values: "				+ passedInOptions);
		boolean rtrn = false;

		List<String> foundOptions = SalesforcePageExtensions.returnSelectOptionsAsList(driver, accountRecordTypeLocator);
		
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
