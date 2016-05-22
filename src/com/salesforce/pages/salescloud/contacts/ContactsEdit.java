package com.salesforce.pages.salescloud.contacts;

import java.util.List;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.SalesforcePageExtensions;
import com.salesforce.utils.driver.VerifyPageElementsExtensions;


public class ContactsEdit extends PageBase
{

	 
	private static ContactsEdit instance;
	public static ContactsEdit Instance = (instance != null) ? instance : new ContactsEdit();

	
	
	/** UI Mappings */

	By saveButtonLocator = By.cssSelector("input[title='Save']");
	By cancelButtonLocator = By.cssSelector("input[title='Cancel']");
	By lastNameLocator = By.xpath("//label[text()='Last Name']/following::td[1]/descendant::input[1]");
	By emailLocator = By.xpath("//label[text()='Email']/following::td[1]/descendant::input[1]");
	By phoneLocator = By.xpath("//label[text()='Phone']/following::td[1]/descendant::input[1]");
	By accountNameLocator = By.xpath("//label[text()='Account Name']/following::td[1]/descendant::span[1]/descendant::input[1]");
	By accountNameLookupLinkLocator = By.xpath("//label[text()='Account Name']/following::td[1]/descendant::span[1]/descendant::a[1]");
	By leadSourceLocator = By.xpath("//label[text()='Lead Source']/following::td[1]/descendant::select[1]");
	By titleLocator = By.xpath("//label[text()='Phone']/following::td[1]/descendant::input[1]");
	
	
	
	/** Page Methods */

	public ContactsEdit verifyPageLoad()
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}

	public ContactsDetail clickOnSaveButton()
	{
		pagelogger.debug("Saving contact record edit...");

		clickOnElement(saveButtonLocator);
		
		return ContactsDetail.Instance;
	}
	
	public ContactsDetail clickOnCancelButton()
	{
		pagelogger.debug("Canceling contact record edit...");

		clickOnElement(cancelButtonLocator);
		
		return ContactsDetail.Instance;
	}
	
	public ContactsEdit setLastName(String fieldValue)
	{
		pagelogger.debug("Setting Last Name to: "  + fieldValue);

		findElement(lastNameLocator);

		findElement(lastNameLocator).clear();
		findElement(lastNameLocator).sendKeys(fieldValue);
		
		return this;
	}
	
	public ContactsEdit setEmail(String fieldValue)
	{
		pagelogger.debug("Setting Email to: "  + fieldValue);

		findElement(emailLocator);

		findElement(emailLocator).clear();
		findElement(emailLocator).sendKeys(fieldValue);
		
		return this;
	}
	
	public ContactsEdit setPhone(String fieldValue)
	{
		pagelogger.debug("Setting Phone to: "  + fieldValue);

		findElement(phoneLocator);

		findElement(phoneLocator).clear();
		findElement(phoneLocator).sendKeys(fieldValue);
		
		return this;
	}
	
	public ContactsEdit setTitle(String fieldValue)
	{
		pagelogger.debug("Setting Title to: "  + fieldValue);

		findElement(titleLocator);

		findElement(titleLocator).clear();
		findElement(titleLocator).sendKeys(fieldValue);
		
		return this;
	}
	
	public ContactsEdit setAccountName(String fieldValue) throws InterruptedException
	{
		pagelogger.debug("Setting Account Name to: "  + fieldValue);

		String id = getAttributeID(accountNameLookupLinkLocator);
		String mwh = driver.getWindowHandle();
		SalesforcePageExtensions.selectFromLookup(driver, fieldValue, mwh, id);
		
		return this;
	}
	
	public ContactsEdit setLeadSource(String fieldValue)
	{
		pagelogger.debug("Setting Lead Source to: "  + fieldValue);

		String val = getAttributeID(leadSourceLocator);
		SalesforcePageExtensions.selectOption(driver, val, fieldValue);

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

	public List<String> returnAllContactRecordLabels()
	{
		pagelogger.debug("Returning all labels in the layout");

		List<String> labels = SalesforcePageExtensions.returnAllLabelsAsList(driver);
		return labels;
	}

	public List<String> returnAllRequiredContactRecordFields()
	{
		pagelogger.debug("Returning all Record fields in the layout");
		List<String> fields = SalesforcePageExtensions.returnAllRequiredFieldsAsList(driver);
		return fields;
	}

	public List<String> returnAllSelectOptions()
	{
		pagelogger.debug("Returning all select options in the layout");
		List<String> fields = SalesforcePageExtensions.returnSelectOptionsAsList(driver, leadSourceLocator);
		return fields;
	}

	public List<String> returnAllPicklistOptions(By parent)
	{
		pagelogger.debug("Returning all picklist options in the layout");
		List<String> fields = SalesforcePageExtensions.returnPicklistOptionsAsList(driver, parent);
		return fields;
	}
	
}
