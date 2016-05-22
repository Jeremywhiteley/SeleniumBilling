package com.salesforce.pages.salescloud;

import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;

import com.salesforce.pages.PageBase;
import com.salesforce.pages.salescloud.calendar.CalendarEventDetail;
import com.salesforce.pages.salescloud.calendar.CalendarEventEdit;
import com.salesforce.pages.salescloud.calendar.CalendarMonthView;

public class SalesCloudHomePage extends PageBase
{

	 
	private static SalesCloudHomePage instance;
	public static SalesCloudHomePage Instance = (instance != null) ? instance : new SalesCloudHomePage();

	/** UI Mappings */

	By fileUploadLinkLocator = By.linkText("File");
	By fileUploadFromComputerLocator = By.id("chatterUploadFileAction");
	By fileUploadInputButtonLocator = By.id("chatterFile");
	By recycleBinLocator = By.linkText("Recycle Bin");
	By newEventButtonLocator = By.cssSelector("input[title='New Event']");
	By calMonthViewButton = By.cssSelector("img[alt='Month View']");
	/** Page Methods */

	public SalesCloudHomePage verifyPageLoad()
	{
		findElement(newEventButtonLocator);
		return this;
	}

	public CalendarEventEdit clickOnNewEventButton()
	{
		pagelogger.debug("Clicking on New event button");

		clickOnElement(newEventButtonLocator);

		return CalendarEventEdit.Instance;
	}

	public boolean getPresenceOfEvent(String eventName)
	{
		boolean isFound = false;
		pagelogger.debug("Verifying if event is present");
		String eventLocator = "//ul[@class='homeCalendarEvents']//a[text()='" + eventName + "']";
		By eventXpath = By.xpath(eventLocator);
		try
		{
			if (findElements(eventXpath).size() > 0)
			{
				isFound = true;
			}
		} catch (NoSuchElementException e)
		{
			pagelogger.debug("Event with name " + eventName + " not found");
		}

		return isFound;
	}

	public CalendarEventDetail clickOnCalendarEvent(String eventName)
	{
		pagelogger.debug("Clicking on calendar with event name "  + eventName);
		
		String eventLocator = "//ul[@class='homeCalendarEvents']//a[text()='" + eventName + "']";
		By eventXpath = By.xpath(eventLocator);
		clickOnElement(eventXpath);
		
		return CalendarEventDetail.Instance;
	}
	
	public CalendarMonthView clickOnMonthViewInCalendar()
	{
		pagelogger.debug("Clicking on month view in calendar ");
		
		clickOnElement(calMonthViewButton);
		
		return CalendarMonthView.Instance;
	}

	public void clickFileUploadLink()
	{
		pagelogger.debug("Clicking the File Upload link...");
		clickOnElement(fileUploadLinkLocator);
	}

	public void clickUploadFromComputer()
	{
		pagelogger.debug("Clicking Upload from Computer link...");
		clickOnElement(fileUploadFromComputerLocator);
	}

	public void clickFileUploadButton()
	{
		pagelogger.debug("Clicking File Upload button...");
		clickOnElement(fileUploadInputButtonLocator);
	}

	public void viewRecycleBin()
	{
		pagelogger.debug("Clicking Recycle Bin link...");
		clickOnElement(recycleBinLocator);
	}

}