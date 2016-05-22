package com.salesforce.pages.servicecloud.contacts;

import java.util.List;
import java.util.Set;

import org.openqa.selenium.By;
import org.openqa.selenium.TimeoutException;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.CommonMethods;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class ServiceCloudContactsEdit extends PageBase 
{

	 
	private static ServiceCloudContactsEdit instance;
	public static ServiceCloudContactsEdit Instance = (instance != null) ? instance : new ServiceCloudContactsEdit();

	
	/** UI Mappings */

	By contactLastNameLocator = By.xpath("//td/label[text()='Last Name']/following::td[1]/descendant::input[1]");
	By emailLocator = By.xpath("//label[text()='Email']/../..//input ");
	By saveButtonLocator = By.xpath("//input[@name='save']");
	By accountNameLocator = By.xpath("//span/descendant::a[contains(@title,'Account Name')]");
	By contactTitleLocator = By.xpath("//label[text()='Title']/../..//td[@class='dataCol']/input");
	By leadSourceLocator = By.xpath("//td[contains(@class, 'labelCol')]/descendant::label[text()='Lead Source']/following::td[1]/descendant::select[1]");
	By contactTypeSelector = By.xpath("//option[@value='Employee']/../../select");
	By contactEditHeaderLocator = By.xpath("//h2[text()='Contact Edit']");
	
	
	/** Page Methods */

	public ServiceCloudContactsEdit verifyPageLoad() 
	{
		synchronize(30);
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}
	
	
	public boolean verifyPageLoadAsBoolean()
	{
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, contactEditHeaderLocator);
		
		try 
		{
			new WebDriverWait(driver, 30).until(ExpectedConditions.visibilityOfElementLocated(contactEditHeaderLocator));
			return true;
		} 
		catch (TimeoutException e) 
		{
		    return false;
		}
	}
	
	public ServiceCloudContactsEdit setLastName(String contactName) 
	{
		pagelogger.debug("Updating Contact Last Name to: "  + contactName);

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, contactLastNameLocator);

		new WebDriverWait(driver, 30).until(ExpectedConditions
				.visibilityOfElementLocated(contactLastNameLocator));

		findElement(contactLastNameLocator).clear();
		findElement(contactLastNameLocator).sendKeys(contactName);

		setDriverContextToPage(driver);
		return this;
	}
	
	public ServiceCloudContactsEdit setEmail(String email) 
	{
		pagelogger.debug("Updating Email id to: "  + email);

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, emailLocator);

		new WebDriverWait(driver, 30).until(ExpectedConditions
				.visibilityOfElementLocated(emailLocator));

		findElement(emailLocator).clear();
		findElement(emailLocator).sendKeys(email);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudContactsEdit setContactType(String contactType) 
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);
		
		IframeUtils.setDriverContextToIframeWithDepth(driver, contactTypeSelector);
		
		String id = getAttributeID(contactTypeSelector);
		SalesforcePageExtensions.selectOption(driver, id, contactType);
		
		setDriverContextToPage(driver);
		return this;
	}
	
	public ServiceCloudContactsEdit setLeadSource(String source) 
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);
		
		IframeUtils.setDriverContextToIframeWithDepth(driver, leadSourceLocator);
		
		String id = getAttributeID(leadSourceLocator);
		SalesforcePageExtensions.selectOption(driver, id, source);
		
		setDriverContextToPage(driver);
		return this;
	}
	
	public ServiceCloudContactsEdit setContactTitle(String title) 
	{
		pagelogger.debug("Updating Contact Title to: "  + title);
		
		IframeUtils.setDriverContextToIframeWithDepth(driver, contactTitleLocator);
		
		String selectid = getAttributeID(contactTitleLocator);
		SalesforcePageExtensions.enterInputValue(driver, selectid, title);

		setDriverContextToPage(driver);
		return this;
	}

	
	public ServiceCloudContactsDetail clickOnSave() 
	{
		pagelogger.debug("Clicking on Save...");

		IframeUtils.setDriverContextToIframeWithDepth(driver, saveButtonLocator);

		clickOnElement(saveButtonLocator);
		
		setDriverContextToPage(driver);
		return ServiceCloudContactsDetail.Instance;
	}

	
	public ServiceCloudContactsEdit setAccountName(String accountName) throws InterruptedException 
	{
		pagelogger.debug("Setting Account Name to: "  + accountName);
		
		IframeUtils.setDriverContextToIframeWithDepth(driver, accountNameLocator);

		String id = getAttributeID(accountNameLocator);
		String mwh = driver.getWindowHandle();
		SalesforcePageExtensions.selectFromLookup(driver, accountName, mwh, id);

		setDriverContextToPage(driver);
		return this;
	}

	public boolean verifyLeadSourceOptions(String passedInOptions) 
	{
		boolean rtrn = false;

		pagelogger.debug("Comparing Lead Source select options with the passed in values: "						+ passedInOptions);

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, leadSourceLocator);

		List<String> foundOptions = SalesforcePageExtensions.returnSelectOptionsAsList(driver, leadSourceLocator);
		
		pagelogger.debug("Found the following options on the page:"  + foundOptions.toString());
		
		String[] foundOptionsArray = (String[]) foundOptions.toArray();
		String[] passedInOptionsAsArray = passedInOptions.split(",");
		Set<String> fieldDifference = CommonMethods.getArrayDifference(passedInOptionsAsArray, foundOptionsArray);

		if (fieldDifference.size() == 0) 
		{
			pagelogger.debug("No differences were found between the passed in options and the found options");
			rtrn = true;
		} 
		else 
		{
			pagelogger.debug("Differences were found between the passed in options and found options: "							+ fieldDifference.toString());
		}

		return rtrn;
	}

	
}

