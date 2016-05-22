package com.salesforce.pages.Billing.Invoices;

import org.openqa.selenium.By;
import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class ProfarmaInvoice extends PageBase{
	
	
	private static ProfarmaInvoice instance;
	public static ProfarmaInvoice Instance = (instance != null) ? instance : new ProfarmaInvoice();
	
	
	/** UI Mappings */
	
    By profarmaLocator= By.xpath(".//input[@name='generate_proforma_invoice']");
	
	By referenceLocator = By.xpath("//input[@Name='j_id0:j_id5:pb:j_id38:j_id39:j_id41']");
	
	By selectLoactor = By.xpath(".//input[@name='j_id0:j_id5:pb:j_id46:0:j_id48']");
	
	By clickOnButton = By.xpath(".//input[@name='j_id0:j_id5:pb:j_id34:j_id35']");
	
	By click= By.xpath(".//span[contains(text(),'Demo Order')]");
	
	By post = By.xpath(".//input[@name='post']");
	
	By cancel = By.xpath(".//input[@name='cancel_invoice']");
	
	By cancelLocator= By.xpath("//label[contains(text(),'Cancellation Reason')]/../..//select");
	
	By Regular = By.xpath(".//input[@name='convert_to_regular_invoice']");
	
	By confirm = By.xpath(".//input[@name='j_id0:j_id33:j_id38']");
	
	By confirmcancel = By.xpath(".//input[@name='j_id0:j_id28:j_id36']");
	
	By invoiceheaderlocator = By.xpath("//div/h2[@class='pageDescription']");
	
	
	public ProfarmaInvoice clickOnProfarmaInvoice() {
		pagelogger.debug("Clicking on the New button...");
		clickOnElement(profarmaLocator);
		return ProfarmaInvoice.Instance;
	}
	
	public String getHeaderText()
	{
		pagelogger.debug("Getting the Account Header text");
		String val = findElement(invoiceheaderlocator).getText();
		return val;
	}
	
	public ProfarmaInvoice clickOnOrder() {
		pagelogger.debug("Clicking on the New button...");
		clickOnElement(click);
		return ProfarmaInvoice.Instance;
	}
	
	public ProfarmaInvoice setReference(String fieldValue)
	{
		pagelogger.debug("Setting order terms: "  + fieldValue);

		findElement(referenceLocator).sendKeys(fieldValue);
		
		return ProfarmaInvoice.Instance;
	}
	
	public ProfarmaInvoice clickOnCheckBox() {
		pagelogger.debug("Clicking on the New button...");
		findElement(selectLoactor).click();
		return ProfarmaInvoice.Instance;
	}
	
	public ProfarmaInvoice clickOnProfarmaButton() {
		pagelogger.debug("Clicking on the New button...");
		clickOnElement(clickOnButton);
		return ProfarmaInvoice.Instance;
		
	}
	
	public ProfarmaInvoice clickOnPostButton() {
		pagelogger.debug("Clicking on the New button...");
		clickOnElement(post);
		return ProfarmaInvoice.Instance;
		
	}
	
	public ProfarmaInvoice clickOnCancelButton() {
		pagelogger.debug("Clicking on the New button...");
		clickOnElement(cancel);
		return ProfarmaInvoice.Instance;
		
	}
	
	public ProfarmaInvoice setCancelInvoice(String stage)
	{
		pagelogger.debug("Setting Opportunity Stage to: "  + stage);
		SalesforcePageExtensions.waitForPageToLoad(driver);

		String id = getAttributeID(cancelLocator);
		SalesforcePageExtensions.selectOption(driver, id, stage);

		return this;
	}

	
	public ProfarmaInvoice convertRegular() {
		pagelogger.debug("Clicking on the New button...");
		clickOnElement(Regular);
		return ProfarmaInvoice.Instance;
	}
	
	public ProfarmaInvoice clickOnConfirm() {
		pagelogger.debug("Clicking on the New button...");
		clickOnElement(confirm);
		return ProfarmaInvoice.Instance;
	}
	public ProfarmaInvoice clickOnConfirmCancel() {
		pagelogger.debug("Clicking on the New button...");
		clickOnElement(confirmcancel);
		return ProfarmaInvoice.Instance;
	}
}
