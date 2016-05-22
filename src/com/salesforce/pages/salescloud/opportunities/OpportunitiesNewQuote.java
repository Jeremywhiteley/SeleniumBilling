package com.salesforce.pages.salescloud.opportunities;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class OpportunitiesNewQuote extends PageBase
{

	 
	private static OpportunitiesNewQuote instance;
	public static OpportunitiesNewQuote Instance = (instance != null) ? instance
			: new OpportunitiesNewQuote();

	
	/** UI Mappings */

	By saveButtonLocator = By.cssSelector("input[title='Save']");
	By quoteNameLocator = By.cssSelector("input[name='Name']");

	
	
	/** Page Methods */

	public OpportunitiesNewQuote verifyPageLoad()
	{
		findElement(saveButtonLocator);
		return this;
	}

	public OpportunityQuoteDetail clickOnSave()
	{
		pagelogger.debug("Saving the Quote...");

		clickOnElement(saveButtonLocator);

		return OpportunityQuoteDetail.Instance;
	}

	public OpportunitiesNewQuote setQuoteName(String name)
	{
		pagelogger.debug("Setting Quote Name to: "  + name);

		findElement(quoteNameLocator).clear();
		findElement(quoteNameLocator).sendKeys(name);

		return this;
	}

	public OpportunitiesNewQuote setStatus(String status)
	{
		pagelogger.debug("Setting Quote Status to: "  + status);

		String id = SalesforcePageExtensions.getControlIDByXpath(driver, "Status");
		SalesforcePageExtensions.selectOption(driver, id, status);

		return this;
	}
}
