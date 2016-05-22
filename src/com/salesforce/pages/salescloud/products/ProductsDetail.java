package com.salesforce.pages.salescloud.products;

import java.util.List;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.SalesforcePageExtensions;
import com.salesforce.utils.driver.VerifyPageElementsExtensions;


public class ProductsDetail extends PageBase
{

	 
	private static ProductsDetail instance;
	public static ProductsDetail Instance = (instance != null) ? instance : new ProductsDetail();

	
	/** UI Mappings */

	By editButtonLocator = By.cssSelector("input[title='Edit']");
	By deleteButtonLocator = By.cssSelector("input[title='Delete']");
	By errorLocator = By.xpath("//div/div[contains(text(), 'Error: Invalid Data')]");

	
	
	/** Page Methods  */

	public ProductsDetail verifyPageLoad()
	{
		pagelogger.debug("Waiting for page to load");

		SalesforcePageExtensions.waitForPageToLoad(driver);

		return this;
	}

	public ProductsEditRecord clickOnEditButton()
	{
		pagelogger.debug("Clicking on the Edit button...");

		clickOnElement(editButtonLocator);
		return ProductsEditRecord.Instance;
	}

	public ProductsHome deleteRecord()
	{
		pagelogger.debug("Clicking on the Delete button...");

		clickOnElement(deleteButtonLocator);
		return ProductsHome.Instance;
		
	}

	public boolean verifyLabelFieldsExist(String fields)
	{
		boolean noErrorsFound = true;

		String[] arrFields = fields.split("\\,", -1);
		List<String> result = VerifyPageElementsExtensions.verifyAllFieldLabelsExist(driver, arrFields);

		if (result.size() > 0)
		{
			noErrorsFound = false;
		}

		return noErrorsFound;
	}

	public boolean verifyFieldsEnabled(String fields)
	{

		boolean val = true;

		String[] arrFields = fields.split("\\,", -1);
		List<String> result = VerifyPageElementsExtensions.verifyFieldsAreEnabled(driver, arrFields);

		pagelogger.debug("Number of list items returned as disabled: "  + result.size());

		if (result.size() > 0)
		{
			val = false;
		}

		return val;
	}

	public boolean verifyHeaderValuesExist(String fields)
	{

		boolean noErrorsFound = true;

		String[] arrFields = fields.split("\\,", -1);
		List<String> result = VerifyPageElementsExtensions.verifyAllTDValuesExist(driver, arrFields);
		pagelogger.debug("Size: "  + result.size());

		if (result.size() > 0)
		{
			noErrorsFound = false;
		}

		return noErrorsFound;
	}

	public boolean verifyTDValuesExist(String fields)
	{
		boolean noErrorsFound = true;

		String[] arrFields = fields.split("\\,", -1);
		List<String> result = VerifyPageElementsExtensions.verifyAllTDValuesExist(driver, arrFields);
		pagelogger.debug("Size: "  + result.size());

		if (result.size() > 0)
		{
			noErrorsFound = false;
		}

		return noErrorsFound;
	}

}
