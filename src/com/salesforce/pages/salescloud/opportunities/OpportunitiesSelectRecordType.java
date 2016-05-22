package com.salesforce.pages.salescloud.opportunities;

import java.util.List;
import java.util.Set;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.CommonMethods;
import com.salesforce.utils.driver.SalesforcePageExtensions;

public class OpportunitiesSelectRecordType extends PageBase
{

	private static OpportunitiesSelectRecordType instance;
	public static OpportunitiesSelectRecordType Instance = (instance != null) ? instance
			: new OpportunitiesSelectRecordType();

	/** UI Mappings */

	By recordTypeLocator = By
			.xpath("//td/label[text()='Record Type of new record']/following::td/div/select");
	By continueLocator = By.cssSelector("input[title='Continue']");

	/** Page Methods */

	public OpportunitiesSelectRecordType verifyPageLoad()
	{
		pagelogger.debug("Waiting for page to load");

		SalesforcePageExtensions.waitForPageToLoad(driver);

		return this;
	}

	public OpportunitiesEdit selectRecordType(String recordType)
	{
		pagelogger.debug("Selecting Record Type: " + recordType);

		String id = getAttributeID(recordTypeLocator);

		SalesforcePageExtensions.selectOption(driver, id, recordType);
		clickOnElement(continueLocator);

		return OpportunitiesEdit.Instance;
	}

	public boolean verifyRecordTypeValues(String passedInOptions)
	{
		pagelogger.debug("Comparing Opportunity record type options with the passed in values: "
				+ passedInOptions);
		boolean rtrn = false;

		List<String> foundOptions = SalesforcePageExtensions.returnSelectOptionsAsList(driver,
				recordTypeLocator);

		pagelogger.debug("Found the following options on the page:" + foundOptions.toString());

		String[] foundOptionsArray = (String[]) foundOptions.toArray();
		String[] passedInOptionsAsArray = passedInOptions.split(",");
		Set<String> fieldDifference = CommonMethods.getArrayDifference(passedInOptionsAsArray,
				foundOptionsArray);

		if (fieldDifference.size() == 0)
		{
			pagelogger
					.debug("No differences were found between the passed in options and the found options");
			rtrn = true;
		} else
		{
			pagelogger
					.debug("Differences were found between the passed in options and found options: "
							+ fieldDifference.toString());
		}

		return rtrn;

	}
}
