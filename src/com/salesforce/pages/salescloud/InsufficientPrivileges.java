package com.salesforce.pages.salescloud;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.SalesforcePageExtensions;

public class InsufficientPrivileges extends PageBase
{

	 
	private static InsufficientPrivileges instance;
	public static InsufficientPrivileges Instance = (instance != null) ? instance
			: new InsufficientPrivileges();

	
	/** UI Mappings */

	By hereLocator = By.linkText("here");
	By insufficientPrivHeaderLocator = By.xpath("//span[text()='Insufficient Privileges']");

	
	
	/** Page Methods */

	public InsufficientPrivileges verifyPageLoad()
	{
		pagelogger.debug("Waiting for page to load");

		SalesforcePageExtensions.waitForPageToLoad(driver);

		return this;
	}

}
