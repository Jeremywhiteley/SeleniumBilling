package com.salesforce.pages.servicecloud.accounts;

import java.text.ParseException;

import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.CommonMethods;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class ServiceCloudAccountsTaskEdit extends PageBase {

	 
	private static ServiceCloudAccountsTaskEdit instance ;
	public static ServiceCloudAccountsTaskEdit Instance = (instance!=null)?instance:new ServiceCloudAccountsTaskEdit();
	
	
	/** UI Mappings */
	
	By subjectInputLocator = By.xpath("//label[text()='Subject']/following::td[1]/descendant::input[1]");
	By dueDateInputLocator = By.xpath("//td[contains(@class,'labelCol')]/descendant::label[text()='Due Date']/following::td[1]/descendant::input[1]");
	By saveButtonLocator = By.xpath("//input[@name='save']");
	
	
	
	/** Page Methods*/
	
	public ServiceCloudAccountsTaskEdit verifyPageLoad() 
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}


	public ServiceCloudAccountsTaskEdit setSubject(String subject) throws InterruptedException
	{
		
		pagelogger.debug("Setting the Subject to: "  + subject);
		
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, subjectInputLocator);
		
		String id = getAttributeID(subjectInputLocator);
		SalesforcePageExtensions.enterInputValue(driver, id, subject);
		
		setDriverContextToPage(driver);
		return this;
	}
	
	
	public ServiceCloudAccountsTaskEdit enterDueDate(String date) throws ParseException
	{
		
		pagelogger.debug("Entering the due date: "  + date);
		
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, dueDateInputLocator);
		
		new WebDriverWait(driver, 30).until(ExpectedConditions
				.presenceOfElementLocated(dueDateInputLocator));
		
		findElement(dueDateInputLocator).clear();
		findElement(dueDateInputLocator).sendKeys(CommonMethods.formatDate("SHORTDAYMONTH", date));
		
		setDriverContextToPage(driver);

		
		return this;
	}
	
	
    public ServiceCloudAccountsTaskDetail clickOnSave()
    {
    	pagelogger.debug("Clicking on the save button...");

        IframeUtils.setDriverContextToIframeWithDepth(driver, saveButtonLocator);
		
        clickOnElement(saveButtonLocator);
        
    	setDriverContextToPage(driver);
    	
    	return ServiceCloudAccountsTaskDetail.Instance;

    }
	
	
}
