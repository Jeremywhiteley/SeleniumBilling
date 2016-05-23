package com.salesforce.pages.Billing.Orders;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.SalesforcePageExtensions;

public class Updateorderstatus extends PageBase {

	private static Updateorderstatus instance;
	public static Updateorderstatus Instance = (instance != null) ? instance : new Updateorderstatus();
	
	 /** UI Mappings */
	
		By updatelocator = By.xpath("//input[@value='Update Order Status']");
	    By savelocator   = By.xpath("//input[@value='Save']");
	    By statuslocator = By.xpath(".//*[@id='j_id0:j_id6:pbMain:j_id45:0:j_id46:0:j_id47:1:j_id67']");
	    By statusendlocator = By.xpath(".//*[@id='j_id0:j_id6:pbMain']/div[2]/table/tbody/tr[2]/td[11]/span/span/a");
	    By orderheaderlocator = By.xpath("//div/h2[@class='pageDescription']");
		
		public Updateorderstatus clickOnUpdateOrderStatus() {
			pagelogger.debug("Clicking on the update order status button...");
			clickOnElement(updatelocator);
			return this;
		}
		
		public Updateorderstatus clickOnServiceEndDate() {
			pagelogger.debug("Clicking on the update order status button...");
			clickOnElement(statusendlocator);
			return this;
		}
		
		public Updateorderstatus setStatus(String stage)
		{
			pagelogger.debug("Setting status: "  + stage);

			SalesforcePageExtensions.waitForPageToLoad(driver);

			String id = getAttributeID(statuslocator);
			SalesforcePageExtensions.selectOption(driver, id, stage);

			return this;
		}
		
		public Updateorderstatus clickOnSave() {
			pagelogger.debug("Clicking on the save button...");
			clickOnElement(savelocator);
			return this;
		}
		
		public String getHeaderText()
		{
			pagelogger.debug("Getting the Account Header text");
			String val = findElement(orderheaderlocator).getText();
			return val;
		}
		
		
}
