package com.salesforce.pages.salescloud.leads;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.pages.salescloud.accounts.AccountDetail;
import com.salesforce.utils.driver.SalesforcePageExtensions;

public class LeadsConvertRecord extends PageBase
{

	 
	private static LeadsConvertRecord instance;
	public static LeadsConvertRecord Instance = (instance != null) ? instance
			: new LeadsConvertRecord();

	/** UI Mappings */

	By convertButtonLocator = By.cssSelector("input[title='Convert']");
	By errorOnConversionMessageLocator = By
			.xpath("//div/div[contains(text(), 'Error: Invalid Data')]");
	By accountNameSelectLocator = By.cssSelector("select[title='Company Name']");
	By subjectLocator = By.xpath("//label[text()='Subject']/../following::input");
	By accountNamelookupButtonLocator = By
			.xpath("//td[text()='Account Name']/following::td[1]/descendant::span[@class='lookupInput']/a");

	/** Page Methods */

	public LeadsConvertRecord setSubject(String subject)
	{
		pagelogger.debug("Setting Subject to: "  + subject);

		pagelogger.debug("Entering a value into the subject field on the convert record page");

		findElement(subjectLocator).clear();
		findElement(subjectLocator).sendKeys(subject);

		return this;
	}

	public AccountDetail clickOnConvertLeadButton()
	{

		pagelogger.debug("Clicking on the convert lead button on the convert record page");
		clickOnElement(convertButtonLocator);

		return AccountDetail.Instance;
	}

	public LeadsConvertRecord setAccountName(String name) throws InterruptedException
	{
		pagelogger.debug("Setting Account Name to: "  + name);

		SalesforcePageExtensions.waitForPageToLoad(driver);

		String id = getAttributeID(accountNamelookupButtonLocator);
		String mwh = driver.getWindowHandle();

		SalesforcePageExtensions.selectFromLookup(driver, name, mwh, id);

		return this;
	}

	public LeadsConvertRecord verifyPageLoad()
	{
		pagelogger.debug("Waiting for page to load");

		SalesforcePageExtensions.waitForPageToLoad(driver);

		return this;
	}

}
