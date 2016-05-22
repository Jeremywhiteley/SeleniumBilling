package com.salesforce.pages.servicecloud.activities;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class ServiceCloudActivitySelectRecordType extends PageBase
{

	 
	private static ServiceCloudActivitySelectRecordType instance;
	public static ServiceCloudActivitySelectRecordType Instance = (instance != null) ? instance : new ServiceCloudActivitySelectRecordType();


	
	/** UI Mappings */

	By recordTypeLocator = By.xpath("//td/label[contains(text(), 'Record Type')]/following::td[1]/div/select");
	By continueLocator = By.cssSelector("input[title='Continue']");
	By accountRecordTypeLocator = By.xpath("//label[text()='Record Type of new record']/../following::select");

	
	
	/** Page Methods */

	public void verifyPageLoad()
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);
	}

	public ServiceCloudActivitySelectRecordType selectActivityFilter(String filter)
	{
		IframeUtils.setDriverContextToIframeWithDepth(driver, recordTypeLocator);

		pagelogger.debug("Selecting the type filter: "  + filter);

		String id = getAttributeID(recordTypeLocator);

		pagelogger.debug("The filter id is: "  + id);
		SalesforcePageExtensions.selectOption(driver, id, filter);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudActivityEdit selectActivity()
	{
		IframeUtils.setDriverContextToIframeWithDepth(driver, continueLocator);

		pagelogger.debug("Selecting continue (record type)");

		clickOnElement(continueLocator);

		setDriverContextToPage(driver);

		return ServiceCloudActivityEdit.Instance;
	}

}
