package com.salesforce.pages.servicecloud.leads;

import java.util.List;

import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class ServiceCloudLeadsDetail extends PageBase
{

	 
	private static ServiceCloudLeadsDetail instance ;
	public static ServiceCloudLeadsDetail Instance = (instance!=null)?instance:new ServiceCloudLeadsDetail();
	
	
	/**UI Mappings */
	
	By leadHeader = By.cssSelector("h2[class='topName']");
	By ratingFieldLocator = By.xpath("//tr/td[text()='Rating']/following::td[1]/descendant::div[1]");
	By ratingSelectLocator = By.xpath("//tr/td[text()='Rating']/following::td[1]/descendant::select");
	By saveButtonLocator = By.cssSelector("input[title='Save']");
	By editButtonLocator = By.cssSelector("input[title='Edit']");
	By altLeadHeaderLocator = By.xpath("//div[@class='content']/descendant::img[@title='Article']/following-sibling::h2");
	By deleteButtonLocator = By.cssSelector("input[title='Delete']");
	By deleteConfirmationButtonLocator = By.xpath("//span[text()='Delete Confirmation']/following::div[1]/descendant::table/descendant::td/descendant::button[text()='Yes']");
	By statusFieldLocator = By.xpath("//td[text()='Lead Status']/following::td[1]/descendant::div[1]");
	By statusSelectLocator = By.xpath("//tr/td[text()='Lead Status']/following::td[1]/descendant::select");

	
	
	/**Page Methods*/

	public ServiceCloudLeadsDetail verifyPageLoad()
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}

	
	public ServiceCloudLeadsEdit clickOnEdit()
    {	
    	pagelogger.debug("Clicking on Edit button...");
    	
        IframeUtils.setDriverContextToIframeWithDepth(driver, editButtonLocator);
        
        clickOnElement(editButtonLocator);
    	
        setDriverContextToPage(driver);
    	return ServiceCloudLeadsEdit.Instance;
    }
    
    
	
	public String getLeadHeader()
	{
		String temp ;
		
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, leadHeader);

		pagelogger.debug("Getting the Lead Header text");
		
		new WebDriverWait(driver, 30).until(ExpectedConditions.presenceOfElementLocated(leadHeader));
		
		temp = findElement(leadHeader).getText();

		setDriverContextToPage(driver);
		return temp;
	}
	
	
    public Boolean searchCampaignHistory(String campaign)
    {	
    	Boolean val = false;
    	
		pagelogger.debug("Searching the Campaign History related list for: "  + campaign);
    	
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, leadHeader);
		
		new WebDriverWait(driver, 30).until(ExpectedConditions.presenceOfElementLocated(leadHeader));

		List<WebElement> elements = null;
		elements = findElements(By.xpath("//h3[text()='Campaign History']/../following::div[1]/descendant::tr[contains(@class,'dataRow')]/th[contains(@class,'dataCell')]/a"));
		
		pagelogger.debug("The number of entries in the Campaigns related list is: "  + elements.size());
		
		if(!elements.isEmpty())
		{
			
			for(WebElement e: elements)
			{
				
				if(e.getText().trim().toUpperCase().equals(campaign.trim().toUpperCase()))
				{
					pagelogger.debug("Found the entry we were looking for in the campaign related list!");
					val = true;
					break;
				}
				else
				{
					pagelogger.debug("Found the following entry in the campaign related list: " + e.getText() + " This does not match: " + campaign + " Will loop back!");
				}
			}

		}
		else
		{
			throw new NoSuchElementException("Could not locate the Campaign list Element with the name: " + campaign);
		
		}

		setDriverContextToPage(driver);
    	return val;
    }
    
    
    public ServiceCloudLeadsDetail setLeadRating(String rating)
    {	
		pagelogger.debug("Updating lead rating to: "  + rating);
    	
		IframeUtils.setDriverContextToIframeWithDepth(driver, leadHeader);
		
		String id = getAttributeID(ratingFieldLocator);
		SalesforcePageExtensions.editInlineTD(driver, id);
		
		String selectid = getAttributeID(ratingSelectLocator);
		SalesforcePageExtensions.selectOption(driver, selectid, rating);
		
		clickOnElement(saveButtonLocator);
		
		setDriverContextToPage(driver);
    	return this;
    }
    
    
    public String getLeadRating()
    {	
		pagelogger.debug("Getting the Lead Rating...");
    	
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, leadHeader);
		
		String val = findElement(ratingFieldLocator).getText();
		
		pagelogger.debug("The lead rating was found to be: "  + val);
		
		setDriverContextToPage(driver);
		return val;
    }
    
    public String getLeadStatus()
    {	
		pagelogger.debug("Getting the Lead Status...");
    	
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, leadHeader);
		
		String val = findElement(statusFieldLocator).getText();
		
		pagelogger.debug("The lead status was found to be: "  + val);
		
		setDriverContextToPage(driver);
		return val;
    }
    
    public ServiceCloudLeadsDetail setLeadStatus(String status)
    {	
		pagelogger.debug("Updating Lead Status to: "  + status);
    	
		IframeUtils.setDriverContextToIframeWithDepth(driver, leadHeader);
		
		String id = getAttributeID(statusFieldLocator);
		SalesforcePageExtensions.editInlineTD(driver, id);
		
		String selectid = getAttributeID(statusSelectLocator);
		SalesforcePageExtensions.selectOption(driver, selectid, status);
		
		clickOnElement(saveButtonLocator);
		
		setDriverContextToPage(driver);
    	return this;
    }
    
	public ServiceCloudLeadsHome deleteCurrentLead() 
	{
		pagelogger.debug("Deleting the current account...");

		IframeUtils.setDriverContextToIframeWithDepth(driver, deleteButtonLocator);

		clickOnElement(deleteButtonLocator);
		
		IframeUtils.setDriverContextToIframeWithDepth(driver, deleteConfirmationButtonLocator);
		clickOnElement(deleteConfirmationButtonLocator);
		
		return ServiceCloudLeadsHome.Instance;
	}


	
}
