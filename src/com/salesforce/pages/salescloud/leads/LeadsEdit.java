package com.salesforce.pages.salescloud.leads;

import java.util.List;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.SalesforcePageExtensions;
import com.salesforce.utils.driver.VerifyPageElementsExtensions;


public class LeadsEdit extends PageBase
{

	 
	private static LeadsEdit instance;
	public static LeadsEdit Instance = (instance != null) ? instance : new LeadsEdit();
	
	
	/** UI Mappings */

	By saveButtonLocator = By.cssSelector("input[title='Save']");
	By cancelButtonLocator = By.cssSelector("input[title='Cancel']");
	By errorLocator = By.xpath("//div/div[contains(text(), 'Error: Invalid Data')]");
	By leadSourceLocator = By.xpath("//td[class=contains(text(), 'labelCol')]/label[text()='Lead Source']/../following::td[1]/descendant::select[1]");
	By leadStatusLocator = By.xpath("//td[class=contains(text(), 'labelCol')]/label[text()='Lead Status']/../following-sibling::td/div/span/select");
	By stateProvinceLocator = By.xpath("//td[@class='labelCol']/label[text()='State/Province']/../following::td[1]/descendant::input[1]");
	By languageLocator = By.xpath("//td/label[text()='Language']/following::td[1]/descendant::select[1]");
	By countryLocator = By.xpath("//td/descendant::label[text()='Country']/../following::td[1]/descendant::input[1]");
	By companyNameLocator = By.xpath("//td/descendant::label[text()='Company']/../following::td[1]/descendant::input[1]");
	By lastNameLocator = By.xpath("//td/descendant::label[text()='Last Name']/../following::td[1]/descendant::input[1]");
	
	
	
	/** Page Methods */

	public LeadsEdit verifyPageLoad()
	{
		findElement(saveButtonLocator);
		return this;
	}

	public LeadsDetail clickOnSaveButton()
	{
		pagelogger.debug("Clicking on the Save Button...");
		
		clickOnElement(saveButtonLocator);
		return LeadsDetail.Instance;
	}
	
	public LeadsDetail clickOnCancelButton()
	{
		pagelogger.debug("Clicking on the Save Button...");
		
		clickOnElement(cancelButtonLocator);
		return LeadsDetail.Instance;
	}

	public LeadsEdit setCompany(String fieldValue)
	{
		pagelogger.debug("Setting Company Name: "  + fieldValue);

		findElement(companyNameLocator);
		
		findElement(companyNameLocator).clear();
		findElement(companyNameLocator).sendKeys(fieldValue);
		
		return this;
	}

	public LeadsEdit setLastName(String lastName)
	{
		pagelogger.debug("Setting Last Name:"  + lastName);
		
		findElement(lastNameLocator);

		findElement(lastNameLocator).clear();
		findElement(lastNameLocator).sendKeys(lastName);
		
		return this;
	}

	public LeadsEdit setLeadStatus(String leadStatus)
	{
		pagelogger.debug("Setting the Lead Status: "  + leadStatus);
		
		findElement(lastNameLocator);
		
		String id = getAttributeID(leadStatusLocator);
		SalesforcePageExtensions.selectOption(driver, id, leadStatus);
		
		return this;
	}

	public LeadsEdit setCountry(String country)
	{
		pagelogger.debug("Setting Country value: "  + country);

		findElement(countryLocator).clear();
		findElement(countryLocator).sendKeys(country);
		
		return this;
	}

	public LeadsEdit setLeadSource(String optionValue)
	{
		pagelogger.debug("Selecting the lead source: "  + optionValue);

		String val = getAttributeID(leadSourceLocator);
		SalesforcePageExtensions.selectOption(driver, val, optionValue);
		
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

	public List<String> returnAllLeadRecordLabels()
	{
		pagelogger.debug("Returning all labels");

		List<String> labels = SalesforcePageExtensions.returnAllLabelsAsList(driver);
		return labels;
	}

	public List<String> returnAllRequiredLeadRecordFields()
	{
		pagelogger.debug("Returning all fields");
		List<String> fields = SalesforcePageExtensions.returnAllRequiredFieldsAsList(driver);
		return fields;
	}

	public List<String> returnAllSelectOptionsForLeadSource()
	{
		pagelogger.debug("Returning all select options for Lead Source");
		List<String> fields = SalesforcePageExtensions.returnSelectOptionsAsList(driver, leadSourceLocator);
		return fields;
	}

	public List<String> returnAllSelectOptionsForLeadStatus()
	{
		pagelogger.debug("Returning all select options for Lead Status");
		List<String> fields = SalesforcePageExtensions.returnSelectOptionsAsList(driver, leadStatusLocator);
		return fields;
	}

	
	public List<String> returnAllPicklistOptions(By parent)
	{
		pagelogger.debug("Returning all picklist Options");
		List<String> fields = SalesforcePageExtensions.returnPicklistOptionsAsList(driver, parent);
		return fields;
	}
	
}
