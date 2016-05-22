package com.salesforce.pages.servicecloud.opportunities;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class ServiceCloudOpportunitiesSelectRecordType extends PageBase
{

	 
	private static ServiceCloudOpportunitiesSelectRecordType instance ;
	public static ServiceCloudOpportunitiesSelectRecordType Instance = (instance!=null)?instance:new ServiceCloudOpportunitiesSelectRecordType();
	
	
	/**UI Mappings */

	public By recordTypeLocator = By.xpath("//label[contains(text(), 'Record Type')]/../..//select");
	public By continueLocator = By.cssSelector("input[title='Continue']");

	
	
	/**Page Methods */
	
	public ServiceCloudOpportunitiesSelectRecordType verifyRecordTypePageLoad()
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}

	public ServiceCloudOpportunitiesEdit selectRecordType(String recordType)
	{
		IframeUtils.setDriverContextToIframeWithDepth(driver, recordTypeLocator);

		pagelogger.debug("Selecting the case record type: "  + recordType);
		
		String id = getAttributeID(recordTypeLocator);
		
		SalesforcePageExtensions.selectOption(driver, id, recordType);
		
		clickOnElement(continueLocator);
		
		setDriverContextToPage(driver);
		return ServiceCloudOpportunitiesEdit.Instance ;
	}
	

	
}
