package com.salesforce.pages.servicecloud.cases;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import org.openqa.selenium.Alert;
import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;
import com.salesforce.utils.driver.VerifyPageElementsExtensions;

public class ServiceCloudCasesEdit extends PageBase
{

	private static ServiceCloudCasesEdit instance;
	public static ServiceCloudCasesEdit Instance = (instance != null) ? instance
			: new ServiceCloudCasesEdit();

	/** UI Mappings */

	By contactNameLocator = By.xpath("//a[contains(@title,'Contact Name')]/../a");
	By contactNameLookupLocator = By
			.xpath("//td[@class='labelCol']/label[text()='Contact Name']/following::td[1]/span/a");
	By saveButtonLocator = By.xpath("//input[@title = 'Save']");
	By saveAndCloseButtonLocator = By.xpath("//input[contains(@value,'Save & Close')]");
	By accountNameLocator = By
			.xpath("//label[contains(text(), 'Account Name')]/../following::td//a");
	By prioritySelectLocator = By
			.xpath("//label[contains(text(), 'Priority')]/../following::td//select");
	By originSelectLocator = By
			.xpath("//label[contains(text(), 'Origin')]/../following::td//select");
	By caseType = By.xpath("//label[contains(text(), 'Type')]/../following::td//select");
	By suggestedArticlesHeaderLocator = By.xpath("//h1[text()='Suggested Articles']");
	By typeLocator = By.xpath("//tr/td/label[text()='Type']/following::td[1]/descendant::select");
	By caseOrigin = By
			.xpath("//tr/td/label[text()='Case Origin']/following::td[1]/descendant::select");
	By priority = By.xpath("//tr/td/label[text()='Priority']/following::td[1]/descendant::select");
	By caseStatusOptionLocator = By.xpath("//label[contains(text(),'Status')]/../..//select");
	By caseChannelLocator = By
			.xpath("//label[contains(text(),'Response Channel')]/../following::select");
	By caseReasonOptionLocator = By.xpath("//select[@name='reason']");
	By caseResolutionTypeLocator = By.xpath("//label[text()='Case Resolution Type']/../..//select");
	By caseRootCause = By.xpath("//label[text()='Root Cause']/../..//select");
	By caseResolutionText = By.xpath("//label[text()='Case Resolution']/../..//textarea");
	By caseDueDate = By.xpath("//label[text()='Request Due Date']/../following::input");
	By caseEscalationReasonText = By.xpath("//label[text()='Escalation Reason']/../..//textarea");
	By caseEscalationCancelReason = By
			.xpath("//label[text()='Cancellation Reason']/../following::input");
	By caseEscalateCheckBox = By
			.xpath("//label[contains(text(),'Escalation Start')]/../following::input");
	By caseEscalateEndCheckBox = By
			.xpath("//label[text()='Escalation End']/../..//input[@type='checkbox']");
	By cancelEscalationCheckBox = By
			.xpath("//label[text()='Cancel Escalation']/../following::input[@type='checkbox']");
	By cancelEscalationGreyedOut = By
			.xpath("//label[text()='Cancel Escalation']/../following::img");
	By caseOnSaveErrorMessage = By.xpath("//span[contains(@id,'errors')]//li");
	By cancelEscalationErrorMsg = By
			.xpath("//label[text()='Cancellation Reason']/../following::strong");
	By caseEscalatedByLocator = By.xpath("//label[text()='Escalated By']/../..//select");
	By caseEscalatedByDetailLocator = By
			.xpath("//label[text()='Escalated By Detail']/../..//select");
	By knowledgeArticleSearchInput = By.xpath("//input[@id='searchText']");
	By knowledgeArticleSearchButton = By.xpath("//button[@class='searchButton']");
	By newCaseStatus = By
			.xpath("//td[contains(text(), 'Request Status')]/following::td[text()='New']");
	By caseDescription = By.xpath("//body[contains(@id,'Case_Desc')]");

	/** Page Methods */

	public ServiceCloudCasesEdit verifyPageLoad()
	{
		pagelogger.debug("Waiting from Service Cloud Edit page to load");
		synchronize(30);
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}

	public String getDefaultSelectValue(By by)
	{
		pagelogger.debug("Getting default select value");

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, by);

		String val = SalesforcePageExtensions.getCurrentSelectOption(by);

		pagelogger.debug("The default <select> value returned as: " + val);

		setDriverContextToPage(driver);

		return val;
	}

	public String getDefaultSelectValueCaseOrigin()
	{
		pagelogger.debug("Getting default select value for Case Origin...");

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, caseOrigin);

		String val = SalesforcePageExtensions.getCurrentSelectOption(caseOrigin);

		pagelogger.debug("The default <select> value returned as: " + val);

		setDriverContextToPage(driver);

		return val;
	}

	public String getDefaultSelectValuePriority()
	{
		pagelogger.debug("Getting default select value for Priority...");

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, priority);

		String val = SalesforcePageExtensions.getCurrentSelectOption(priority);

		pagelogger.debug("The default <select> value returned as: " + val);

		setDriverContextToPage(driver);

		return val;
	}

	public String getDefaultSelectValueStatus()
	{
		pagelogger.debug("Getting default select value for Status...");

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, caseStatusOptionLocator);

		String val = SalesforcePageExtensions.getCurrentSelectOption(caseStatusOptionLocator);

		pagelogger.debug("The default <select> value returned as: " + val);

		setDriverContextToPage(driver);

		return val;
	}

	public String getDefaultSelectValueType()
	{
		pagelogger.debug("Getting default select value for Type...");

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, typeLocator);

		String val = SalesforcePageExtensions.getCurrentSelectOption(typeLocator);

		pagelogger.debug("The default <select> value returned as: " + val);

		setDriverContextToPage(driver);

		return val;
	}

	public ServiceCloudCasesEdit setContactName(String contactName) throws InterruptedException
	{
		IframeUtils.setDriverContextToIframeWithDepth(driver, contactNameLocator);

		String id = getAttributeID(contactNameLocator);
		String mwh = driver.getWindowHandle();
		SalesforcePageExtensions.selectFromLookup(driver, contactName, mwh, id);

		setDriverContextToPage(driver);
		return this;

	}

	public String getListOfExternalUserLookupColumns(String contactName)
			throws InterruptedException
	{
		By lookupSearchBoxLocator = By.xpath("//form/descendant::div/input[@type='text']");
		By lookupGoLocator = By.xpath("//form/descendant::div/input[@type='submit']");
		By lookupSearchFrame = By.id("searchFrame");
		By lookupResultsFrame = By.id("resultsFrame");
		By lookupColumns = By.xpath("//div[@class='lookup']//tr[@class='headerRow']");

		pagelogger.debug("Invoking change owner contact lookup.");

		new WebDriverWait(driver, 30).until(ExpectedConditions.titleContains(pageTitle));

		IframeUtils.setDriverContextToIframeWithDepth(driver, contactNameLocator);

		String id = getAttributeID(contactNameLocator);
		String mwh = driver.getWindowHandle();
		final String[] valsArray = contactName.split("\\,", -1);

		pagelogger.debug("Main window handle is: " + mwh);

		String columnHeaders = null;
		List<WebElement> elements = null;
		elements = findElements(By.id(id));

		if (!elements.isEmpty())
		{
			clickOnElement(By.id(id));
			Set<String> s = driver.getWindowHandles();
			Iterator<String> ite = s.iterator();

			while (ite.hasNext())
			{
				String popupHandle = ite.next().toString();
				pagelogger.debug("~~~Current Window Handle is: " + popupHandle);

				if (!popupHandle.contains(mwh))
				{
					pagelogger.debug("New Window Handle is: " + popupHandle
							+ ". Now executing on pop-up Window");
					driver.switchTo().window(popupHandle);
					findElement(lookupSearchFrame);
					driver.switchTo().frame(findElement(lookupSearchFrame));
					findElement(lookupSearchBoxLocator).sendKeys(valsArray[0]);
					clickOnElement(lookupGoLocator);
					driver.switchTo().defaultContent();
					driver.switchTo().frame(findElement(lookupResultsFrame));
					columnHeaders = findElement(lookupColumns).getText();
					pagelogger.debug("Switching back to main Window: " + mwh);
					driver.switchTo().window(mwh);
				}

			}
		} else
		{
			throw new NoSuchElementException(
					"Could not locate the Lookup Button (to open new window) with the Locator ID: "
							+ id + ". Will not search for: " + valsArray[1]);
		}

		setDriverContextToPage(driver);
		return columnHeaders.replace(' ', ',');
	}

	public ServiceCloudCasesEdit searchForArticle(String searchTerm)
	{

		pagelogger.debug("Searching for the article: " + searchTerm);

		IframeUtils.setDriverContextToIframeWithDepth(driver, knowledgeArticleSearchInput);

		findElement(knowledgeArticleSearchInput).clear();
		findElement(knowledgeArticleSearchInput).sendKeys(searchTerm);
		clickOnElement(knowledgeArticleSearchButton);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudCasesDetail clickOnSaveButton()
	{
		pagelogger.debug("Clicking on the Save button...");

		IframeUtils.setDriverContextToIframeWithDepth(driver, saveButtonLocator);

		clickOnElement(saveButtonLocator);

		setDriverContextToPage(driver);
		return ServiceCloudCasesDetail.Instance;
	}

	public ServiceCloudCloseCase clickOnSaveAndClose()
	{
		pagelogger.debug("Clicking on the Save & Close button");

		IframeUtils.setDriverContextToIframeWithDepth(driver, saveAndCloseButtonLocator);

		clickOnElement(saveAndCloseButtonLocator);

		Alert alert = driver.switchTo().alert();
		alert.accept();

		setDriverContextToPage(driver);
		return ServiceCloudCloseCase.Instance;
	}

	public boolean isUpsertFailureErrorMsgPresent(List<String> expectedErrorMsg)
	{
		pagelogger.debug("Checking to see if the following Upsert Error Message is present: "
				+ expectedErrorMsg);

		boolean found = false;
		synchronize(30);

		IframeUtils.setDriverContextToIframeWithDepth(driver, caseOnSaveErrorMessage);

		try
		{
			List<WebElement> webElementsOfErrorMsgs = findElements(caseOnSaveErrorMessage);
			List<String> listOfErrorMsgs = new ArrayList<String>();

			if (webElementsOfErrorMsgs.size() > 0)
			{

				for (WebElement e : webElementsOfErrorMsgs)
				{
					listOfErrorMsgs.add(e.getText().trim());
				}

				if (listOfErrorMsgs.equals(expectedErrorMsg))
				{
					found = true;
					setDriverContextToPage(driver);
				}
			} else
			{
				caseOnSaveErrorMessage = By.xpath("//div[contains(@id,'errors')]");

				IframeUtils.setDriverContextToIframeWithDepth(driver, caseOnSaveErrorMessage);

				String errorMsg = findElement(caseOnSaveErrorMessage).getText();

				if (errorMsg.contains(expectedErrorMsg.get(0)))
				{
					found = true;
					setDriverContextToPage(driver);
				}
			}
		} catch (org.openqa.selenium.NoSuchElementException e)
		{
			setDriverContextToPage(driver);
			return found;
		}

		return found;
	}

	public ServiceCloudCasesEdit setAccountName(String accountName) throws InterruptedException
	{
		pagelogger.debug("Editing the Account name - setting it to: " + accountName);

		new WebDriverWait(driver, 30).until(ExpectedConditions.titleContains(pageTitle));

		IframeUtils.setDriverContextToIframeWithDepth(driver, accountNameLocator);
		IframeUtils.setDriverContextToIframeWithDepth(driver, accountNameLocator);

		pagelogger.debug("getting id...");
		String id = getAttributeID(accountNameLocator);
		pagelogger.debug("id is: " + id);

		String mwh = driver.getWindowHandle();
		SalesforcePageExtensions.selectFromLookup(driver, accountName, mwh, id);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudCasesEdit updateCasePriority(String priority)
	{
		pagelogger.debug("Updating case priority to: " + priority);

		IframeUtils.setDriverContextToIframeWithDepth(driver, prioritySelectLocator);

		String selectid = getAttributeID(prioritySelectLocator);
		SalesforcePageExtensions.selectOption(driver, selectid, priority);

		setDriverContextToPage(driver);
		return ServiceCloudCasesEdit.Instance;
	}

	public ServiceCloudCasesEdit updateCaseOrigin(String origin)
	{
		pagelogger.debug("Updating case origin to: " + origin);

		IframeUtils.setDriverContextToIframeWithDepth(driver, originSelectLocator);

		String selectid = getAttributeID(originSelectLocator);
		SalesforcePageExtensions.selectOption(driver, selectid, origin);

		setDriverContextToPage(driver);
		return ServiceCloudCasesEdit.Instance;
	}

	public ServiceCloudCasesEdit updateRequestType(String typeOfRequest)
	{
		pagelogger.debug("Updating request type to: " + typeOfRequest);

		IframeUtils.setDriverContextToIframeWithDepth(driver, caseType);

		String selectid = getAttributeID(caseType);

		SalesforcePageExtensions.selectOption(driver, selectid, typeOfRequest);

		setDriverContextToPage(driver);

		return ServiceCloudCasesEdit.Instance;
	}

	public ServiceCloudCasesEdit selectCaseChannel(String channel)
	{
		pagelogger.debug("Selecting the following Case Channel: " + channel);

		SalesforcePageExtensions.waitForPageToLoad(driver);
		IframeUtils.setDriverContextToIframeWithDepth(driver, caseChannelLocator);

		String id = getAttributeID(caseChannelLocator);
		SalesforcePageExtensions.selectOption(driver, id, channel);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudCasesEdit selectCaseClosingStatus(String closeStatus)
	{
		pagelogger.debug("Selecting the Case Closing Status: " + closeStatus);

		SalesforcePageExtensions.waitForPageToLoad(driver);
		IframeUtils.setDriverContextToIframeWithDepth(driver, caseStatusOptionLocator);

		String id = getAttributeID(caseStatusOptionLocator);
		SalesforcePageExtensions.selectOption(driver, id, closeStatus);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudCasesEdit setToPageContext()
	{
		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudCasesEdit selectCaseEscalatedBy(String caseEscalatedBy)
	{
		pagelogger.debug("Selecting Case escalated by: " + caseEscalatedBy);

		SalesforcePageExtensions.waitForPageToLoad(driver);
		IframeUtils.setDriverContextToIframeWithDepth(driver, caseEscalatedByLocator);

		String id = getAttributeID(caseEscalatedByLocator);
		SalesforcePageExtensions.selectOption(driver, id, caseEscalatedBy);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudCasesEdit selectCaseEscalatedByDetail(String caseEscalatedByDetail)
	{

		pagelogger.debug("Selecting Case escalated by detail: " + caseEscalatedByDetail);

		SalesforcePageExtensions.waitForPageToLoad(driver);
		IframeUtils.setDriverContextToIframeWithDepth(driver, caseEscalatedByDetailLocator);

		String id = getAttributeID(caseEscalatedByDetailLocator);
		SalesforcePageExtensions.selectOption(driver, id, caseEscalatedByDetail);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudCasesEdit selectCaseResolutionType(String resolutionType)
	{
		pagelogger.debug("Selecting Case resolution type: " + resolutionType);

		SalesforcePageExtensions.waitForPageToLoad(driver);
		IframeUtils.setDriverContextToIframeWithDepth(driver, caseResolutionTypeLocator);

		String id = getAttributeID(caseResolutionTypeLocator);
		SalesforcePageExtensions.selectOption(driver, id, resolutionType);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudCasesEdit selectCaseRootCause(String rootCause)
	{
		pagelogger.debug("Selecting Case Root Cause: " + rootCause);

		SalesforcePageExtensions.waitForPageToLoad(driver);
		IframeUtils.setDriverContextToIframeWithDepth(driver, caseRootCause);

		String id = getAttributeID(caseRootCause);
		SalesforcePageExtensions.selectOption(driver, id, rootCause);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudCasesEdit addCaseResolutionText(String caseResolution)
	{
		pagelogger.debug("Adding the following Case Resolution text: " + caseResolution);

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, caseResolutionText);

		new WebDriverWait(driver, 30).until(ExpectedConditions
				.visibilityOfAllElementsLocatedBy(caseResolutionText));

		findElement(caseResolutionText).sendKeys(caseResolution);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudCasesEdit addCaseDueDate(String dueDate)
	{
		pagelogger.debug("Adding the case due date: " + dueDate);
		synchronize(30);

		IframeUtils.setDriverContextToIframeWithDepth(driver, caseDueDate);

		findElement(caseDueDate).sendKeys(dueDate);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudCasesEdit addCaseEscalationReason(String caseEscalationReason)
	{
		pagelogger.debug("Adding the Case Escalation Reason: " + caseEscalationReason);

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, caseEscalationReasonText);

		new WebDriverWait(driver, 30).until(ExpectedConditions
				.visibilityOfAllElementsLocatedBy(caseEscalationReasonText));

		findElement(caseEscalationReasonText).sendKeys(caseEscalationReason);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudCasesEdit addCaseDescription(String caseDesc)
	{
		pagelogger.debug("Adding the Case Description: " + caseDesc);

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, caseDescription);

		try
		{
			findElement(caseDescription).sendKeys(caseDesc);
		} catch (NoSuchElementException e)
		{
			pagelogger.debug("Case Description probably in nested iframe" + caseDesc);

			setDriverContextToPage(driver);
			IframeUtils.setDriverContextToIframeWithDepth(driver, caseDescription, 2);

			findElement(caseDescription).sendKeys(caseDesc);
		}

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudCasesEdit addCaseCancelEscalationReason(String caseEscalationReason)
	{
		pagelogger.debug("Adding the Case Cancel Escalation Reason: " + caseEscalationReason);

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, caseEscalationCancelReason);

		findElement(caseEscalationCancelReason).sendKeys(caseEscalationReason);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudCasesEdit clearCaseResolutionText()
	{
		pagelogger.debug("Clearing the Case Resolution text...");

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, caseResolutionText);

		new WebDriverWait(driver, 30).until(ExpectedConditions
				.visibilityOfAllElementsLocatedBy(caseResolutionText));

		findElement(caseResolutionText).clear();

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudCasesEdit checkStartEscalation()
	{
		pagelogger.debug("Checking the Start Escalation checkbox");

		IframeUtils.setDriverContextToIframeWithDepth(driver, caseEscalateCheckBox);

		if (!findElement(caseEscalateCheckBox).isSelected())
		{
			clickOnElement(caseEscalateCheckBox);
		} else
		{
			pagelogger.debug("The start escalate checkbox was already checked!");
		}

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudCasesEdit checkEndEscalation()
	{
		pagelogger.debug("Clicking End Escalate Case");

		IframeUtils.setDriverContextToIframeWithDepth(driver, caseEscalateEndCheckBox);

		if (!findElement(caseEscalateEndCheckBox).isSelected())
		{
			clickOnElement(caseEscalateEndCheckBox);
		} else
		{
			pagelogger.debug("The end escalation checkbox was already checked!");
		}

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudCasesEdit checkCancelEscalation()
	{
		pagelogger.debug("Clicking End Escalate Case");

		IframeUtils.setDriverContextToIframeWithDepth(driver, cancelEscalationCheckBox);

		if (!findElement(cancelEscalationCheckBox).isSelected())
		{
			clickOnElement(cancelEscalationCheckBox);
		} else
		{
			pagelogger.debug("The end escalation checkbox was already checked!");
		}
		setDriverContextToPage(driver);

		return this;
	}

	public boolean verifyCaseEscalateByDetailOptions(String[] options)
	{
		return VerifyPageElementsExtensions.verifySelectOptions(driver,
				caseEscalatedByDetailLocator, options);
	}

	public ServiceCloudCasesEdit unCheckStartEscalation()
	{
		pagelogger.debug("Unchecking the Start Escalation checkbox");

		IframeUtils.setDriverContextToIframeWithDepth(driver, caseEscalateCheckBox);

		if (findElement(caseEscalateCheckBox).isSelected())
		{
			clickOnElement(caseEscalateCheckBox);
		} else
		{
			pagelogger.debug("The start escalation checkbox was already unchecked!");
		}

		setDriverContextToPage(driver);
		return this;
	}

}
