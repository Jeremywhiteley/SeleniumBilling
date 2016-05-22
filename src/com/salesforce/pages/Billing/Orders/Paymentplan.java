package com.salesforce.pages.Billing.Orders;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;

public class Paymentplan extends PageBase {
	
	private static Paymentplan instance;
	public static Paymentplan Instance = (instance != null) ? instance : new Paymentplan();
	
    /** UI Mappings */
	
	By clickArrow = By.xpath("//img[@class='allTabsArrow']");
	
	By clickonpaymentplantab = By.xpath(".//*[@id='bodyCell']/div[3]/div[2]/table/tbody/tr[9]/td[2]/a");
	
	By clickOnNew = By.xpath("//input[@name='new']");
	
	By name = By.xpath(".//*[@id='Name']");
	
	By startdatelocator = By.xpath(".//*[@id='ep']/div[2]/div[3]/table/tbody/tr[4]/td[2]/span/span/a");
	
	By numberOfInstallments = By.xpath(".//*[@id='00N2800000AItOm']");
	
	By downpaymentlocator = By.xpath(".//*[@id='00N2800000AItOh']");
	
	By Minimuminstallmentslocator = By.xpath(".//*[@id='00N2800000AItOl']");
	
	By Maxlocator = By.xpath(".//*[@id='00N2800000AItOk']");
	
	By savelocator = By.xpath("//input[@value=' Save ']");
	
	By planheaderlocator = By.xpath("//div/h2[@class='pageDescription']");
	
	public Paymentplan clickOnArrowButton() {
		pagelogger.debug("Clicking on the New button...");
		clickOnElement(clickArrow);
		return Paymentplan.Instance;
	}
	
	public Paymentplan clickOnPaymentPlanTab() {
		pagelogger.debug("Clicking on the New button...");
		clickOnElement(clickonpaymentplantab);
		return Paymentplan.Instance;
	}
	
	public Paymentplan clickOnNewButton() {
		pagelogger.debug("Clicking on the New button...");
		clickOnElement(clickOnNew);
		return Paymentplan.Instance;
	}
	
	public Paymentplan setPaymentPlanName(String fieldValue)
	{
		pagelogger.debug("Setting order Name to: "  + fieldValue);

		findElement(name);
		
		findElement(name).sendKeys(fieldValue);
		
		return Paymentplan.Instance;
	}
	
	public Paymentplan setNoOfInstallments(String fieldValue)
	{
		pagelogger.debug("Setting order Name to: "  + fieldValue);

		findElement(numberOfInstallments);
		
		findElement(numberOfInstallments).sendKeys(fieldValue);
		
		return Paymentplan.Instance;
	}
	
	public Paymentplan setDownPayment(String fieldValue)
	{
		pagelogger.debug("Setting order Name to: "  + fieldValue);

		findElement(downpaymentlocator);
		
		findElement(downpaymentlocator).sendKeys(fieldValue);
		
		return Paymentplan.Instance;
	}
	
	public Paymentplan setMinInstallments(String fieldValue)
	{
		pagelogger.debug("Setting order Name to: "  + fieldValue);

		findElement(Minimuminstallmentslocator);
		
		findElement(Minimuminstallmentslocator).sendKeys(fieldValue);
		
		return Paymentplan.Instance;
	}
	
	public Paymentplan setMaxInstallments(String fieldValue)
	{
		pagelogger.debug("Setting order Name to: "  + fieldValue);

		findElement(Maxlocator);
		
		findElement(Maxlocator).sendKeys(fieldValue);
		
		return Paymentplan.Instance;
	}
	
	public Paymentplan setSave()
	{
		pagelogger.debug("Clicking on the New button...");
		clickOnElement(savelocator);
		return Paymentplan.Instance;
	}
	
	public Paymentplan clickOnStartDate() {
		pagelogger.debug("Clicking on the New button...");
		clickOnElement(startdatelocator);
		return Paymentplan.Instance;
	}

	public String getHeaderText()
	{
		pagelogger.debug("Getting the Account Header text");
		String val = findElement(planheaderlocator).getText();
		return val;
	}
}