package com.salesforce.pages.servicecloud.contacts;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class ServiceCloudContactsSelectRecordType extends PageBase 
{

	 
	private static ServiceCloudContactsSelectRecordType instance;
	public static ServiceCloudContactsSelectRecordType Instance = (instance != null) ? instance : new ServiceCloudContactsSelectRecordType();
	
	
	
	/** UI Mappings */

	public By recordTypeLocator = By.xpath("//label[contains(text(), 'Record Type')]/../..//select");
	public By continueLocator = By.cssSelector("input[title='Continue']");

	
	
	/** Page Methods */

	public ServiceCloudContactsEdit selectRecordType(String recordType) 
	{
		pagelogger.debug("Selecting the case record type: "  + recordType);

		try 
		{
			IframeUtils.setDriverContextToIframeWithDepth(driver, recordTypeLocator);
			String id = getAttributeID(recordTypeLocator);

			SalesforcePageExtensions.selectOption(driver, id, recordType);
			clickOnElement(continueLocator);
		} 
		catch (Exception e) 
		{
			pagelogger.debug("Record Type is not found for this environment. Will try to skip this and try.");
		}
		
		setDriverContextToPage(driver);
		return ServiceCloudContactsEdit.Instance;
	}

	
	public ServiceCloudContactsSelectRecordType verifyPageLoad() 
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}

}
