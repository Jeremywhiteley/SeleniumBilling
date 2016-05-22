package com.salesforce.pages.Billing.Accounts;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;




public class CreatesAccount extends PageBase {
	
	private static CreatesAccount instance;
	public static CreatesAccount Instance = (instance != null) ? instance : new CreatesAccount();

	
	
	/** UI Mappings */

	
	By accountLocator = By.xpath(".//*[@id='Account_Tab']/a");
	By newButtonLocator = By.xpath(".//*[@id='hotlist']/table/tbody/tr/td[2]/input");
	By nameLocator = By.id("acc2");
	By saveLocator = By.xpath(".//*[@id='topButtonRow']/input[1]");
	By accountHeaderLocator = By.xpath("//div/h2[@class='pageDescription']");
	
	
	public CreatesAccount clickOnAccounts() {
		pagelogger.debug("Clicking on invoice scheduler...");
		clickOnElement(accountLocator);
		return this;
	}
	
	public CreatesAccount clickOnNew() {
		pagelogger.debug("Clicking on invoice scheduler...");
		clickOnElement(newButtonLocator);
		return this;
	}
	
	public CreatesAccount setAccountName(String fieldValue)
	{
		pagelogger.debug("Setting scheduler Name to: "  + fieldValue);

		findElement(nameLocator);
		
		findElement(nameLocator).sendKeys(fieldValue);
		
		return this;
	}
	
	public CreatesAccount clickOnSave() throws InterruptedException
	{
		pagelogger.debug("Creating Account");

		clickOnElement(saveLocator);
        Thread.sleep(1000);
		
		return this;
	}
	
	public String getHeaderText()
	{
		pagelogger.debug("Getting the Account Header text");
		String val = findElement(accountHeaderLocator).getText();
		return val;
	}
}

