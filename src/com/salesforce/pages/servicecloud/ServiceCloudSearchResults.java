package com.salesforce.pages.servicecloud;

import java.util.List;

import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.WebElement;

import com.salesforce.pages.PageBase;
import com.salesforce.pages.servicecloud.accounts.ServiceCloudAccountsDetail;
import com.salesforce.pages.servicecloud.cases.ServiceCloudCasesDetail;
import com.salesforce.pages.servicecloud.cases.ServiceCloudCasesEdit;
import com.salesforce.pages.servicecloud.contacts.ServiceCloudContactsDetail;
import com.salesforce.pages.servicecloud.contacts.ServiceCloudContactsEdit;
import com.salesforce.pages.servicecloud.knowledge.ServiceCloudKnowledgeDetail;
import com.salesforce.pages.servicecloud.leads.ServiceCloudLeadsDetail;
import com.salesforce.pages.servicecloud.questions.ServiceCloudQuestionsDetail;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;

public class ServiceCloudSearchResults extends PageBase
{

	private static ServiceCloudSearchResults instance;
	public static ServiceCloudSearchResults Instance = (instance != null) ? instance
			: new ServiceCloudSearchResults();

	/** UI Mappings */

	By resultsHeaderLocator = By.xpath("//div[@class='content']/h1[text()='Search']");
	By searchAllLocator = By.xpath("//a[@id='searchAll']");

	/** Page Methods */

	public ServiceCloudSearchResults verifyPageLoad()
	{
		synchronize(30);
		SalesforcePageExtensions.waitForPageToLoad(driver);

		return this;
	}

	public ServiceCloudSearchResults clickSearchAll()
	{
		pagelogger.debug("Clicking on the Search All button...");

		IframeUtils.setDriverContextToIframeWithDepth(driver, searchAllLocator);

		clickOnElement(searchAllLocator);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudKnowledgeDetail selectArticle(String articleName)
	{
		pagelogger.debug("Attempting to find and select the article named: " + articleName);

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, resultsHeaderLocator);

		Boolean val = false;

		List<WebElement> elements = findElements(By
				.xpath("//div[contains(@id, 'KnowledgeArticle')]/table/descendant::tr[contains(@class,'dataRow')]/td/a"));

		pagelogger
				.debug("Number of records found in the Articles related list: " + elements.size());

		if (elements.size() < 1)
		{
			pagelogger.debug("No items were found in the Knowledge Articles Section");
		} else
		{

			for (WebElement element : elements)
			{

				if (element.getText().toUpperCase().equals(articleName.toUpperCase()))
				{
					pagelogger.debug("Found the Knowledge Article requested");
					clickOnElement(By.linkText(element.getText()));
					val = true;
					break;
				} else
				{
					pagelogger.debug("Found the article: " + element.getText()
							+ ". This is not the article requested. Will loop back");
				}

			}

			if (val.equals(false))
			{
				throw new NoSuchElementException(
						"Could not locate the Knowledge Article with the name: " + articleName);

			}
		}

		setDriverContextToPage(driver);
		return ServiceCloudKnowledgeDetail.Instance;
	}

	public ServiceCloudAccountsDetail selectCustomers(String accountName)
	{
		pagelogger.debug("Attempting to find and select the Account named: " + accountName);

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, resultsHeaderLocator);

		Boolean val = false;

		List<WebElement> elements = findElements(By
				.xpath("//div[contains(@id, 'Account')]/table/descendant::tr[contains(@class,'dataRow')]/th/a"));

		pagelogger
				.debug("Number of records found in the Accounts related list: " + elements.size());

		if (elements.size() < 1)
		{
			pagelogger.debug("No items were found in the Accounts Section");
		} else
		{

			for (WebElement element : elements)
			{

				if (element.getText().toUpperCase().equals(accountName.toUpperCase()))
				{
					pagelogger.debug("Found the Customer Account requested");
					clickOnElement(By
							.xpath("//div[contains(@id, 'Account')]/table/descendant::tr[contains(@class,'dataRow')]/th/a[text()='"
									+ accountName + "']"));
					val = true;
					break;
				} else
				{
					pagelogger.debug("Found the article: " + element.getText()
							+ ". This is not the account requested. Will loop back");
				}

			}

			if (val.equals(false))
			{
				throw new NoSuchElementException("Could not locate the Account with the name: "
						+ accountName);

			}

		}

		setDriverContextToPage(driver);
		return ServiceCloudAccountsDetail.Instance;
	}

	public ServiceCloudCasesDetail selectCase(String caseName)
	{
		pagelogger.debug("Attempting to find and Select the Case named: " + caseName);

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, resultsHeaderLocator);

		Boolean val = false;

		List<WebElement> elements = findElements(By
				.xpath("//div[contains(@id, 'Case')]/table/descendant::tr[contains(@class,'dataRow')]/th/a"));

		pagelogger.debug("Number of records found in the Cases related list: " + elements.size());

		if (elements.size() < 1)
		{
			pagelogger.debug("No items were found in the Cases Section");
		} else
		{

			for (WebElement element : elements)
			{

				if (element.getText().toUpperCase().equals(caseName.toUpperCase()))
				{
					pagelogger.debug("Found the Case requested");
					clickOnElement(By.linkText(element.getText()));
					val = true;
					break;
				} else
				{
					pagelogger.debug("Found the case: " + element.getText()
							+ ". This is not the case requested. Will loop back");
				}

			}

			if (val.equals(false))
			{
				throw new NoSuchElementException("Could not locate the Case with the name: "
						+ caseName);
			}

		}

		setDriverContextToPage(driver);
		return ServiceCloudCasesDetail.Instance;
	}

	public ServiceCloudCasesEdit editCase(String caseName)
	{
		pagelogger.debug("Attempting to find and Edit the Case named: " + caseName);

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, resultsHeaderLocator);

		Boolean val = false;

		List<WebElement> elements = findElements(By
				.xpath("//div[contains(@id, 'Case')]/table/descendant::tr[contains(@class,'dataRow')]/th/a"));

		pagelogger.debug("Number of records found in the Cases related list: " + elements.size());

		if (elements.size() < 1)
		{
			pagelogger.debug("No items were found in the Cases Section");
		} else
		{

			for (WebElement element : elements)
			{

				if (element.getText().toUpperCase().equals(caseName.toUpperCase()))
				{
					pagelogger.debug("Found the Case requested...Will click on Edit...");
					clickOnElement(By
							.xpath("//div[contains(@id, 'Case')]/table/descendant::tr[contains(@class,'dataRow')]/th/a[text()='"
									+ caseName + "']/../../descendant::td[1]/a[text()='Edit']"));
					val = true;
					break;
				} else
				{
					pagelogger.debug("Found the case: " + element.getText()
							+ ". This is not the case requested. Will loop back");
				}

			}

			if (val.equals(false))
			{
				throw new NoSuchElementException("Could not locate the Case with the name: "
						+ caseName);
			}

		}

		setDriverContextToPage(driver);
		return ServiceCloudCasesEdit.Instance;
	}

	public ServiceCloudQuestionsDetail selectQuestion(String question)
	{
		pagelogger.debug("Attempting to find and select the Question: " + question);

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, resultsHeaderLocator);

		Boolean val = false;

		List<WebElement> elements = findElements(By
				.xpath("//div[contains(@id, 'Question')]/table/descendant::tr[contains(@class,'dataRow')]/th/a"));

		pagelogger.debug("Number of records found in the Questions related list: "
				+ elements.size());

		if (elements.size() < 1)
		{
			pagelogger.debug("No items were found in the Questions Section");
		} else
		{

			for (WebElement element : elements)
			{

				if (element.getText().toUpperCase().equals(question.toUpperCase()))
				{
					pagelogger.debug("Found the Question requested");
					clickOnElement(By
							.xpath("//div[contains(@id, 'Question')]/table/descendant::tr[contains(@class,'dataRow')]/th/a[text()='"
									+ question + "']"));
					val = true;
					break;
				} else
				{
					pagelogger.debug("Found the question: " + element.getText()
							+ ". This is not the question requested. Will loop back");
				}

			}

			if (val.equals(false))
			{
				throw new NoSuchElementException("Could not locate the Question with the text: "
						+ question);

			}

		}

		setDriverContextToPage(driver);
		return ServiceCloudQuestionsDetail.Instance;
	}

	public ServiceCloudContactsDetail selectContact(String contact)
	{
		pagelogger.debug("Attempting to find and select the Contact named: " + contact);

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, resultsHeaderLocator);

		Boolean val = false;

		List<WebElement> elements = findElements(By
				.xpath("//div[contains(@id, 'Contact')]/table/descendant::tr[contains(@class,'dataRow')]/th/a"));

		pagelogger
				.debug("Number of records found in the Contacts related list: " + elements.size());

		if (elements.size() < 1)
		{
			pagelogger.debug("No items were found in the Contacts Section");
		} else
		{

			for (WebElement element : elements)
			{

				if (element.getText().toUpperCase().equals(contact.toUpperCase()))
				{
					pagelogger.debug("Found the Contact requested");
					clickOnElement(By
							.xpath("//div[contains(@id, 'Contact')]/table/descendant::tr[contains(@class,'dataRow')]/th/a[text()='"
									+ contact + "']"));
					val = true;
					break;
				} else
				{
					pagelogger.debug("Found the contact: " + element.getText()
							+ ". This is not the contact requested. Will loop back");
				}

			}

			if (val.equals(false))
			{
				throw new NoSuchElementException("Could not locate the Contact with the name: "
						+ contact);

			}

		}

		setDriverContextToPage(driver);
		return ServiceCloudContactsDetail.Instance;
	}

	public ServiceCloudContactsEdit clickOnEditContact(String contact)
	{
		pagelogger.debug("Attempting to find and select the Contact named: " + contact);

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, resultsHeaderLocator);

		String contactEdit = "//a[text()='{Contact}']/../..//a";
		contactEdit = contactEdit.replace("{Contact}", contact);

		try
		{
			clickOnElement(By.xpath(contactEdit));
		} catch (NoSuchElementException e)
		{
			pagelogger.debug("Cannot find the contact edit link");
		}

		setDriverContextToPage(driver);
		return ServiceCloudContactsEdit.Instance;
	}

	public ServiceCloudLeadsDetail selectLead(String lead)
	{
		pagelogger.debug("Attempting to find and select the Lead named: " + lead);

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, resultsHeaderLocator);

		Boolean val = false;

		List<WebElement> elements = findElements(By
				.xpath("//div[contains(@id, 'Lead')]/table/descendant::tr[contains(@class,'dataRow')]/th/a"));

		pagelogger.debug("Number of records found in the Leads related list: " + elements.size());

		if (elements.size() < 1)
		{
			pagelogger.debug("No items were found in the Leads Section");
		} else
		{

			for (WebElement element : elements)
			{

				if (element.getText().toUpperCase().equals(lead.toUpperCase()))
				{
					pagelogger.debug("Found the Lead requested");
					clickOnElement(By.linkText(element.getText()));
					val = true;
					break;
				} else
				{
					pagelogger.debug("Found the lead: " + element.getText()
							+ ". This is not the lead requested. Will loop back");
				}

			}

			if (val.equals(false))
			{
				throw new NoSuchElementException("Could not locate the Lead with the name: " + lead);

			}

		}

		setDriverContextToPage(driver);
		return ServiceCloudLeadsDetail.Instance;
	}

}
