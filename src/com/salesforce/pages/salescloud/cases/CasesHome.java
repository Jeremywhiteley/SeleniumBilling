package com.salesforce.pages.salescloud.cases;

import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.Select;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.SalesforcePageExtensions;

public class CasesHome extends PageBase
{

	private static CasesHome instance;
	public static CasesHome Instance = (instance != null) ? instance : new CasesHome();

	/** UI Mappings */

	By newLocator = By.cssSelector("input[name='new']");
	By goLocator = By.cssSelector("input[name='go']");

	/** Page Methods */

	public CasesEdit createNewRecord()
	{
		pagelogger.debug("Clicking on Create New Case button");

		clickOnElement(newLocator);

		return CasesEdit.Instance;
	}

	public CasesHome selectCasesViewFilter(String filter)
	{
		String id = SalesforcePageExtensions.getControlIDByXpath(driver, "View:");

		WebElement select = findElement(By.id(id));
		Select dropdown = new Select(select);

		pagelogger.debug("Selecting the following value from the case view filter dropdown: "
				+ filter);

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

	public CasesHome sortCasesTableByLetter(String letter)
	{
		pagelogger.debug("Sorting cases by letter");

		SalesforcePageExtensions.waitForPageToLoad(driver);
		SalesforcePageExtensions.sortRecordTableByLetter(driver, letter);
		return this;
	}

	public CasesDetail selectFromCasesTable(String searchValue)
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);

		pagelogger.debug("Selecting the following value from the case table: " + searchValue);
		SalesforcePageExtensions.selectFromRecordTable(driver, searchValue);

		return CasesDetail.Instance;
	}

}
