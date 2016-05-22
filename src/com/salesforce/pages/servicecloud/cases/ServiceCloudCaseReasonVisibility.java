package com.salesforce.pages.servicecloud.cases;

import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class ServiceCloudCaseReasonVisibility extends PageBase 
{

	 
	private static ServiceCloudCaseReasonVisibility instance;
	public static ServiceCloudCaseReasonVisibility Instance = (instance != null) ? instance : new ServiceCloudCaseReasonVisibility();

	
	/** UI Mappings */

	By userTypeLocator = By.xpath(" //span[contains(text(),'Select a user type')]/select");
	By continueLocator = By.cssSelector("input[title='Continue']");
	By recordTypeOptionLocator = By.xpath("//label[contains(text(), 'Record Type')]/../..//select/option");
	By loadingIcon = By.xpath(" //span[contains(@id,'loadingStatus.start') and contains(@style,'display: none')] ");
	String caseReasonCheckBoxChecked = "//a[text()='{Reason}' and contains(@class,'clicked')]/i";
	String caseReasonCheckBoxUnChecked = "//a[text()='{Reason}'][not(contains(@class,'clicked'))]/i";
	By caseReasonUpdate = By.xpath("//input[contains(@value,'Update Request Reason Visibility')]");
	By selectAllButton = By.xpath("//input[@value='Select All']");

	
	/** Page Methods */

	public ServiceCloudCaseReasonVisibility selectUserType(String userType) 
	{
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, userTypeLocator);

		pagelogger.debug("Selecting the user type: "  + userType);

		SalesforcePageExtensions.selectOption(driver,
				"//span[contains(text(),'Select a user type')]/select",
				userType);

		setDriverContextToPage(driver);

		return this;
	}
	

	public ServiceCloudCaseReasonVisibility waitForLoaderToComplete() 
	{
		synchronize(30);
		new WebDriverWait(driver, 10).until(ExpectedConditions.presenceOfElementLocated(loadingIcon));
		return this;
	}
	

	public ServiceCloudCaseReasonVisibility clickOnCaseReasonToCheck(String caseReason) 
	{
		pagelogger.debug("Clicking on reason to select");
		
		IframeUtils.setDriverContextToIframeWithDepth(driver, userTypeLocator);
		String caseReasonChkBoxUnChecked = caseReasonCheckBoxUnChecked.replace("{Reason}", caseReason);
		String caseReasonChkBoxChecked = caseReasonCheckBoxChecked.replace("{Reason}", caseReason);
		
		try 
		{
			clickOnElement(By.xpath(caseReasonChkBoxUnChecked));
		} 
		catch (NoSuchElementException e) 
		{
			pagelogger.debug("Case Reason Already selected or not found");
		}
		
		try 
		{
			findElement(By.xpath(caseReasonChkBoxChecked));
		} catch (NoSuchElementException e) {
			pagelogger.debug("Selected Case Reason not found. Case Might fail");
		}
		
		setDriverContextToPage(driver);
		return this;
	}
	

	public ServiceCloudCaseReasonVisibility clickOnCaseReasonToUnCheck(String caseReason) 
	{
		pagelogger.debug("Clicking on reason to select");
		
		IframeUtils.setDriverContextToIframeWithDepth(driver, userTypeLocator);
		String caseReasonChkBoxUnChecked = caseReasonCheckBoxUnChecked.replace(
				"{Reason}", caseReason);
		String caseReasonChkBoxChecked = caseReasonCheckBoxChecked.replace(
				"{Reason}", caseReason);
		
		try 
		{
			clickOnElement(By.xpath(caseReasonChkBoxChecked));
		} 
		catch (NoSuchElementException e) 
		{
			pagelogger.debug("Case Reason Already unselected or not found");
		}
		
		try 
		{
			findElement(By.xpath(caseReasonChkBoxUnChecked));
		} 
		catch (NoSuchElementException e) 
		{
			pagelogger.debug("UnSelected Case Reason not found. Case Might fail");
		}
		
		setDriverContextToPage(driver);
		return this;
		
	}

	
	public ServiceCloudCaseReasonVisibility clickOnUpdateCaseReasonVisibilityButton() 
	{
		IframeUtils.setDriverContextToIframeWithDepth(driver, caseReasonUpdate);

		pagelogger.debug("Clicking on the Update case reason Visibility button...");

		clickOnElement(caseReasonUpdate);
		setDriverContextToPage(driver);

		return this;
	}

	
	public ServiceCloudCaseReasonVisibility clickOnSelectAllButton() 
	{
		IframeUtils.setDriverContextToIframeWithDepth(driver, selectAllButton);

		pagelogger.debug("Clicking on the Select All button...");

		clickOnElement(selectAllButton);
		setDriverContextToPage(driver);

		return this;
	}
	

	public boolean verifyIfAllReasonsSelected() 
	{
		pagelogger.debug("Verifing that all case reasons are selected after clicking select All.");

		synchronize(30);
		new WebDriverWait(driver, 30).until(ExpectedConditions.titleContains(pageTitle));
		
		By targetContactNameLocator = By.xpath("//a[@class='jstree-anchor']");
		String idOfCaseRecord = IframeUtils.setDriverContextToIframeWithDepth(driver,targetContactNameLocator);
		
		if (idOfCaseRecord.isEmpty()) 
		{
			return true;
		} 
		else
		{
			return false;
		}
		
	}

	
	public ServiceCloudCaseReasonVisibility verifyRecordTypePageLoad() 
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}

	
}
