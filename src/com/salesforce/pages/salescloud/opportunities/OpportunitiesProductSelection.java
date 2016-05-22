package com.salesforce.pages.salescloud.opportunities;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;


public class OpportunitiesProductSelection extends PageBase
{

	 
	private static OpportunitiesProductSelection instance;
	public static OpportunitiesProductSelection Instance = (instance != null) ? instance : new OpportunitiesProductSelection();
	
	
	/** UI Mappings */

	By selectDirectMailCheckboxLoator = By.xpath("//a[span[text()='Direct Mail']]/preceding::td[3]/div/input");
	By selectButtonLocator = By.cssSelector("input[title='Select']");
	
	
	
	/** Page Methods */

	public OpportunitiesProductSelection verifyPageLoad()
	{
		pagelogger.debug("Verifying that the opportunities product selection page has loaded...");
		findElement(selectButtonLocator);
		return this;
	}

	public OpportunitiesProductEditSelection clickOnSelectButton()
	{
		pagelogger.debug("Clicking on Select Button...");

		clickOnElement(selectButtonLocator);

		return OpportunitiesProductEditSelection.Instance;
	}

	public OpportunitiesProductSelection checkmarkDirectMail()
	{
		pagelogger.debug("Checking the Direct Mail Checkbox...");

		clickOnElement(selectDirectMailCheckboxLoator);
		return this;
	}

	public OpportunitiesProductSelection checkProductFromList(String productName)
	{
		pagelogger.debug("Checking the Product Checkbox: "  + productName);

		String prodNameLocator = "//span[text()='" + productName + "']/../../../..//input";
		clickOnElement(By.xpath(prodNameLocator));
		return this;
	}
}
