package com.salesforce.pages.servicecloud.accounts;

import java.util.List;

import org.openqa.selenium.Alert;
import org.openqa.selenium.By;
import org.openqa.selenium.NoAlertPresentException;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.pages.servicecloud.cases.ServiceCloudCaseReasonVisibility;
import com.salesforce.pages.servicecloud.contacts.ServiceCloudContactsDetail;
import com.salesforce.pages.servicecloud.contacts.ServiceCloudContactsSelectRecordType;
import com.salesforce.pages.servicecloud.opportunities.ServiceCloudOpportunitiesSelectRecordType;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;
import com.salesforce.utils.driver.ServiceCloudPageExtensions;
import com.salesforce.utils.driver.VerifyPageElementsExtensions;

public class ServiceCloudAccountsDetail extends PageBase
{

	private static ServiceCloudAccountsDetail instance;
	public static ServiceCloudAccountsDetail Instance = (instance != null) ? instance
			: new ServiceCloudAccountsDetail();

	/** UI Mappings */

	By accountOwner = By.xpath("//td[text()='Account Owner']/..//a[contains(@id,'lookup')]");
	By accountHeaderLocator = By.xpath("//div/h2[@class='topName']");
	By altAccountHeaderLocator = By
			.xpath("//div[@class='content']/descendant::img[@title='Article']/following-sibling::h2");
	By newTaskLocator = By
			.xpath("//h3[text()='Open Activities']/following::td[1]/descendant::input[@title='New Task']");
	By newEventLocator = By
			.xpath("//h3[text()='Open Activities']/following::td[1]/descendant::input[@title='New Event']");
	By newContactLocator = By.cssSelector("input[title='New Contact']");
	By newOpportunityLocator = By.cssSelector("input[title='New Opportunity']");
	By editButtonLocator = By.cssSelector("input[title='Edit']");
	By deleteButtonLocator = By.cssSelector("input[title='Delete']");
	By typeFieldLocator = By.xpath("//tr/td[text()='Type']/following::td[1]/descendant::div[1]");
	By typeSelectLocator = By.xpath("//tr/td[text()='Type']/following::td[1]/descendant::select");
	By saveButtonLocator = By.cssSelector("input[title='Save']");
	By userVisibiity = By.xpath("//a[contains(text(),'Edit User Visibility')]");
	By contactRelatedListHeaderLocator = By
			.xpath("//td[@class='pbTitle']/descendant::h3[text()='Contacts']");
	By firstEvent = By
			.xpath("//tr[contains(@class,'even first')]/th[contains(@class,'dataCell')]/a");

	/** Page Methods */

	public ServiceCloudAccountsDetail verifyPageLoad()
	{
		synchronize(30);
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}

	public String getAccountOwner()
	{
		pagelogger.debug("Getting the Account Owner text...");

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, accountOwner);

		new WebDriverWait(driver, 30).until(ExpectedConditions
				.presenceOfElementLocated(accountOwner));

		String accountOwnerName = findElement(accountOwner).getText();

		setDriverContextToPage(driver);
		return accountOwnerName;
	}

	public ServiceCloudAccountsEdit clickOnEdit()
	{
		pagelogger.debug("Clicking on Edit button...");

		clickOnElement(editButtonLocator);

		setDriverContextToPage(driver);

		return ServiceCloudAccountsEdit.Instance;
	}

	public ServiceCloudAccountsEdit clickOnSaveButton()
	{
		pagelogger.debug("Clicking on Save button...");

		clickOnElement(saveButtonLocator);

		setDriverContextToPage(driver);

		return ServiceCloudAccountsEdit.Instance;
	}

	public ServiceCloudAccountsHome deleteCurrentAccount()
	{
		pagelogger.debug("Deleting the current Account...");

		clickOnElement(deleteButtonLocator);
		Alert alert;

		try
		{
			alert = driver.switchTo().alert();
			alert.accept();
		} catch (NoAlertPresentException e)
		{
			pagelogger.debug("WARNING: Account delete alert was NOT found...");
			alert = driver.switchTo().alert();
			alert.accept();
		}

		return ServiceCloudAccountsHome.Instance;
	}

	public boolean isRelatedListPresent(String relatedListName)
	{
		boolean isFound = false;

		synchronize(30);
		String relatedListXpath = "//h2[contains(text(),'" + relatedListName + "')]";
		By relatedListLocator = By.xpath(relatedListXpath);

		try
		{
			IframeUtils.setDriverContextToIframeWithDepth(driver, relatedListLocator, 2);

			if (findElements(relatedListLocator).size() > 0)
			{
				isFound = true;
			}
		} catch (NoSuchElementException e)
		{
			pagelogger.debug("Related list " + relatedListName + " not found");
		}

		return isFound;
	}

	public String getAccountHeader()
	{
		pagelogger.debug("Getting the account header...");

		String val = ServiceCloudPageExtensions.getDetailHeader(driver, accountHeaderLocator,
				altAccountHeaderLocator);

		pagelogger.debug("The account header returned as: " + val);

		return val;

	}

	public ServiceCloudAccountsTaskEdit clickOnNewTaskButton()
	{
		pagelogger.debug("Click on the New Task button...");

		IframeUtils.setDriverContextToIframeWithDepth(driver, newTaskLocator);

		clickOnElement(newTaskLocator);
		setDriverContextToPage(driver);

		return ServiceCloudAccountsTaskEdit.Instance;

	}

	public ServiceCloudAccountsEventEdit clickOnNewEventButton()
	{

		IframeUtils.setDriverContextToIframeWithDepth(driver, newEventLocator);

		pagelogger.debug("Clicking on the New Event button...");

		clickOnElement(newEventLocator);
		setDriverContextToPage(driver);

		return ServiceCloudAccountsEventEdit.Instance;

	}

	public ServiceCloudContactsSelectRecordType clickOnNewContactButton()
	{
		pagelogger.debug("Clicking on the New Contact button...");

		IframeUtils.setDriverContextToIframeWithDepth(driver, newContactLocator);

		clickOnElement(newContactLocator);
		setDriverContextToPage(driver);

		return ServiceCloudContactsSelectRecordType.Instance;

	}

	public ServiceCloudCaseReasonVisibility clickOnEditUserVisibility()
	{
		pagelogger.debug("Clicking on the Edit User Visibility button...");

		IframeUtils.setDriverContextToIframeWithDepth(driver, userVisibiity);

		clickOnElement(userVisibiity);
		setDriverContextToPage(driver);

		return ServiceCloudCaseReasonVisibility.Instance;

	}

	public String getAccountType()
	{

		pagelogger.debug("Getting the Lead rating...");

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, typeFieldLocator);

		String val = findElement(typeFieldLocator).getText();

		pagelogger.debug("The lead rating was found to be: " + val);

		setDriverContextToPage(driver);
		return val;
	}

	public ServiceCloudAccountsDetail setAccountType(String type)
	{
		pagelogger.debug("Updating Account type to: " + type);

		IframeUtils.setDriverContextToIframeWithDepth(driver, typeFieldLocator);

		String id = getAttributeID(typeFieldLocator);

		new WebDriverWait(driver, 30).until(ExpectedConditions.titleContains(pageTitle));

		SalesforcePageExtensions.editInlineTD(driver, id);

		String selectid = getAttributeID(typeSelectLocator);
		SalesforcePageExtensions.selectOption(driver, selectid, type);

		setDriverContextToPage(driver);

		return this;
	}

	public ServiceCloudOpportunitiesSelectRecordType clickOnNewOpportunity()
	{
		pagelogger.debug("Clicking on the New Opportunity button...");

		IframeUtils.setDriverContextToIframeWithDepth(driver, newOpportunityLocator);

		clickOnElement(newOpportunityLocator);
		setDriverContextToPage(driver);

		return ServiceCloudOpportunitiesSelectRecordType.Instance;

	}

	public List<String> returnAllAccountRecordLabels()
	{
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, accountHeaderLocator);
		List<String> labels = SalesforcePageExtensions.returnAllLabelsAsList(driver);
		setDriverContextToPage(driver);

		return labels;
	}

	public ServiceCloudContactsDetail selectFromContactRelatedList(String contact)
	{

		pagelogger.debug("Searching the Contact (SELECT) related list for: " + contact);

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, contactRelatedListHeaderLocator);

		new WebDriverWait(driver, 30).until(ExpectedConditions
				.presenceOfElementLocated(contactRelatedListHeaderLocator));

		List<WebElement> elements = null;
		elements = driver
				.findElements(By
						.xpath("//h3[text()='Contacts']/../following::div[1]/descendant::tr[contains(@class,'dataRow')]/th[contains(@class,'dataCell')]/a"));

		pagelogger.debug("The number of entries in the Contacts related list is: "
				+ elements.size());

		if (!elements.isEmpty())
		{

			for (WebElement e : elements)
			{

				if (e.getText().toUpperCase().equals(contact.toUpperCase()))
				{
					pagelogger
							.debug("Found the entry we were looking for in the contact related list-Will select it!");
					e.click();
					break;
				} else
				{
					pagelogger
							.debug("Found the following entry in the contact related list: "
									+ e.getText() + " This does not match: " + contact
									+ " Will loop back!");
				}
			}

		} else
		{
			throw new NoSuchElementException(
					"Could not locate the Contact Related list Element with the name: " + contact);

		}

		setDriverContextToPage(driver);

		return ServiceCloudContactsDetail.Instance;
	}

	public Boolean verifyInContactRelatedList(String contact)
	{

		Boolean val = false;

		pagelogger.debug("Searching the Contact (VERIFY) related list for: " + contact);

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, contactRelatedListHeaderLocator);

		new WebDriverWait(driver, 30).until(ExpectedConditions
				.presenceOfElementLocated(contactRelatedListHeaderLocator));

		List<WebElement> elements = null;
		elements = driver
				.findElements(By
						.xpath("//h3[text()='Contacts']/../following::div[1]/descendant::tr[contains(@class,'dataRow')]/th[contains(@class,'dataCell')]/a"));

		pagelogger.debug("The number of entries in the Contacts related list is: "
				+ elements.size());

		if (!elements.isEmpty())
		{

			for (WebElement e : elements)
			{

				if (e.getText().toUpperCase().equals(contact.toUpperCase()))
				{
					PageBase.Instance.pagelogger
							.debug("Found the entry we were looking for in the contact related list!");
					val = true;
					break;
				} else
				{
					pagelogger
							.debug("Found the following entry in the contact related list: "
									+ e.getText() + " This does not match: " + contact
									+ " Will loop back!");
				}
			}

		} else
		{
			throw new NoSuchElementException(
					"Could not locate the Contact Related list Element with the name: " + contact);

		}

		setDriverContextToPage(driver);

		return val;
	}

	public ServiceCloudAccountsEventDetail clickOnFirstEvent()
	{
		pagelogger.debug("Clicking on first event");

		IframeUtils.setDriverContextToIframeWithDepth(driver, firstEvent);

		clickOnElement(firstEvent);
		setDriverContextToPage(driver);

		return ServiceCloudAccountsEventDetail.Instance;
	}

	public boolean verifyFieldLabelsExist(String labelList)
	{
		boolean rtrn = false;

		pagelogger
				.debug("Verifying that the following labels are present on the Account Detail page: "
						+ labelList);

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, accountHeaderLocator);

		String[] passedInFieldsAsArray = labelList.split(",");
		List<String> fieldDifferenceList = VerifyPageElementsExtensions.verifyAllTDValuesExist(
				driver, passedInFieldsAsArray);

		if (fieldDifferenceList.size() == 0)
		{
			pagelogger
					.debug("No differences were found between the passed in fields and found fields");
			rtrn = true;
		} else
		{
			pagelogger
					.debug("A field difference was found! --> The difference between the passed in fields and found fields is: "
							+ fieldDifferenceList.toString());
		}

		return rtrn;
	}

}
