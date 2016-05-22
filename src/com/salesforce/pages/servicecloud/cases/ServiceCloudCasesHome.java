package com.salesforce.pages.servicecloud.cases;

import java.util.List;

import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;
import com.salesforce.utils.driver.ServiceCloudPageExtensions;

public class ServiceCloudCasesHome extends PageBase
{

	private static ServiceCloudCasesHome instance;
	public static ServiceCloudCasesHome Instance = (instance != null) ? instance
			: new ServiceCloudCasesHome();

	/** UI Mappings */

	By caseFilterLocator = By.xpath("//option[contains(text(),'Cases')]/../../select");
	By newCaseButtonLocator = By.cssSelector("input[title='New Case']");
	By refreshButtonLocator = By.cssSelector("input[title='Refresh']");
	By closecaseButton = By.xpath("//input[@title='Close']");
	By caseNumberLocator = By.xpath("//div[@title='Case Number']");
	By closeCaseLabel = By.xpath("//h1[text()='Close Case']");
	By changeOwnerButton = By.xpath("//input[@title='Change Owner']");
	By acceptButton = By.xpath("//input[@title='Accept']");
	By changeStatusButton = By.xpath("//input[@title='Change Status']");
	String statusOfACase = "//a[text()='case_number']/../../..//div[contains(@id,'CASES_STATUS')]";
	String ownerOfACase = "//a[text()='case_number']/../../..//div[contains(@id,'CASES_STATUS')]";
	String delCase = "//a[text()='case_number']/../../..//span[text()='Del']";
	String editCase = "//a[text()='case_number']/../../..//span[text()='Edit']";
	By goButton = By.xpath("//span/input[contains(@value,'Go')]");

	/** Page Methods */

	public ServiceCloudCasesHome verifyPageLoad()
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}

	public ServiceCloudCasesHome selectCaseFilter(String filter)
	{
		pagelogger.debug("Selecting the case filter: " + filter);

		IframeUtils.setDriverContextToIframeWithDepth(driver, caseFilterLocator);

		String id = getAttributeID(caseFilterLocator);
		pagelogger.debug("The filter id is: " + id);
		SalesforcePageExtensions.selectOption(driver, id, filter);

		try
		{
			clickOnElement(goButton);
		} catch (NoSuchElementException e)
		{
			pagelogger.debug("Go Button not found. Page might not load as expected. " + id);

		}

		setDriverContextToPage(driver);
		return this;
	}

	public List<String> getCasesFilterAsList()
	{
		List<String> fields = SalesforcePageExtensions.returnPicklistOptionsAsList(driver,
				caseFilterLocator);
		return fields;
	}

	public ServiceCloudCasesHome refreshCaseTable()
	{
		pagelogger.debug("Refreshing the Cases Home page");

		IframeUtils.setDriverContextToIframeWithDepth(driver, refreshButtonLocator);

		clickOnElement(refreshButtonLocator);

		setDriverContextToPage(driver);
		return this;

	}

	public String getStatusOfACase(String caseNumber)
	{
		pagelogger.debug("Getting the status of case: " + caseNumber);

		synchronize(30);

		IframeUtils.setDriverContextToIframeWithDepth(driver, refreshButtonLocator);

		String status = findElement(By.xpath(statusOfACase.replace("case_number", caseNumber)))
				.getText();

		setDriverContextToPage(driver);
		return status;
	}

	public ServiceCloudCasesDetail selectFromCaseTable(String caseNumber)
	{
		pagelogger.debug("Selecting the following record within the case table: " + caseNumber);

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, refreshButtonLocator);

		new WebDriverWait(driver, 10).until(ExpectedConditions
				.visibilityOfElementLocated(refreshButtonLocator));

		SalesforcePageExtensions.selectFromRecordTable(driver, caseNumber);

		setDriverContextToPage(driver);
		return ServiceCloudCasesDetail.Instance;
	}

	public void selectAccountTab(String tab)
	{
		pagelogger.debug("Selecting the Account tab...");

		synchronize(30);
		ServiceCloudPageExtensions.selectNavigatorTab(driver, tab);

	}

	public void clickOnDeleteCase(String caseNumber)
	{
		pagelogger.debug("Clicking on the Delete Case button...");

		IframeUtils.setDriverContextToIframeWithDepth(driver, refreshButtonLocator);

		String delCaseLocator = delCase.replace("case_number", caseNumber);
		clickOnElement(By.xpath((delCaseLocator)));
		SalesforcePageExtensions.acceptModalDialog(driver);

		setDriverContextToPage(driver);
	}

	public void clickOnEditCase(String caseNumber)
	{

		pagelogger.debug("Clicking on the Edit Case button...");

		IframeUtils.setDriverContextToIframeWithDepth(driver, refreshButtonLocator);

		String editCaseLocator = editCase.replace("case_number", caseNumber);
		clickOnElement(By.xpath((editCaseLocator)));

		setDriverContextToPage(driver);
	}

	public ServiceCloudCasesSelectRecordType clickOnNewCaseButton()
	{

		pagelogger.debug("Clicking on the New Case button...");

		IframeUtils.setDriverContextToIframeWithDepth(driver, newCaseButtonLocator);

		clickOnElement(newCaseButtonLocator);

		setDriverContextToPage(driver);

		return ServiceCloudCasesSelectRecordType.Instance;
	}

	public ServiceCloudCloseCase clickOnCloseCaseButton()
	{
		pagelogger.debug("Clicking on the Close Case button...");

		IframeUtils.setDriverContextToIframeWithDepth(driver, closecaseButton);

		clickOnElement(closecaseButton);

		findElement(closeCaseLabel);

		setDriverContextToPage(driver);

		return ServiceCloudCloseCase.Instance;
	}

	public ServiceCloudCasesHome checkmarkCase(String caseNumber)
	{
		pagelogger.debug("Checkmarking the case: " + caseNumber);

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, caseNumberLocator);

		pagelogger.debug("Checkmarking the case: " + caseNumber);

		SalesforcePageExtensions.checkmarkCaseRecordFromRecordTable(driver, caseNumber);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudCasesHome checkmarkFirstCaseDifferentFromLoggedInUser(String username)
	{
		pagelogger.debug("Checkmarking the first case:of user " + username);

		String firstCaseDifferentFromLoggedInUser = "//div[contains(@class,'OWNER_NAME')]//span[not(contains(text(),'"
				+ username + "'))]/../../../..//input[@class='checkbox']";
		By caseCheckbox = By.xpath(firstCaseDifferentFromLoggedInUser);

		IframeUtils.setDriverContextToIframeWithDepth(driver, caseCheckbox);

		clickOnElement(caseCheckbox);

		setDriverContextToPage(driver);
		return this;

	}

	public String getOwnerNameOfCaseDifferentFromLoggedInUser(String username)
	{
		pagelogger.debug("Getting the owner name of the case " + username);

		synchronize(30);
		String firstCaseDifferentFromLoggedInUser = "//div[contains(@class,'OWNER_NAME')]//span[not(contains(text(),'"
				+ username + "'))]";
		By caseOwner = By.xpath(firstCaseDifferentFromLoggedInUser);

		IframeUtils.setDriverContextToIframeWithDepth(driver, caseOwner);

		String owner = findElement(caseOwner).getText();

		setDriverContextToPage(driver);
		return owner;

	}

	public String getCaseNumberOfFirstCaseDifferentFromLoggedInUser(String username)
	{
		pagelogger.debug("Getting the Case number text");

		String val = "";
		synchronize(30);
		String firstCaseDifferentFromLoggedInUser = "//div[contains(@class,'OWNER_NAME')]//span[not(contains(text(),'"
				+ username + "'))]/../../../..//div[contains(@id,'CASE_NUM')]/a";
		By caseNo = By.xpath(firstCaseDifferentFromLoggedInUser);

		IframeUtils.setDriverContextToIframeWithDepth(driver, caseNo);

		val = findElement(caseNo).getText();

		setDriverContextToPage(driver);
		return val;
	}

	public ServiceCloudCasesChangeOwner clickOnChangeOwnerButton()
	{
		pagelogger.debug("Clicking on the Change Owner button!");

		IframeUtils.setDriverContextToIframeWithDepth(driver, changeOwnerButton);

		clickOnElement(changeOwnerButton);

		setDriverContextToPage(driver);
		return ServiceCloudCasesChangeOwner.Instance;
	}

	public ServiceCloudCasesHome clickOnAccept()
	{
		pagelogger.debug("Clicking on the Accept button!");

		IframeUtils.setDriverContextToIframeWithDepth(driver, acceptButton);

		clickOnElement(acceptButton);

		setDriverContextToPage(driver);
		return ServiceCloudCasesHome.Instance;
	}

	public ServiceCloudCasesChangeStatus clickOnChangeStatusButton()
	{
		pagelogger.debug("Clicking on the Change Status button...");

		IframeUtils.setDriverContextToIframeWithDepth(driver, changeStatusButton);

		clickOnElement(changeStatusButton);

		setDriverContextToPage(driver);
		return ServiceCloudCasesChangeStatus.Instance;

	}

}
