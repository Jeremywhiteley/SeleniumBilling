package com.salesforce.pages;

import java.util.List;

import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.WebElement;

import com.salesforce.pages.PageBase;
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

	


}
