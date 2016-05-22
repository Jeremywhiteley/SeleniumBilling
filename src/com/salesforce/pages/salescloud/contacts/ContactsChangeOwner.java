package com.salesforce.pages.salescloud.contacts;

import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.SalesforcePageExtensions;

public class ContactsChangeOwner extends PageBase
{

	private static ContactsChangeOwner instance;
	public static ContactsChangeOwner Instance = (instance != null) ? instance
			: new ContactsChangeOwner();

	/** UI Mappings */

	By saveButtonLocator = By.cssSelector("input[title='Save']");
	By searchScopeDropdownLocator = By.cssSelector("select[title='Search scope']");
	By lookupButtonLocator = By
			.xpath("//td/label[text()='Owner']/following::td[1]/descendant::span[@class='lookupInput']/a");
	By errorLocator = By.xpath("//div/div[contains(text(), 'Error: Invalid Data')]");

	/** Page Methods */

	public ContactsDetail clickOnSave()
	{
		pagelogger.debug("Clicking on the Save button...");

		clickOnElement(saveButtonLocator);
		return ContactsDetail.Instance;
	}

	public ContactsChangeOwner setOwnerType(String field)
	{
		pagelogger.debug("Setting Owner Type to: " + field);

		SalesforcePageExtensions.waitForPageToLoad(driver);
		String id = getAttributeID(searchScopeDropdownLocator);
		SalesforcePageExtensions.selectOption(driver, id, field);

		return this;
	}

	public ContactsChangeOwner setOwner(String vals) throws InterruptedException
	{
		pagelogger.debug("Search for then Setting Owner to : " + vals);

		SalesforcePageExtensions.waitForPageToLoad(driver);

		String id = getAttributeID(lookupButtonLocator);
		String mwh = driver.getWindowHandle();

		SalesforcePageExtensions.selectFromLookup(driver, vals, mwh, id);

		return this;
	}

	public boolean verifyIfUpdateErrorPresent()
	{
		pagelogger.debug("Checking for the presence of an update error...");

		boolean val = false;

		try
		{
			if (findElement(errorLocator).isDisplayed() == true)
			{
				val = true;
			}
		} catch (NoSuchElementException e)
		{
			pagelogger.debug("Error Message was Not present!");
		}

		return val;
	}

}
