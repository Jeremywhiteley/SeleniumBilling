package com.salesforce.pages.servicecloud.opportunities;

import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;


public class ServiceCloudOpportunitiesDetail extends PageBase
{

	 
	private static ServiceCloudOpportunitiesDetail instance ;
	public static ServiceCloudOpportunitiesDetail Instance = (instance!=null)?instance:new ServiceCloudOpportunitiesDetail();
	
	
	/**UI Mappings */

	By saveButtonLocator = By.cssSelector("input[title='Save']");
	By opportunityName = By.xpath("//td[@class='labelCol'][text()='Opportunity Name']/following::td[1]/div");
	By opportunityHeaderLocator = By.xpath("//div[@class='content']/descendant::h2");

	
	/**Page Methods*/
	
	public ServiceCloudOpportunitiesDetail verifyPageLoad()
	{
		synchronize(30);
		findElement(saveButtonLocator);
		
		return this;
	}
	
	
	public String getHeaderText()
	{
		pagelogger.debug("Getting the Opportunity header text");
		
		String val = "";
		
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, opportunityName);
		
		new WebDriverWait(driver, 30).until(ExpectedConditions.presenceOfElementLocated(opportunityHeaderLocator));
		
		val = findElement(opportunityHeaderLocator).getText();
		
		setDriverContextToPage(driver);
		return val;
	}
	
	
	
}
