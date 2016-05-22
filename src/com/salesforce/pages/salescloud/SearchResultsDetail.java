package com.salesforce.pages.salescloud;

import java.util.List;

import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.WebElement;

import com.salesforce.pages.PageBase;
import com.salesforce.pages.salescloud.accounts.AccountDetail;
import com.salesforce.pages.salescloud.contacts.ContactsDetail;
import com.salesforce.pages.salescloud.leads.LeadsDetail;
import com.salesforce.pages.salescloud.opportunities.OpportunitiesDetail;
import com.salesforce.utils.driver.SalesforcePageExtensions;

public class SearchResultsDetail extends PageBase
{

	private static SearchResultsDetail instance;
	public static SearchResultsDetail Instance = (instance != null) ? instance
			: new SearchResultsDetail();

	/** UI Mappings */

	By resultsHeaderLocator = By.xpath("//div/h1[text()='Search Results']");

	/** Page Methods */

	public SearchResultsDetail verifyPageLoad()
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}

	public AccountDetail searchAccountResultsForRecord(String accountName)
	{
		pagelogger.debug("Searching results for Account Record: " + accountName);

		Boolean val = false;
		List<WebElement> elements = driver
				.findElements(By
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
					pagelogger.debug("Found the Account requested");
					clickOnElement(By
							.xpath("//div[contains(@id, 'Account')]/table/descendant::tr[contains(@class,'dataRow')]/th/a[text()='"
									+ accountName + "']"));
					val = true;
					break;
				} else
				{
					pagelogger.debug("Found the Account: " + element.getText()
							+ ". This is not the account requested. Will loop back");
				}

			}

			if (val.equals(false))
			{
				throw new NoSuchElementException("Could not locate the Account with the name: "
						+ accountName);

			}

		}

		return AccountDetail.Instance;
	}

	public OpportunitiesDetail searchOpportunityResultsForRecord(String searchTerm)
	{
		pagelogger.debug("Searching results for Opportunity Record: " + searchTerm);

		By recordCount = By.xpath("//div[@id='Opportunity_body']/table/tbody/tr");

		List<WebElement> elements = null;
		elements = findElements(recordCount);

		pagelogger.debug("Number of records found: " + elements.size());

		if (elements.size() < 1)
		{
			pagelogger.debug("No items were found in the Opportunities Section");
		} else
		{

			for (int i = 0; i < elements.size(); i++)
			{

				try
				{
					By currRecord = By.xpath("//div[@id='Opportunity_body']/table/tbody/tr["
							+ (i + 2) + "]/th[class=(contains(text(), 'dataCell'))]/a");

					if (findElement(currRecord).getText().toUpperCase().trim()
							.equals(searchTerm.toUpperCase().trim()))
					{
						pagelogger.debug("Found the Opportunity Record requested");
						clickOnElement(currRecord);
						break;
					}

				} catch (NoSuchElementException e)
				{
					pagelogger
							.debug("The table row searched does not contain the requested record: "
									+ searchTerm);
				}

			}
		}

		return OpportunitiesDetail.Instance;

	}

	public LeadsDetail searchLeadResultsForRecord(String searchTerm)
	{
		pagelogger.debug("Searching results for Lead Record: " + searchTerm);

		By recordCount = By.xpath("//div[@id='Lead_body']/table/tbody/tr");

		List<WebElement> elements = null;
		elements = findElements(recordCount);

		pagelogger.debug("Number of records found: " + elements.size());

		if (elements.size() < 1)
		{
			pagelogger.debug("No items were found in the Leads Section");
		} else
		{

			for (int i = 0; i < elements.size(); i++)
			{

				try
				{
					By currRecord = By.xpath("//div[@id='Lead_body']/table/tbody/tr[" + (i + 2)
							+ "]/th[class=(contains(text(), 'dataCell'))]/a");

					if (findElement(currRecord).getText().toUpperCase().trim()
							.equals(searchTerm.toUpperCase().trim()))
					{
						pagelogger.debug("Found the Lead Record requested");
						clickOnElement(currRecord);
						break;
					}

				} catch (NoSuchElementException e)
				{
					pagelogger
							.debug("The table row searched does not contain the requested record: "
									+ searchTerm);
				}

			}
		}

		return LeadsDetail.Instance;

	}

	public ContactsDetail searchContactResultsForRecord(String searchTerm)
	{
		pagelogger.debug("Searching results for Contact Record: " + searchTerm);

		By recordCount = By.xpath("//div[@id='Contact_body']/table/tbody/tr");

		List<WebElement> elements = null;
		elements = findElements(recordCount);

		pagelogger.debug("Number of records found: " + elements.size());

		if (elements.size() < 1)
		{
			pagelogger.debug("No items were found in the Contacts Section");
		} else
		{

			for (int i = 0; i < elements.size(); i++)
			{

				try
				{
					By currRecord = By.xpath("//div[@id='Contact_body']/table/tbody/tr[" + (i + 2)
							+ "]/th[class=(contains(text(), 'dataCell'))]/a");
					pagelogger.debug("Found the following record in the Contact Table: "
							+ findElement(currRecord).getText());

					if (findElement(currRecord).getText().toUpperCase().trim()
							.equals(searchTerm.toUpperCase().trim()))
					{
						pagelogger.debug("Found the Contact Record requested");
						clickOnElement(currRecord);
						break;
					}

				} catch (NoSuchElementException e)
				{
					pagelogger
							.debug("The table row searched does not contain the requested record: "
									+ searchTerm);
				}

			}
		}

		return ContactsDetail.Instance;

	}

}
