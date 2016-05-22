package com.salesforce.pages.Billing.Orders;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;

public class orderpreviewinvoice extends PageBase {
	
	private static orderpreviewinvoice instance;
	public static orderpreviewinvoice Instance = (instance != null) ? instance : new orderpreviewinvoice();
	
	
	 /** UI Mappings */
	
		By previewinvoicelocator = By.xpath("//input[@value='Preview Invoice']");
		
		By invoicedatelocator = By.xpath(".//*[@id='j_id0:j_id2:pb:j_id29']/div/table/tbody/tr[2]/td/div/span/span/a");
		
		By targetlocator = By.xpath(".//*[@id='j_id0:j_id2:pb:j_id29']/div/table/tbody/tr[3]/td/div/span/span/a");
		
		By generateinvoicelocator = By.xpath("//input[@value='Generate Invoice Preview']");
		
		By invoiceheaderlocator= By.xpath(".//*[@id='pageContainer1']/xhtml:div[2]/xhtml:div[1]");
		
		public orderpreviewinvoice clickOnPreviewInvoice() {
			pagelogger.debug("Clicking on the paymentplan button...");
			clickOnElement(previewinvoicelocator);
			return this;
		}
		
		public orderpreviewinvoice clickOnInvoiceDate() {
			pagelogger.debug("Clicking on the paymentplan button...");
			clickOnElement(invoicedatelocator);
			return this;
		}
		
		public orderpreviewinvoice clickOnTargetDate() {
			pagelogger.debug("Clicking on the paymentplan button...");
			clickOnElement(targetlocator);
			return this;
		}
		
		public orderpreviewinvoice clickOnGenerateInvoice() {
			pagelogger.debug("Clicking on the paymentplan button...");
			clickOnElement(generateinvoicelocator);
			return this;
		}
		
		public String getHeaderText()
		{
			pagelogger.debug("Getting the Account Header text");
			String val = findElement(invoiceheaderlocator).getText();
			return val;
		}
		

}
