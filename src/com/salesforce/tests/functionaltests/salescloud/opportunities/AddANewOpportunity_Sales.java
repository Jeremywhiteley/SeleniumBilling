package com.salesforce.tests.functionaltests.salescloud.opportunities;

import static org.junit.Assert.assertTrue;

import java.io.IOException;

import jxl.read.biff.BiffException;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.experimental.categories.Category;
import org.junit.runners.MethodSorters;

import com.salesforce.custom.junit.Categories.Regression;
import com.salesforce.pages.salescloud.opportunities.OpportunitiesDetail;
import com.salesforce.tests.functionaltests.CloudBaseTest;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class AddANewOpportunity_Sales extends CloudBaseTest
{
	@Test
	@Category(Regression.class)
	public void testAddANewOpportunity() throws BiffException, IOException, InterruptedException,
			RowsExceededException, WriteException
	{

		/**
		 * Initialize Test Data
		 */

		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String accountName = xlsUtil.ReadCell(xlsUtil.GetCell("AccountName"), 1);
		final String tab = xlsUtil.ReadCell(xlsUtil.GetCell("Tab"), 1);
		final String oppStage = xlsUtil.ReadCell(xlsUtil.GetCell("OppStage"), 1);
		final String name = xlsUtil.ReadCell(xlsUtil.GetCell("OppName"), 1);
		final String recordType = xlsUtil.ReadCell(xlsUtil.GetCell("OppRecordType"), 1);

		/**
		 * Begin Test
		 */
		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();
		defaultTopFrame.verifyPageLoad().changeCurrentApp(salesCloudAppName);
		salesCloudTopFrame.selectTab(tab);

		OpportunitiesDetail detail = salesCloudOpportunitiesHome.clickOnNewButton()
				.selectRecordType(recordType).setOpportunityName(name).setAccountName(accountName)
				.clickOnDefaultDateLink().setOpportunityStage(oppStage).clickOnSaveButton();

		/**
		 * Assertion
		 */
		assertTrue("Opportunity not saved", !(detail.getOpportunityHeader().isEmpty()));
	}

}