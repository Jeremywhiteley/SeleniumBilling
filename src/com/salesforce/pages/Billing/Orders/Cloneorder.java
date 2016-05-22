package com.salesforce.pages.Billing.Orders;

import org.openqa.selenium.By;
import com.salesforce.pages.PageBase;

public class Cloneorder extends PageBase {
	
	private static Cloneorder instance;
	public static Cloneorder Instance = (instance != null) ? instance : new Cloneorder();
	
	/** UI Mappings **/
	

	By clonelocator = By.xpath(".//input[@name='clone']");
	By previewlocator = By.xpath(".//input[@value='Preview']");
	By quicksavelocator = By.xpath(".//input[@value='Quick Save']");
	By cancellocator = By.xpath(".//input[@value='Cancel']");
	By stepwizardlocator = By.xpath(".//input[@value='Step Wizard']");
	By nextLocator = By.xpath(".//input[@value='Next']");
	By savelocator = By.xpath(".//input[@value='Save']");
	By orderheaderlocator = By.xpath("//div/h2[@class='pageDescription']");
	
	public Cloneorder clickOnClone(){
		
		pagelogger.debug("Clicking on clone button");
		clickOnElement(clonelocator);
		return this;
	}
	
	public String getHeaderText()
	{
		pagelogger.debug("Getting the Account Header text");
		String val = findElement(orderheaderlocator).getText();
		return val;
	}
	
	
	public Cloneorder clcikOnStepWizard(){
		pagelogger.debug("Clicking on Stepwizard button");
		clickOnElement(stepwizardlocator);
		return this;
	}
	
	public Cloneorder clcikOnNext(){
		pagelogger.debug("Clicking on next button");
		clickOnElement(nextLocator);
		return this;
	}
	
	public Cloneorder clcikOnSave(){
		pagelogger.debug("Clicking on save button");
		clickOnElement(savelocator);
		return this;
	}
	
	
    public Cloneorder clickOnQuickSave(){
		
		pagelogger.debug("Clicking on Quicksave button");
		clickOnElement(quicksavelocator);
		return this;
	}
	
    public Cloneorder clickOnCancel(){
		
		pagelogger.debug("Clicking on cancel button");
		clickOnElement(cancellocator);
		return this;
	}
    
   public Cloneorder clickOnPreview() throws InterruptedException{
		
		pagelogger.debug("Clicking on preview button");
		clickOnElement(previewlocator);
		Thread.sleep(3000);
		return this;
	}
	
}
