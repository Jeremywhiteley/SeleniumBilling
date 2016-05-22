package com.salesforce.pages.salescloud.campaigns;

import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.Select;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.SalesforcePageExtensions;

public class CampaignsHome extends PageBase
{

	private static CampaignsHome instance;
	public static CampaignsHome Instance = (instance != null) ? instance : new CampaignsHome();

	/** UI Mappings */

	By goLocator = By.cssSelector("input[name='go']");
	By newAccountLocator = By.cssSelector("input[title='New Account']");
	By viewLocator = By
			.xpath("//tr/td/descendant::form[@id='filter_element']/descendant::label[text()='View:']/following::span[1]/select");

	/** Page Methods */

	public CampaignsHome verifyPageLoad()
	{
		pagelogger.debug("Waiting for page to load");

		findElement(goLocator);

		return this;
	}

	public CampaignsHome campaignsViewFilter(String filter)
	{
		pagelogger.debug("Setting Campaigns View Filter to: " + filter);

		WebElement select = findElement(viewLocator);
		Select dropdown = new Select(select);

		String id = getAttributeID(viewLocator);

		pagelogger.debug("Selecting the campaign view type: " + filter);

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

	public CampaignsHome sortCampaignsTableByLetter(String letter)
	{
		pagelogger.debug("Sorting Campaigns Table by letter: " + letter);
		SalesforcePageExtensions.waitForPageToLoad(driver);
		SalesforcePageExtensions.sortRecordTableByLetter(driver, letter);
		return this;
	}

	public CampaignsDetail selectFromCampaignsTable(String searchValue)
	{
		pagelogger.debug("Selecing the following from the Campaigns Table: " + searchValue);

		SalesforcePageExtensions.waitForPageToLoad(driver);
		SalesforcePageExtensions.selectFromRecordTable(driver, searchValue);

		return CampaignsDetail.Instance;
	}

}
