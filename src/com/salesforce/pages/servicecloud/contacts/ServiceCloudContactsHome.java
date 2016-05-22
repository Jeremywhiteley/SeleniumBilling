package com.salesforce.pages.servicecloud.contacts;

import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class ServiceCloudContactsHome extends PageBase 
{

	 
	private static ServiceCloudContactsHome instance;
	public static ServiceCloudContactsHome Instance = (instance != null) ? instance : new ServiceCloudContactsHome();
	
	
	/** UI Mappings */
	
	By contactFilterLocator = By.xpath("//div[@class='controls']/select");
	By newContactButtonLocator = By.xpath("//input[contains(@title,'New')]");
	By refreshButtonLocator = By.cssSelector("input[title='Refresh']");
	By closecaseButton = By.xpath("//input[@title='Close']");
	By caseNumberLocator = By.xpath("//div[@title='Case Number']");
	By closeCaseLabel = By.xpath("//h1[text()='Close Case']");
	By changeOwnerButton = By.xpath("//input[@title='Change Owner']");
	By changeStatusButton = By.xpath("//input[@title='Change Status']");
	String statusOfACase = "//a[text()='case_number']/../../..//div[contains(@id,'CASES_STATUS')]";
	String ownerOfACase = "//a[text()='case_number']/../../..//div[contains(@id,'CASES_STATUS')]";
	String editCase = "//a[text()='case_number']/../../..//span[text()='Del']";
	String delCase = "//a[text()='case_number']/../../..//span[text()='Edit']";
	By goButton = By.xpath("//span/input[contains(@value,'Go')]");
	
	
	/** Page Methods */

	public ServiceCloudContactsHome verifyPageLoad() 
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}

	
	public void setURL(String url) 
	{
		URL = url;
	}

	
	public ServiceCloudContactsDetail selectFromContactTable(String contact) 
	{
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, refreshButtonLocator);

		SalesforcePageExtensions.selectFromRecordTable(driver, contact);

		setDriverContextToPage(driver);

		return ServiceCloudContactsDetail.Instance;
	}

	
	public void ClickOnDeleteCase(String caseNumber) 
	{
		IframeUtils.setDriverContextToIframeWithDepth(driver, refreshButtonLocator);
		
		String delCaseLocator = delCase.replace("case_number", caseNumber);
		clickOnElement(By.xpath((delCaseLocator)));
		
		SalesforcePageExtensions.acceptModalDialog(driver);
		
		setDriverContextToPage(driver);
	}

	
	public void ClickOnEditCase(String caseNumber) 
	{
		IframeUtils.setDriverContextToIframeWithDepth(driver, refreshButtonLocator);
		
		String editCaseLocator = editCase.replace("case_number", caseNumber);
		clickOnElement(By.xpath((editCaseLocator)));
		
		setDriverContextToPage(driver);
	}

	
	public ServiceCloudContactsEdit clickOnNewContact() 
	{
		IframeUtils.setDriverContextToIframeWithDepth(driver, newContactButtonLocator);
		
		clickOnElement(newContactButtonLocator);
		setDriverContextToPage(driver);
		
		return ServiceCloudContactsEdit.Instance;
	}
	

	public ServiceCloudContactsHome filterContactTableByLetter(String filter)
	{
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, newContactButtonLocator);

		pagelogger.debug("Sorting Contact table by: "  + filter);

		SalesforcePageExtensions.sortRecordTableByLetter(driver, filter);

		setDriverContextToPage(driver);
		return this;
	}
	
	
	public ServiceCloudContactsHome selectContactFilter(String filter) 
	{
		pagelogger.debug("Selecting the contact filter: "  + filter);
		
		IframeUtils.setDriverContextToIframeWithDepth(driver, contactFilterLocator);
		
		String id = getAttributeID(contactFilterLocator);
		pagelogger.debug("The filter id is: "+ id);
		SalesforcePageExtensions.selectOption(driver, id, filter);
		
		try 
		{
			clickOnElement(goButton);
		} 
		catch (NoSuchElementException e) 
		{
			pagelogger.debug("Go Button not found. Page might not load as expected. "+ id);
		}
	
		setDriverContextToPage(driver);
		return this;
	}
	
}
