package com.salesforce.pages.servicecloud.cases;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;
import com.salesforce.utils.driver.VerifyPageElementsExtensions;


public class ServiceCloudCloseCase extends PageBase
{

	 
	private static ServiceCloudCloseCase instance ;
	public static ServiceCloudCloseCase Instance= (instance!=null)?instance:new ServiceCloudCloseCase();
	
	
	/** UI Mappings */

	public By caseStatusErrorMsg = By.xpath("//label[contains(text(),'Status')]/../..//div[@class='errorMsg']");
	public By caseResolutionErrorMsg = By.xpath("//label[text()='Request Resolution']/../..//div[@class='errorMsg']");
	public By caseResolutionTypeErrorMsg = By.xpath("//label[contains(text(),'Request Resolution Type')]/../..//div[@class='errorMsg']");
	public By caseStatusOptionLocator = By.xpath("//label[contains(text(),'Status')]/../..//select");
	public By caseReasonOptionLocator = By.xpath("//select[@name='reason']");
	public By caseResolutionTypeLocator = By.xpath("//label[contains(text(),'Request Resolution Type')]/../..//select");
	public By caseResolutionText = By.xpath("//label[contains(text(),'Request Resolution')]/../..//textarea");
	By saveButtonLocator = By.xpath("//label[text()='Case Reason']/../../../../../following::div//input[@title='Save']");
	By closeCaseErrorText = By.xpath("//div[contains(@id,'errorDiv')]");
	
	
	
	/** Page Methods */

	public boolean isCloseCaseErrorMsgPresent(String expectedErrorMsg) 
	{
		pagelogger.debug("Checking to see if the following Upsert Error Message is present: "						+ expectedErrorMsg);

		boolean found = false;
		synchronize(30);
		
		IframeUtils.setDriverContextToIframeWithDepth(driver, closeCaseErrorText);
		
		try 
		{
			String errorMsg = findElement(closeCaseErrorText).getText();
			
			if (errorMsg.contains(expectedErrorMsg)) 
			{
				found = true;
				setDriverContextToPage(driver);
			}
		} 
		catch (org.openqa.selenium.NoSuchElementException e) 
		{
			setDriverContextToPage(driver);
			return found;
		}
		
		return found;
	}
	
	
	public ServiceCloudCloseCase setCaseClosingStatus(String closeStatus)
	{	
		pagelogger.debug("Setting the Case Closing Status: "  + closeStatus);

		SalesforcePageExtensions.waitForPageToLoad(driver);
		
		IframeUtils.setDriverContextToIframeWithDepth(driver, caseStatusOptionLocator);
		
		String id = getAttributeID(caseStatusOptionLocator);
		SalesforcePageExtensions.selectOption(driver, id, closeStatus);		
		
		setDriverContextToPage(driver);
		return this;
	}
	
	
	public ServiceCloudCloseCase setCaseResolutionType(String resolutionType)
	{
		pagelogger.debug("Setting the Case Resolution Type: "  + resolutionType);

		SalesforcePageExtensions.waitForPageToLoad(driver);
		IframeUtils.setDriverContextToIframeWithDepth(driver, caseResolutionTypeLocator);
		
		String id = getAttributeID(caseResolutionTypeLocator);
		SalesforcePageExtensions.selectOption(driver, id, resolutionType);		
		
		setDriverContextToPage(driver);
		return this;
	}
	
	
	public ServiceCloudCloseCase setCaseResolutionText(String caseResolution)
	{
		
		pagelogger.debug("Setting the Case Resolution text: "  + caseResolution);

		synchronize(30);
		
		IframeUtils.setDriverContextToIframeWithDepth(driver, caseResolutionText);
		
		findElement(caseResolutionText).sendKeys(caseResolution);
    	
		setDriverContextToPage(driver);
		return this;
	}
	
	 public boolean verifyCaseResolutionTypeOptions(String[] options)
	 {
		 
		 pagelogger.debug("Verifying the select options for Case Resolution Type!");
		 
		 return VerifyPageElementsExtensions.verifySelectOptions(driver, caseResolutionTypeLocator, options);
	 }
	 
	 
	 public boolean isCaseStatusErrorMsgPresent()
	 {
		pagelogger.debug("Checking to see if the Case Status error is present!");

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, caseStatusErrorMsg);
			
		try
		{
			findElements(caseStatusErrorMsg);
			setDriverContextToPage(driver);
			return true;
		}
		catch(org.openqa.selenium.NoSuchElementException e)
		{
			setDriverContextToPage(driver);
			return false;
		}
			
	 }
	 
	 
	 public boolean isCaseResolutionErrorMsgPresent()
	 { 
		pagelogger.debug("Checking to see if the Case Resolution error is present!");

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, caseResolutionErrorMsg);
			
		try
		{
			findElements(caseResolutionErrorMsg);
			setDriverContextToPage(driver);
			return true;
		}
		catch(org.openqa.selenium.NoSuchElementException e)
		{
			setDriverContextToPage(driver);
			return false;
		}
			
	 }
	 
	 
	 public boolean isCaseResolutionTypeErrorMsgPresent()
	 {
		pagelogger.debug("Checking to see if the Case Resolution Type error is present!");

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, caseResolutionTypeErrorMsg);
			
		try
		{
			findElements(caseResolutionTypeErrorMsg);
			setDriverContextToPage(driver);
			return true;
		}
		catch(org.openqa.selenium.NoSuchElementException e)
		{
			setDriverContextToPage(driver);
			return false;
		}
			
	 }
	 
	 
	 public ServiceCloudCasesDetail clickOnSaveButton()
	 {
		pagelogger.debug("Clicking on the Save button!");

		IframeUtils.setDriverContextToIframeWithDepth(driver, saveButtonLocator);
		
		clickOnElement(saveButtonLocator);
    	
    	setDriverContextToPage(driver);
    	return ServiceCloudCasesDetail.Instance;
	 }
	 
	
	public ServiceCloudCloseCase setCaseCloseReason(String closeReason)
	{
		
		pagelogger.debug("Selecting the Case Close Reason: "  + closeReason);

		SalesforcePageExtensions.waitForPageToLoad(driver);
		IframeUtils.setDriverContextToIframeWithDepth(driver, caseReasonOptionLocator);
		String id = getAttributeID(caseReasonOptionLocator);
		SalesforcePageExtensions.selectOption(driver, id, closeReason);	
		
		return this;
	}
	
	
}