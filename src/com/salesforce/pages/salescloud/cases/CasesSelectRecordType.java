package com.salesforce.pages.salescloud.cases;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class CasesSelectRecordType extends PageBase
{

	 
	private static CasesSelectRecordType instance;
	public static CasesSelectRecordType Instance = (instance != null) ? instance : new CasesSelectRecordType();

	
	/** UI Mappings */

	public By recordTypeLocator = By.xpath("//td/label[contains(text(), 'Record Type')]/following::td[1]/div/select");
	public By continueLocator = By.cssSelector("input[title='Continue']");
	
	
	
	/** Page Methods */

	public CasesEdit selectRecordType(String recordType)
	{
		pagelogger.debug("Selecting the case record type: "  + recordType);

		String id = getAttributeID(recordTypeLocator);
		SalesforcePageExtensions.selectOption(driver, id, recordType);
		clickOnElement(continueLocator);

		return CasesEdit.Instance;
	}
}
