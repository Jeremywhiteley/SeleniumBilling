package com.salesforce.pages.servicecloud.cases;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class ServiceCloudCasesChangeOwner extends PageBase 
{

     
	private static ServiceCloudCasesChangeOwner instance ;
	public static ServiceCloudCasesChangeOwner Instance = (instance!=null)?instance:new ServiceCloudCasesChangeOwner();
	
	
	/**UI Mappings */

	By lookupButtonLocator = By.xpath("//a[contains(@title,'Owner name')]");
	By saveButtonLocator = By.xpath("//input[@name='save']");
	By changeCaseOwnerLabel = By.xpath("//h1[text()='Change Request Owner']");
	
	
	/**Page Methods*/

    public ServiceCloudCasesChangeOwner setOwner(String vals) throws InterruptedException
    {	
        IframeUtils.setDriverContextToIframeWithDepth(driver, lookupButtonLocator);
        
    	String id = getAttributeID(lookupButtonLocator);
    	String mwh = driver.getWindowHandle();
    	
    	SalesforcePageExtensions.selectFromLookup(driver, vals, mwh, id);
    	setDriverContextToPage(driver);
    	
    	return this;
    }
   
    
    public ServiceCloudCasesHome clickOnSaveButton()
    {
    	IframeUtils.setDriverContextToIframeWithDepth(driver, saveButtonLocator);
    	
    	clickOnElement(saveButtonLocator);
    	
		setDriverContextToPage(driver);
		
    	return ServiceCloudCasesHome.Instance;	
    }
    
   
}

