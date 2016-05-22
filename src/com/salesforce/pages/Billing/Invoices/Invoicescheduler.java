package com.salesforce.pages.Billing.Invoices;

import org.openqa.selenium.By;
/**import java.util.concurrent.TimeUnit;
import java.text.ParseException;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;
import com.salesforce.utils.driver.SalesforcePageExtensions;*/
import com.salesforce.pages.PageBase;
public class Invoicescheduler extends PageBase {

	//private static final TimeUnit SECONDS = null;
	private static Invoicescheduler instance;
	public static Invoicescheduler Instance = (instance != null) ? instance : new Invoicescheduler();

	
	
	/** UI Mappings */
	
	
	
	By schedulerLocator = By.xpath(".//*[@id='01r280000007ETR_Tab']/a");
	By newButtonLocator = By.xpath(".//*[@id='hotlist']/table/tbody/tr/td[2]/input");
	By nameLocator = By.id("j_id0:form1:mainSection:j_id39:j_id40:0:j_id41");
	By currencyLocator = By.id("j_id0:form1:mainSection:j_id39:j_id40:2:j_id41");
	By dateLocator = By.id("j_id0:form1:mainSection:j_id42:j_id43");
	By savelocator = By.xpath(".//*[@id='j_id0:form1:mainSection:j_id8:j_id9']");
	By invoiceschedulerlocator = By.xpath("//div/h2[@class='pageDescription']");
	
	public Invoicescheduler clickOnInvoiceScheduler() {
		pagelogger.debug("Clicking on invoice scheduler...");
		clickOnElement(schedulerLocator);
		return this;
	}
	
	public String getHeaderText()
	{
		pagelogger.debug("Getting the Account Header text");
		String val = findElement(invoiceschedulerlocator).getText();
		return val;
	}
	
	public Invoicescheduler clickOnNewButton() {
		pagelogger.debug("Clicking on new button...");
		clickOnElement(newButtonLocator);
		return this;
	}
	
	public Invoicescheduler setSchedulerName(String fieldValue)
	{
		pagelogger.debug("Setting scheduler Name to: "  + fieldValue);

		findElement(nameLocator);
		
		findElement(nameLocator).sendKeys(fieldValue);
		
		return this;
	}
	
	public Invoicescheduler setCurrency(String fieldValue)
	{
		pagelogger.debug("Setting currency: "  + fieldValue);

		findElement(currencyLocator);
		
		findElement(currencyLocator).sendKeys(fieldValue);
		
		return this;
	}
	
	public Invoicescheduler setDateAndTime(String fieldValue) throws InterruptedException
	{
		pagelogger.debug("Setting Date and Time: "  + fieldValue);

		findElement(dateLocator);
		findElement(dateLocator).clear();
		Thread.sleep(2000);
		
		findElement(dateLocator).sendKeys(fieldValue);
		
		return this;
	}
	
	public Invoicescheduler clickOnSave() throws InterruptedException {
		pagelogger.debug("Clicking on the button...");
		
		clickOnElement(savelocator);
		Thread.sleep(30000);
		return this;
	}
	
}
