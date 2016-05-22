package com.salesforce.pages.salescloud.products;

import java.util.List;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class ProductsEditRecord extends PageBase
{

	 
	private static ProductsEditRecord instance;
	public static ProductsEditRecord Instance = (instance != null) ? instance
			: new ProductsEditRecord();

	
	/** UI Mappings */

	By saveButtonLocator = By.cssSelector("input[title='Save']");
	By errorLocator = By.xpath("//div/div[contains(text(), 'Error: Invalid Data')]");
	By accountRecordTypeValueLocator = By.xpath("//td[text()='Account Record Type']/following-sibling::td[1]");
	By productFamilyLocator = By.xpath("//td[class=contains(text(), 'labelCol')]/label[text()='Product Family']/following::td[1]/span/select");

	
	
	/** Page Methods */

	public List<String> returnAllProductRecordLabels()
	{
		pagelogger.debug("Returning all labels");

		List<String> labels = SalesforcePageExtensions.returnAllLabelsAsList(driver);
		return labels;
	}

	public List<String> returnAllRequiredProductRecordFields()
	{
		pagelogger.debug("Returning all record fields");
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
