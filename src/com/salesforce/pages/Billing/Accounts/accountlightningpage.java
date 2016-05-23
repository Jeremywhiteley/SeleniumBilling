package com.salesforce.pages.Billing.Accounts;

import java.util.List;

import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;

import com.salesforce.pages.PageBase;

public class accountlightningpage extends PageBase {
	
	private static accountlightningpage instance;
	public static accountlightningpage Instance = (instance != null) ? instance : new accountlightningpage();
	
    /** UI Mappings */

	By userlocator = By.xpath(".//div[@id='userNavButton']");
	By switchlocator = By.xpath(".//a[@title='Switch to Lightning Experience']");
	By checkboxlocator = By.xpath(".//input[@id='simpleDialog0checkbox']");
	By switchlocator1 = By.xpath("//input[@value='Switch']");
	By accountlocator = By.xpath(".//*[@href='#/sObject/Account/home']");
	By newlocator = By.xpath("//div[@title='New']");
	By accountnamelocator = By.xpath("//input[@class='input uiInput uiInputText uiInput--default uiInput--input']");
	By phonelocator = By.xpath("//div/label/span[text()='Phone']/../following::input[1]");
	By selectgatewaylocator = By.xpath("//input[@placeholder='Select Payment Gateway']");
	By gateway = By.xpath("//div[@title='First Data']");
	By wesitelocator = By.xpath("//div/label/span[text()='Website']/../following::input[1]");
	By typelocator = By.xpath("//label/span[text()='Type']/following::select[1]");
	
	By savelocator = By.xpath("//button[@title='Save']");
	
	public accountlightningpage clickOnUser() {
		pagelogger.debug("Clicking on invoice scheduler...");
		clickOnElement(userlocator);
		return this;
	}
	
	public accountlightningpage clickOnSwitch() {
		pagelogger.debug("Clicking on invoice scheduler...");
		clickOnElement(switchlocator1);
		return this;
	}
	
	public accountlightningpage clickOnCheckbox() {
		pagelogger.debug("Clicking on invoice scheduler...");
		clickOnElement(checkboxlocator);
		return this;
	}
	
	public accountlightningpage clickOnSwitchLighrning() {
		pagelogger.debug("Clicking on invoice scheduler...");
		clickOnElement(switchlocator);
		return this;
	}
	
	public accountlightningpage setAccountName(String fieldValue)
	{
		pagelogger.debug("Setting scheduler Name to: "  + fieldValue);

		findElement(accountnamelocator);
		
		findElement(accountnamelocator).sendKeys(fieldValue);
		
		return this;
	}
	
	public accountlightningpage setWebsiteName(String fieldValue)
	{
		pagelogger.debug("Setting website Name to: "  + fieldValue);

		findElement(wesitelocator);
		
		findElement(wesitelocator).sendKeys(fieldValue);
		
		return this;
	}
	
	public accountlightningpage clickOnDefaultPaymentGateway() throws InterruptedException {
		pagelogger.debug("Clicking on invoice scheduler...");
		clickOnElement(selectgatewaylocator);
		Thread.sleep(3000);
		return this;
	}
	
	public accountlightningpage setgateway()
	{
		pagelogger.debug("Setting scheduler Name to: ");
        clickOnElement(gateway);
		
        return this;
	}
	
	public accountlightningpage clickOnType()
	{
		pagelogger.debug("Setting type Name to: ");
        clickOnElement(typelocator);
		
        return this;
	}
	
	
	public accountlightningpage setPhoneNum(String fieldValue)
	{
		pagelogger.debug("Setting scheduler Name to: "  + fieldValue);

		findElement(phonelocator);
		
		findElement(phonelocator).sendKeys(fieldValue);
		
		return this;
	}
	
	public accountlightningpage clickOnAccounts() throws InterruptedException {
		pagelogger.debug("Clicking on invoice scheduler...");
		clickOnElement(accountlocator);
		return this;
	}
	
	public accountlightningpage clickOnNew() {
		pagelogger.debug("Clicking on invoice scheduler...");
		clickOnElement(newlocator);
		return this;
	}
	
	public accountlightningpage clickOnSave() {
		pagelogger.debug("Clicking on invoice scheduler...");
		clickOnElement(savelocator);
		return this;
	}

	public accountlightningpage verifyPageLoad() {
		findElement(savelocator);
		return this;
	}
	
	public boolean getPresenceOfActivity(String activityName)
	{
		pagelogger.debug("Searching Activity Related List for entry: " + activityName);

		boolean val = false;
		List<WebElement> rows = findElements(By
				.xpath("//div[contains(@id, 'RelatedActivityList')]/div/div/div[contains(@id, '_body')]/table/tbody/tr[contains(@class, 'dataRow')]/th/a"));

		for (int i = 1; i <= rows.size(); i++)
		{
			pagelogger.debug("Searching row [" + i + "] for value: " + activityName);

			if (rows.get(i - 1).getText().toUpperCase().trim()
					.equals(activityName.toUpperCase().trim()))
			{
				val = true;
				break;
			} else
			{
				pagelogger.debug("Did not find the passed in row. Found: "
						+ rows.get(i - 1).getText() + " wanted to find: "
						+ activityName.toUpperCase().trim());
			}
		}

		return val;

	}
	
}
