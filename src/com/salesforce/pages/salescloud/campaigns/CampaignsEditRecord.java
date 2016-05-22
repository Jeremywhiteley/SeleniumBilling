package com.salesforce.pages.salescloud.campaigns;

import java.util.List;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class CampaignsEditRecord extends PageBase
{

	 
	private static CampaignsEditRecord instance;
	public static CampaignsEditRecord Instance = (instance != null) ? instance : new CampaignsEditRecord();
	
	/** UI Mappings */

	By saveButtonLocator = By.cssSelector("input[title='Save']");
	public By typeLocator = By.xpath("//tr/td[@class='labelCol']/label[text()='Type']/following::td[1]/descendant::select");
	public By statusLocator = By.xpath("//tr/td[@class='labelCol']/label[text()='Status']/following::td[1]/descendant::select");

	
	
	/** Page Methods */

	public CampaignsEditRecord verifyPageLoad()
	{
		pagelogger.debug("Waiting for page to load");

		SalesforcePageExtensions.waitForPageToLoad(driver);

		return this;
	}

	public List<String> returnAllCampaignRecordLabels()
	{
		pagelogger.debug("Returning all campaign record labels");
		List<String> labels = SalesforcePageExtensions.returnAllLabelsAsList(driver);
		return labels;
	}

	public List<String> returnAllRequiredCampaignRecordFields()
	{
		pagelogger.debug("Returning all required fields");
		List<String> fields = SalesforcePageExtensions.returnAllRequiredFieldsAsList(driver);
		return fields;
	}

	public List<String> returnAllSelectOptions(By parent)
	{
		pagelogger.debug("Returning all selection option fields");
		List<String> fields = SalesforcePageExtensions.returnSelectOptionsAsList(driver, parent);
		return fields;
	}

	public List<String> returnAllPicklistOptions(By parent)
	{
		pagelogger.debug("Returning all picklist option fields");
		List<String> fields = SalesforcePageExtensions.returnPicklistOptionsAsList(driver, parent);
		return fields;
	}

}
