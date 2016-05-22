package com.salesforce.pages.servicecloud.questions;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class ServiceCloudQuestionsEdit extends PageBase
{

	 
	private static ServiceCloudQuestionsEdit instance ;
	public static ServiceCloudQuestionsEdit Instance = (instance!=null)?instance:new ServiceCloudQuestionsEdit();
	
	
	/**UI Mappings */
	
	By questionTitleLocator = By.xpath("//td/label[text()='Question Title']/../following::td[1]/descendant::input[1]");
	By saveButtonLocator = By.xpath("//td/input[@title='Save']");
	
	
	
	/**Page Methods*/
	
	public ServiceCloudQuestionsEdit verifyPageLoad()
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}
	
	
	public ServiceCloudQuestionsEdit setQuestionTitle(String title)
	{
	
		pagelogger.debug("Entering quesiton title: "  + title);

		IframeUtils.setDriverContextToIframeWithDepth(driver, questionTitleLocator);
		
		String id = getAttributeID(questionTitleLocator);
		SalesforcePageExtensions.enterInputValue(driver, id, title);
	
		setDriverContextToPage(driver);
		return ServiceCloudQuestionsEdit.Instance;
	}
	
	
	public ServiceCloudQuestionsDetail clickOnSaveButton()
	{
		pagelogger.debug("Saving the new question...");

		IframeUtils.setDriverContextToIframeWithDepth(driver, saveButtonLocator);
		
		clickOnElement(saveButtonLocator);
		
		setDriverContextToPage(driver);
		return ServiceCloudQuestionsDetail.Instance;

	}

}
