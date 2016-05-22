package com.salesforce.pages.servicecloud.cases;

import java.util.List;

import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class ServiceCloudCasesSelectRecordType extends PageBase 
{

	 
	private static ServiceCloudCasesSelectRecordType instance;
	public static ServiceCloudCasesSelectRecordType Instance = (instance != null) ? instance : new ServiceCloudCasesSelectRecordType();

	
	/** UI Mappings */

	public By recordTypeLocator = By.xpath("//label[contains(text(), 'Record Type')]/../..//select");
	public By continueLocator = By.cssSelector("input[title='Continue']");

	
	/** Page Methods */

	public ServiceCloudCasesEdit selectRecordType(String recordType) 
	{
		pagelogger.debug("Selecting the Case Record Type: "  + recordType);

		synchronize(30);

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
		return ServiceCloudCasesEdit.Instance;
	}

	
	public List<String> getRecordTypeValuesAsList() 
	{
		synchronize(30);
		SalesforcePageExtensions.waitForPageToLoad(driver);
		
		IframeUtils.setDriverContextToIframeWithDepth(driver, recordTypeLocator);
		
		new WebDriverWait(driver, 30).until(ExpectedConditions
				.visibilityOfAllElementsLocatedBy(recordTypeLocator));
		
		List<String> pickListValues = SalesforcePageExtensions.returnSelectOptionsAsList(driver, recordTypeLocator);
		pickListValues.remove("--None--");
		
		setDriverContextToPage(driver);
		return pickListValues;
	}
	

	public ServiceCloudCasesSelectRecordType verifyRecordTypePageLoad() 
	{
		synchronize(30);
		
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}

	
}
