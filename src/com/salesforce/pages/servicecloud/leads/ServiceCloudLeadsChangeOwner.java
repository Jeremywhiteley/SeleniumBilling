package com.salesforce.pages.servicecloud.leads;

import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class ServiceCloudLeadsChangeOwner extends PageBase 
{

     
	private static ServiceCloudLeadsChangeOwner instance ;
	public static ServiceCloudLeadsChangeOwner Instance = (instance!=null)?instance:new ServiceCloudLeadsChangeOwner();
	
	
	/**UI Mappings */

	By lookupButtonLocator = By.xpath("//a[contains(@title,'Owner name')]");
	By saveButtonLocator = By.xpath("//input[@name='save']");
	By changeCaseOwnerLabel = By.xpath("//h1[text()='Change Lead Owner']");
	By ownerSelectLocator = By.xpath("//tr/td/label[text()='Owner']/following::td[1]/descendant::select");
	
	
	/**Page Methods*/

	public ServiceCloudLeadsChangeOwner selectRecordType(String type)
	{	
		pagelogger.debug("Selecting the owner type: "  + type);
		
        IframeUtils.setDriverContextToIframeWithDepth(driver, ownerSelectLocator);

		String id = getAttributeID(ownerSelectLocator);
		
		SalesforcePageExtensions.selectOption(driver, id, type);
				
		setDriverContextToPage(driver);
		return this;
	}
	
	
    public ServiceCloudLeadsChangeOwner lookupOwner(String vals) throws InterruptedException
    {	
        IframeUtils.setDriverContextToIframeWithDepth(driver, lookupButtonLocator);
        
    	new WebDriverWait(driver, 30).until(ExpectedConditions
				.visibilityOfElementLocated(changeCaseOwnerLabel));
  
        
    	String id = getAttributeID(lookupButtonLocator);
    	String mwh = driver.getWindowHandle();
    	
    	SalesforcePageExtensions.selectFromLookup(driver, vals, mwh, id);
    	
		setDriverContextToPage(driver);
    	return this;
    }
   
    
    public ServiceCloudLeadsHome ClickOnSave()
    {	
    	IframeUtils.setDriverContextToIframeWithDepth(driver, saveButtonLocator);
    	
    	clickOnElement(saveButtonLocator);
    	
		setDriverContextToPage(driver);
    	return ServiceCloudLeadsHome.Instance;
    }
    
   
}

