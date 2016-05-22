package com.salesforce.pages.servicecloud;

import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.pages.servicecloud.cases.ServiceCloudCasesDetail;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class ServiceCloudTargetContactsEdit extends PageBase 
{

	 
	private static ServiceCloudTargetContactsEdit instance;
	public static ServiceCloudTargetContactsEdit Instance = (instance != null) ? instance : new ServiceCloudTargetContactsEdit();
	
	
	/** UI Mappings */

	By contactNameLocator = By.xpath("//label[text()='Contact']/../following::td//a");
	By saveButtonLocator = By.xpath("//input[@title='Save']");
	
	
	/** Page Methods */

	public ServiceCloudTargetContactsEdit verifyPageLoad()
	{
		synchronize(30);
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}

	
	public ServiceCloudTargetContactsEdit editContactName(String contactName) throws InterruptedException 
	{
		new WebDriverWait(driver, 30).until(ExpectedConditions.titleContains(pageTitle));
		
		IframeUtils.setDriverContextToIframeWithDepth(driver, contactNameLocator);
		
		String id = getAttributeID(contactNameLocator);
		String mwh = driver.getWindowHandle();
		SalesforcePageExtensions.selectFromLookup(driver, contactName, mwh, id);
	
		setDriverContextToPage(driver);
		return this;
	}


	public ServiceCloudCasesDetail clickOnSave() 
	{
		IframeUtils.setDriverContextToIframeWithDepth(driver, saveButtonLocator);

		clickOnElement(saveButtonLocator);

		setDriverContextToPage(driver);
		return ServiceCloudCasesDetail.Instance;
	}

	
}
