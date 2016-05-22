package com.salesforce.pages.servicecloud.leads;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class ServiceCloudLeadsChangeStatus extends PageBase 
{

     
	private static ServiceCloudLeadsChangeStatus instance ;
	public static ServiceCloudLeadsChangeStatus Instance = (instance!=null)?instance:new ServiceCloudLeadsChangeStatus();
	
	
	/** UI Mappings */

    By newStatusOptionLocator = By.xpath("//tr/td/label[text()='New Status']/following::td[1]/descendant::select");
	By saveButtonLocator = By.xpath("//input[@name='save']");

	
	/**Page Methods */
	
    public ServiceCloudLeadsHome selectNewLeadStatus(String status)
    {	
    	IframeUtils.setDriverContextToIframeWithDepth(driver, newStatusOptionLocator);

		String id = getAttributeID(newStatusOptionLocator);
		SalesforcePageExtensions.selectOption(driver, id, status);
		
		clickOnElement(saveButtonLocator);
		
		setDriverContextToPage(driver);
		return ServiceCloudLeadsHome.Instance;
	}
   

   
}
