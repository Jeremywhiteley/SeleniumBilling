package com.salesforce.pages.salescloud.tasks;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class TaskSelectRecordType extends PageBase
{

	 
	private static TaskSelectRecordType instance;
	public static TaskSelectRecordType Instance = (instance != null) ? instance : new TaskSelectRecordType();

	
	/** UI Mappings */

	By recordTypeLocator = By.xpath("//td/label[contains(text(), 'Record Type')]/following::td[1]/div/select");
	By continueButtonLocator = By.cssSelector("Input[title='Continue']");

	
	
	/** Page Methods */

	public TaskEdit selectRecordType(String recordType)
	{

		String id = getAttributeID(recordTypeLocator);

		pagelogger.debug("Selecting the account record type: "  + recordType);

		SalesforcePageExtensions.selectOption(driver, id, recordType);
		clickOnElement(continueButtonLocator);
		return TaskEdit.Instance;
	}

}
