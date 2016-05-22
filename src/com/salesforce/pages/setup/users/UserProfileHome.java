package com.salesforce.pages.setup.users;

import java.util.List;

import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class UserProfileHome extends PageBase
{

	 
	private static UserProfileHome instance;
	public static UserProfileHome Instance = (instance != null) ? instance : new UserProfileHome();

	
	/** UI Mappings */
	
	By editButtonLocator = By.xpath("//td[contains(@id,'bottomButton')]/input[@name='edit']");
	By languagePickList = By
			.xpath("//label[contains(text(),'Language Skill')]/../following::td/table//select");
	By saveButtonLocator = By.xpath("//input[@name='save']");
	By portalManagerIndicator = By
			.xpath("//span[contains(text(),'Portal Manager Indicator')]/../following::td[contains(@class,'dataCol')]");
	By languageLocator = By.xpath("//select[@id='LanguageLocaleKey']");
	By loginButtonLocator = By.xpath("//td[contains(@id,'bottomButton')]/input[@name='login']");

	
	
	/** Page Methods */

	public UserProfileHome clickOnEdit()
	{
		pagelogger.debug("Clicking on the Edit button...");

		clickOnElement(editButtonLocator);
		return this;
	}

	public List<String> returnAllLanguageOptions()
	{
		pagelogger.debug("Returning all of the language options on the user profile page");

		List<String> fields = SalesforcePageExtensions.returnSelectOptionsAsList(driver, languagePickList);
		return fields;
	}

	public UserProfileHome verifyPageLoad()
	{
		pagelogger.debug("Waiting for page to load");

		SalesforcePageExtensions.waitForPageToLoad(driver);

		return this;

	}

	public UserProfileHome clickOnSave()
	{
		pagelogger.debug("Clicking on the Save button...");

		clickOnElement(saveButtonLocator);
		return this;
	}

	public boolean verifyIfLangIsSaved(String language)
	{
		pagelogger.debug("Getting the Language Text...");

		boolean isFound = false;
		String languageXpath = "//td[contains(@class,'dataCol')][text()='{Language}']";
		languageXpath = languageXpath.replace("{Language}", language);
		By languageLocator = By.xpath(languageXpath);

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, languageLocator);

		try
		{
			if (findElements(languageLocator).size() > 0)
			{
				isFound = true;
			}
		} catch (NoSuchElementException e)
		{
			pagelogger.debug("Language not saved");
		}

		return isFound;
	}

	public UserProfileHome selectLanguage(String language)
	{
		pagelogger.debug("Selecting the Language...");

		String id = getAttributeID(languageLocator);
		SalesforcePageExtensions.selectOption(driver, id, language);

		return this;
	}

	public UserProfileHome clickOnLogin()
	{
		pagelogger.debug("Clicking on the login button!");

		clickOnElement(loginButtonLocator);

		return this;
	}

	public boolean verifyIfPortalManagerIndicatorIsMarked()
	{
		pagelogger.debug("Verifying Portal manager Indicator!");

		String indicatorText = findElement(portalManagerIndicator).getText();

		if (indicatorText.equals("Y"))
		{
			return true;
		} else
		{
			return false;
		}

	}

}
