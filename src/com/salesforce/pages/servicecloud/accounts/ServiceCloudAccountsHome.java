package com.salesforce.pages.servicecloud.accounts;

import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;

public class ServiceCloudAccountsHome extends PageBase
{

	private static ServiceCloudAccountsHome instance;
	public static ServiceCloudAccountsHome Instance = (instance != null) ? instance
			: new ServiceCloudAccountsHome();

	/** UI Mappings */

	By accountFilterLocator = By.xpath("//div[@class='controls']/select");
	By newAccountButtonLocator = By.xpath("//input[contains(@title,'New')]");
	By followButtonLocator = By.cssSelector("input[title='Follow']");
	By mapAccountsButtonLocator = By.cssSelector("input[title='Map Accounts']");
	By refreshButtonLocator = By.cssSelector("input[title='Refresh']");

	/** Page Methods */

	public ServiceCloudAccountsHome verifyPageLoad()
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);
		synchronize(30);
		return this;
	}

	public ServiceCloudAccountsHome selectAccountFilter(String filter)
	{
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, refreshButtonLocator);

		pagelogger.debug("Selecting the Account filter: " + filter);

		String id = getAttributeID(accountFilterLocator);

		pagelogger.debug("The filter id is: " + id);
		SalesforcePageExtensions.selectOption(driver, id, filter);

		setDriverContextToPage(driver);
		return this;
	}

	public void refreshAccountTable()
	{
		IframeUtils.setDriverContextToIframeWithDepth(driver, refreshButtonLocator);

		pagelogger.debug("Refreshing the Account table");

		clickOnElement(refreshButtonLocator);

		setDriverContextToPage(driver);
	}

	public ServiceCloudAccountsDetail selectFromAccountTable(String account)
	{
		pagelogger.debug("Selecting the following value from the Account table: " + account);

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, refreshButtonLocator);

		SalesforcePageExtensions.selectFromRecordTable(driver, account);

		setDriverContextToPage(driver);

		return ServiceCloudAccountsDetail.Instance;
	}

	public ServiceCloudAccountsSelectRecordType createNewAccount()
	{
		pagelogger.debug("Creating a new Account...");

		IframeUtils.setDriverContextToIframeWithDepth(driver, refreshButtonLocator);

		clickOnElement(newAccountButtonLocator);

		setDriverContextToPage(driver);

		return ServiceCloudAccountsSelectRecordType.Instance;
	}

	public void checkmarkAccount(String account)
	{
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, refreshButtonLocator);

		pagelogger.debug("Checkmarking the Account: " + account);

		new WebDriverWait(driver, 30).until(ExpectedConditions
				.presenceOfElementLocated(newAccountButtonLocator));

		SalesforcePageExtensions.checkmarkRecordFromRecordTable(driver, account);

		setDriverContextToPage(driver);
	}

	public void clickFollowButton()
	{
		IframeUtils.setDriverContextToIframeWithDepth(driver, refreshButtonLocator);

		pagelogger.debug("Clicking on the Account Follow button");

		clickOnElement(followButtonLocator);

		setDriverContextToPage(driver);
	}

	public void mapAccounts()
	{
		IframeUtils.setDriverContextToIframeWithDepth(driver, mapAccountsButtonLocator);

		pagelogger.debug("Refreshing the Questions Home page");

		clickOnElement(followButtonLocator);

		setDriverContextToPage(driver);
	}

	public ServiceCloudAccountsHome filterAccountTableByLetter(String filter)
	{
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, refreshButtonLocator);

		pagelogger.debug("Sorting Account table by: " + filter);

		SalesforcePageExtensions.sortRecordTableByLetter(driver, filter);

		setDriverContextToPage(driver);

		return this;
	}

	public boolean verifyIfLabelExist(String labelName)
	{
		pagelogger.debug("Verifying if label exist with the name: " + labelName);

		synchronize(30);
		By labelLocator = By.xpath("//td[text()='" + labelName + "']");
		IframeUtils.setDriverContextToIframeWithDepth(driver, labelLocator);

		if (findElements(labelLocator).size() > 0)
		{
			return true;
		} else
		{
			return false;
		}

	}

}
