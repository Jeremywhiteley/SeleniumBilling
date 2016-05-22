package com.salesforce.pages.setup.users;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.SalesforcePageExtensions;

public class UserSettingsHome extends PageBase
{

	 

	private static UserSettingsHome instance;
	public static UserSettingsHome Instance = (instance != null) ? instance : new UserSettingsHome();

	
	/** UI Mappings */

	By emailSetup = By.xpath("//span[text()='Email']");
	By emailSetupMyStayInTouchSettingsLocator = By
			.xpath("//span[text()='My Stay-in-Touch Settings']");

	
	
	/** Page Methods */

	public UserMyStayInTouchSettings selectEmailSetup()
	{
		pagelogger.debug("Setting up Email...");

		clickOnElement(emailSetup);
		pagelogger.debug("Clicking on My Stay In Touch Settings button");
		clickOnElement(emailSetupMyStayInTouchSettingsLocator);

		return UserMyStayInTouchSettings.Instance;
	}

	public UserSettingsHome verifyPageIsLoad()
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;

	}

}
