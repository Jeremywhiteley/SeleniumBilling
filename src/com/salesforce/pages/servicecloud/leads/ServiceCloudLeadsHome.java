package com.salesforce.pages.servicecloud.leads;

import org.openqa.selenium.By;
import org.openqa.selenium.TimeoutException;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class ServiceCloudLeadsHome extends PageBase
{

	 
	private static ServiceCloudLeadsHome instance ;
	public static ServiceCloudLeadsHome Instance = (instance!=null)?instance:new ServiceCloudLeadsHome();
	
	
	/**UI Mappings */
	
	By leadFilterLocator = By.xpath("//div[@class='controls']/select");
	By newLeadLocator = By.cssSelector("input[title='New Lead']");
	By changeStatusLocator = By.cssSelector("input[title='Change Status']");
	By changeOwnerLocator = By.cssSelector("input[title='Change Owner']");
	By addToCampaignLocator = By.cssSelector("input[title='Add to Campaign']");
	By leadCaptureLocator = By.cssSelector("input[title='Lead Capture']");
	By refreshButtonLocator = By.cssSelector("input[title='Refresh']");
	By leadNameLocator = By.xpath("//div[@title='Name']");

	
	/**Page Methods*/
	
	public ServiceCloudLeadsHome verifyPageLoad()
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}
	
	public boolean verifyPageLoadAsBoolean()
	{
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, refreshButtonLocator);
		
		try 
		{
			new WebDriverWait(driver, 30).until(ExpectedConditions.visibilityOfElementLocated(refreshButtonLocator));
			return true;
		} 
		catch (TimeoutException e) 
		{
		    return false;
		}
	}
	
	
	public ServiceCloudLeadsHome filterLeadsTableByLetter(String filter)
	{
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, refreshButtonLocator);
		
		pagelogger.debug("Filtering the Leads table by the letter: "  + filter);
		
		SalesforcePageExtensions.sortRecordTableByLetter(driver, filter);
		
		setDriverContextToPage(driver);
		
		return this;
	}
	
	
	public ServiceCloudLeadsHome selectLeadFilter(String filter)
	{
		IframeUtils.setDriverContextToIframeWithDepth(driver, refreshButtonLocator);

		pagelogger.debug("Selecting the question filter: "  + filter);
		
		String id = getAttributeID(leadFilterLocator);
		pagelogger.debug("The filter id is: "  + id);
		SalesforcePageExtensions.selectOption(driver, id, filter);
		
		setDriverContextToPage(driver);
		return this;
	}
	

	public void refreshLeadTable()
	{
		IframeUtils.setDriverContextToIframeWithDepth(driver, refreshButtonLocator);

		pagelogger.debug("Refreshing the Questions Home page");
		
		clickOnElement(refreshButtonLocator);
		setDriverContextToPage(driver);
	}
	
	
	public ServiceCloudLeadsDetail selectFromLeadTable(String question)
	{
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, refreshButtonLocator);
		
		SalesforcePageExtensions.selectFromRecordTable(driver, question);
		
		setDriverContextToPage(driver);
		return ServiceCloudLeadsDetail.Instance;
	}
	
	
	public ServiceCloudLeadsHome checkmarkLead(String leadName) 
	{
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, leadNameLocator);
		
		pagelogger.debug("Checkmarking the lead: "  + leadName);
		
		SalesforcePageExtensions.checkmarkRecordFromRecordTable(driver, leadName);
		
		setDriverContextToPage(driver);
		return this;
	}
	
	
	public String getLeadStatusFromRecordTable(String leadName) 
	{
		String val = "";
			
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, leadNameLocator);
		
		pagelogger.debug("Attempting to get a column value...");
		
		val = SalesforcePageExtensions.getRecordTableColumnValue(driver, leadName, "LEAD_STATUS");
		setDriverContextToPage(driver);
		
		return val;
	}
	
	
	public String getLeadOwnerFromRecordTable(String leadName) 
	{
		String val = "";
			
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, leadNameLocator);
		
		pagelogger.debug("Attempting to get a column value...");
		
		val = SalesforcePageExtensions.getRecordTableColumnValue(driver, leadName, "USERS_ALIAS");
		
		setDriverContextToPage(driver);
		return val;
	}
	
	
	public ServiceCloudLeadsSelectRecordType ClickOnNewLead() 
	{
		IframeUtils.setDriverContextToIframeWithDepth(driver, refreshButtonLocator);
		
		clickOnElement(newLeadLocator);
		
		setDriverContextToPage(driver);
		return ServiceCloudLeadsSelectRecordType.Instance;
	}
	
	
	public ServiceCloudLeadsChangeStatus ClickOnChangeStatus() 
	{
		IframeUtils.setDriverContextToIframeWithDepth(driver, refreshButtonLocator);
		
		clickOnElement(changeStatusLocator);
		
		setDriverContextToPage(driver);
		return ServiceCloudLeadsChangeStatus.Instance;
	}
	
	
	public ServiceCloudLeadsChangeOwner ClickOnChangeOwner() 
	{
		IframeUtils.setDriverContextToIframeWithDepth(driver, refreshButtonLocator);
		
		clickOnElement(changeOwnerLocator);
		
		setDriverContextToPage(driver);
		return ServiceCloudLeadsChangeOwner.Instance;
	}
	
	
	public ServiceCloudLeadsAddToCampaign ClickOnAddToCampaign() 
	{
		IframeUtils.setDriverContextToIframeWithDepth(driver, refreshButtonLocator);
		
		clickOnElement(addToCampaignLocator);
		
		setDriverContextToPage(driver);
		return ServiceCloudLeadsAddToCampaign.Instance;
	}

	
}
