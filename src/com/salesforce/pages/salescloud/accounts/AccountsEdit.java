package com.salesforce.pages.salescloud.accounts;

import java.util.List;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.SalesforcePageExtensions;
import com.salesforce.utils.driver.VerifyPageElementsExtensions;


public class AccountsEdit extends PageBase
{

	 
	private static AccountsEdit instance;
	public static AccountsEdit Instance = (instance != null) ? instance : new AccountsEdit();

	
	/** UI Mappings */

	By saveButtonLocator = By.cssSelector("input[title='Save']");
	By errorLocator = By.xpath("//div/div[contains(text(), 'Error: Invalid Data')]");
	By industryLocator = By
			.xpath("//td[class=contains(text(), 'labelCol')]/following::label[text()='Industry']/../following-sibling::td[1]/descendant::select[1]");
	By typeLocator = By
			.xpath("//td[class=contains(text(), 'labelCol')]/following::label[text()='Type']/../following-sibling::td[1]/descendant::select[1]");
	By billingAddressStreetLocator = By
			.xpath("//label[text()='Billing Street']/following::td[1]/descendant::textarea[1]");
	By billingAddressCityLocator = By
			.xpath("//label[text()='Billing City']/following::td[1]/descendant::input[1]");
	By billingAddressZipLocator = By
			.xpath("//label[text()='Billing Zip/Postal Code']/following::td[1]/descendant::input[1]");
	By billingAddressStateLocator = By
			.xpath("//label[text()='Billing State/Province']/following::td[1]/descendant::input[1]");
	By billingAddressCountryLocator = By
			.xpath("//label[text()='Billing Country']/following::td[1]/descendant::input[1]");
	By accountNameLocator = By.xpath("//label[text()='Account Name']/../following::input[1]");

	
	
	/** Page Methods */

	public AccountsEdit verifyPageLoad()
	{
		pagelogger.debug("Waiting for page to load");
		findElement(saveButtonLocator);
		return AccountsEdit.Instance;
	}

	public AccountDetail clickOnSaveButton()
	{
		pagelogger.debug("Clicking on the Save button...");

		clickOnElement(saveButtonLocator);

		return AccountDetail.Instance;
	}

	public AccountsEdit setAccountName(String accountName)
	{
		pagelogger.debug("Setting Account Name to: "  + accountName);

		findElement(accountNameLocator);

		findElement(accountNameLocator).clear();
		findElement(accountNameLocator).sendKeys(accountName);

		return this;
	}

	public AccountsEdit setType(String optionValue)
	{
		pagelogger.debug("Setting Type to value: "  + optionValue);

		String val = getAttributeID(typeLocator);
		SalesforcePageExtensions.selectOption(driver, val, optionValue);

		return this;
	}

	public boolean verifyTDValuesExist(String fields)
	{
		boolean noErrorsFound = true;

		pagelogger.debug("Verifying all labels exist (TD)");

		String[] arrFields = fields.split("\\,", -1);
		List<String> result = VerifyPageElementsExtensions.verifyAllTDValuesExist(driver, arrFields);
		pagelogger.debug("Size: "  + result.size());

		if (result.size() > 0)
		{
			noErrorsFound = false;
		}

		return noErrorsFound;
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

	public List<String> returnAllAccountRecordLabels()
	{
		pagelogger.debug("Returning all account record labels");
		List<String> labels = SalesforcePageExtensions.returnAllLabelsAsList(driver);
		return labels;
	}

	public List<String> returnAllRequiredAccountRecordFields()
	{
		pagelogger.debug("Returning all required field list");
		List<String> fields = SalesforcePageExtensions.returnAllRequiredFieldsAsList(driver);
		return fields;
	}

	public List<String> returnAllSelectOptions()
	{
		pagelogger.debug("Returning all select options");
		List<String> fields = SalesforcePageExtensions.returnSelectOptionsAsList(driver, typeLocator);
		return fields;
	}

	public AccountsEdit setBillingStreet(String fieldValue)
	{
		pagelogger.debug("Setting the Billing Street to: "  + fieldValue);

		findElement(billingAddressStreetLocator);

		findElement(billingAddressStreetLocator).clear();
		findElement(billingAddressStreetLocator).sendKeys(fieldValue);

		return this;

	}

	public AccountsEdit setBillingCity(String fieldValue)
	{
		pagelogger.debug("Setting the Billing City to: "  + fieldValue);

		findElement(billingAddressCityLocator);

		findElement(billingAddressCityLocator).clear();
		findElement(billingAddressCityLocator).sendKeys(fieldValue);

		return this;
	}

	public AccountsEdit setBillingZip(String fieldValue)
	{
		pagelogger.debug("Setting the Billing Zip Code to: "  + fieldValue);

		findElement(billingAddressZipLocator);

		findElement(billingAddressZipLocator).clear();
		findElement(billingAddressZipLocator).sendKeys(fieldValue);

		return this;
	}

	public AccountsEdit setBillingState(String fieldValue)
	{
		pagelogger.debug("Setting the Billing State to: "  + fieldValue);

		findElement(billingAddressStreetLocator);

		findElement(billingAddressStreetLocator).clear();
		findElement(billingAddressStreetLocator).sendKeys(fieldValue);

		return this;
	}

	public AccountsEdit setBillingCountry(String fieldValue)
	{
		pagelogger.debug("Setting the Billing Country to: "  + fieldValue);

		findElement(billingAddressCountryLocator).clear();
		findElement(billingAddressCountryLocator).sendKeys(fieldValue);

		return this;
	}

	public AccountsEdit setIndustry(String optionValue)
	{

		pagelogger.debug("Selecting the Industry to: "  + optionValue);

		String val = getAttributeID(industryLocator);
		pagelogger.debug("Selecting the Industry: "  + optionValue);

		SalesforcePageExtensions.selectOption(driver, val, optionValue);

		return this;
	}
}
