package com.salesforce.pages.servicecloud.leads;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class ServiceCloudLeadsSelectRecordType extends PageBase
{

	 
	private static ServiceCloudLeadsSelectRecordType instance ;
	public static ServiceCloudLeadsSelectRecordType Instance = (instance!=null)?instance:new ServiceCloudLeadsSelectRecordType();

	
	/**UI Mappings */

	public By recordTypeLocator = By.xpath("//label[contains(text(), 'Record Type')]/../..//select");
	public By continueLocator = By.cssSelector("input[title='Continue']");
	
	
	
	/**Page Methods*/

	public ServiceCloudLeadsSelectRecordType verifyRecordTypePageLoad()
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}
	
	
	public ServiceCloudLeadsEdit selectRecordType(String recordType)
	{
		pagelogger.debug("Selecting the lead record type: "  + recordType);
		
		IframeUtils.setDriverContextToIframeWithDepth(driver, recordTypeLocator);
		
		String id = getAttributeID(recordTypeLocator);
		
		SalesforcePageExtensions.selectOption(driver, id, recordType);
		clickOnElement(continueLocator);
		
		setDriverContextToPage(driver);
		return ServiceCloudLeadsEdit.Instance ;

	}
	
	
}
