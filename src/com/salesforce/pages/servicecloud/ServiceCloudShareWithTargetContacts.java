package com.salesforce.pages.servicecloud;

import java.util.concurrent.TimeUnit;

import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.pages.servicecloud.cases.ServiceCloudCasesDetail;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class ServiceCloudShareWithTargetContacts extends PageBase 
{

	 
	private static ServiceCloudShareWithTargetContacts instance;
	public static ServiceCloudShareWithTargetContacts Instance = (instance != null) ? instance : new ServiceCloudShareWithTargetContacts();

	
	/** UI Mappings */
	By contactNameLocator = By.xpath("//label[text()='Contact']/../following::td//a");
	By updateSharingButtonLocator = By.xpath("//input[@value='Update Sharing']");
	String shareContactUser = "//span[contains(text(),'Select a contact')]/select";

	
	/** Page Methods */

	public ServiceCloudShareWithTargetContacts verifyPageLoad() 
	{
		synchronize(30);
		SalesforcePageExtensions.waitForPageToLoad(driver);
		
		return this;
	}

	
	public ServiceCloudShareWithTargetContacts selectUserToShare(String user) 
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);
		IframeUtils.setDriverContextToIframeWithDepth(driver,By.xpath(shareContactUser));
		SalesforcePageExtensions.selectOption(driver, shareContactUser, user);
		
		setDriverContextToPage(driver);
		return this;
	}

	
	public ServiceCloudShareWithTargetContacts checkCasesCheckbox(String caseNo) 
	{
		pagelogger.debug("Click Case to share");
		driver.manage().timeouts().implicitlyWait(3, TimeUnit.SECONDS);
		
		By caseChkBox = By.xpath("//span[contains(text(),'Select a contact')]/..//td[contains(text(),'"
						+ caseNo + "')]/..//input");
		
		IframeUtils.setDriverContextToIframeWithDepth(driver, caseChkBox);

		if (!findElement(caseChkBox).isSelected()) 
		{
			clickOnElement(caseChkBox);
		}
		else 
		{
			pagelogger.debug("The case checkbox was already checked!");
		}
		
		setDriverContextToPage(driver);
		return this;
	}

	
	public ServiceCloudShareWithTargetContacts unCheckCasesCheckbox(String caseNo) 
	{
		pagelogger.debug("Uncheck Case to share");
		
		driver.manage().timeouts().implicitlyWait(3, TimeUnit.SECONDS);
		By caseChkBox = By.xpath("//span[contains(text(),'Select a contact')]/..//td[contains(text(),'"
						+ caseNo + "')]/..//input");
		
		IframeUtils.setDriverContextToIframeWithDepth(driver, caseChkBox);

		if (findElement(caseChkBox).isSelected()) 
		{
			clickOnElement(caseChkBox);
		} 
		else 
		{
			pagelogger.debug("The case checkbox was already unchecked!");
		}
		
		setDriverContextToPage(driver);
		return this;
	}

	
	public ServiceCloudShareWithTargetContacts checkActivityCheckbox(String activityNo) 
	{
		pagelogger.debug("Click Activity to share");
		
		driver.manage().timeouts().implicitlyWait(3, TimeUnit.SECONDS);
		By activityChkBox = By.xpath("//div[contains(text(),'" + activityNo+ "')]/../../td/input");
		
		IframeUtils.setDriverContextToIframeWithDepth(driver, activityChkBox);

		if (!findElement(activityChkBox).isSelected()) 
		{
			clickOnElement(activityChkBox);
		} 
		else 
		{
			pagelogger.debug("The Activity checkbox was already checked!");
		}
		
		setDriverContextToPage(driver);
		return this;
	}

	
	public ServiceCloudShareWithTargetContacts EditContactName(String contactName) throws InterruptedException
	{
		new WebDriverWait(driver, 30).until(ExpectedConditions.titleContains(pageTitle));
		
		IframeUtils.setDriverContextToIframeWithDepth(driver, contactNameLocator);
		
		String id = getAttributeID(contactNameLocator);
		String mwh = driver.getWindowHandle();
		SalesforcePageExtensions.selectFromLookup(driver, contactName, mwh, id);
	
		setDriverContextToPage(driver);
		return this;
	}

	
	public ServiceCloudCasesDetail clickOnUpdateSharing() 
	{
		IframeUtils.setDriverContextToIframeWithDepth(driver,updateSharingButtonLocator);

		clickOnElement(updateSharingButtonLocator);
		By successMessage = By.xpath("//div[contains(text(),'Internal Sharing has successfully been updated.')]");
		
		setDriverContextToPage(driver);
		IframeUtils.setDriverContextToIframeWithDepth(driver, successMessage);
		
		return ServiceCloudCasesDetail.Instance;
	}
	

}
