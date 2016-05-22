package com.salesforce.pages.servicecloud.questions;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class ServiceCloudQuestionsSelectRecordType extends PageBase
{

	 
	private static ServiceCloudQuestionsSelectRecordType instance ;
	public static ServiceCloudQuestionsSelectRecordType Instance = (instance!=null)?instance:new ServiceCloudQuestionsSelectRecordType();

	
	/**UI Mappings */

	public By recordTypeLocator = By.xpath("//tr/td/label[text()='Zone']/following::td[1]/descendant::select[1]");
	public By continueLocator = By.cssSelector("input[title='Continue']");

	
	
	/**Page Methods */
	
	public ServiceCloudQuestionsSelectRecordType verifyRecordTypePageLoad()
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}

	
	public ServiceCloudQuestionsEdit selectRecordType(String recordType)
	{
		IframeUtils.setDriverContextToIframeWithDepth(driver, recordTypeLocator);

		pagelogger.debug("Selecting the case record type: "  + recordType);
		
		String id = getAttributeID(recordTypeLocator);
		
		SalesforcePageExtensions.selectOption(driver, id, recordType);
		
		clickOnElement(continueLocator);
		
		setDriverContextToPage(driver);
		return ServiceCloudQuestionsEdit.Instance ;
	}
	

	
}
