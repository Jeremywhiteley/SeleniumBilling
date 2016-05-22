package com.salesforce.pages.salescloud.contacts;

import java.util.List;

import org.openqa.selenium.Alert;
import org.openqa.selenium.By;
import org.openqa.selenium.NoAlertPresentException;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.pages.salescloud.cases.CasesSelectRecordType;
import com.salesforce.pages.salescloud.opportunities.OpportunitiesSelectRecordType;
import com.salesforce.pages.salescloud.tasks.TaskEdit;
import com.salesforce.utils.driver.SalesforcePageExtensions;
import com.salesforce.utils.driver.VerifyPageElementsExtensions;

public class ContactsDetail extends PageBase
{

	private static ContactsDetail instance;
	public static ContactsDetail Instance = (instance != null) ? instance : new ContactsDetail();

	/** UI Mappings */

	By editButtonLocator = By.cssSelector("input[title='Edit']");
	By contactHeaderLocator = By.xpath("//div/h2[@class='topName']");
	By deleteButtonLocator = By.cssSelector("input[title='Delete']");
	By titleLocator = By.xpath("//td[text()='Title']/following-sibling::td[1]");
	By titleInputLocator = By
			.xpath("//td[text()='Title']/following-sibling::td[1]/descendant::input[1]");
	By phoneLocator = By.xpath("//td[text()='Phone']/following-sibling::td[1]");
	By phoneInputLocator = By
			.xpath("//td[text()='Phone']/following-sibling::td[1]/descendant::input[1]");
	By emailLocator = By.xpath("//td[text()='Email']/following-sibling::td[1]");
	By emailInputLocator = By
			.xpath("//td[text()='Email']/following-sibling::td[1]/descendant::input[1]");
	By leadSourceFieldLocator = By
			.xpath("//tr/td[text()='Lead Source']/following::td[1]/descendant::div[1]");
	By leadSourceSelectLocator = By
			.xpath("//tr/td[text()='Lead Source']/following::td[1]/descendant::select[1]");
	By accountNameFieldLocator = By
			.xpath("//tr/td[text()='Account Name']/following::td[1]/descendant::div[1]");
	By accountNameLookupLocator = By
			.xpath("//tr/td[text()='Account Name']/following::td[1]/descendant::div[1]/../descendant::div[2]/descendant::span[1]/descendant::a[1]");
	By contactName = By.xpath("//td[text()='Name']/..//div");
	By accountName = By.xpath("//td[text()='Account Name']/..//div");
	By newOpportunityButtonLocator = By.cssSelector("input[value='New Opportunity']");
	By changeOwnerLocator = By.xpath("//a[text()='[Change]']");
	By contactOwnerLocator = By.xpath("//td[text()='Contact Owner']/..//a[contains(@id,'lookup')]");
	By newTaskButtonLocator = By.cssSelector("input[value='New Task']");
	By newCaseButtonLocator = By.cssSelector("input[value='New Case']");
	By logACallButtonLocator = By.cssSelector("input[value='Log a Call']");

	/** Page Methods */

	public ContactsDetail verifyPageLoad()
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}

	public ContactsChangeOwner clickOnChangeOwner()
	{
		pagelogger.debug("Clicking on Change Owner...");

		clickOnElement(changeOwnerLocator);
		return ContactsChangeOwner.Instance;
	}

	public String getHeaderText()
	{
		pagelogger.debug("Getting the Contact Header text...");
		String val = findElement(contactHeaderLocator).getText();
		return val;
	}

	public String getContactOwner()
	{
		pagelogger.debug("Getting the Contact Owner...");

		String accountOwnerName = findElement(contactOwnerLocator).getText();
		return accountOwnerName;
	}

	public String getContactName()
	{
		pagelogger.debug("Getting the Contact Name...");

		String contact = findElement(contactName).getText();
		setDriverContextToPage(driver);

		return contact;
	}

	public String getAccountName()
	{
		pagelogger.debug("Getting the Account Name...");

		String accountDisplayName = findElement(accountName).getText();
		return accountDisplayName;
	}

	public ContactsEdit clickOnEditButton()
	{
		pagelogger.debug("Editing the Contact record detail...");

		clickOnElement(editButtonLocator);

		return ContactsEdit.Instance;
	}

	public OpportunitiesSelectRecordType clickOnNewOpportunityButton()
	{
		pagelogger.debug("Clicking on New Opportunity...");

		SalesforcePageExtensions.waitForPageToLoad(driver);
		clickOnElement(newOpportunityButtonLocator);

		return OpportunitiesSelectRecordType.Instance;
	}

	public ContactsHome clickOnDeleteButton()
	{
		pagelogger.debug("Clicking on Delete...");

		clickOnElement(deleteButtonLocator);

		Alert alert;

		try
		{
			alert = driver.switchTo().alert();
			alert.accept();
		} catch (NoAlertPresentException e)
		{
			pagelogger.debug("WARNING: Contact Delete confirmation box was not present...");
			throw e;
		}

		return ContactsHome.Instance;
	}

	public ContactsDetail setTitle(String title)
	{
		pagelogger.debug("Setting Title to: " + title);

		String titleCellID = getAttributeID(titleLocator);
		SalesforcePageExtensions.editInlineTD(driver, titleCellID);

		new WebDriverWait(driver, 30).until(ExpectedConditions
				.presenceOfElementLocated(titleInputLocator));

		String titleInputID = getAttributeID(titleInputLocator);
		SalesforcePageExtensions.enterInputValue(driver, titleInputID, title);

		return this;
	}

	public ContactsDetail setPhone(String phone)
	{
		pagelogger.debug("Setting Phone to: " + phone);

		String titleCellID = getAttributeID(phoneLocator);
		SalesforcePageExtensions.editInlineTD(driver, titleCellID);

		String titleInputID = getAttributeID(phoneInputLocator);
		SalesforcePageExtensions.enterInputValue(driver, titleInputID, phone);

		return this;
	}

	public ContactsDetail setEmail(String email)
	{
		pagelogger.debug("Setting Email to: " + email);

		String titleCellID = getAttributeID(emailLocator);
		SalesforcePageExtensions.editInlineTD(driver, titleCellID);

		String titleInputID = getAttributeID(emailInputLocator);
		SalesforcePageExtensions.enterInputValue(driver, titleInputID, email);

		return this;
	}

	public ContactsEdit setLeadSource(String source)
	{
		pagelogger.debug("Setting Lead Source to: " + source);

		String id = getAttributeID(leadSourceFieldLocator);
		SalesforcePageExtensions.editInlineTD(driver, id);

		String selectid = getAttributeID(leadSourceSelectLocator);
		SalesforcePageExtensions.selectOption(driver, selectid, source);

		return ContactsEdit.Instance;
	}

	public ContactsDetail setAccountName(String name) throws InterruptedException
	{
		pagelogger.debug("Setting Account Name to: " + name);

		String id = getAttributeID(accountNameFieldLocator);
		SalesforcePageExtensions.editInlineTD(driver, id);

		new WebDriverWait(driver, 30).until(ExpectedConditions
				.visibilityOfElementLocated(accountNameLookupLocator));

		String lookupID = getAttributeID(leadSourceSelectLocator);
		String mwh = driver.getWindowHandle();
		SalesforcePageExtensions.selectFromLookup(driver, name, mwh, lookupID);

		return this;
	}

	public boolean verifyTDValuesExist(String fields)
	{
		pagelogger.debug("Verifying all contact detail labels exist (TD)...");
		boolean noErrorsFound = true;

		String[] arrFields = fields.split("\\,", -1);
		List<String> result = VerifyPageElementsExtensions
				.verifyAllTDValuesExist(driver, arrFields);
		pagelogger.debug("Size: " + result.size());

		if (result.size() > 0)
		{
			noErrorsFound = false;
		}

		return noErrorsFound;
	}

	public boolean getPresenceOfOpportunity(String opportunityName)
	{
		pagelogger.debug("Searching Opportunity Related List for entry: " + opportunityName);

		boolean val = false;
		List<WebElement> rows = driver
				.findElements(By
						.xpath("//div[contains(@id, 'RelatedOpportunityList')]/div/div/div[contains(@id, '_body')]/table/tbody/tr[contains(@class, 'dataRow')]/th/a"));

		for (int i = 1; i <= rows.size(); i++)
		{
			pagelogger.debug("Searching row [" + i + "] for value: " + opportunityName);

			if (rows.get(i - 1).getText().toUpperCase().trim()
					.equals(opportunityName.toUpperCase().trim()))
			{
				val = true;
				break;
			} else
			{
				pagelogger.debug("Did not find the passed in row. Found: "
						+ rows.get(i - 1).getText() + " wanted to find: " + opportunityName.trim());
			}
		}

		return val;
	}

	public String getLeadSource()
	{
		pagelogger.debug("Getting the Lead Source...");

		String val = findElement(leadSourceFieldLocator).getText();

		return val;
	}

	public TaskEdit clickOnNewTaskButton()
	{
		pagelogger.debug("Clicking on New Task Button...");

		SalesforcePageExtensions.waitForPageToLoad(driver);
		clickOnElement(newTaskButtonLocator);

		return TaskEdit.Instance;
	}

	public TaskEdit clickOnLogACallButton()
	{
		pagelogger.debug("Clicking on Log a Call Button...");

		SalesforcePageExtensions.waitForPageToLoad(driver);
		clickOnElement(logACallButtonLocator);

		return TaskEdit.Instance;
	}

	public CasesSelectRecordType clickOnNewCaseButton()
	{
		pagelogger.debug("Clicking on New Case Button...");

		SalesforcePageExtensions.waitForPageToLoad(driver);
		clickOnElement(newCaseButtonLocator);

		return CasesSelectRecordType.Instance;
	}

	public boolean getPresenceOfActivity(String activityName)
	{
		pagelogger.debug("Searching Activity Related List for entry: " + activityName);

		boolean val = false;
		List<WebElement> rows = driver
				.findElements(By
						.xpath("//div[contains(@id, 'RelatedActivityList')]/div/div/div[contains(@id, '_body')]/table/tbody/tr[contains(@class, 'dataRow')]/th/a"));

		for (int i = 1; i <= rows.size(); i++)
		{
			pagelogger.debug("Searching row [" + i + "] for value: " + activityName);

			if (rows.get(i - 1).getText().toUpperCase().trim()
					.equals(activityName.toUpperCase().trim()))
			{
				val = true;
				break;
			} else
			{
				pagelogger.debug("Did not find the passed in row. Found: " + rows.get(i).getText()
						+ " wanted to find: " + activityName.toUpperCase().trim());
			}
		}

		return val;

	}

	public boolean getPresenceOfCase(String caseName)
	{
		pagelogger.debug("Searching Cases Related List for entry: " + caseName);

		boolean val = false;
		List<WebElement> rows = driver
				.findElements(By
						.xpath("//div[contains(@id, 'RelatedCaseList')]//td[contains(@class,'dataCell')]/a"));

		for (int i = 1; i <= rows.size(); i++)
		{
			pagelogger.debug("Searching row [" + i + "] for value: " + caseName);

			if (rows.get(i - 1).getText().toUpperCase().trim()
					.equals(caseName.toUpperCase().trim()))
			{
				val = true;
				break;
			} else
			{
				pagelogger.debug("Did not find the passed in row. Found: " + rows.get(i).getText()
						+ " wanted to find: " + caseName.toUpperCase().trim());
			}
		}

		return val;

	}

	public ContactsDetail deleteOpportunity(String oppName)
	{
		pagelogger.debug("Deleting Opportunity from the related list: " + oppName);

		if (this.getPresenceOfOpportunity(oppName))
		{
			pagelogger.debug("Found the Opportunity in the related list. Will delete!");
			Alert alert;

			clickOnElement(By.xpath("//a[text()='" + oppName + "']/../../td/a[text()='Del']"));

			try
			{
				alert = driver.switchTo().alert();
				alert.accept();
			} catch (NoAlertPresentException e)
			{
				pagelogger
						.debug("WARNING: Opportunity Delete confirmation box was not present after selecting Del...");
				throw e;
			}

		} else
		{
			pagelogger.debug("Could not find Opportunity in the related list: " + oppName);
			throw new NoSuchElementException("Opportunity not found in related list: " + oppName);
		}

		return ContactsDetail.Instance;
	}
}
