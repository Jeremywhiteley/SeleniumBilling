package com.salesforce.pages.Billing.Orders;

import java.text.ParseException;
//import java.util.concurrent.TimeUnit;

import org.openqa.selenium.By;
/**import org.openqa.selenium.WebElement;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;*/

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.SalesforcePageExtensions;

public class OrderHome extends PageBase {

	//private static final TimeUnit SECONDS = null;
	private static OrderHome instance;
	public static OrderHome Instance = (instance != null) ? instance : new OrderHome();

	
	
	/** UI Mappings */
	
	By clickNewButton = By.cssSelector("input[name='new']");
	By nameLocator = By.id("j_id0:jobForm:pb:render:j_id37");
	By termsLocator = By.id("j_id0:jobForm:pb:render:j_id38:7:j_id39");
	By renewlocator = By.xpath(".//*[@id='j_id0:jobForm:pb:render:j_id38:6:j_id39']");
	By orderheaderlocator = By.xpath("//div/h2[@class='pageDescription']");

	By nextButtonLocator = By.xpath(".//*[@id='j_id0:jobForm:pb:j_id32']/input[1]");
	
	By PBDM = By.xpath(".//*[@id='j_id0:jobForm:pb:render:j_id38:11:j_id39']");
	
	By paymentTerms= By.id("j_id0:jobForm:pb:render:j_id38:13:j_id39");
	By serviceStartDate = By.id("j_id0:jobForm:pb:render:j_id38:10:j_id39");
	
	By accountNameLocator = By.xpath("//label[contains(text(), 'Account')]/../following::td//a");

	By addproductlocator = By.id("j_id0:j_id3:j_id33:searchString");
	
	//By addLocator = By.xpath(".//*[@id='ui-active-menuitem']/button");
	
	By addLocator = By.xpath("//a[contains(text(),'GenWatt Diesel 200kW')]/..//button[text()='Add']");  // //a[@id='ui-active-menuitem']/button
	
	By addLocator3 = By.xpath("//a[contains(text(),'GenWatt Propane 500kW')]/..//button[text()='Add']");  // //a[@id='ui-active-menuitem']/button
	
	By step2ButtonLocator = By.xpath(".//*[@id='j_id0:j_id3:j_id33:j_id34']/input[2]");
	
	By savelocator = By.xpath(".//*[@id='j_id0:j_id7:pb:j_id33:j_id35']");
	
	By editlocator = By.xpath("//input[@value=' Edit ']");
	
	By removelocator = By.xpath(".//*[@id='j_id0:j_id3:jobrateplancharges:j_id96:0:j_id97:0:j_id98:0:j_id100']");
	
	By addLocator2 = By.xpath("//a[contains(text(),'GenWatt Diesel 200kW')]/..//button[text()='Add']");  // //a[@id='ui-active-menuitem']/button
 
	By midtermlocator = By.xpath("//input[@value='Mid-Term Adjustment']");
	
	By midtermsearchlocator = By.xpath(".//*[@id='j_id0:j_id5:j_id13:searchString']");
	
	By midtermsavelocator = By.xpath(".//*[@id='j_id0:j_id5:page4:j_id172:j_id173']");
	
	By serviceenddatelocator = By.xpath(".//*[@id='j_id0:j_id5:jobrateplancharges']/div[2]/table/tbody/tr[1]/td[12]/span/span/a");
	
	By startdatelocator = By.xpath(".//*[@id='j_id0:j_id5:jobrateplancharges']/div[2]/table/tbody/tr[3]/td[11]/span/span/a");
	
	By startdatelocator1 = By.xpath(".//*[@id='j_id0:j_id5:jobrateplancharges']/div[2]/table/tbody/tr[5]/td[11]/span/span/a");
	
	By startdatelocator2 = By.xpath(".//*[@id='j_id0:j_id5:jobrateplancharges']/div[2]/table/tbody/tr[6]/td[11]/span/span/a");
	
	By changeqtylocator = By.xpath(".//*[@id='j_id0:j_id5:jobrateplancharges:midBlock:0:j_id130:0:j_id131:0:j_id133']");
	
    By changeqtylocator1 = By.xpath(".//*[@id='j_id0:j_id5:jobrateplancharges:midBlock:1:j_id130:0:j_id131:0:j_id133']");

	By increaseqtylocator = By.xpath(".//*[@id='j_id0:j_id5:jobrateplancharges:midBlock:0:j_id130:0:j_id131:1:j_id147']");
	
	By decreseqtylocator = By.xpath(".//*[@id='j_id0:j_id5:jobrateplancharges:midBlock:1:j_id130:0:j_id131:1:j_id147']");
	
	By downgradestartdate = By.xpath(".//*[@id='j_id0:j_id5:jobrateplancharges']/div[2]/table/tbody/tr[3]/td[12]/span/span/a");
	
	By subtotallocator = By.xpath(".//*[@id='ep']/div[2]/div[12]/table/tbody/tr[1]/td[2]");
	
	By tcvlocator = By.xpath(".//*[@id='ep']/div[2]/div[4]/table/tbody/tr[3]/td[4]");

	public OrderHome clickOnNewButton() {
		pagelogger.debug("Clicking on the New button...");
		clickOnElement(clickNewButton);
		return OrderHome.Instance;
	}
	
	public OrderHome clickOnServiceEndDate() {
		pagelogger.debug("Clicking on the service end  button...");
		clickOnElement(serviceenddatelocator);
		return OrderHome.Instance;
	}
	
	public OrderHome clickOnServiceEndDateDowngrade() {
		pagelogger.debug("Clicking on the service end  button...");
		clickOnElement(downgradestartdate);
		return OrderHome.Instance;
	}
	
	public  String getHeaderText()
	{
		pagelogger.debug("Getting the Account Header text");
		String val = findElement(orderheaderlocator).getText();
		return val;
	}
	
	public String getSubTotal()
	{
		pagelogger.debug("Getting the Account Header text");
		String val = findElement(subtotallocator).getText();
		return val;
	}
	
	public String getTCV()
	{
		pagelogger.debug("Getting the Account Header text");
		String val = findElement(tcvlocator).getText();
		return val;
	}
	
	
	public OrderHome setOrderName(String fieldValue)
	{
		pagelogger.debug("Setting order Name to: "  + fieldValue);

		findElement(nameLocator);
		
		findElement(nameLocator).sendKeys(fieldValue);
		
		return OrderHome.Instance;
	}
	
	public OrderHome setTerms(String fieldValue)
	{
		pagelogger.debug("Setting order terms: "  + fieldValue);

		findElement(termsLocator);
		findElement(termsLocator).sendKeys(fieldValue);
		
		return OrderHome.Instance;
	}
	
	public OrderHome clickOnNextButton()
	{
		pagelogger.debug("Saving order wizard step1...");

		clickOnElement(nextButtonLocator);
		
		return OrderHome.Instance;
	}

	
   public OrderHome setRenew(String fieldValue)
	{
		pagelogger.debug("Setting renew: "  + fieldValue);

		findElement(renewlocator);
		findElement(renewlocator).isDisplayed();
		
		return OrderHome.Instance;
	}
	
	public OrderHome setPBDM(String stage)
	{
		pagelogger.debug("Setting Preffred billing day of month: "  + stage);

		SalesforcePageExtensions.waitForPageToLoad(driver);

		String id = getAttributeID(PBDM);
		SalesforcePageExtensions.selectOption(driver, id, stage);

		return this;
	}
	
	public OrderHome setPaymentTerms(String stage)
	{

		pagelogger.debug("Setting Payment Terms: "  + stage);

		SalesforcePageExtensions.waitForPageToLoad(driver);

		String id = getAttributeID(paymentTerms);
		SalesforcePageExtensions.selectOption(driver, id, stage);

		return this;
	}
	
	public OrderHome enterStartDate(String date) throws ParseException
	{
		
		pagelogger.debug("Setting Opportunity Close Date to: "  + date);

		synchronize(30);

		findElement(serviceStartDate).clear();
		findElement(serviceStartDate).sendKeys(date);
		return this;
	}
	public OrderHome setAccountName(String accountName) throws InterruptedException
	{
		pagelogger.debug("Setting Account Name to: "  + accountName);

		String id = getAttributeID(accountNameLocator);
		String mwh = driver.getWindowHandle();
		SalesforcePageExtensions.selectFromLookup(driver, accountName, mwh, id);
		
		return this;
	}
	
	public OrderHome addProducts(String productname)
	{
		pagelogger.debug("Setting Opportunity Close Date to: "  + productname);
		findElement(addproductlocator).sendKeys(productname);
		
		return this;
	}
	
	public OrderHome clickOnAddButton() throws InterruptedException
	{
			
		pagelogger.debug("adding product to order...");

		clickOnElement(addLocator);
	    //driver.manage().timeouts().implicitlyWait(8, TimeUnit.SECONDS);
		Thread.sleep(40000);
		
		return OrderHome.Instance;
	}
	
	public OrderHome clickOnAddButton2() throws InterruptedException
	{
			
		pagelogger.debug("adding product to order...");

		clickOnElement(addLocator3);
	    //driver.manage().timeouts().implicitlyWait(8, TimeUnit.SECONDS);
		Thread.sleep(40000);
		
		return OrderHome.Instance;
	}
	
	public OrderHome clickOnNextStep2Button()
	{
		pagelogger.debug("Saving order wizard step2...");

		clickOnElement(step2ButtonLocator);
		
		return OrderHome.Instance;
	}
	
	public OrderHome clickOnSaveButton() throws InterruptedException
	{
		pagelogger.debug("Saving order wizard step2...");

		clickOnElement(savelocator);
		
		Thread.sleep(1000);
		
		return OrderHome.Instance;
	}
	
	//Below Methods are using in edit order class
	
	public OrderHome clickOnEdit()
	{
		pagelogger.debug("Clicking on edit....");

		clickOnElement(editlocator);
		
		return OrderHome.Instance;
	}
	
	public OrderHome clickOnRemove()
	{
		pagelogger.debug("Removing product....");

		clickOnElement(removelocator);
		
		return OrderHome.Instance;
	}
	
	public OrderHome clickOnAdd() throws InterruptedException
	{

		clickOnElement(addLocator2);
	
	    //driver.manage().timeouts().implicitlyWait(8, TimeUnit.SECONDS);
		Thread.sleep(40000);
		
		return OrderHome.Instance;
	
	}
	
	public OrderHome clickOnMidTerm() throws InterruptedException
	{

		clickOnElement(midtermlocator);
	
	    //driver.manage().timeouts().implicitlyWait(8, TimeUnit.SECONDS);
		Thread.sleep(40000);
		
		return OrderHome.Instance;
	
	}
	public OrderHome addProductsToMidterm(String productname)
	{
		pagelogger.debug("Setting Opportunity Close Date to: "  + productname);
		findElement(midtermsearchlocator).sendKeys(productname);
		
		return this;
	}
	
	public OrderHome clickOnMidtermSaveButton() throws InterruptedException
	{
		pagelogger.debug("Saving order wizard step2...");

		clickOnElement(midtermsavelocator);
		
		Thread.sleep(1000);
		
		return OrderHome.Instance;
	}
	
	public OrderHome clickOnStartDate() throws InterruptedException
	{
		pagelogger.debug("Saving order wizard step2...");

		clickOnElement(startdatelocator);
		
		Thread.sleep(1000);
		
		return OrderHome.Instance;
	}
	
	public OrderHome clickOnStartDate1() throws InterruptedException
	{
		pagelogger.debug("Saving order wizard step2...");

		clickOnElement(startdatelocator1);
		
		Thread.sleep(1000);
		
		return OrderHome.Instance;
	}
	
	public OrderHome clickOnStartDate2() throws InterruptedException
	{
		pagelogger.debug("Saving order wizard step2...");

		clickOnElement(startdatelocator2);
		
		Thread.sleep(1000);
		
		return OrderHome.Instance;
	}
	
	public OrderHome changeQty() throws InterruptedException
	{
		pagelogger.debug("Saving order wizard step2...");

		clickOnElement(changeqtylocator);
		
		Thread.sleep(1000);
		
		return OrderHome.Instance;
	}
	
	public OrderHome changeQty1() throws InterruptedException
	{
		pagelogger.debug("Saving order wizard step2...");

		clickOnElement(changeqtylocator1);
		
		Thread.sleep(1000);
		
		return OrderHome.Instance;
	}
	
	public OrderHome increaseQty(String fieldValue)
	{
		pagelogger.debug("Setting order Name to: "  + fieldValue);

		findElement(increaseqtylocator).clear();
		
		findElement(increaseqtylocator).sendKeys(fieldValue);
		
		return OrderHome.Instance;
	}
	
	public OrderHome decreaseQty(String fieldValue)
	{
		pagelogger.debug("Setting order Name to: "  + fieldValue);

		findElement(decreseqtylocator).clear();
		
		findElement(decreseqtylocator).sendKeys(fieldValue);
		
		return OrderHome.Instance;
	}
		
}
