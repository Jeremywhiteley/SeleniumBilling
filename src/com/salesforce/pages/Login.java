package com.salesforce.pages;

import org.openqa.selenium.By;

import com.salesforce.pages.salescloud.SalesCloudHomePage;
import com.salesforce.utils.datastore.FileIO;
import com.salesforce.utils.driver.SalesforcePageExtensions;

public class Login extends PageBase
{

	public Login()
	{
		if (FileIO.getConfigProperty("CurrentEnvironment").toUpperCase().equals("PROD"))
		{
			URL = "https://login.salesforce.com";
		} 
		else if (FileIO.getConfigProperty("CurrentEnvironment").toUpperCase().equals("QA"))
		{
			URL = "https://login.salesforce.com";
		}
		else
		{
			URL = "https://test.salesforce.com";
		}
	}

	
	/** UI Mappings */

	By usernameLocator = By.id("username");
	By passwordLocator = By.id("password");
	By loginButtonLocator = By.id("Login");
	By scheduledMaintenanceNotificationLocator = By.xpath("//div/h1[text()='Scheduled Maintenance Notification']");
	By scheduleMaintenanceContinueLocator = By.xpath("//div/h1[text()='Scheduled Maintenance Notification']/following::form/p/a[text()='Continue']");
	By loginErrorLocator = By.xpath("//div[contains(text(), 'Your login attempt has failed.')]");
	By activationRequiredError = By.xpath("//h2[text()='Activation Required']");

	
	/** Page Methods */

	public void doLogin(String user, String pass)
	{
		pagelogger.debug("Logging in using the user/pass: " + user + "/" + pass);

		this.open();
		this.enterUsername(user);
		this.enterPassword(pass);
		this.submitForm();
	}

	public void enterUsername(String userName)
	{
		pagelogger.debug("Entering Username: " + userName);

		findElement(usernameLocator).clear();
		findElement(usernameLocator).sendKeys(userName);
	}

	public void enterPassword(String password)
	{
		pagelogger.debug("Entering Password: " + password);

		findElement(passwordLocator).sendKeys(password);
	}

	public Login verifyPageLoad()
	{
		synchronize(30);
		SalesforcePageExtensions.waitForPageToLoad(driver);

		return this;
	}

	public SalesCloudHomePage submitForm()
	{
		pagelogger.debug("Submitting Login Form!");

		clickOnElement(loginButtonLocator);

		try
		{
			if (findElementsIgnoreException(loginErrorLocator, 2).size() > 0)
			{
				throw new Exception("Username/Password combination was NOT valid... ");
			}
			if (findElementsIgnoreException(activationRequiredError, 2).size() > 0)
			{
				throw new Exception("IP not shortlisted. Device needs to activated. ");
			}

		} catch (Exception e)
		{
			pagelogger.debug(e.getMessage());
		}

		return SalesCloudHomePage.Instance;

	}
}
