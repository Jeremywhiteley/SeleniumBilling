package com.salesforce.pages.servicecloud.leads;

import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class ServiceCloudLeadsEdit extends PageBase 
{

     
	private static ServiceCloudLeadsEdit instance ;
	public static ServiceCloudLeadsEdit Instance = (instance!=null)?instance:new ServiceCloudLeadsEdit();
	
	
	/**UI Mappings */

	By lastNameLocator = By.xpath("//tr/td/label[text()='Last Name']/following::td[1]/descendant::input");
	By companyLocator = By.xpath("//tr/td/label[text()='Company']/following::td[1]/descendant::input");
	By saveButtonLocator = By.xpath("//input[@name='save']");
	By accountNameLocator = By.xpath("//a[contains(@title,'Account Name')]/../a");
    By leadStatusLocator = By.xpath("//tr/td/label[text()='Lead Status']/following::td[1]/descendant::select");
    By leadRatingLocator = By.xpath("//tr/td/label[text()='Rating']/following::td[1]/descendant::select");
	
    
	/**Page Methods*/
    
	public ServiceCloudLeadsEdit verifyPageLoad()
	{	
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}
	
	
    public ServiceCloudLeadsEdit setLastName(String name)
    {
		pagelogger.debug("Entering the Last Name: "  + name);

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, lastNameLocator);
		
		new WebDriverWait(driver, 30).until(ExpectedConditions.titleContains("Lead Edit: "));
		
        findElement(lastNameLocator).clear();
        findElement(lastNameLocator).sendKeys(name);
        
        setDriverContextToPage(driver);
        return this;
    }
    
    
    public ServiceCloudLeadsEdit setLeadRating(String rating)
    {
		pagelogger.debug("Updating the Lead Rating to: "  + rating);

		IframeUtils.setDriverContextToIframeWithDepth(driver, leadRatingLocator);
		
		String id = getAttributeID(leadRatingLocator);
		SalesforcePageExtensions.selectOption(driver, id, rating);
		
        setDriverContextToPage(driver);
		return this;
    }
    
    public ServiceCloudLeadsEdit setCompany(String name)
    {
		pagelogger.debug("Entering the Company Name: "  + name);

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, companyLocator);
		
		new WebDriverWait(driver, 30).until(ExpectedConditions.titleContains("Lead Edit: "));
		
        findElement(companyLocator).clear();
        findElement(companyLocator).sendKeys(name);
        
        setDriverContextToPage(driver);
        return this;
    }
      
    
	public ServiceCloudLeadsEdit setLeadStatus(String status)
	{	
		pagelogger.debug("Selecting the Lead Status: "  + status);
		
		IframeUtils.setDriverContextToIframeWithDepth(driver, leadStatusLocator);
		
		String id = getAttributeID(leadStatusLocator);
		
		SalesforcePageExtensions.selectOption(driver, id, status);
		
		setDriverContextToPage(driver);
		return ServiceCloudLeadsEdit.Instance ;
	}
    
    
    public ServiceCloudLeadsDetail clickOnSave()
    {	
        IframeUtils.setDriverContextToIframeWithDepth(driver, saveButtonLocator);
        
        clickOnElement(saveButtonLocator);
    	
        setDriverContextToPage(driver);

    	return ServiceCloudLeadsDetail.Instance;
    }

    
}
