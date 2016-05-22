package com.salesforce.tests.functionaltests.salescloud.contacts;

import static org.junit.Assert.assertFalse;

import java.io.IOException;

import jxl.read.biff.BiffException;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

import com.salesforce.pages.salescloud.SearchResultsDetail;
import com.salesforce.pages.salescloud.contacts.ContactsDetail;
import com.salesforce.pages.salescloud.opportunities.OpportunitiesDetail;
import com.salesforce.pages.salescloud.opportunities.OpportunitiesEdit;
import com.salesforce.pages.salescloud.opportunities.OpportunitiesSelectRecordType;
import com.salesforce.tests.functionaltests.CloudBaseTest;


@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class SelectContactDelOpp_Sales extends CloudBaseTest
{

	@Test
	public void testSelectContactDelOpp_Sales() throws BiffException, IOException,
			InterruptedException, RowsExceededException, WriteException
	{

		/**
		 * Initialize Test Data
		 */
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String recordType = xlsUtil.ReadCell(xlsUtil.GetCell("RecordType"), 1);
		final String opportunityName = xlsUtil.ReadCell(xlsUtil.GetCell("OpportunityName"), 1);
		final String opportunityAccountName = xlsUtil.ReadCell(xlsUtil.GetCell("OpportunityAccountName"), 1);
		final String stage = xlsUtil.ReadCell(xlsUtil.GetCell("Stage"), 1);
		final String forecastCategory = xlsUtil.ReadCell(xlsUtil.GetCell("ForecastCategory"), 1);
		final String searchText = xlsUtil.ReadCell(xlsUtil.GetCell("SearchText"), 1);
		final String contactName = xlsUtil.ReadCell(xlsUtil.GetCell("ContactName"), 1);

		
		/**
		 * Begin Test
		 */
		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();
		defaultTopFrame.verifyPageLoad().changeCurrentApp(salesCloudAppName);

		SearchResultsDetail searchResults = salesCloudTopFrame.enterTextAndSearch(searchText);
		ContactsDetail detail = searchResults.verifyPageLoad().searchContactResultsForRecord(
				contactName);

		OpportunitiesSelectRecordType opportunityType = detail.verifyPageLoad()
				.clickOnNewOpportunityButton();

		OpportunitiesEdit opportunityEdit = opportunityType.verifyPageLoad().selectRecordType(
				recordType);
		OpportunitiesDetail opportunityDetail = opportunityEdit.verifyPageLoad()
				.setOpportunityName(opportunityName).setAccountName(opportunityAccountName)
				.clickOnDefaultDateLink().setOpportunityStage(stage)
				.setForecastCategory(forecastCategory).clickOnSaveButton();

		opportunityDetail.verifyPageLoad();
		searchResults = salesCloudTopFrame.enterTextAndSearch(searchText);
		detail = searchResults.verifyPageLoad().searchContactResultsForRecord(contactName);
		detail.deleteOpportunity(opportunityName);
		
		
		/**
		 * Assertion
		 */
		assertFalse("Opportunity was found in the Opportunities related list after delete", detail
				.verifyPageLoad().getPresenceOfOpportunity(opportunityName));
	}

}
