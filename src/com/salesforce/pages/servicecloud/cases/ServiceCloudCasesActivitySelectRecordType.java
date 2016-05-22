package com.salesforce.pages.servicecloud.cases;

import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.pages.servicecloud.activities.ServiceCloudActivityEdit;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;
import com.salesforce.utils.driver.VerifyPageElementsExtensions;


public class ServiceCloudCasesActivitySelectRecordType extends PageBase 
{

	 
	private static ServiceCloudCasesActivitySelectRecordType instance;
	public static ServiceCloudCasesActivitySelectRecordType Instance = (instance != null) ? instance : new ServiceCloudCasesActivitySelectRecordType();

	
	/** UI Mappings */

	By recordTypeLocator = By.xpath("//label[contains(text(), 'Record Type')]/../..//select");
	By continueLocator = By.cssSelector("input[title='Continue']");
	By recordTypeOptionLocator = By.xpath("//label[contains(text(), 'Record Type')]/../..//select/option");

	
	
	/** Page Methods */

	public ServiceCloudActivityEdit selectRecordType(String recordType) 
	{
		IframeUtils.setDriverContextToIframeWithDepth(driver, recordTypeLocator);

		pagelogger.debug("Selecting the case record type: "  + recordType);

		String id = getAttributeID(recordTypeLocator);
		SalesforcePageExtensions.selectOption(driver, id, recordType);

		clickOnElement(continueLocator);

		setDriverContextToPage(driver);

		return ServiceCloudActivityEdit.Instance;
	}

	
	public boolean verifyNewActivityRecordTypeOptions(String[] options) 
	{
		return VerifyPageElementsExtensions.verifySelectOptions(driver, recordTypeLocator, options);
	}

	
	public boolean verifyIfOnlyASingleOptionIsPresent() 
	{
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, recordTypeLocator);

		new WebDriverWait(driver, 10).until(ExpectedConditions
				.visibilityOfElementLocated(recordTypeLocator));

		if (findElements(recordTypeOptionLocator).size() > 1) {
			return false;
		}
		return true;
	}
	

	public ServiceCloudCasesActivitySelectRecordType verifyRecordTypePageLoad() 
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}
	
	

}
