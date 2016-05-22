package com.salesforce.pages.Billing.Orders;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.SalesforcePageExtensions;

public class Addpaymentplanfororder extends PageBase {
	
	private static Addpaymentplanfororder instance;
	public static Addpaymentplanfororder Instance = (instance != null) ? instance : new Addpaymentplanfororder();


    /** UI Mappings */
	
	By paymentplanlocator = By.xpath("//input[@name='payment_plan']");
	
	By planlocator = By.xpath("//label[contains(text(), 'Payment Plan')]/../following::td//a");
	
	By showplanlocator = By.xpath("//input[@value='Show Plan']");
	
	By installmentlocator = By.xpath("//input[@value='Generate Installments']");
	
	By planheaderlocator = By.xpath(".//*[@id='lookupa0S28000002m3jg00N2800000AItN7']");
	
	By savelocator = By.xpath("//input[@value='Save']");
	
	public Addpaymentplanfororder clickOnPaymentplan() {
		pagelogger.debug("Clicking on the paymentplan button...");
		clickOnElement(paymentplanlocator);
		return this;
	}
	
	public Addpaymentplanfororder setPaymentplan(String planname) throws InterruptedException
	{
		pagelogger.debug("Setting Account Name to: "  + planname);

		String id = getAttributeID(planlocator);
		String mwh = driver.getWindowHandle();
		SalesforcePageExtensions.selectFromLookup(driver, planname, mwh, id);
		return this;
	}
	
	public Addpaymentplanfororder clickOnShowPlan() throws InterruptedException {
		pagelogger.debug("Clicking on the Showplan button...");	
		clickOnElement(showplanlocator);
		Thread.sleep(5000);
		return this;
	}
	
	public Addpaymentplanfororder clickOnGenerateInstallments() throws InterruptedException {
		pagelogger.debug("Clicking on the GenerateInstallments button...");
		clickOnElement(installmentlocator);
		Thread.sleep(5000);
		return this;
	}
	
	public Addpaymentplanfororder clickOnSave() {
		pagelogger.debug("Clicking on the Save button...");
		clickOnElement(savelocator);
		return this;
	}
	
	public String getHeaderText()
	{
		pagelogger.debug("Getting the Account Header text");
		String val = findElement(planheaderlocator).getText();
		return val;
	}
	
	
}
