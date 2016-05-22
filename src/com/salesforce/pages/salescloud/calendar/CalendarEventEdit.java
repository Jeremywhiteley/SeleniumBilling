package com.salesforce.pages.salescloud.calendar;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.pages.salescloud.SalesCloudHomePage;

public class CalendarEventEdit extends PageBase
{

	 
	private static CalendarEventEdit instance;
	public static CalendarEventEdit Instance = (instance != null) ? instance
			: new CalendarEventEdit();

	/** UI Mappings */

	By saveButtonLocator = By.cssSelector("input[title='Save']");
	By relatedToLocator = By
			.xpath("//td[class=contains(text(), 'labelCol')]/span/label[text()='Related To']/following::td[1]/div/select");
	By subjectLocator = By.xpath("//label[text()='Subject']/../following::input");
	By privateCheckbox = By.cssSelector("input[id='IsPrivate']");

	/** Page Methods */

	public CalendarEventEdit verifyPageLoad()
	{
		findElement(saveButtonLocator);
		return this;
	}

	public SalesCloudHomePage clickOnSave()
	{
		pagelogger.debug("Saving the Event...");

		clickOnElement(saveButtonLocator);

		return SalesCloudHomePage.Instance;
	}

	public CalendarEventEdit setSubject(String subject)
	{
		pagelogger.debug("Entering the Event Subject");

		findElement(subjectLocator).clear();
		findElement(subjectLocator).sendKeys(subject);

		return this;
	}

	public CalendarEventEdit markAsPrivate()
	{
		pagelogger.debug("Marking the event as private");

		findElement(privateCheckbox).click();

		return this;
	}
}
