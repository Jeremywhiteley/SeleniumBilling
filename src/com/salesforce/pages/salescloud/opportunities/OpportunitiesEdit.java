package com.salesforce.pages.salescloud.opportunities;

import java.util.List;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.SalesforcePageExtensions;
import com.salesforce.utils.driver.VerifyPageElementsExtensions;


public class OpportunitiesEdit extends PageBase
{

	 
	private static OpportunitiesEdit instance;
	public static OpportunitiesEdit Instance = (instance != null) ? instance
			: new OpportunitiesEdit();
	/** UI Mappings */

	By saveButtonLocator = By.cssSelector("input[title='Save']");
	By errorLocator = By.xpath("//div/div[contains(text(), 'Error: Invalid Data')]");
	By typeLocator = By.xpath("//tr/td[class=contains(text(), 'labelCol')]/label[text()='Type']/following::td[1]/descendant::select");
	By leadSourceLocator = By.xpath("//td/label[text()='Lead Source']/following::td[1]/descendant::select[1]");
	By stageLocator = By.xpath("//td[class=contains(text(), 'labelCol')]/label[text()='Stage']/following::td[1]/div/span/select");
	By opportunityNameLocator = By.xpath("//td/label[text()='Opportunity Name']/following::td[1]/descendant::input[1]");
	By closeDateLocator = By.xpath("//td/label[text()='Close Date']/following::td[1]/descendant::input[1]");
	By accountNameLocator = By.xpath("//label[contains(text(), 'Account Name')]/../following::td//a");
	By opportunityStageLocator = By.xpath("//label[contains(text(),'Stage')]/../..//select");
	By forecastCategoryLocator = By.xpath("//label[text()='Forecast Category']/../following::td[1]/descendant::select[1]");
	By defaultDateLink = By.xpath("//span[@class='dateFormat']/a");
	
	
	
	/** Page Methods */

	public OpportunitiesEdit verifyPageLoad()
	{
		pagelogger.debug("Waiting for page to load");
		 
		SalesforcePageExtensions.waitForPageToLoad(driver);

		return this;
	}
	
	public boolean verifyTDAndSpanValuesExist(String fields)
	{
		boolean noErrorsFound = true;

		pagelogger.debug("Verifying all labels exist (Span + TD)");

		String[] arrFields = fields.split("\\,", -1);
		List<String> result = VerifyPageElementsExtensions.verifyAllFieldLabelsAndTDsExist(driver, arrFields);
		pagelogger.debug("Size: "  + result.size());

		if (result.size() > 0)
		{
			noErrorsFound = false;
		}

		return noErrorsFound;
	}

	public OpportunitiesDetail clickOnSaveButton()
	{
		pagelogger.debug("Clicking on the Save button...");
		
		clickOnElement(saveButtonLocator);
		return OpportunitiesDetail.Instance;
	}

	public OpportunitiesEdit clickOnDefaultDateLink()
	{
		pagelogger.debug("Clicking on Default Date link...");
		
		clickOnElement(defaultDateLink);
		return OpportunitiesEdit.Instance;
	}
	
	public OpportunitiesEdit setForecastCategory(String category)
	{
		pagelogger.debug("Setting the Forecast Category to: "  + category);

		SalesforcePageExtensions.waitForPageToLoad(driver);

		String id = getAttributeID(forecastCategoryLocator);
		SalesforcePageExtensions.selectOption(driver, id, category);

		return this;
	}
	
	public OpportunitiesEdit setOpportunityName(String name)
	{
		pagelogger.debug("Setting Opportunity Name to: "  + name);

		synchronize(30);

		findElement(opportunityNameLocator).clear();
		findElement(opportunityNameLocator).sendKeys(name);
		
		return this;
	}

	public OpportunitiesEdit setCloseDate(String date)
	{
		pagelogger.debug("Setting Opportunity Close Date to: "  + date);

		synchronize(30);

		findElement(closeDateLocator).clear();
		findElement(closeDateLocator).sendKeys(date);
		
		return this;
	}
	
	public OpportunitiesEdit setOpportunityStage(String stage)
	{
		pagelogger.debug("Setting Opportunity Stage to: "  + stage);

		SalesforcePageExtensions.waitForPageToLoad(driver);

		String id = getAttributeID(opportunityStageLocator);
		SalesforcePageExtensions.selectOption(driver, id, stage);

		return this;
	}

	public OpportunitiesEdit setAccountName(String accountName) throws InterruptedException
	{
		pagelogger.debug("Setting Account Name to: "  + accountName);

		String id = getAttributeID(accountNameLocator);
		String mwh = driver.getWindowHandle();
		SalesforcePageExtensions.selectFromLookup(driver, accountName, mwh, id);
		
		return this;
	}

	public List<String> returnAllOpportunityRecordLabels()
	{
		pagelogger.debug("Returning all opportunity labels...");

		List<String> labels = SalesforcePageExtensions.returnAllLabelsAsList(driver);
		return labels;
	}

	public List<String> returnAllRequiredOpportunityRecordFields()
	{
		pagelogger.debug("Returning all opportunity fields...");
		List<String> fields = SalesforcePageExtensions.returnAllRequiredFieldsAsList(driver);
		return fields;
	}

	public List<String> returnAllSelectOptions()
	{
		pagelogger.debug("Returning all opportunity select options...");
		List<String> fields = SalesforcePageExtensions.returnSelectOptionsAsList(driver, typeLocator);
		return fields;
	}

	public List<String> returnAllPicklistOptions()
	{
		pagelogger.debug("Returning all opportunity picklist options...");
		List<String> fields = SalesforcePageExtensions.returnSelectOptionsAsList(driver, typeLocator);
		return fields;
	}
	
	public List<String> getStageValuesAsList()
	{
		pagelogger.debug("Getting Opportunity Stage values");
		return SalesforcePageExtensions.returnPicklistOptionsAsList(driver, stageLocator);
	}

}
