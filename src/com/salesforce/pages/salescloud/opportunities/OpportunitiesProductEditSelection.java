package com.salesforce.pages.salescloud.opportunities;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;

public class OpportunitiesProductEditSelection extends PageBase
{

	private static OpportunitiesProductEditSelection instance;
	public static OpportunitiesProductEditSelection Instance = (instance != null) ? instance
			: new OpportunitiesProductEditSelection();

	/** UI Mappings */

	By saveButtonLocator = By.cssSelector("input[title='Save']");
	By cancelButtonLocator = By.cssSelector("input[title='Cancel']");
	By directMailSalesPriceLocator = By
			.xpath("//tr/th[contains(text(), 'Direct Mail')]/following-sibling::td/descendant::input[contains(@id, 'Price')]");
	By quantityInputLocator = By.xpath("//input[contains(@name,'Quantity')]");

	/** Page Methods */

	public OpportunitiesProductEditSelection verifyPageLoad()
	{
		pagelogger.debug("Verifying that the opportunities product selection page has loaded...");

		findElement(saveButtonLocator);
		return this;
	}

	public OpportunitiesProductEditSelection enterQuantityForProductSelected(String quantity)
	{
		pagelogger.debug("Adding Quantity for the product selected: " + quantity);

		findElement(quantityInputLocator).clear();
		findElement(quantityInputLocator).sendKeys(quantity);
		return this;
	}

	public OpportunitiesDetail clickOnSave()
	{
		pagelogger.debug("Saving the opportunity record...");

		clickOnElement(saveButtonLocator);

		return OpportunitiesDetail.Instance;
	}

	public OpportunitiesDetail clickOnCancel()
	{
		pagelogger.debug("CLicking on the Cencel Button...");

		clickOnElement(cancelButtonLocator);

		return OpportunitiesDetail.Instance;
	}

	public boolean verifyDirectMailPrice(String price)
	{
		pagelogger.debug("Verying the Direct Mail price: " + price);

		boolean val = false;
		findElement(directMailSalesPriceLocator);
		String currentPrice = findElement(directMailSalesPriceLocator).getAttribute("value");

		if (currentPrice.toUpperCase().trim().equals(price.toUpperCase().trim()))
		{
			pagelogger
					.debug("The direct mail price on the record and the passed in value matched!");
			val = true;
		} else
		{
			pagelogger
					.debug("The direct mail price on the record did not match the passed in value (record,passedVal)"
							+ currentPrice + ", " + price);
		}

		return val;
	}

}
