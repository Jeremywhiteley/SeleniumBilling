package com.salesforce.pages.setup.users;

import java.util.List;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.SalesforcePageExtensions;
import com.salesforce.utils.driver.VerifyPageElementsExtensions;

public class UserDetail extends PageBase
{

	private static UserDetail instance;
	public static UserDetail Instance = (instance != null) ? instance : new UserDetail();

	/** UI Mappings */

	By editButtonLocator = By.cssSelector("input[title='Edit']");

	/** Page Methods */

	public UserDetail verifyPageLoad()
	{
		pagelogger.debug("Waiting for page to load");

		SalesforcePageExtensions.waitForPageToLoad(driver);

		return this;
	}

	public boolean verifyLabelFieldsExist(String fields)
	{
		pagelogger.debug("Verifying if fields exist");

		boolean noErrorsFound = true;

		String[] arrFields = fields.split("\\,", -1);
		List<String> result = VerifyPageElementsExtensions.verifyAllFieldLabelsExist(driver,
				arrFields);

		if (result.size() > 0)
		{
			noErrorsFound = false;
		}

		return noErrorsFound;
	}

}
