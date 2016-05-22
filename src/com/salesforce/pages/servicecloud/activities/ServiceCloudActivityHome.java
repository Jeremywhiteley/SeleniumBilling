package com.salesforce.pages.servicecloud.activities;

import java.util.List;

import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class ServiceCloudActivityHome extends PageBase
{

	 
	private static ServiceCloudActivityHome instance ;
	public static ServiceCloudActivityHome Instance = (instance!=null)?instance:new ServiceCloudActivityHome();
	
	
	/**UI Mappings */
	
	By activityFilterLocator = By.xpath("//div[@class='controls']/select");
	By newActivityButtonLocator = By.cssSelector("input[title='New Activity']");
	By followButtonLocator = By.cssSelector("input[title='Follow']");
	By refreshButtonLocator = By.cssSelector("input[title='Refresh']");
	
	
	/**Page Methods*/
	
	public ServiceCloudActivityHome verifyPageLoad()
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);
		synchronize(30);
		return this;
	}
	
	
	public void selectActivityFilter(String filter)
	{
		
		IframeUtils.setDriverContextToIframeWithDepth(driver, refreshButtonLocator);

		pagelogger.debug("Selecting the question filter: "  + filter);
		
		String id = getAttributeID(activityFilterLocator);
		
		pagelogger.debug("The filter id is: "  + id);
		SalesforcePageExtensions.selectOption(driver, id, filter);
		
		setDriverContextToPage(driver);
	}
	
	
	public List<String> getActivitiesFilterAsList()
	{
		List<String> fields = SalesforcePageExtensions.returnPicklistOptionsAsList(driver,
				activityFilterLocator);
		return fields;
	}
	
	
	public void refreshActivityTable()
	{
		IframeUtils.setDriverContextToIframeWithDepth(driver, refreshButtonLocator);

		pagelogger.debug("Refreshing the Questions Home page");
		
		clickOnElement(refreshButtonLocator);
		
		setDriverContextToPage(driver);
	}
	
	
	public ServiceCloudActivityDetail selectFromActivityTable(String activity)
	{
		IframeUtils.setDriverContextToIframeWithDepth(driver, refreshButtonLocator);
		
		SalesforcePageExtensions.selectFromRecordTable(driver, activity);
		
		setDriverContextToPage(driver);
		
		return ServiceCloudActivityDetail.Instance;
	}
	
	
	public ServiceCloudActivitySelectRecordType createNewActivity()
	{
		IframeUtils.setDriverContextToIframeWithDepth(driver, refreshButtonLocator);

		pagelogger.debug("Refreshing the Activity Home page");
		
		clickOnElement(newActivityButtonLocator);
		
		setDriverContextToPage(driver);
		
		return ServiceCloudActivitySelectRecordType.Instance;
	}
	
	
	public void checkmarkActivity(String account)
	{
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, refreshButtonLocator);
		
		pagelogger.debug("Checkmarking the account: "  + account);
		
		new WebDriverWait(driver, 30).until(ExpectedConditions.presenceOfElementLocated(newActivityButtonLocator));

		SalesforcePageExtensions.checkmarkRecordFromRecordTable(driver, account);
		
		setDriverContextToPage(driver);
	}

		
	public ServiceCloudActivityHome filterActivityTableByLetter(String filter)
	{
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, refreshButtonLocator);

		pagelogger.debug("Sorting Account table by: "  + filter);
		
		SalesforcePageExtensions.sortRecordTableByLetter(driver, filter);
		
		setDriverContextToPage(driver);
		
		return this;
		
	}
	

}
