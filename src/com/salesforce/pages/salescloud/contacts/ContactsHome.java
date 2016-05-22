package com.salesforce.pages.salescloud.contacts;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.SalesforcePageExtensions;

public class ContactsHome extends PageBase
{

	private static ContactsHome instance;
	public static ContactsHome Instance = (instance != null) ? instance : new ContactsHome();

	/** UI Mappings */

	By newContactButtonLocator = By.cssSelector("input[name='new']");
	By goLocator = By.cssSelector("input[name='go']");
	By editButtonLocator = By.cssSelector("input[title='Edit']");

	/** Page Methods */

	public ContactsEdit clickOnNewButton()
	{
		pagelogger.debug("Clicking on the New Button...");

		clickOnElement(newContactButtonLocator);

		return ContactsEdit.Instance;
	}

	public ContactsHome sortContactsTableByLetter(String letter)
	{
		pagelogger.debug("Sorting the Contacts Table by letter: " + letter);

		SalesforcePageExtensions.waitForPageToLoad(driver);
		SalesforcePageExtensions.sortRecordTableByLetter(driver, letter);

		return this;
	}

	public boolean selectFromContactsTable(String searchValue)
	{
		pagelogger.debug("Selecting the following value from the Contacts Table: " + searchValue);

		SalesforcePageExtensions.waitForPageToLoad(driver);

		boolean val = SalesforcePageExtensions.selectFromRecordTable(driver, searchValue);
		return val;

	}

	public ContactsHome verifyPageLoad()
	{
		findElement(newContactButtonLocator);
		return this;
	}

	public ContactsEdit clickOnNewContact()
	{
		pagelogger.debug("Clicking on New Contact Button...");

		clickOnElement(newContactButtonLocator);
		setDriverContextToPage(driver);

		return ContactsEdit.Instance;
	}
}
