package com.salesforce.pages.Billing.Orders;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;

public class Adhocinvoicepage extends PageBase{
	
	private static Adhocinvoicepage instance;
	public static Adhocinvoicepage Instance = (instance != null) ? instance : new Adhocinvoicepage();

	
	/** UI Mappings */
	
	By adhocinvoicelocator = By.xpath("//input[@value='Ad-hoc Invoice']");
	
	By invoicedatelocator = By.xpath(".//*[@id='j_id0:j_id1:pb:j_id29']/div/table/tbody/tr[2]/td/div/span/span/a");
	
	By targetdatelocator = By.xpath(".//*[@id='j_id0:j_id1:pb:j_id29']/div/table/tbody/tr[3]/td/div/span/span/a");
	
	By generateinvoicelocator = By.xpath("//input[@value='Generate Invoice']");
	
	By invoiceorderlocator = By.xpath(".//*[@id='lookupa0K28000001CYma00N2800000AItLA']");
	
	public Adhocinvoicepage clickOnNewButton() {
		pagelogger.debug("Clicking on the New button...");
		clickOnElement(adhocinvoicelocator);
		return this;
	}
	
	public Adhocinvoicepage clickOnInvoiceDate() {
		pagelogger.debug("Clicking on the New button...");
		clickOnElement(invoicedatelocator);
		return this;
	}
	
	public Adhocinvoicepage clickOnTargetDate() {
		pagelogger.debug("Clicking on the New button...");
		clickOnElement(targetdatelocator);
		return this;
	}
	
	public Adhocinvoicepage clickOnGenerateInvoice() {
		pagelogger.debug("Clicking on the New button...");
		clickOnElement(generateinvoicelocator);
		return this;
	}
	
	public String getHeaderText()
	{
		pagelogger.debug("Getting the Account Header text");
		String val = findElement(invoiceorderlocator).getText();
		return val;
	}
}
