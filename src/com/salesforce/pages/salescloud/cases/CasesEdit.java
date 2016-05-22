package com.salesforce.pages.salescloud.cases;

import java.util.List;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.SalesforcePageExtensions;
import com.salesforce.utils.driver.VerifyPageElementsExtensions;


public class CasesEdit extends PageBase
{

	 
	private static CasesEdit instance;
	public static CasesEdit Instance = (instance != null) ? instance : new CasesEdit();

	/** UI Mappings */

	By saveButtonLocator = By.cssSelector("input[title='Save']");
	By errorLocator = By.xpath("//div/div[contains(text(), 'Error: Invalid Data')]");
	By subjectLocator = By.xpath("//label[text()='Subject']/../following::input");
	
	
	
	/** Page Methods */

	public CasesEdit verifyPageLoad()
	{
		pagelogger.debug("Waiting for page to load...");

		SalesforcePageExtensions.waitForPageToLoad(driver);

		return this;
	}

	public boolean verifyTDAndSpanValuesExist(String fields)
	{
		pagelogger.debug("Verifying all labels exist (Span + TD)");

		boolean noErrorsFound = true;

		String[] arrFields = fields.split("\\,", -1);
		List<String> result = VerifyPageElementsExtensions.verifyAllFieldLabelsAndTDsExist(driver, arrFields);
		pagelogger.debug("Size: "  + result.size());

		if (result.size() > 0)
		{
			noErrorsFound = false;
		}

		return noErrorsFound;
	}

	public CasesEdit setSubject(String subject)
	{
		pagelogger.debug("Entering the Case Subject...");

		findElement(subjectLocator).clear();
		findElement(subjectLocator).sendKeys(subject);

		return this;
	}

	public CasesDetail clickOnSaveButton()
	{
		pagelogger.debug("Clicking on the Save button...");

		clickOnElement(saveButtonLocator);
		
		return CasesDetail.Instance;
	}

}
