package com.salesforce.pages.servicecloud.knowledge;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.pages.servicecloud.cases.ServiceCloudCasesEdit;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;
import com.salesforce.utils.driver.ServiceCloudPageExtensions;


public class ServiceCloudKnowledgeDetail extends PageBase 
{

	 
	private static ServiceCloudKnowledgeDetail instance;
	public static ServiceCloudKnowledgeDetail Instance = (instance != null) ? instance : new ServiceCloudKnowledgeDetail();

	
	/** UI Mappings */
	
	By languageSelectLocator = By.xpath("//div/form/descendant::label[contains(text(), 'Language')]/following::select");
	By articleHeaderLocator = By.xpath("//div[@class='content']/descendant::img[@title='Article']/following-sibling::h1");
	By altArticleHeaderLocator = By.xpath("//div[@class='content']/descendant::img[@title='Article']/following-sibling::h2");
	By requestArticleReviewButton = By.xpath("//button[text()='Request Article Review']");
	By tabText = By.xpath("//span[@class='tabText']");

	
	/** Page Methods */

	public ServiceCloudKnowledgeDetail verifyPageLoad() 
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}

	
	public ServiceCloudCasesEdit clickOnArticleReviewButton() 
	{
		pagelogger.debug("Clicking on the Article Review button");

		IframeUtils.setDriverContextToIframeWithDepth(driver, requestArticleReviewButton);
		clickOnElement(requestArticleReviewButton);
		
		setDriverContextToPage(driver);

		return ServiceCloudCasesEdit.Instance;
	}

	
	public ServiceCloudKnowledgeDetail selectLanguage(String language) 
	{
		pagelogger.debug("Selecting the language: "  + language);

		IframeUtils.setDriverContextToIframeWithDepth(driver, languageSelectLocator);

		String id = getAttributeID(languageSelectLocator);
		SalesforcePageExtensions.selectOption(driver, id, language);

		setDriverContextToPage(driver);
		return this;
	}

	
	public String getKnowledgeHeader() 
	{
		pagelogger.debug("Getting the knowledge article header...");

		String val = ServiceCloudPageExtensions.getDetailHeader(driver, articleHeaderLocator, altArticleHeaderLocator);

		pagelogger.debug("The knowledge article header returned as: "  + val);

		return val;
	}
	

	public String getSubTabText() 
	{
		pagelogger.debug("Getting the knowledge sub tab text");
		
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, tabText);
		
		String subTabText = findElement(tabText).getText().replace("...", "");
		
		setDriverContextToPage(driver);
		return subTabText;
	}

}
