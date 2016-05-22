package com.salesforce.pages.servicecloud.accounts;

import java.util.List;

import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;

public class ServiceCloudAccountsEdit extends PageBase
{

	private static ServiceCloudAccountsEdit instance;
	public static ServiceCloudAccountsEdit Instance = (instance != null) ? instance
			: new ServiceCloudAccountsEdit();

	/** UI Mappings */

	By lastNameLocator = By
			.xpath("//tr/td/label[text()='Last Name']/following::td[1]/descendant::input");
	By companyLocator = By
			.xpath("//tr/td/label[text()='Company']/following::td[1]/descendant::input");
	By saveButtonLocator = By.xpath("//input[@title='Save']");
	By accountTypeLocator = By
			.xpath("//tr/td/label[text()='Type']/following::td[1]/descendant::select");
	By accountNameLocator = By.xpath("//label[text()='Account Name']/../following::td//input");
	By parentAccountNameLocator = By
			.xpath("//label[contains(text(), 'Parent Account')]/../following::td//a");
	By accountOnSaveErrorMessage = By
			.xpath("//label[text()='Background check required']/../following::td//div[text()=' You must enter a value']");
	By backroundVerificationPicklist = By
			.xpath("//label[text()='Background check required']/../following::td//table//select");
	By lobPicklist = By.xpath("//label[text()='LOB']/../following::select");
	By domainPicklist = By.xpath("//label[text()='Domain']/../following::select");

	/** Page Methods */

	public ServiceCloudAccountsEdit verifyPageLoad()
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}

	public ServiceCloudAccountsEdit addAccountName(String accountName)
	{
		pagelogger.debug("Setting the Account name to: " + accountName);

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, accountNameLocator);

		findElement(accountNameLocator).sendKeys(accountName);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudAccountsEdit selectAccountsType(String status)
	{

		pagelogger.debug("Selecting the Account Type: " + status);

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, accountTypeLocator);

		String id = getAttributeID(accountTypeLocator);

		SalesforcePageExtensions.selectOption(driver, id, status);

		setDriverContextToPage(driver);
		return ServiceCloudAccountsEdit.Instance;
	}

	public List<String> getBackgroundCheckPicklistValues()
	{
		pagelogger.debug("Retrieving the background check picklist values!");

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, backroundVerificationPicklist);

		new WebDriverWait(driver, 30).until(ExpectedConditions
				.visibilityOfAllElementsLocatedBy(backroundVerificationPicklist));

		List<String> fields = SalesforcePageExtensions.returnSelectOptionsAsList(driver,
				backroundVerificationPicklist);
		setDriverContextToPage(driver);

		return fields;
	}

	public List<String> getLobPicklistValues()
	{
		pagelogger.debug("Retrieving the LOB picklist values!");

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, lobPicklist);
		List<String> fields = SalesforcePageExtensions.returnSelectOptionsAsList(driver,
				lobPicklist);
		setDriverContextToPage(driver);

		return fields;
	}

	public List<String> getDomainPicklistValues()
	{
		pagelogger.debug("Retrieving the Domain picklist values!");

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, domainPicklist);

		List<String> fields = SalesforcePageExtensions.returnSelectOptionsAsList(driver,
				domainPicklist);
		setDriverContextToPage(driver);
		fields.remove("--None--");

		return fields;
	}

	public boolean isSaveWithoutBackgroundInfoErrorMsgPresent()
	{

		pagelogger.debug("Checking to see if the background info error message is present!");

		boolean found = false;
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, accountOnSaveErrorMessage);

		try
		{
			new WebDriverWait(driver, 10).until(ExpectedConditions
					.visibilityOfAllElementsLocatedBy(accountOnSaveErrorMessage));

			findElement(accountOnSaveErrorMessage);
			found = true;
			setDriverContextToPage(driver);

			pagelogger.debug("The error message was found!");

		} catch (org.openqa.selenium.NoSuchElementException e)
		{

			pagelogger.debug("The error message was not found!");

			setDriverContextToPage(driver);
			return found;
		}

		return found;
	}

	public ServiceCloudAccountsDetail clickOnSaveButton()
	{
		pagelogger.debug("Clicking on the Save Button... ");

		IframeUtils.setDriverContextToIframeWithDepth(driver, saveButtonLocator);

		clickOnElement(saveButtonLocator);

		setDriverContextToPage(driver);
		return ServiceCloudAccountsDetail.Instance;
	}

	public ServiceCloudAccountsEdit editParentAccountName(String accountName)
			throws InterruptedException
	{

		pagelogger.debug("Editing the Parent Account name - setting it to: " + accountName);

		synchronize(30);
		new WebDriverWait(driver, 30).until(ExpectedConditions.titleContains(pageTitle));
		IframeUtils.setDriverContextToIframeWithDepth(driver, parentAccountNameLocator);

		String id = getAttributeID(parentAccountNameLocator);
		String mwh = driver.getWindowHandle();
		SalesforcePageExtensions.selectFromLookup(driver, accountName, mwh, id);

		setDriverContextToPage(driver);
		return this;
	}

}
