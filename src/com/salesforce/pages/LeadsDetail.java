package com.salesforce.pages;

import java.util.List;

import org.openqa.selenium.By;

import org.openqa.selenium.WebElement;

import com.salesforce.pages.PageBase;

import com.salesforce.utils.driver.SalesforcePageExtensions;
import com.salesforce.utils.driver.VerifyPageElementsExtensions;

public class LeadsDetail extends PageBase
{

	private static LeadsDetail instance;
	public static LeadsDetail Instance = (instance != null) ? instance : new LeadsDetail();

	/** UI Mappings */

	By editButtonLocator = By.cssSelector("input[title='Edit']");
	By newEventButtonLocator = By.cssSelector("input[title='New Event']");
	By newTaskButtonLocator = By.cssSelector("input[value='New Task']");
	By saveButtonLocator = By.cssSelector("input[title='Save']");
	By leadSourceFieldLocator = By
			.xpath("//td[text()='Lead Source']/following::td[1]/descendant::div[1]");
	By leadSourceSelectLocator = By
			.xpath("//td[class=contains(text(),'labelCol')][text()='Lead Source']/following-sibling::td/div[2]/span/select");
	By convertButtonLocator = By.cssSelector("input[title='Convert']");
	By leadStatusFieldLocator = By
			.xpath("//td[class=contains(text(),'labelCol')][text()='Lead Status']/following-sibling::td/div[1]");
	By leadStatusSelectLocator = By
			.xpath("//td[class=contains(text(),'labelCol')][text()='Lead Status']/following-sibling::td/div[2]/span/select");
	By errorLocator = By
			.xpath("//td[@id='bodyCell']/descendant::div[@class='pbHeader']/descendant::h2[text()='Lead Detail']/following::div[@class='pbBody']/div[@class='pbError']");
	By okButton = By.cssSelector("input[value='OK']");
	By cancelButtonLocator = By.cssSelector("input[value='Cancel']");
	By changeLeadOwnerLocator = By
			.xpath("//td[text()='Lead Owner']/following-sibling::td/div/a[text()='[Change]']");
	By totalScoreValueLocator = By
			.xpath("//td[text()='Total Score']/following::td[1]/descendant::div[1]");
	By leadHeaderLocator = By.xpath("//div/h2[@class='topName']");
	By nameLocator = By.xpath("//td[text()='Name']/following::td[1]/descendant::div[1]");
	By leadOwnerLocator = By.xpath("//td[text()='Lead Owner']/..//a[contains(@id,'lookup')]");
	By leadPhoneFieldLocator = By.xpath("//td[text()='Phone']/following::td[1]/descendant::div[1]");
	By leadPhoneInputLocator = By
			.xpath("//td[class=contains(text(),'labelCol')][text()='Phone']/following::td[1]/descendant::input[1]");

	/** Page Methods */

	public LeadsDetail verifyPageLoad()
	{
		findElement(editButtonLocator);
		return this;
	}

	public String getHeaderText()
	{
		pagelogger.debug("Getting the Lead Header text...");

		String val = findElement(leadHeaderLocator).getText();
		return val;
	}

	public String getName()
	{
		pagelogger.debug("Getting the Name text...");

		String val = findElement(nameLocator).getText();
		return val;
	}

	

	public LeadsDetail clickOnSaveButton()
	{
		pagelogger.debug("Saving the Lead record...");

		clickOnElement(saveButtonLocator);
		return this;
	}

	

	public boolean verifyLabelFieldsExist(String fields)
	{

		boolean noErrorsFound = true;

		pagelogger
				.debug("Verifying all field labels on the lead detail record (span) against the passed in values: "
						+ fields);

		String[] arrFields = fields.split("\\,", -1);
		List<String> result = VerifyPageElementsExtensions.verifyAllFieldLabelsExist(driver,
				arrFields);

		if (result.size() > 0)
		{
			noErrorsFound = false;
		}

		return noErrorsFound;
	}

	public boolean verifyFieldsEnabled(String fields)
	{

		boolean val = false;

		pagelogger
				.debug("Veriying that the following fields are enabled on the leads record detail: "
						+ fields);

		String[] arrFields = fields.split("\\,", -1);
		List<String> result = VerifyPageElementsExtensions
				.verifyFieldsAreEnabled(driver, arrFields);

		pagelogger.debug("Number of list items returned: " + result.size());

		if (result.size() == 0)
		{
			val = true;
		}

		return val;
	}

	public boolean verifyOverallLeadScoreMatches(String score)
	{
		boolean val = false;
		findElement(totalScoreValueLocator);

		String temp = findElement(totalScoreValueLocator).getText();

		if (temp.toUpperCase().trim().equals(score.toUpperCase().trim()))
		{
			pagelogger
					.debug("The passed in Overall Lead Score value matched the current Overall Lead Score value: "
							+ score);
			val = true;
		} else
		{
			pagelogger.debug("ERROR: Displayed Overall Lead Score value: " + temp
					+ " did not match the passed in Overall Lead Score value: " + score);
		}

		return val;
	}

	public boolean verifyTDValuesExist(String fields)
	{
		boolean noErrorsFound = true;

		pagelogger
				.debug("Verifying all field labels on the lead detail record (TD) against the passed in values: "
						+ fields);

		String[] arrFields = fields.split("\\,", -1);
		List<String> result = VerifyPageElementsExtensions
				.verifyAllTDValuesExist(driver, arrFields);
		pagelogger.debug("Size: " + result.size());

		if (result.size() > 0)
		{
			noErrorsFound = false;
		}

		return noErrorsFound;
	}

	public boolean verifyHeaderValuesExist(String fields)
	{
		boolean noErrorsFound = true;

		pagelogger
				.debug("Verifying all headers on the lead detail record (h3) against the passed in values: "
						+ fields);

		String[] arrFields = fields.split("\\,", -1);
		List<String> result = VerifyPageElementsExtensions
				.verifyAllTDValuesExist(driver, arrFields);
		pagelogger.debug("Size: " + result.size());

		if (result.size() > 0)
		{
			noErrorsFound = false;
		}

		return noErrorsFound;
	}

	public LeadsDetail setLeadSource(String field)
	{
		pagelogger.debug("Setting the Lead Source to: " + field);

		findElement(leadSourceFieldLocator);
		String leadSourceID = getAttributeID(leadSourceFieldLocator);

		pagelogger.debug("Double-clicking on the lead source table cell to make it editable");

		SalesforcePageExtensions.editInlineTD(driver, leadSourceID);
		String leadSourceOptID = getAttributeID(leadSourceSelectLocator);

		pagelogger.debug("Selecting option value: " + field + " from <select> with the id: "
				+ leadSourceOptID);

		SalesforcePageExtensions.selectOption(driver, leadSourceOptID, field);

		return this;
	}

	public String getLeadSource()
	{
		pagelogger.debug("Getting the Lead Source...");

		String status = findElement(leadSourceFieldLocator).getText();
		return status;
	}

	public LeadsDetail setLeadStatus(String optionValue)
	{
		pagelogger.debug("Editing the Lead Status on the record detail page");

		String leadStatus = getAttributeID(leadStatusFieldLocator);

		SalesforcePageExtensions.editInlineTD(driver, leadStatus);
		String leadSourceOptID = getAttributeID(leadStatusSelectLocator);
		SalesforcePageExtensions.selectOption(driver, leadSourceOptID, optionValue);

		return this;
	}

	public String getLeadStatus()
	{
		pagelogger.debug("Getting the Lead Status...");

		String status = findElement(leadStatusFieldLocator).getText();
		return status;
	}

	
	public boolean getPresenceOfActivity(String activityName)
	{
		pagelogger.debug("Searching Activity Related List for entry: " + activityName);

		boolean val = false;
		List<WebElement> rows = findElements(By
				.xpath("//div[contains(@id, 'RelatedActivityList')]/div/div/div[contains(@id, '_body')]/table/tbody/tr[contains(@class, 'dataRow')]/th/a"));

		for (int i = 1; i <= rows.size(); i++)
		{
			pagelogger.debug("Searching row [" + i + "] for value: " + activityName);

			if (rows.get(i - 1).getText().toUpperCase().trim()
					.equals(activityName.toUpperCase().trim()))
			{
				val = true;
				break;
			} else
			{
				pagelogger.debug("Did not find the passed in row. Found: "
						+ rows.get(i - 1).getText() + " wanted to find: "
						+ activityName.toUpperCase().trim());
			}
		}

		return val;

	}

	
	public String getLeadOwner()
	{
		pagelogger.debug("Getting the Lead Owner...");

		String leadOwnerName = findElement(leadOwnerLocator).getText();
		return leadOwnerName;
	}

	public LeadsDetail setPhone(String field)
	{
		pagelogger.debug("Updating Phone to: " + field);

		String fieldID = getAttributeID(leadPhoneFieldLocator);
		SalesforcePageExtensions.editInlineTD(driver, fieldID);

		String fieldInputID = getAttributeID(leadPhoneInputLocator);
		SalesforcePageExtensions.enterInputValue(driver, fieldInputID, field);

		return this;
	}

	public String getPhone()
	{
		pagelogger.debug("Getting the Phone...");

		String phone = findElement(leadPhoneFieldLocator).getText();
		return phone;
	}

}
