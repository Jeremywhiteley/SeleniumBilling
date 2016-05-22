package com.salesforce.pages.servicecloud.cases;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class ServiceCloudCasesEventEdit extends PageBase 
{

	 
	private static ServiceCloudCasesEventEdit instance ;
	public static ServiceCloudCasesEventEdit Instance = (instance!=null)?instance:new ServiceCloudCasesEventEdit();
	
	
	/** UI Mappings */
	
	By subjectComboLocator = By.cssSelector("a[title='Combo (New Window)']");
	By dueDateInputLocator = By.xpath("//td[contains(@class,'labelCol')]/descendant::label[text()='Due Date']/following::td[1]/descendant::input[1]");
	By saveButtonLocator = By.xpath("//input[@name='save']");
	
	
	/** Page Methods*/
	
	public ServiceCloudCasesEventEdit verifyPageLoad() 
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}


	public ServiceCloudCasesEventEdit selectSubjectFromComboLookup(String subject) throws InterruptedException
	{
		pagelogger.debug("Selecting from the combo box new window subject: "  + subject);
		
		IframeUtils.setDriverContextToIframeWithDepth(driver, subjectComboLocator);
		
		String mwh = driver.getWindowHandle();
		clickOnElement(subjectComboLocator);
		SalesforcePageExtensions.selectFromComboBoxLookup(driver, subject, mwh);
		
		setDriverContextToPage(driver);
		return this;
	}
	
    public ServiceCloudCasesEventDetail clickOnSave()
    {
    	
    	pagelogger.debug("Clicking on the save button...");

        IframeUtils.setDriverContextToIframeWithDepth(driver, saveButtonLocator);
        
        clickOnElement(saveButtonLocator);
 
    	setDriverContextToPage(driver);
    	return ServiceCloudCasesEventDetail.Instance;

    }
	
	
}
