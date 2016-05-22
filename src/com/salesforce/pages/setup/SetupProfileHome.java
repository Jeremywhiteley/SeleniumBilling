package com.salesforce.pages.setup;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class SetupProfileHome extends PageBase
{

	 

	private static SetupProfileHome instance;
	public static SetupProfileHome Instance = (instance != null) ? instance
			: new SetupProfileHome();

	
	/** UI Mappings */

	By manageUsersLocator = By.xpath("//a[text()='Manage Users']");

	
	/** Page Methods */

	public boolean verifyIfProfileExist(String profileName)
	{
		pagelogger.debug("Verifying if profile exists with the name: "  + profileName);

		By profileLocator = By.xpath("//span[text()='" + profileName + "']");
		IframeUtils.setDriverContextToIframeWithDepth(driver, profileLocator);

		if (findElements(profileLocator).size() > 0)
		{
			return true;
		} else
		{
			return false;
		}
	}

	public SetupProfileHome verifyPageLoad()
	{
		pagelogger.debug("Waiting for page to load");

		SalesforcePageExtensions.waitForPageToLoad(driver);

		return this;
	}

}
