package com.salesforce.pages.servicecloud.accounts;

import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class ServiceCloudAccountsTaskDetail extends PageBase
{

	 
	private static ServiceCloudAccountsTaskDetail instance ;
	public static ServiceCloudAccountsTaskDetail Instance = (instance!=null)?instance:new ServiceCloudAccountsTaskDetail();
	
	
	
	/**UI Mappings */
	
	By taskHeaderLocator = By.xpath("//div[@class='content']/h1[text()='Task']/following::h2");
	
	
	
	/**Page Methods*/
	
	public ServiceCloudAccountsTaskDetail verifyPageLoad()
	{
		synchronize(30);
		SalesforcePageExtensions.waitForPageToLoad(driver);
		
		return this;
	}
	
	
	public String getHeaderText()
	{
		pagelogger.debug("Getting the Task header text...");
		String val = "";
		
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, taskHeaderLocator);
		
		new WebDriverWait(driver, 30).until(ExpectedConditions.visibilityOfElementLocated(taskHeaderLocator));
		
		val = findElement(taskHeaderLocator).getText();
		setDriverContextToPage(driver);

		return val;	
	}
	
	
}
