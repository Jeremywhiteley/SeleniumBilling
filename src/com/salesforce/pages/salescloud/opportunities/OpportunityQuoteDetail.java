package com.salesforce.pages.salescloud.opportunities;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;


public class OpportunityQuoteDetail extends PageBase
{

	 
	private static OpportunityQuoteDetail instance;
	public static OpportunityQuoteDetail Instance = (instance != null) ? instance
			: new OpportunityQuoteDetail();

	
	/** UI Mappings */

	By editButtonLocator = By.cssSelector("input[title='Edit']");
	By opportunityLinkLocator = By.xpath("//td[text()='Opportunity Name']/following::a");

	
	
	/** Page Methods */

	public OpportunityQuoteDetail verifyPageLoad()
	{
		pagelogger.debug("Waiting for page to load");

		findElement(editButtonLocator);
		return this;
	}

	public OpportunitiesDetail clickOnOpportunity()
	{
		pagelogger.debug("Clicking on Opportunity Link");

		clickOnElement(opportunityLinkLocator);

		return OpportunitiesDetail.Instance;
	}
}
