package com.salesforce.pages.setup;

import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.Select;

import com.salesforce.pages.PageBase;
import com.salesforce.pages.setup.users.UserDetail;
import com.salesforce.utils.driver.SalesforcePageExtensions;

public class SetupUsersDetail extends PageBase
{

	private static SetupUsersDetail instance;
	public static SetupUsersDetail Instance = (instance != null) ? instance
			: new SetupUsersDetail();

	/** UI Mappings */

	By newUserLocator = By.cssSelector("input[title='New User']");

	/** Page Methods */

	public SetupUsersDetail usersViewFilter(String filter)
	{
		pagelogger.debug("Selecting user filter:" + filter);

		String id = SalesforcePageExtensions.getControlIDByXpath(driver, "View:");

		WebElement select = findElement(By.id(id));
		Select dropdown = new Select(select);

		if (dropdown.getFirstSelectedOption().getText().toUpperCase()
				.equals(filter.toUpperCase().trim()))
		{
			pagelogger.debug("Filter: " + filter
					+ " was already selected. Ignoring View Filter dropdown");
		} else
		{
			SalesforcePageExtensions.selectOption(driver, id, filter);
		}

		return this;
	}

	public boolean isUserFilterPresent(String filter)
	{
		pagelogger.debug("Verifying if filter is present");

		String id = SalesforcePageExtensions.getControlIDByXpath(driver, "View:");
		WebElement select = findElement(By.id(id));
		Select dropdown = new Select(select);

		if (dropdown.getFirstSelectedOption().getText().toUpperCase()
				.equals(filter.toUpperCase().trim()))
		{
			pagelogger.debug("Filter: " + filter
					+ " was already selected. Ignoring View Filter dropdown");
			return true;
		} else
		{
			return SalesforcePageExtensions.selectOption(driver, id, filter);
		}

	}

	public SetupUsersDetail sortActiveUsersTableByLetter(String letter)
	{
		pagelogger.debug("Sorting User table by letter.");

		SalesforcePageExtensions.waitForPageToLoad(driver);
		SalesforcePageExtensions.sortRecordTableByLetter(driver, letter);

		return this;

	}

	public UserDetail selectFromUsersTable(String searchValue)
	{
		pagelogger.debug("Selecting users from the record table.");

		SalesforcePageExtensions.waitForPageToLoad(driver);
		SalesforcePageExtensions.selectFromVerticallyExpandingTable(driver, searchValue);

		return UserDetail.Instance;
	}
}
