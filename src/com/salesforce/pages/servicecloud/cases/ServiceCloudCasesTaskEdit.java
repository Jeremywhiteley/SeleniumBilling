package com.salesforce.pages.servicecloud.cases;

import java.text.ParseException;

import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.CommonMethods;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class ServiceCloudCasesTaskEdit extends PageBase 
{

	 
	private static ServiceCloudCasesTaskEdit instance ;
	public static ServiceCloudCasesTaskEdit Instance = (instance!=null)?instance:new ServiceCloudCasesTaskEdit();
	
	
	/** UI Mappings */
	
	By subjectComboLocator = By.cssSelector("a[title='Combo (New Window)']");
	By dueDateInputLocator = By.xpath("//td[contains(@class,'labelCol')]/descendant::label[text()='Due Date']/following::td[1]/descendant::input[1]");
	By saveButtonLocator = By.xpath("//input[@name='save']");
	
	
	
	/** Page Methods*/
	
	public ServiceCloudCasesTaskEdit verifyPageLoad() 
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}


	public ServiceCloudCasesTaskEdit selectSubjectFromComboLookup(String subject) throws InterruptedException
	{
		pagelogger.debug("Selecting from the combo box new window subject: "  + subject);
		
		IframeUtils.setDriverContextToIframeWithDepth(driver, subjectComboLocator);
		
		String mwh = driver.getWindowHandle();
		
		clickOnElement(subjectComboLocator);
		
		SalesforcePageExtensions.selectFromComboBoxLookup(driver, subject, mwh);
		
		setDriverContextToPage(driver);
		return this;
	}
	
	
	public ServiceCloudCasesTaskEdit enterDueDate(String date) throws ParseException
	{	
		pagelogger.debug("Entering the due date: "  + date);
		
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, dueDateInputLocator);
		
		new WebDriverWait(driver, 30).until(ExpectedConditions
				.presenceOfElementLocated(dueDateInputLocator));
		
		findElement(dueDateInputLocator).clear();
		findElement(dueDateInputLocator).sendKeys(CommonMethods.formatDate("SHORTDAYMONTH", date));
		
		setDriverContextToPage(driver);
		return this;
	}
	
	
    public ServiceCloudCasesTaskDetail clickOnSave()
    {
    	pagelogger.debug("Clicking on the save button...");

        IframeUtils.setDriverContextToIframeWithDepth(driver, saveButtonLocator);
        
        clickOnElement(saveButtonLocator);
    	
    	setDriverContextToPage(driver);
    	return ServiceCloudCasesTaskDetail.Instance;

    }
	
	
}
