package com.salesforce.pages.servicecloud.leads;

import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class ServiceCloudLeadsAddToCampaign extends PageBase 
{

     
	private static ServiceCloudLeadsAddToCampaign instance ;
	public static ServiceCloudLeadsAddToCampaign Instance = (instance!=null)?instance:new ServiceCloudLeadsAddToCampaign();
	
	
	/**UI Mappings */

	By lookupButtonLocator = By.xpath("//a[contains(@title,'Campaign: Lookup')]");
	By addToCampaignButtonLocator = By.cssSelector("input[title='Add to Campaign']");
	By doneButtonLocator = By.cssSelector("input[title='Done']");
	By addMembersLabelLocator = By.xpath("//h2[contains(text(), 'Add Members')]");
	By memberStatusSelectLocator = By.xpath("//tr/td/label[text()='Member Status:']/following::td[1]/descendant::select");
	By doNotOverrideRadioButtonLocator = By.xpath("//tr/td[text()='Existing Members:']/following::td[1]/descendant::label[text()='Do not override the member status']/preceding::input[1]");
	By overrideRadioButtonLocator = By.xpath("//tr/td[text()='Existing Members:']/following::td[1]/descendant::label[text()='Override the member status']/preceding::input[1]");
	
	
	/**Page Methods*/
	
    public ServiceCloudLeadsAddToCampaign lookupCampaign(String vals) throws InterruptedException
    {
    	
		pagelogger.debug("Looking up campaign...");

		IframeUtils.setDriverContextToIframeWithDepth(driver, addMembersLabelLocator);
		
    	new WebDriverWait(driver, 30).until(ExpectedConditions
				.visibilityOfElementLocated(addMembersLabelLocator));
    	        
    	String id = getAttributeID(lookupButtonLocator);
    	String mwh = driver.getWindowHandle();
    	
    	SalesforcePageExtensions.selectFromLookup(driver, vals, mwh, id);
    	
		setDriverContextToPage(driver);
    	return this;
    }
    
    
	public ServiceCloudLeadsAddToCampaign selectMemberStatus(String status)
	{	
		pagelogger.debug("Selecting the member status: "  + status);
		
		IframeUtils.setDriverContextToIframeWithDepth(driver, memberStatusSelectLocator);
		
		String id = getAttributeID(memberStatusSelectLocator);
		
		SalesforcePageExtensions.selectOption(driver, id, status);
				
		setDriverContextToPage(driver);
		return this;
	}
	
	
	public ServiceCloudLeadsAddToCampaign setOverrideStatus(String status)
	{	
		pagelogger.debug("Selecting the override radio button: "  + status);
		
		IframeUtils.setDriverContextToIframeWithDepth(driver, addMembersLabelLocator);
    	
    	if(status.toUpperCase().equals("OVERRIDE"))
    	{
    		pagelogger.debug("Selecting override radio button");
    		clickOnElement(overrideRadioButtonLocator);
    	}
    	else
    	{
    		pagelogger.debug("Selecting DO NOT override radio button (default behavior)");
    		clickOnElement(doNotOverrideRadioButtonLocator);
    	}
    	
		setDriverContextToPage(driver);
		return this;
	}
   
    
    public ServiceCloudLeadsHome clickOnAddToCampaign()
    {	
		pagelogger.debug("Clicking add to campaign button...");
    	
		IframeUtils.setDriverContextToIframeWithDepth(driver, addToCampaignButtonLocator);
		
    	clickOnElement(addToCampaignButtonLocator);
    	
		setDriverContextToPage(driver);

		IframeUtils.setDriverContextToIframeWithDepth(driver, doneButtonLocator);
    	
		clickOnElement(doneButtonLocator);

		setDriverContextToPage(driver);
    	return ServiceCloudLeadsHome.Instance;
    }

      
}

