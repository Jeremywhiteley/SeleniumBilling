package com.salesforce.pages.salescloud.calendar;

import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;

import com.salesforce.pages.PageBase;

public class CalendarMonthView extends PageBase
{

	 
	private static CalendarMonthView instance;
	public static CalendarMonthView Instance = (instance != null) ? instance
			: new CalendarMonthView();

	/** UI Mappings */

	By thisMonthLinkLocator = By.xpath("//a[text()='This Month']");

	/** Page Methods */

	public CalendarMonthView verifyPageLoad()
	{
		pagelogger.debug("Waiting for page to load");

		findElement(thisMonthLinkLocator);
		return this;
	}

	public boolean getPresenceOfEventInCalendar(String eventName)
	{
		boolean isFound = false;
		pagelogger.debug("Verifying if event is present in the month view");
		String eventLocator = "//td[@class='calToday']//a[text()='" + eventName + "']";
		By eventXpath = By.xpath(eventLocator);
		try
		{
			if (findElements(eventXpath).size() > 0)
			{
				isFound = true;
			}
		} catch (NoSuchElementException e)
		{
			pagelogger.debug("Event with name " + eventName + " not found in month view");
		}

		return isFound;
	}
}
