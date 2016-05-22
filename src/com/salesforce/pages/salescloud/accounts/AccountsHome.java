package com.salesforce.pages.salescloud.accounts;

import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.Select;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.SalesforcePageExtensions;

public class AccountsHome extends PageBase
{

	private static AccountsHome instance;
	public static AccountsHome Instance = (instance != null) ? instance : new AccountsHome();

	/** UI Mappings */

	By newLocator = By.cssSelector("input[name='new']");
	By goLocator = By.cssSelector("input[name='go']");
	By newAccountLocator = By.cssSelector("input[title='New Account']");

	/** Page Methods */

	public AccountsHome verifyPageLoad()
	{
		pagelogger.debug("Verifying page has loaded successfully");
		SalesforcePageExtensions.waitForPageToLoad(driver);

		return this;
	}

	public AccountsSelectRecordType clickOnNewButton()
	{
		pagelogger.debug("Clicking on Create New Record button");

		clickOnElement(newLocator);
		return AccountsSelectRecordType.Instance;
	}

	public AccountsHome setViewFilter(String filter)
	{
		pagelogger.debug("Setting View filter to: " + filter);

		String id = SalesforcePageExtensions.getControlIDByXpath(driver, "View:");
		WebElement select = findElement(By.id(id));
		Select dropdown = new Select(select);

		pagelogger.debug("Selecting the account view type: " + filter);

		if (dropdown.getFirstSelectedOption().getText().toUpperCase()
				.equals(filter.toUpperCase().trim()))
		{
			pagelogger
					.debug("The <option> value was found as the default selected element. Selecting it now");
			clickOnElement(goLocator);
		} else
		{
			SalesforcePageExtensions.selectOption(driver, id, filter);
		}

		return this;
	}

	public AccountsHome sortAccountsTableByLetter(String letter)
	{
		pagelogger.debug("Sorting the Accounts table by letter: " + letter);

		SalesforcePageExtensions.waitForPageToLoad(driver);
		SalesforcePageExtensions.sortRecordTableByLetter(driver, letter);
		return this;
	}

	public AccountDetail selectFromAccountsTable(String searchValue)
	{
		pagelogger.debug("Selecting the following value from the Accounts table: " + searchValue);

		SalesforcePageExtensions.waitForPageToLoad(driver);
		pagelogger.debug("Selecting the following value from the accounts record table: "
				+ searchValue);

		SalesforcePageExtensions.selectFromRecordTable(driver, searchValue);

		return AccountDetail.Instance;

	}

}
