package com.salesforce.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.Select;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.SalesforcePageExtensions;

public class LeadsHome extends PageBase
{

	private static LeadsHome instance;
	public static LeadsHome Instance = (instance != null) ? instance : new LeadsHome();

	/** UI Mappings */

	By newLocator = By.cssSelector("input[name='new']");
	By goLocator = By.cssSelector("input[name='go']");

	/** Page Methods */

	public LeadsHome verifyPageLoad()
	{
		pagelogger.debug("Waiting for page to load");

		SalesforcePageExtensions.waitForPageToLoad(driver);

		return this;
	}

	public LeadsHome setViewFilter(String filter)
	{
		pagelogger.debug("Setting View filter to: " + filter);

		String id = SalesforcePageExtensions.getControlIDByXpath(driver, "View:");
		WebElement select = findElement(By.id(id));
		Select dropdown = new Select(select);

		pagelogger.debug("Selecting the Lead view type: " + filter);

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

	

	public boolean leadsViewFilter(String filter)
	{
		boolean val = false;
		String id = SalesforcePageExtensions.getControlIDByXpath(driver, "View:");

		WebElement select = findElement(By.id(id));
		Select dropdown = new Select(select);

		if (dropdown.getFirstSelectedOption().getText().toUpperCase()
				.equals(filter.toUpperCase().trim()))
		{
			pagelogger
					.debug("The <option> value was found as the default selected element. Selecting it now");

			clickOnElement(goLocator);
			val = true;
		} else
		{
			val = SalesforcePageExtensions.selectOption(driver, id, filter);
		}

		return val;
	}

	public LeadsHome sortLeadsTableByLetter(String letter)
	{
		pagelogger.debug("Sorting the leads Table by the Letter: " + letter);

		SalesforcePageExtensions.waitForPageToLoad(driver);
		SalesforcePageExtensions.sortRecordTableByLetter(driver, letter);

		return this;
	}

	public LeadsDetail selectFromLeadsTable(String searchValue)
	{
		pagelogger.debug("Selecting the following value from the Leads table: " + searchValue);

		SalesforcePageExtensions.waitForPageToLoad(driver);
		pagelogger.debug("Selecting the following value from the leads record table: "
				+ searchValue);

		SalesforcePageExtensions.selectFromRecordTable(driver, searchValue);

		return LeadsDetail.Instance;

	}

}
