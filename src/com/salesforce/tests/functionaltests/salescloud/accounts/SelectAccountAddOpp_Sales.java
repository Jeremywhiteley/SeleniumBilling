package com.salesforce.tests.functionaltests.salescloud.accounts;

import static org.junit.Assert.assertTrue;

import java.io.IOException;

import jxl.read.biff.BiffException;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

import com.salesforce.pages.salescloud.accounts.AccountDetail;
import com.salesforce.pages.salescloud.opportunities.OpportunitiesDetail;
import com.salesforce.pages.salescloud.opportunities.OpportunitiesEdit;
import com.salesforce.pages.salescloud.opportunities.OpportunitiesSelectRecordType;
import com.salesforce.tests.functionaltests.CloudBaseTest;


@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class SelectAccountAddOpp_Sales extends CloudBaseTest
{
	
	@Test
	public void testSelectAccountAddOpp_Sales() throws BiffException, IOException, InterruptedException,
			RowsExceededException, WriteException
	{

		/**
		 * Initialize Test Data
		 */
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String tab = xlsUtil.ReadCell(xlsUtil.GetCell("Tab"), 1);
		final String view = xlsUtil.ReadCell(xlsUtil.GetCell("View"), 1);
		final String filter = xlsUtil.ReadCell(xlsUtil.GetCell("Filter"), 1);
		final String accountName = xlsUtil.ReadCell(xlsUtil.GetCell("AccountName"), 1);
		final String recordType = xlsUtil.ReadCell(xlsUtil.GetCell("RecordType"), 1);
		final String opportunityName = xlsUtil.ReadCell(xlsUtil.GetCell("OpportunityName"), 1);
		final String opportunityAccountName = xlsUtil.ReadCell(xlsUtil.GetCell("OpportunityAccountName"), 1);
		final String stage = xlsUtil.ReadCell(xlsUtil.GetCell("Stage"), 1);
		final String forecastCategory = xlsUtil.ReadCell(xlsUtil.GetCell("ForecastCategory"), 1);
		
		
		/**
		 * Begin Test
		 */
		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();
		defaultTopFrame.verifyPageLoad().changeCurrentApp(salesCloudAppName);
		salesCloudTopFrame.selectTab(tab);

		salesCloudAccountsHome.verifyPageLoad().setViewFilter(view).verifyPageLoad().sortAccountsTableByLetter(filter);
		
		AccountDetail detail = salesCloudAccountsHome.selectFromAccountsTable(accountName);
		OpportunitiesSelectRecordType opportunityType = detail.verifyPageLoad().clickOnNewOpportunity();
		
		OpportunitiesEdit opportunityEdit = opportunityType.verifyPageLoad().selectRecordType(recordType);
		OpportunitiesDetail opportunityDetail = 
				opportunityEdit.verifyPageLoad().setOpportunityName(opportunityName).setAccountName(opportunityAccountName).clickOnDefaultDateLink()
				.setOpportunityStage(stage).setForecastCategory(forecastCategory).clickOnSaveButton();
		
		opportunityDetail.verifyPageLoad();
		
		salesCloudTopFrame.selectTab(tab);
		salesCloudAccountsHome.verifyPageLoad().setViewFilter(view).verifyPageLoad().sortAccountsTableByLetter(filter);
		salesCloudAccountsHome.selectFromAccountsTable(accountName);
		
		/**
		 * Assertion
		 */
		assertTrue("Opportunity was not found in the Opportunities related list", detail.verifyPageLoad().getPresenceOfOpportunity(opportunityName));
	}
	
}
