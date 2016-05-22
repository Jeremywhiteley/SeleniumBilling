package com.salesforce.pages.salescloud.events;

import java.util.List;

import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.pages.salescloud.accounts.AccountDetail;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class EventsEdit extends PageBase
{

	 
	private static EventsEdit instance;
	public static EventsEdit Instance = (instance != null) ? instance : new EventsEdit();
	
	
	/** UI Mappings */

	By saveButtonLocator = By.cssSelector("input[title='Save']");
	By assignedToParentLocator = By.xpath("//label[contains(text(), 'Assigned To')]/../following::td[1]//a");
	By typeLocator = By.xpath("//td[class=contains(text(), 'labelCol')]/span/label[text()='Type']/../following::td[1]/div/span/select");
	By showTimeLocator = By.xpath("//td[class=contains(text(), 'labelCol')]/following::label[text()='Show Time As']/following::td[1]/select");
	By nameLocator = By.xpath("//td[class=contains(text(), 'labelCol')]/span/label[text()='Name']/following::td[1]/div/select");
	By relatedToLocator = By.xpath("//td[class=contains(text(), 'labelCol')]/span/label[text()='Related To']/following::td[1]/div/select");
	By subjectLocator = By.xpath("//td/descendant::label[text()='Subject']/../following-sibling::td[1]/descendant::input[1]");
	
	
	/** Page Methods */

	public EventsEdit verifyPageLoad()
	{
		pagelogger.debug("Waiting for page to load");

		SalesforcePageExtensions.waitForPageToLoad(driver);

		return this;
	}
	

	public AccountDetail clickOnSaveButton()
	{
		pagelogger.debug("Clicking on the Edit button...");
		
		clickOnElement(saveButtonLocator);
		return AccountDetail.Instance;
	}

	public EventsEdit setAssignedTo(String name) throws InterruptedException
	{
		pagelogger.debug("Setting the Assigned To value to: "  + name);

		String id = getAttributeID(assignedToParentLocator);
		String mwh = driver.getWindowHandle();
		SalesforcePageExtensions.selectFromLookup(driver, name, mwh, id);
		
		return this;
	}

	public EventsEdit setName(String name)
	{
		pagelogger.debug("Setting Name to: "  + name);
		
		String id = getAttributeID(nameLocator);

		SalesforcePageExtensions.selectOption(driver, id, name);
		
		return this;
	}
	
	public EventsEdit setSubject(String fieldValue)
	{
		pagelogger.debug("Setting the Subject field to: "  + fieldValue);
		
		new WebDriverWait(driver, 30).until(ExpectedConditions
				.visibilityOfElementLocated(subjectLocator));
		
		findElement(subjectLocator).clear();
		findElement(subjectLocator).sendKeys(fieldValue);
		
		return this;
	}

	public List<String> returnAllEventRecordLabels()
	{
		pagelogger.debug("Returning all labels");

		List<String> labels = SalesforcePageExtensions.returnAllLabelsAsList(driver);
		return labels;
	}

	public List<String> returnAllRequiredEventRecordFields()
	{
		pagelogger.debug("Returning all required fields");
		List<String> fields = SalesforcePageExtensions.returnAllRequiredFieldsAsList(driver);
		return fields;
	}

	public List<String> returnAllSelectOptions(By parent)
	{
		pagelogger.debug("Returning all select options");
		List<String> fields = SalesforcePageExtensions.returnSelectOptionsAsList(driver, parent);
		return fields;
	}

	public List<String> returnAllPicklistOptions(By parent)
	{
		pagelogger.debug("Returning all picklist options");
		List<String> fields = SalesforcePageExtensions.returnPicklistOptionsAsList(driver, parent);
		return fields;
	}

}
