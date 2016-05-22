package com.salesforce.pages.salescloud;

import java.util.List;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class UserEdit extends PageBase
{

	 
	private static UserEdit instance;
	public static UserEdit Instance = (instance != null) ? instance : new UserEdit();
	
	
	/** UI Mappings */

	By saveButtonLocator = By.cssSelector("input[title='Save']");

	
	
	/** Page Methods */

	public UserEdit verifyPageLoad()
	{
		pagelogger.debug("Waiting for page to load");

		SalesforcePageExtensions.waitForPageToLoad(driver);

		return this;
	}

	public List<String> returnAllUserRecordLabels()
	{
		pagelogger.debug("Returning all user labels");

		List<String> labels = SalesforcePageExtensions.returnAllLabelsAsList(driver);
		return labels;
	}

}
