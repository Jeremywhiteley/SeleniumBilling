package com.salesforce.pages.setup.users;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.CommonMethods;

public class UserMyStayInTouchSettings extends PageBase
{

	 

	private static UserMyStayInTouchSettings instance;
	public static UserMyStayInTouchSettings Instance = (instance != null) ? instance : new UserMyStayInTouchSettings();

	
	/** UI Mappings */

	By automaticBccYesLocator = By.id("auto_bcc1");
	By automaticBccNoLocator = By.id("auto_bcc0");
	By reminderForNewContactsYesLocator = By.id("String1");
	By reminderForNewContactsNoLocator = By.id("String0");
	By subjectLocator = By.cssSelector("input[name='subject']");
	By noteLocator = By.cssSelector("textarea[name='note']");
	By signatureLocator = By.cssSelector("textarea[name='signature']");
	By saveLocator = By.cssSelector("input[name='save']");

	
	
	/** Page Methods */

	public UserMyStayInTouchSettings setAutomaticBCC(String selection)
	{
		if (selection.toUpperCase().trim().equals("YES"))
		{
			pagelogger.debug("Setting BCC to Yes");
			clickOnElement(automaticBccYesLocator);
		} else
		{
			pagelogger.debug("Setting BCC to No");
			clickOnElement(automaticBccNoLocator);
		}
		return this;
	}

	public UserMyStayInTouchSettings setReminder(String selection)
	{
		if (selection.toUpperCase().trim().equals("YES"))
		{
			pagelogger.debug("Setting Reminder to Yes");
			clickOnElement(reminderForNewContactsYesLocator);
		} else
		{
			pagelogger.debug("Setting Reminder to No");
			clickOnElement(reminderForNewContactsNoLocator);
		}
		return this;
	}

	public UserMyStayInTouchSettings setSubject()
	{
		pagelogger.debug("Setting the My Stay In Touch Settings Subject value to a random string");
		findElement(subjectLocator).sendKeys(CommonMethods.generateRandomString(20));
		return this;
	}

	public UserMyStayInTouchSettings setNote()
	{
		pagelogger.debug("Setting the My Stay In Touch Settings Note value to a random string");
		findElement(noteLocator).sendKeys(CommonMethods.generateRandomString(20));
		return this;
	}

	public UserMyStayInTouchSettings setSignature()
	{
		pagelogger.debug("Setting the My Stay In Touch Settings Signature value to a random string");
		findElement(signatureLocator).sendKeys(CommonMethods.generateRandomString(20));
		return this;
	}

	public UserProfileHome save()
	{
		pagelogger.debug("Saving changes made to My Stay In Touch settings");
		clickOnElement(saveLocator);
		return UserProfileHome.Instance;
	}

}
