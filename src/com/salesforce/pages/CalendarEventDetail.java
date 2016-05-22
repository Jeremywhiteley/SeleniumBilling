package com.salesforce.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;

import com.salesforce.pages.PageBase;
import com.salesforce.pages.SalesCloudHomePage;


public class CalendarEventDetail extends PageBase
{

	 
	private static CalendarEventDetail instance;
	public static CalendarEventDetail Instance = (instance != null) ? instance
			: new CalendarEventDetail();

	/** UI Mappings */

	By editButtonLocator = By.cssSelector("input[title='Edit']");
	By deleteButtonLocator = By.cssSelector("input[title='Delete']");
	By isPrivateChecked = By.cssSelector("img[title='Checked']");

	/** Page Methods */

	public CalendarEventDetail verifyPageLoad()
	{
		pagelogger.debug("Waiting for page to load");

		findElement(editButtonLocator);
		return this;
	}

	public boolean isPrivateChecked()
	{
		boolean isFound = false;
		pagelogger.debug("Verifying if private is checked");
		try
		{
			if (findElements(isPrivateChecked).size() > 0)
			{
				isFound = true;
			}
		} catch (NoSuchElementException e)
		{
			pagelogger.debug("Is private not checked.");
		}

		return isFound;
	}

	public SalesCloudHomePage clickOnDelete()
	{
		pagelogger.debug("Deleting the Event...");

		clickOnElement(deleteButtonLocator);

		return SalesCloudHomePage.Instance;
	}

}
