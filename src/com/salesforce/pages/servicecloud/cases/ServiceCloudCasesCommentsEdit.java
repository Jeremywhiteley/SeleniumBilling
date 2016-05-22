package com.salesforce.pages.servicecloud.cases;

import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;


public class ServiceCloudCasesCommentsEdit extends PageBase 
{
	 
	private static ServiceCloudCasesCommentsEdit instance ;
	public static ServiceCloudCasesCommentsEdit Instance = (instance!=null)?instance:new ServiceCloudCasesCommentsEdit();
	
	
	/** UI Mappings */
	
	By caseCommentTextArea = By.xpath("//textarea[@id='CommentBody']"); 
	By caseAllCommentsInGrid=By.xpath("//div[contains(@id,'RelatedComments')]//td[contains(@class,'dataCell')]/br"); 
	By saveButtonLocator = By.xpath("//input[@name='save']");
	
	
	
	/** Page Methods*/
	
	public ServiceCloudCasesCommentsEdit verifyPageLoad() 
	{
		new WebDriverWait(driver, 10).until(ExpectedConditions
				.titleContains(pageTitle));
		return this;
	}
	
	
	public ServiceCloudCasesCommentsEdit addCommentInTextArea(String comment)
	{
		IframeUtils.setDriverContextToIframeWithDepth(driver, caseCommentTextArea);
		findElement(caseCommentTextArea).sendKeys(comment);
    	setDriverContextToPage(driver);
		return this;
	}
	
	
    public ServiceCloudCasesDetail clickOnSave()
    {
    	
    	pagelogger.debug("Clicking on the save button...");

        IframeUtils.setDriverContextToIframeWithDepth(driver, saveButtonLocator);
		
        clickOnElement(saveButtonLocator);
    	
    	setDriverContextToPage(driver);
    	
    	return ServiceCloudCasesDetail.Instance;

    }
	
	
}
