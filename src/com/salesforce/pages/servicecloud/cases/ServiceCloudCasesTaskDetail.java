package com.salesforce.pages.servicecloud.cases;

import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;


public class ServiceCloudCasesTaskDetail extends PageBase
{

	 
	private static ServiceCloudCasesTaskDetail instance ;
	public static ServiceCloudCasesTaskDetail Instance = (instance!=null)?instance:new ServiceCloudCasesTaskDetail();
	
	
	/**UI Mappings */
	
	By taskHeaderLocator = By.xpath("//div[@class='content']/h1[text()='Task']/following::h2");
	
	
	
	/**Page Methods*/
	
	public ServiceCloudCasesTaskDetail verifyPageLoad()
	{
		synchronize(30);
		findElement(taskHeaderLocator);
		
		return this;
	}
	
	
	public String getHeaderText()
	{
		pagelogger.debug("Getting the Task header text");
		String val = "";
		
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, taskHeaderLocator);
		
		new WebDriverWait(driver, 30).until(ExpectedConditions.presenceOfElementLocated(taskHeaderLocator));
		
		val = findElement(taskHeaderLocator).getText();
		setDriverContextToPage(driver);

		return val;	
	}
	
	
	
}
