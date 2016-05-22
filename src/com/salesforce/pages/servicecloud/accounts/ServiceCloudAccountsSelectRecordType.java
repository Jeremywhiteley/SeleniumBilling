package com.salesforce.pages.servicecloud.accounts;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;

public class ServiceCloudAccountsSelectRecordType extends PageBase
{

	private static ServiceCloudAccountsSelectRecordType instance;
	public static ServiceCloudAccountsSelectRecordType Instance = (instance != null) ? instance
			: new ServiceCloudAccountsSelectRecordType();

	/** UI Mappings */

	By recordTypeLocator = By
			.xpath("//td/label[contains(text(), 'Record Type')]/following::td[1]/div/select");
	By continueLocator = By.cssSelector("input[title='Continue']");
	By accountRecordTypeLocator = By
			.xpath("//label[text()='Record Type of new record']/../following::select");

	/** Page Methods */

	public ServiceCloudAccountsSelectRecordType verifyPageLoad()
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}

	public ServiceCloudAccountsSelectRecordType selectAccountRecordType(String filter)
	{

		pagelogger.debug("Selecting the Account Record Type filter: "+ filter);

		IframeUtils.setDriverContextToIframeWithDepth(driver, recordTypeLocator);

		String id = getAttributeID(recordTypeLocator);

		pagelogger.debug("The filter id is: "  + id);
		SalesforcePageExtensions.selectOption(driver, id, filter);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudAccountsEdit selectContinue()
	{
		IframeUtils.setDriverContextToIframeWithDepth(driver, continueLocator);

		pagelogger.debug("Selecting the continue button");

		clickOnElement(continueLocator);

		setDriverContextToPage(driver);

		return ServiceCloudAccountsEdit.Instance;
	}

}
