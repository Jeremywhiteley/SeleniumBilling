package com.salesforce.pages.servicecloud.opportunities;

import java.text.ParseException;

import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.CommonMethods;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class ServiceCloudOpportunitiesEdit extends PageBase 
{

     
	private static ServiceCloudOpportunitiesEdit instance ;
	public static ServiceCloudOpportunitiesEdit Instance = (instance!=null)?instance:new ServiceCloudOpportunitiesEdit();
   
	
	/**UI Mappings */

	By saveButtonLocator = By.xpath("//input[@name='save']");
	By nameInputLocator = By.xpath("//td[contains(@class,'labelCol')]/descendant::label[text()='Opportunity Name']/following::td[1]/descendant::input[1]");
	By amountInputLocator = By.xpath("//td[contains(@class,'labelCol')]/descendant::label[text()='Amount']/following::td[1]/descendant::input[1]");
	By closeDateInputLocator = By.xpath("//td[contains(@class,'labelCol')]/descendant::label[text()='Close Date']/following::td[1]/descendant::input[1]");
	By stageSelectLocator = By.xpath("//td[contains(@class,'labelCol')]/descendant::label[text()='Stage']/following::td[1]/descendant::select");
	
	
	
	/**Page Methods*/
	
	public ServiceCloudOpportunitiesEdit verifyPageLoad()
	{
		synchronize(30);
		findElement(saveButtonLocator);
		
		return this;
	}
	
	
	public ServiceCloudOpportunitiesEdit enterCloseDate(String date) throws ParseException
	{
		pagelogger.debug("Entering the opportunity close date: "  + date);
		
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, closeDateInputLocator);
		
		new WebDriverWait(driver, 30).until(ExpectedConditions
				.presenceOfElementLocated(closeDateInputLocator));
		
		findElement(closeDateInputLocator).clear();
		findElement(closeDateInputLocator).sendKeys(CommonMethods.formatDate("SHORTDAYMONTH", date));
		
		setDriverContextToPage(driver);
		return this;
	}
	
	
    public ServiceCloudOpportunitiesEdit enterOpportunityName(String name)
    {
		pagelogger.debug("Setting the Opportunity Name: "  + name);

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, nameInputLocator);
		
		new WebDriverWait(driver, 30).until(ExpectedConditions
				.presenceOfElementLocated(nameInputLocator));
		
        findElement(nameInputLocator).clear();
        findElement(nameInputLocator).sendKeys(name);
        
        setDriverContextToPage(driver);
        return this;
    }
	
	
    public ServiceCloudOpportunitiesEdit enterAmount(String amount)
    {
		pagelogger.debug("Setting the Opportunity Amount: "  + amount);

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, amountInputLocator);
		
		new WebDriverWait(driver, 30).until(ExpectedConditions
				.presenceOfElementLocated(amountInputLocator));
		
        findElement(amountInputLocator).clear();
        findElement(amountInputLocator).sendKeys(amount);
        
        setDriverContextToPage(driver);
        return this;
    }
    
    
    public ServiceCloudOpportunitiesEdit setStage(String stage)
    {
		pagelogger.debug("Setting Opportunity Stage to: "  + stage);
    	
		IframeUtils.setDriverContextToIframeWithDepth(driver, stageSelectLocator);

		String selectid = getAttributeID(stageSelectLocator);
		clickOnElement(stageSelectLocator);
		
		SalesforcePageExtensions.selectOption(driver, selectid, stage);
				
		setDriverContextToPage(driver);
    	return ServiceCloudOpportunitiesEdit.Instance;
    }
    
    
    public ServiceCloudOpportunitiesDetail clickOnSaveButton()
    {
    	pagelogger.debug("Clicking on the Save button...");

        IframeUtils.setDriverContextToIframeWithDepth(driver, saveButtonLocator);
        clickOnElement(saveButtonLocator);
    	
    	setDriverContextToPage(driver);
    	return ServiceCloudOpportunitiesDetail.Instance;

    }

   
}
