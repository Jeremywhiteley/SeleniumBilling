package com.salesforce.pages.servicecloud.questions;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.pages.servicecloud.cases.ServiceCloudCasesEdit;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class ServiceCloudQuestionsDetail extends PageBase
{

	 
	private static ServiceCloudQuestionsDetail instance ;
	public static ServiceCloudQuestionsDetail Instance = (instance!=null)?instance:new ServiceCloudQuestionsDetail();
	
	
	/**UI Mappings */
	
	By questionText = By.xpath("//div[contains(@class,'feeditemcontent')]/descendant::div[contains(@class,'feeditemtext')]");
	By questionActions = By.xpath("//a[text()='Actions']");
	By escalateToCase = By.xpath("//a[text()='Actions']/..//a[text()='Escalate to Case']");
	
	
	
	/**Page Methods
	 */
	public ServiceCloudQuestionsDetail verifyPageLoad()
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}
	
	
	public ServiceCloudCasesEdit escalateToCase()
	{
		IframeUtils.setDriverContextToIframeWithDepth(driver, questionActions);
		
		clickOnElement(questionActions);
		clickOnElement(escalateToCase);
		
		return ServiceCloudCasesEdit.Instance;

	}
	
	public String getQuestionText()
	{
		String temp ;
		
		IframeUtils.setDriverContextToIframeWithDepth(driver, questionText);

		pagelogger.debug("Getting the question text...");
		
		temp = findElement(questionText).getText();

		pagelogger.debug("The question text found is: "  + temp);
		
		setDriverContextToPage(driver);
		return temp;
	}
	
	
}
