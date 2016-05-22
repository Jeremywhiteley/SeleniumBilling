package com.salesforce.pages.salescloud.campaigns;

import java.io.IOException;
import java.util.List;

import jxl.read.biff.BiffException;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class CampaignsDetail extends PageBase
{

	 
	private static CampaignsDetail instance;
	public static CampaignsDetail Instance = (instance != null) ? instance : new CampaignsDetail();

	
	/** UI Mappings */

	By editLocator = By.cssSelector("input[title='Edit']");

	
	
	/** Page Methods */

	public CampaignsEditRecord clickOnEditButton() throws BiffException, IOException
	{
		pagelogger.debug("Clicking on Edit button...");
		
		clickOnElement(editLocator);

		return CampaignsEditRecord.Instance;
	}

	public CampaignsDetail verifyPageLoad()
	{
		pagelogger.debug("Waiting for page to load");

		SalesforcePageExtensions.waitForPageToLoad(driver);

		return this;
	}

	public List<String> returnAllCampaignRecordLabels()
	{
		pagelogger.debug("Returning all record labels");

		List<String> labels = SalesforcePageExtensions.returnAllLabelsAsList(driver);
		return labels;
	}

	public List<String> returnAllRequiredCampaignRecordFields()
	{
		pagelogger.debug("Returning all required fields");

		List<String> fields = SalesforcePageExtensions.returnAllRequiredFieldsAsList(driver);
		return fields;
	}

}
