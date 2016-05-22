package com.salesforce.pages.servicecloud.cases;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class ServiceCloudCasesChangeStatus extends PageBase 
{

	 
	private static ServiceCloudCasesChangeStatus instance;
	public static ServiceCloudCasesChangeStatus Instance = (instance != null) ? instance : new ServiceCloudCasesChangeStatus();
	
	
	/** UI Mappings */

	By caseNewStatusSelectLocator = By.xpath("//select[@name='status']");
	By changeCaseStatusLabel = By.xpath("//h1[text()='Change Request Status']");
	By saveButtonLocator = By.xpath("//input[@name='save']");
	
	
	
	/** Page Methods */

	public ServiceCloudCasesChangeStatus verifyPageLoad()
	{
		synchronize(30);
		SalesforcePageExtensions.waitForPageToLoad(driver);

		return this;
	}
	
	public ServiceCloudCasesChangeStatus setCaseStatus(String newCaseStatus) 
	{
		pagelogger.debug("Setting the Case Status to: "  + newCaseStatus);
		
		IframeUtils.setDriverContextToIframeWithDepth(driver,caseNewStatusSelectLocator);

		String id = getAttributeID(caseNewStatusSelectLocator);
		SalesforcePageExtensions.selectOption(driver, id, newCaseStatus);
		
		setDriverContextToPage(driver);
		return this;
	}
	
	
	public ServiceCloudCasesHome clickOnSaveButton()
	{
		pagelogger.debug("Clicking on the Save button...");

		IframeUtils.setDriverContextToIframeWithDepth(driver, saveButtonLocator);
		
		clickOnElement(saveButtonLocator);

		setDriverContextToPage(driver);
		return ServiceCloudCasesHome.Instance;
	}

	
}
