package com.salesforce.pages.servicecloud.cases;

import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;


public class ServiceCloudCasesEventDetail extends PageBase
{

	 
	private static ServiceCloudCasesEventDetail instance ;
	public static ServiceCloudCasesEventDetail Instance = (instance!=null)?instance:new ServiceCloudCasesEventDetail();
	
	
	/**UI Mappings */
	
	By eventHeaderLocator = By.xpath("//div[@class='content']/h1[text()='Calendar Event']/following::h2");
	
	
	
	/**Page Methods*/
	
	public ServiceCloudCasesEventDetail verifyPageLoad()
	{
		synchronize(30);
		findElement(eventHeaderLocator);
		
		return this;
	}
	
	
	public String getHeaderText()
	{
		pagelogger.debug("Getting the Task header text");
		String val = "";
		
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, eventHeaderLocator);
		
		new WebDriverWait(driver, 30).until(ExpectedConditions.presenceOfElementLocated(eventHeaderLocator));
		
		val = findElement(eventHeaderLocator).getText();
		setDriverContextToPage(driver);

		return val;
	}
	
	
}
