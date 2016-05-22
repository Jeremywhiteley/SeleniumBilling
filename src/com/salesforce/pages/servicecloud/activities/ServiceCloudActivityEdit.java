package com.salesforce.pages.servicecloud.activities;

import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class ServiceCloudActivityEdit extends PageBase 
{

	 
	private static ServiceCloudActivityEdit instance;
	public static ServiceCloudActivityEdit Instance = (instance != null) ? instance : new ServiceCloudActivityEdit();

	
	/** UI Mappings */

	By saveButtonLocator = By.xpath("//input[@name='save']");
	By statusSelectLocator = By.xpath("//td/label[text()='Activity Status']/following::td[1]/descendant::select[1]");
	By activitySubTypeLocator = By.xpath("//td/label[text()='Activity Sub Type']/following::td[1]/descendant::select[1]");
	By activityType = By.xpath("//label[text()='Activity Type']/../following::td//select");
	By activityDetail = By.xpath("//td/label[text()='Activity Detail']/following::td[1]/descendant::select[1]");
	By dateEnterByLinkLocator = By.xpath("//span[@class='dateFormat']/descendant::a[1]");
	By caseNoLocator = By.xpath("//label[contains(text(),'Request')]/../following::td//a");
	By activityDueDate = By.xpath("//label[contains(text(),'Activity Due Date')]/../following::input");
	By primaryContactNumber = By.xpath("//label[text()='Primary Phone Number']/../following::input");
	By secondaryContactNumber = By.xpath("//label[text()='Secondary Phone Number']/../following::input");

	
	
	/** Page Methods */

	public ServiceCloudActivityEdit verifyPageLoad() 
	{
		pagelogger.debug("Waiting for activity edit to load");
		
		synchronize(30);
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}

	
	public ServiceCloudActivityEdit editCaseNo(String caseNo)throws InterruptedException 
	{
		pagelogger.debug("Editing the Case number - setting it to: "  + caseNo);

		IframeUtils.setDriverContextToIframeWithDepth(driver, caseNoLocator);
		String id = getAttributeID(caseNoLocator);
		String mwh = driver.getWindowHandle();
		SalesforcePageExtensions.selectFromLookup(driver, caseNo, mwh, id);
		setDriverContextToPage(driver);
		
		return this;
	}

	
	public ServiceCloudActivityEdit selectStatus(String status) 
	{
		pagelogger.debug("Selecting the activity status: "  + status);

		IframeUtils.setDriverContextToIframeWithDepth(driver, statusSelectLocator);

		String id = getAttributeID(statusSelectLocator);
		SalesforcePageExtensions.selectOption(driver, id, status);

		setDriverContextToPage(driver);

		return this;
	}

	
	public ServiceCloudActivityEdit selectActivitySubType(String subType) 
	{

		pagelogger.debug("Selecting the activity sub type: "  + subType);

		IframeUtils.setDriverContextToIframeWithDepth(driver, activitySubTypeLocator);

		String id = getAttributeID(activitySubTypeLocator);
		SalesforcePageExtensions.selectOption(driver, id, subType);

		setDriverContextToPage(driver);

		return this;
	}
	
	
	public ServiceCloudActivityEdit selectActivityType(String type) {

		pagelogger.debug("Selecting the activity  type: "  + type);

		IframeUtils.setDriverContextToIframeWithDepth(driver, activityType);

		String id = getAttributeID(activityType);
		SalesforcePageExtensions.selectOption(driver, id, type);

		setDriverContextToPage(driver);

		return this;
	}

	
	public ServiceCloudActivityEdit selectActivityDetail(String detail) {

		pagelogger.debug("Selecting the activity detail: "  + detail);

		IframeUtils.setDriverContextToIframeWithDepth(driver, activityDetail);

		String id = getAttributeID(activityDetail);
		SalesforcePageExtensions.selectOption(driver, id, detail);

		setDriverContextToPage(driver);

		return this;
	}

	
	public ServiceCloudActivityEdit enterPrimaryContactnumber(String number) 
	{

		pagelogger.debug("Entering Primary contact number "  + number);
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, primaryContactNumber);

		new WebDriverWait(driver, 30).until(ExpectedConditions
				.visibilityOfElementLocated(primaryContactNumber));

		findElement(primaryContactNumber).clear();
		findElement(primaryContactNumber).sendKeys(number);
		setDriverContextToPage(driver);

		return this;
	}
	
	
	public ServiceCloudActivityEdit enterSecondaryContactnumber(String number) 
	{

		pagelogger.debug("Entering Secondary contact number "  + number);
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, secondaryContactNumber);

		new WebDriverWait(driver, 30).until(ExpectedConditions
				.visibilityOfElementLocated(secondaryContactNumber));

		findElement(secondaryContactNumber).clear();
		findElement(secondaryContactNumber).sendKeys(number);
		setDriverContextToPage(driver);

		return this;
	}

	
	public ServiceCloudActivityEdit setActivityDueDate(String date) 
	{
		pagelogger.debug("Entering Activity Due date "  + date);
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, activityDueDate);

		findElement(activityDueDate).clear();
		findElement(activityDueDate).sendKeys(date);
		setDriverContextToPage(driver);

		return this;
	}

	
	public ServiceCloudActivityEdit setDate() 
	{
		pagelogger.debug("Setting the activity date to default value");

		IframeUtils.setDriverContextToIframeWithDepth(driver, statusSelectLocator);

		clickOnElement(dateEnterByLinkLocator);

		return this;
	}

	
	public ServiceCloudActivityDetail clickOnSave() 
	{
		pagelogger.debug("Setting the activity save button");

		IframeUtils.setDriverContextToIframeWithDepth(driver, saveButtonLocator);

		clickOnElement(saveButtonLocator);

		return ServiceCloudActivityDetail.Instance;

	}
	

}
