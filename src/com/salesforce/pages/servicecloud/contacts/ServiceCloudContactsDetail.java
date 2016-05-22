package com.salesforce.pages.servicecloud.contacts;

import java.util.List;
import java.util.concurrent.TimeUnit;

import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.pages.servicecloud.accounts.ServiceCloudAccountsDetail;
import com.salesforce.pages.servicecloud.cases.ServiceCloudCasesSelectRecordType;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;
import com.salesforce.utils.driver.ServiceCloudPageExtensions;
import com.salesforce.utils.driver.VerifyPageElementsExtensions;


public class ServiceCloudContactsDetail extends PageBase 
{

	 
	private static ServiceCloudContactsDetail instance;
	public static ServiceCloudContactsDetail Instance = (instance != null) ? instance : new ServiceCloudContactsDetail();
	
	
	/** UI Mappings */

	By editButtonLocator = By.xpath("//input[@title='Edit']");
	By detailTab = By.xpath("//div[@id='navigatortab']/descendant::ul[1]/descendant::span/descendant::span[@class='tabText']");
	By contactName = By.xpath("//td[text()='Name']/..//div");
	By accountName = By.xpath("//td[text()='Account Name']/..//div");
	By contactHeaderLocator = By.xpath("//h2[@class='topName']");
	By altContactHeaderLocator = By.xpath("//div[@class='content']/descendant::img[@title='Article']/following-sibling::h2");
	By saveButtonLocator = By.xpath("//td/descendant::input[@title='Save']");
	By contactTitleLocator = By.xpath("//td[text()='Title']/following-sibling::td[1]");
	By contactTitleInputLocator = By.xpath("//td[text()='Title']/following-sibling::td[1]/descendant::input[1]");
	By contactTemp = By.xpath("//td[text()='Title']/following-sibling::td[1]/div");
	By contactInfo = By.xpath("//img[contains(@id,'Contact_Info')]");
	By accountNameLinkLocator = By.xpath("//tr/td[@class='labelCol'][text()='Account Name']/following::td[1]/descendant::a[1]");
	By contactDetailHeaderLocator = By.xpath("//tr/td[@class='pbTitle']/descendant::h2[text()='Contact Detail']");
	String caseRelatedListDataRow = "//body/div//div[contains(@class,'contact')]//div[contains(@class,'listRelatedObject caseBlock')]//th/a[text()='{caseNo}']";
	By caseRelatedListFullList = By.xpath("//body/div//div[contains(@class,'contact')]//div[contains(@class,'listRelatedObject caseBlock')]//div[contains(@class,'ShowMore')]/a[contains(text(),'Go to list')]");
	By caseRelatedList = By.xpath("//body/div//div[contains(@class,'contact')]//div[contains(@class,'listRelatedObject caseBlock')]");
	By contactDetailsBody = By.xpath("//body[@class='hasMotif contactTab  sfdcBody brandQuaternaryBgr']");
	By manageExternalUser = By.xpath("//div[@id='workWithPortalButton']");
	By deleteContact = By.xpath("//input[@title='Delete']");
	By newRequestButton = By.xpath("//input[@value='New Request']");

	
	
	/** Page Methods */

	public ServiceCloudContactsDetail verifyPageLoad() 
	{
		synchronize(30);
		SalesforcePageExtensions.waitForPageToLoad(driver);
		
		return this;
	}

	public ServiceCloudCasesSelectRecordType clickOnNewRequest() throws InterruptedException 
	{
		pagelogger.debug("Clicking on the New request button");

		IframeUtils.setDriverContextToIframeWithDepth(driver, newRequestButton);
		
		clickOnElement(newRequestButton);

		setDriverContextToPage(driver);
		return ServiceCloudCasesSelectRecordType.Instance;
	}

	
	public ServiceCloudContactsHome clickOnDeleteContact() 
	{
		pagelogger.debug("Clicking on the Delete contact button!");

		clickOnElement(deleteContact);
		
		SalesforcePageExtensions.acceptModalDialog(driver);
		
		setDriverContextToPage(driver);
		return ServiceCloudContactsHome.Instance;
	}
	
	public String getContactName() 
	{
		pagelogger.debug("Getting the Contact name!");

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, contactName);

		new WebDriverWait(driver, 30).until(ExpectedConditions
				.visibilityOfElementLocated(contactName));
				
		String contact = findElement(contactName).getText();
		setDriverContextToPage(driver);
		return contact;
	}
	

	public String getAccountName() 
	{
		pagelogger.debug("Getting the Account name!");

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, accountName);

		new WebDriverWait(driver, 30).until(ExpectedConditions
				.visibilityOfElementLocated(accountName));
				
		String accountDisplayName = findElement(accountName).getText();
		setDriverContextToPage(driver);
		return accountDisplayName;
	}

	
	public boolean isCasePresentInCaseRelatedList(String caseNo) {

		pagelogger.debug("Checking to see if the following case is present in the case list: "  + caseNo);

		IframeUtils.setDriverContextToIframeWithDepth(driver, caseRelatedList);

		driver.manage().timeouts().implicitlyWait(10, TimeUnit.SECONDS);
				
		boolean isThereMoreCaseToBeShown = findElements(caseRelatedListFullList).size() > 0;

		if (!isThereMoreCaseToBeShown) 
		{
			caseRelatedListDataRow = caseRelatedListDataRow.replace("{caseNo}",caseNo);
			By caseRelatedListDataRowLocator = By.xpath(caseRelatedListDataRow);
			return findElements(caseRelatedListDataRowLocator).size() > 0;
		} 
		else 
		{
			clickOnElement(caseRelatedListFullList);
			new WebDriverWait(driver, 30).until(ExpectedConditions
					.titleContains("Requests:"));
		}

		setDriverContextToPage(driver);

		String idOfCaseRecord = ServiceCloudPageExtensions
				.setDriverContextToIframeForLinkText(driver, caseNo);

		if (idOfCaseRecord.isEmpty()) 
		{
			return false;
		} 
		else
		{
			return true;
		}
		
	}

	public String getHeaderText() 
	{
		pagelogger.debug("Getting the Contact header text");
		String val = "";

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, contactHeaderLocator);

		new WebDriverWait(driver, 30).until(ExpectedConditions
				.visibilityOfElementLocated(contactHeaderLocator));

		val = findElement(contactHeaderLocator).getText();
		setDriverContextToPage(driver);

		return val;
	}
	

	public String getContactTitle() 
	{
		pagelogger.debug("Getting the Contact Title...");

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, contactTemp);

		new WebDriverWait(driver, 30).until(ExpectedConditions
				.visibilityOfElementLocated(contactTemp));
				
		String contactDisplayTitle = findElement(contactTemp).getText();
	
		setDriverContextToPage(driver);
		return contactDisplayTitle;
	}

	
	public ServiceCloudContactsDetail setContactTitle(String title) 
	{
		pagelogger.debug("Setting Contact Title to: "  + title);

		IframeUtils.setDriverContextToIframeWithDepth(driver, contactTitleLocator);

		String selectid = getAttributeID(contactTitleLocator);
		SalesforcePageExtensions.editInlineTD(driver, selectid);

		selectid = getAttributeID(contactTitleInputLocator);
		SalesforcePageExtensions.enterInputValue(driver, selectid, title);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudContactsEdit clickOnEdit() 
	{
		pagelogger.debug("Clicking on Edit button...");

		IframeUtils.setDriverContextToIframeWithDepth(driver, editButtonLocator);

		clickOnElement(editButtonLocator);

		setDriverContextToPage(driver);
		return ServiceCloudContactsEdit.Instance;
	}
	
	
	public ServiceCloudContactsDetail clickOnSave() 
	{
		pagelogger.debug("Clicking on Save button...");

		IframeUtils.setDriverContextToIframeWithDepth(driver, saveButtonLocator);

		clickOnElement(saveButtonLocator);

		setDriverContextToPage(driver);
		return ServiceCloudContactsDetail.Instance;
	}

	
	public ServiceCloudAccountsDetail clickOnAccountName() 
	{
		pagelogger.debug("Clicking on the Account Name link");

		IframeUtils.setDriverContextToIframeWithDepth(driver, accountNameLinkLocator);

		clickOnElement(accountNameLinkLocator);

		setDriverContextToPage(driver);
		return ServiceCloudAccountsDetail.Instance;
	}

	public ServiceCloudContactsDetail clickOnManageExternalUserButton() 
	{
		pagelogger.debug("Clicking on Manage External User Button...");
		IframeUtils.setDriverContextToIframeWithDepth(driver, manageExternalUser);

		clickOnElement(manageExternalUser);
		
		setDriverContextToPage(driver);
		return this;
	}
	

	public void selectOptionForManageExternalUser(String option) 
	{
		pagelogger.debug("Selecting the option."  + option);

		String optionToSelect = "//div[@id='workWithPortalMenu']/a[text()='" + option + "']";
	
		IframeUtils.setDriverContextToIframeWithDepth(driver, By.xpath(optionToSelect));

		clickOnElement(By.xpath(optionToSelect));
		setDriverContextToPage(driver);

	}

	
	public boolean verifyFieldLabelsExist(String labelList) 
	{
		boolean rtrn = false;

		pagelogger.debug("Verifying that the following labels are present on the Contact Detail page: "  + labelList);

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, contactDetailHeaderLocator);

		String[] passedInFieldsAsArray = labelList.split(",");
		List<String> fieldDifferenceList = VerifyPageElementsExtensions.verifyAllTDValuesExist(driver, passedInFieldsAsArray);

		if (fieldDifferenceList.size() == 0) 
		{
			pagelogger.debug("No differences were found between the passed in fields and found fields");
			rtrn = true;
		} 
		else 
		{
			pagelogger.debug("A field difference was found! --> The difference between the passed in fields and found fields is: "							+ fieldDifferenceList.toString());
		}

		return rtrn;
	}
	
	public List<String> returnAllContactRecordLabels() 
	{
		synchronize(30);
	
		IframeUtils.setDriverContextToIframeWithDepth(driver, contactHeaderLocator);
		
		List<String> labels = SalesforcePageExtensions.returnAllLabelsAsList(driver);
		
		setDriverContextToPage(driver);
		return labels;
	}

	
	public boolean verifyIsFieldsExist(String fieldName) 
	{
		pagelogger.debug("Verifying if field exist with the name: "  + fieldName);

		synchronize(30);
		By fieldLocator = By.xpath("//td[text()='" + fieldName + "']");
		
		IframeUtils.setDriverContextToIframeWithDepth(driver, fieldLocator);
		
		if (findElements(fieldLocator).size() > 0) 
		{
			return true;
		} 
		else 
		{
			return false;
		}
	}

	
}
