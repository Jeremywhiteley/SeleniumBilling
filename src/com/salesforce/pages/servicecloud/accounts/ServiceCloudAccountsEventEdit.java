package com.salesforce.pages.servicecloud.accounts;

import java.text.ParseException;

import org.openqa.selenium.By;
import org.openqa.selenium.Keys;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.CommonMethods;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class ServiceCloudAccountsEventEdit extends PageBase 
{

	 
	private static ServiceCloudAccountsEventEdit instance ;
	public static ServiceCloudAccountsEventEdit Instance = (instance!=null)?instance:new ServiceCloudAccountsEventEdit();
	
	
	/** UI Mappings */
	
	By subjectInputLocator = By.xpath("//label[text()='Subject']/following::td[1]/descendant::input[1]");
	By startDateInputLocator = By.xpath("//td[contains(@class,'labelCol')]/descendant::label[text()='Start']/following::td[1]/descendant::input[1]");
	By startTimeInputLocator = By.xpath("//td[contains(@class,'labelCol')]/descendant::label[text()='Start']/following::td[1]/descendant::input[2]");
	By saveButtonLocator = By.xpath("//input[@name='save']");
	
	
	
	
	/** Page Methods*/
	
	public ServiceCloudAccountsEventEdit verifyPageLoad() 
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}


	public ServiceCloudAccountsEventEdit setSubject(String subject) throws InterruptedException
	{
		pagelogger.debug("Setting the Subject to: "  + subject);
		
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, subjectInputLocator);
		
		new WebDriverWait(driver, 30).until(ExpectedConditions
				.visibilityOfElementLocated(subjectInputLocator));
		
		String id = getAttributeID(subjectInputLocator);
		SalesforcePageExtensions.enterInputValue(driver, id, subject);
		
		setDriverContextToPage(driver);
		return this;
	}
	
	
	public ServiceCloudAccountsEventEdit setStartDate(String date) throws ParseException
	{
		pagelogger.debug("Entering the Start Date: "  + date);
		
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, startDateInputLocator);
		
		new WebDriverWait(driver, 30).until(ExpectedConditions
				.presenceOfElementLocated(startDateInputLocator));
		
		findElement(startDateInputLocator).clear();
		findElement(startDateInputLocator).sendKeys(CommonMethods.formatDate("SHORTDAYMONTH", date));
		findElement(startDateInputLocator).sendKeys(Keys.TAB);
		
		setDriverContextToPage(driver);

		
		return this;
	}
	
	
	public ServiceCloudAccountsEventEdit setStartTime(String time) throws ParseException
	{
		
		pagelogger.debug("Entering the Start Time: "  + time);
		
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, startTimeInputLocator);
		
		new WebDriverWait(driver, 30).until(ExpectedConditions
				.presenceOfElementLocated(startTimeInputLocator));
		
		findElement(startTimeInputLocator).clear();
		findElement(startTimeInputLocator).sendKeys(CommonMethods.formatTime("12-WITH-AMPM", time));
		
		setDriverContextToPage(driver);

		
		return this;
	}
	
	
    public ServiceCloudAccountsDetail clickOnSaveButton()
    {
    	pagelogger.debug("Clicking on the Save button...");

        IframeUtils.setDriverContextToIframeWithDepth(driver, saveButtonLocator);
        
        clickOnElement(saveButtonLocator);
    	
    	setDriverContextToPage(driver);
    	
    	return ServiceCloudAccountsDetail.Instance;

    }
	
	
}
