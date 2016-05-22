package com.salesforce.pages.salescloud.accounts;

import java.util.List;

import org.openqa.selenium.Alert;
import org.openqa.selenium.By;
import org.openqa.selenium.NoAlertPresentException;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.WebElement;

import com.salesforce.pages.PageBase;
import com.salesforce.pages.salescloud.contacts.ContactsEdit;
import com.salesforce.pages.salescloud.events.EventsEdit;
import com.salesforce.pages.salescloud.opportunities.OpportunitiesSelectRecordType;
import com.salesforce.pages.salescloud.tasks.TaskDetail;
import com.salesforce.pages.salescloud.tasks.TaskEdit;
import com.salesforce.utils.driver.SalesforcePageExtensions;
import com.salesforce.utils.driver.VerifyPageElementsExtensions;

public class AccountDetail extends PageBase
{

	private static AccountDetail instance;
	public static AccountDetail Instance = (instance != null) ? instance : new AccountDetail();

	/** UI Mappings */

	By editButtonLocator = By.cssSelector("input[title='Edit']");
	By deleteButtonLocator = By.cssSelector("input[title='Delete']");
	By errorLocator = By.xpath("//div/div[contains(text(), 'Error: Invalid Data')]");
	By changeOwnerLocator = By.xpath("//a[text()='[Change]']");
	By logAVisitLocator = By.cssSelector("input[value='Log A Visit']");
	By newTaskButtonLocator = By.cssSelector("input[value='New Task']");
	By newEventButtonLocator = By.cssSelector("input[value='New Event']");
	By newOpportunityButtonLocator = By.cssSelector("input[value='New Opportunity']");
	By newContactButtonLocator = By.cssSelector("input[value='New Contact']");
	By accountHeaderLocator = By.xpath("//div/h2[@class='pageDescription']");
	By industryFieldLocator = By
			.xpath("//tr/td[text()='Industry']/following::td[1]/descendant::div[1]");
	By industrySelectLocator = By
			.xpath("//tr/td[text()='Industry']/following::td[1]/descendant::select");
	By saveButtonLocator = By.cssSelector("input[title='Save']");
	By accountOwnerLocator = By
			.xpath("//td[text()='Customer Owner']/..//a[contains(@id,'lookup')]");
	By linkHeader = By.cssSelector("div[class='listHoverLinks'][style*='visible']");
	By detailTab = By.xpath("//span[text()='Details']");

	/** Page Methods */

	public AccountDetail verifyPageLoad()
	{
		pagelogger.debug("Waiting for page to load");

		findElement(editButtonLocator);
		return this;
	}

	public EventsEdit clickOnNewEvent()
	{
		pagelogger.debug("Clicking on New Event...");

		SalesforcePageExtensions.waitForPageToLoad(driver);
		clickOnElement(newEventButtonLocator);

		return EventsEdit.Instance;
	}

	public AccountDetail clickOnDetailTab()
	{
		pagelogger.debug("Clicking on Detail tab...");

		SalesforcePageExtensions.waitForPageToLoad(driver);
		clickOnElement(detailTab);

		return this;
	}

	public TaskEdit clickOnNewTask()
	{
		pagelogger.debug("Clicking on New Task...");

		SalesforcePageExtensions.waitForPageToLoad(driver);
		findElement(newTaskButtonLocator);
		clickOnElement(newTaskButtonLocator);

		return TaskEdit.Instance;
	}

	public ContactsEdit clickOnNewContact()
	{
		pagelogger.debug("Clicking on New Contact...");

		SalesforcePageExtensions.waitForPageToLoad(driver);
		findElement(newContactButtonLocator);
		clickOnElement(newContactButtonLocator);

		return ContactsEdit.Instance;
	}

	public OpportunitiesSelectRecordType clickOnNewOpportunity()
	{
		pagelogger.debug("Clicking on New Opportunity...");

		SalesforcePageExtensions.waitForPageToLoad(driver);
		findElement(newOpportunityButtonLocator);
		clickOnElement(newOpportunityButtonLocator);

		return OpportunitiesSelectRecordType.Instance;
	}

	public AccountsEdit clickOnEdit()
	{
		pagelogger.debug("Clicking on Edit...");

		clickOnElement(editButtonLocator);

		return AccountsEdit.Instance;
	}

	public AccountsHome clickOnDelete()
	{
		pagelogger.debug("Clicking on Delete...");

		clickOnElement(deleteButtonLocator);

		return AccountsHome.Instance;
	}

	public AccountDetail deleteOpportunity(String opportunityName)
	{
		pagelogger.debug("Deleting Opportunity from the related list: " + opportunityName);

		if (this.getPresenceOfOpportunity(opportunityName))
		{
			pagelogger.debug("Found the Opportunity in the related list. Will delete!");
			Alert alert;

			clickOnElement(By.xpath("//a[text()='" + opportunityName
					+ "']/../../td[1]/descendant::a[text()='Del']"));

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
			pagelogger.debug("Could not find Opportunity in the related list: " + opportunityName);
			throw new NoSuchElementException("Opportunity not found in related list: "
					+ opportunityName);
		}

		return AccountDetail.Instance;
	}

	public AccountDetail deleteContact(String contactName)
	{
		pagelogger.debug("Deleting Contact from the related list: " + contactName);

		if (this.getPresenceOfContact(contactName))
		{
			pagelogger.debug("Found the Contact in the related list. Will delete!");
			Alert alert;

			clickOnElement(By.xpath("//a[text()='" + contactName
					+ "']/../../td[1]/descendant::a[text()='Del']"));

			try
			{
				alert = driver.switchTo().alert();
				alert.accept();
			} catch (NoAlertPresentException e)
			{
				pagelogger
						.debug("WARNING: Contact Delete confirmation box was not present after selecting Del...");
				throw e;
			}

		} else
		{
			pagelogger.debug("Could not find Contact in the related list: " + contactName);
			throw new NoSuchElementException("Contact not found in related list: " + contactName);
		}

		return AccountDetail.Instance;
	}

	public TaskEdit clickOnLogAVisit()
	{
		pagelogger.debug("Clicking on Log A Visit...");

		findElement(logAVisitLocator);
		clickOnElement(logAVisitLocator);

		return TaskEdit.Instance;
	}

	public boolean verifyLabelFieldsExist(String fields)
	{
		pagelogger.debug("Verifying if label field exist...");

		boolean noErrorsFound = true;

		String[] arrFields = fields.split("\\,", -1);
		List<String> result = VerifyPageElementsExtensions.verifyAllFieldLabelsExist(driver,
				arrFields);

		if (result.size() > 0)
		{
			noErrorsFound = false;
		}

		return noErrorsFound;
	}

	public boolean verifyFieldsEnabled(String fields)
	{
		pagelogger.debug("Verifying if fields are enabled...");

		boolean val = true;

		String[] arrFields = fields.split("\\,", -1);
		List<String> result = VerifyPageElementsExtensions
				.verifyFieldsAreEnabled(driver, arrFields);

		pagelogger.debug("Number of list items returned as disabled: " + result.size());

		if (result.size() > 0)
		{
			val = false;
		}

		return val;
	}

	public boolean verifyHeaderValuesExist(String fields)
	{
		pagelogger.debug("Verifying if header values exist...");

		boolean noErrorsFound = true;

		String[] arrFields = fields.split("\\,", -1);
		List<String> result = VerifyPageElementsExtensions.verifyAllHeaderValuesExist(driver,
				arrFields);
		pagelogger.debug("Size: " + result.size());

		if (result.size() > 0)
		{
			noErrorsFound = false;
		}

		return noErrorsFound;
	}

	public boolean verifyTDValuesExist(String fields)
	{
		pagelogger.debug("Verifying if TD values exist...");

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

	public boolean verifyUpdateFailure()
	{
		pagelogger.debug("Verifying record update failure");

		boolean val = false;
		findElement(errorLocator);

		if (findElement(errorLocator).isDisplayed() == true)
		{
			val = true;
			pagelogger.debug("Found expected error message");
		} else
		{
			pagelogger.debug("Did not find expected error message");
		}

		return val;
	}

	public boolean verifyUpdateSuccess()
	{
		pagelogger.debug("Verifying record update success");

		boolean val = false;
		findElement(errorLocator);

		if (findElement(errorLocator).isDisplayed() == false)
		{
			val = true;
			pagelogger.debug("Did not find error message - this is expected");
		} else
		{
			pagelogger.debug("Found error message - this is NOT expected");
		}

		return val;
	}

	public AccountsChangeOwner clickOnChangeOwner()
	{
		pagelogger.debug("Clicking on Change Owner");

		clickOnElement(changeOwnerLocator);
		return AccountsChangeOwner.Instance;
	}

	public boolean selectVisit(String visitName)
	{
		pagelogger.debug("Selecting Visit Related List entry: " + visitName);

		boolean val = false;
		List<WebElement> rows = driver
				.findElements(By
						.xpath("//div[contains(@id, 'RelatedHistoryList')]/div/div/form/div[contains(@id, '_body')]/table/tbody/tr[contains(@class, 'dataRow')]/th/a"));

		pagelogger.debug("Found number of rows in visit list: " + rows.size());
		for (int i = 0; i < rows.size(); i++)
		{
			int ctr = i + 1;
			pagelogger.debug("Searching row [" + String.valueOf(ctr) + "] for value: " + visitName);

			if (rows.get(i).getText().toUpperCase().trim()
					.equals("VISIT WITH " + visitName.toUpperCase().trim()))
			{
				rows.get(i).click();
				pagelogger.debug("Found the passed in row value - Clicking...");
				val = true;
				break;
			} else
			{
				pagelogger.debug("Did not find the passed in row. Found: " + rows.get(i).getText()
						+ " wanted to find: " + "VISIT WITH " + visitName.toUpperCase().trim());
			}
		}

		return val;
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

	public boolean getPresenceOfContact(String contactName)
	{

		pagelogger.debug("Searching Contact Related List for entry: " + contactName);

		boolean val = false;
		List<WebElement> rows = driver
				.findElements(By
						.xpath("//div[contains(@id, 'RelatedContactList')]/div/div/div[contains(@id, '_body')]/table/tbody/tr[contains(@class, 'dataRow')]/th/a"));

		pagelogger.debug("Total number of rows is: " + rows.size());

		for (int i = 1; i <= rows.size(); i++)
		{
			pagelogger.debug("Searching row [" + i + "] for value: " + contactName);
			pagelogger.debug("Row value is" + rows.get(i - 1).getText());

			if (rows.get(i - 1).getText().toUpperCase().trim()
					.equals(contactName.toUpperCase().trim()))
			{
				val = true;
				break;
			} else
			{
				pagelogger.debug("Did not find the passed in row. Found: "
						+ rows.get(i - 1).getText() + " wanted to find: " + contactName.trim());
			}
		}

		return val;
	}

	public TaskDetail selectContact(String contactName)
	{
		pagelogger.debug("Selecting Contact Related List entry: " + contactName);

		List<WebElement> rows = driver
				.findElements(By
						.xpath("//div[contains(@id, 'RelatedContactList')]/div/div/div[contains(@id, '_body')]/table/tbody/tr[contains(@class, 'dataRow')]/th/a"));
		pagelogger.debug("Found number of rows in Contact list: " + rows.size());
		for (int i = 1; i <= rows.size(); i++)
		{
			pagelogger.debug("Searching row [" + i + "] for value: " + contactName);

			if (rows.get(i - 1).getText().toUpperCase().trim()
					.equals(contactName.toUpperCase().trim()))
			{
				rows.get(i - 1).click();
				pagelogger.debug("Found the passed in row value - Clicking...");
				break;
			} else
			{
				pagelogger.debug("Did not find the passed in row. Found: " + rows.get(i).getText()
						+ " wanted to find: " + contactName.toUpperCase().trim());
			}
		}

		return TaskDetail.Instance;
	}

	public TaskDetail selectOpenActivity(String activityName)
	{
		pagelogger.debug("Selecting Activity Related List entry: " + activityName);

		List<WebElement> rows = driver
				.findElements(By
						.xpath("//div[contains(@id, 'RelatedActivityList')]/div/div/div[contains(@id, '_body')]/table/tbody/tr[contains(@class, 'dataRow')]/th/a"));
		pagelogger.debug("Found number of rows in visit list: " + rows.size());
		for (int i = 1; i <= rows.size(); i++)
		{
			pagelogger.debug("Searching row [" + i + "] for value: " + activityName);

			if (rows.get(i - 1).getText().toUpperCase().trim()
					.equals(activityName.toUpperCase().trim()))
			{
				rows.get(i - 1).click();
				pagelogger.debug("Found the passed in row value - Clicking...");
				break;
			} else
			{
				pagelogger.debug("Did not find the passed in row. Found: " + rows.get(i).getText()
						+ " wanted to find: " + activityName.toUpperCase().trim());
			}
		}

		return TaskDetail.Instance;
	}

	public String getHeaderText()
	{
		pagelogger.debug("Getting the Account Header text");
		String val = findElement(accountHeaderLocator).getText();
		return val;
	}

	public TaskDetail selectTask(String taskName)
	{
		pagelogger.debug("Clicking on Taskname: " + taskName);
		clickOnElement(By.xpath("// div[contains(@id,'ActivityList')]//th/a[text()='" + taskName
				+ "']"));

		return TaskDetail.Instance;
	}

	public AccountDetail clickOnSave()
	{
		pagelogger.debug("Clicking on Save...");
		clickOnElement(saveButtonLocator);

		return this;
	}

	public AccountDetail setAccountIndustry(String industry)
	{
		pagelogger.debug("Updating Account Industry to: " + industry);

		findElement(linkHeader);
		String id = getAttributeID(industryFieldLocator);
		SalesforcePageExtensions.editInlineTD(driver, id);
		String selectid = getAttributeID(industrySelectLocator);
		SalesforcePageExtensions.selectOption(driver, selectid, industry);
		clickOnElement(saveButtonLocator);

		return this;
	}

	public String getAccountIndustry()
	{
		pagelogger.debug("Getting the Account Industry.");

		String val = findElement(industryFieldLocator).getText();

		return val;
	}

	public String getAccountOwner()
	{
		pagelogger.debug("Getting the Account Owner");

		String accountOwnerName = findElement(accountOwnerLocator).getText();
		return accountOwnerName;
	}

}
