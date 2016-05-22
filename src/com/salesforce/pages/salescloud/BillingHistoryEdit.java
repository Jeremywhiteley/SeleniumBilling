package com.salesforce.pages.salescloud;

import java.util.List;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class BillingHistoryEdit extends PageBase
{

	 
	private static BillingHistoryEdit instance;
	public static BillingHistoryEdit Instance = (instance != null) ? instance : new BillingHistoryEdit();

	
	/** UI Mappings */

	By saveButtonLocator = By.cssSelector("input[title='Save']");
	public By previousPaymentMethodsLocator = By.xpath("//tr/td[@class='labelCol']/label[text()='Previous Payment Methods']/following::td[1]/descendant::select");
	public By statusLocator = By.xpath("//tr/td[@class='labelCol']/label[text()='Status']/following::td[1]/descendant::select");
	
	
	/** Page Methods */

	public void verifyPageLoad()
	{
		findElement(saveButtonLocator);
	}

	public List<String> returnAllHistoryRecordLabels()
	{
		List<String> labels = SalesforcePageExtensions.returnAllLabelsAsList(driver);
		return labels;
	}

	public List<String> returnAllRequiredHistoryRecordFields()
	{
		List<String> fields = SalesforcePageExtensions.returnAllRequiredFieldsAsList(driver);
		return fields;
	}

	public List<String> returnAllSelectOptions(By parent)
	{
		List<String> fields = SalesforcePageExtensions.returnSelectOptionsAsList(driver, parent);
		return fields;
	}

	public List<String> returnAllPicklistOptions(By parent)
	{
		List<String> fields = SalesforcePageExtensions.returnPicklistOptionsAsList(driver, parent);
		return fields;
	}

}
