package com.salesforce.pages.Billing.Orders;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;

public class Generateinvoicepage extends PageBase {
	
	private static Generateinvoicepage instance;
	public static Generateinvoicepage Instance = (instance != null) ? instance : new Generateinvoicepage();

	
    /** UI Mappings **/
	
    By generateinvoicelocator = By.xpath("//input[@value='Generate Invoice']");
    
	By invoiceorderlocator = By.xpath(".//*[@id='bodyCell']/div[1]/div[1]/div[1]/h1");
	
	By confirmlocator = By.xpath("//input[@value='Confirm']");

	
    public Generateinvoicepage clickOnGenerateInvoice(){
		
		pagelogger.debug("Clicking on clone button");
		clickOnElement(generateinvoicelocator);
		return this;
	}
    
   public Generateinvoicepage clickOnConfirm(){
		
		pagelogger.debug("Clicking on clone button");
		clickOnElement(confirmlocator);
		return this;
	}
    
	
    public String getHeaderText()
	{
		pagelogger.debug("Getting the Account Header text");
		String val = findElement(invoiceorderlocator).getText();
		return val;
	}
	
}
