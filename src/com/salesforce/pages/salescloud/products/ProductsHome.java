package com.salesforce.pages.salescloud.products;

import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.Select;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.SalesforcePageExtensions;

public class ProductsHome extends PageBase
{

	private static ProductsHome instance;
	public static ProductsHome Instance = (instance != null) ? instance : new ProductsHome();

	/** UI Mappings */

	By newButtonLocator = By.cssSelector("input[title='New']");
	By ownedProductViewLocator = By
			.xpath("//div/h3[text()='Owned Product Views']/following::div[1]/descendant::label[text()='View:']/following::span[1]/select");
	By ownedProductGoButtonLocator = By
			.xpath("//div/h3[text()='Owned Product Views']/following::div[1]/descendant::label[text()='View:']/following::span[1]/input");
	By priceBooksViewLocator = By
			.xpath("//div/h3[text()='Price Books']/following::div[1]/descendant::label[text()='View:']/following::span[1]/select");
	By priceBooksGoButtonLocator = By
			.xpath("//div/h3[text()='Price Books']/following::div[1]/descendant::label[text()='View:']/following::span[1]/input");
	By productViewLocator = By
			.xpath("//div/h3[text()='Product Views']/following::div[1]/descendant::label[text()='View:']/following::span[1]/select");
	By productGoButtonLocator = By
			.xpath("//div/h3[text()='Product Views']/following::div[1]/descendant::label[text()='View:']/following::span[1]/input");

	/** Page Methods */

	public ProductsHome verifyPageLoad()
	{
		pagelogger.debug("Waiting for page to load");

		SalesforcePageExtensions.waitForPageToLoad(driver);

		return this;
	}

	public ProductsHome clickOnNewButton()
	{
		pagelogger.debug("Clicking on Create New Record button");

		clickOnElement(newButtonLocator);
		return this;
	}

	public ProductsHome setOwnedProductViewFilter(String filter)
	{
		pagelogger.debug("Setting Owned Product View Filter to: " + filter);

		WebElement select = findElement(ownedProductViewLocator);
		String id = getAttributeID(ownedProductViewLocator);
		Select dropdown = new Select(select);

		pagelogger
				.debug("Selecting the following value from the Owned Product view filter dropdown: "
						+ filter);

		if (dropdown.getFirstSelectedOption().getText().toUpperCase()
				.equals(filter.toUpperCase().trim()))
		{
			pagelogger
					.debug("The <option> value was found as the default selected element. Selecting it now");
			clickOnElement(ownedProductGoButtonLocator);
		} else
		{
			SalesforcePageExtensions.selectOption(driver, id, filter);
		}

		return this;
	}

	public ProductsHome setProductViewFilter(String filter)
	{
		pagelogger.debug("Setting Product View Filter to: " + filter);

		String id = getAttributeID(productViewLocator);
		Select dropdown = new Select(findElement(productViewLocator));

		pagelogger.debug("Selecting the following value from the Product view filter dropdown: "
				+ filter);

		if (dropdown.getFirstSelectedOption().getText().toUpperCase()
				.equals(filter.toUpperCase().trim()))
		{
			pagelogger
					.debug("The <option> value was found as the default selected element. Selecting it now");
			clickOnElement(productGoButtonLocator);
		} else
		{
			SalesforcePageExtensions.selectOption(driver, id, filter);
		}

		return this;
	}

	public ProductsHome setPriceBookViewFilter(String filter)
	{
		pagelogger.debug("Setting Price Book View Filter to: " + filter);

		WebElement select = findElement(priceBooksViewLocator);
		String id = getAttributeID(priceBooksViewLocator);
		Select dropdown = new Select(select);

		pagelogger.debug("Selecting the following value from the Price Book view filter dropdown: "
				+ filter);

		if (dropdown.getFirstSelectedOption().getText().toUpperCase()
				.equals(filter.toUpperCase().trim()))
		{
			pagelogger
					.debug("The <option> value was found as the default selected element. Selecting it now");
			clickOnElement(priceBooksGoButtonLocator);
		} else
		{
			SalesforcePageExtensions.selectOption(driver, id, filter);
		}

		return this;
	}

	public ProductsHome sortProductsTableByLetter(String letter)
	{
		pagelogger.debug("Sorting Products Table by letter: " + letter);

		SalesforcePageExtensions.waitForPageToLoad(driver);
		SalesforcePageExtensions.sortRecordTableByLetter(driver, letter);
		return this;
	}

	public boolean selectFromProductsTable(String searchValue)
	{
		pagelogger.debug("Selecting the following from the Products table: " + searchValue);

		SalesforcePageExtensions.waitForPageToLoad(driver);
		boolean val = SalesforcePageExtensions.selectFromRecordTable(driver, searchValue);

		return val;
	}

}
