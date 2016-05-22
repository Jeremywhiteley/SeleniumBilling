package com.salesforce.pages.salescloud.opportunities;

import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.Select;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.SalesforcePageExtensions;

public class OpportunitiesHome extends PageBase
{

	private static OpportunitiesHome instance;
	public static OpportunitiesHome Instance = (instance != null) ? instance
			: new OpportunitiesHome();

	/** UI Mappings */

	By newLocator = By.cssSelector("input[name='new']");
	By goLocator = By.cssSelector("input[name='go']");

	/** Page Methods */

	public OpportunitiesSelectRecordType clickOnNewButton()
	{
		pagelogger.debug("Clicking on Create New Opportunity button");

		clickOnElement(newLocator);
		return OpportunitiesSelectRecordType.Instance;
	}

	public boolean opportunitiesViewFilter(String filter)
	{
		pagelogger.debug("Setting Opportunities View Filter to: " + filter);

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

	public OpportunitiesHome sortOpportunitiesTableByLetter(String letter)
	{
		pagelogger.debug("Sorting the Opportunities Table by letter: " + letter);

		SalesforcePageExtensions.waitForPageToLoad(driver);
		SalesforcePageExtensions.sortRecordTableByLetter(driver, letter);
		return this;
	}

	public boolean selectFromOpportunitiesTable(String searchValue)
	{
		pagelogger.debug("Selecting the following from the Opportunities Table: " + searchValue);

		SalesforcePageExtensions.waitForPageToLoad(driver);
		boolean val = SalesforcePageExtensions.selectFromRecordTable(driver, searchValue);

		return val;
	}

}
