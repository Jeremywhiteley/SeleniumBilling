package com.salesforce.tests.functionaltests.salescloud.opportunities;

import static org.junit.Assert.assertTrue;

import java.io.IOException;

import jxl.read.biff.BiffException;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

import com.salesforce.pages.salescloud.opportunities.OpportunitiesDetail;
import com.salesforce.tests.functionaltests.CloudBaseTest;


@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class VerifyAddQuoteInOpp_Sales extends CloudBaseTest
{

	@Test
	public void testAddNewQuoteToOpportunity() throws BiffException, IOException,
			InterruptedException, RowsExceededException, WriteException
	{

		/**
		 * Initialize Test Data
		 */
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String accountName = xlsUtil.ReadCell(xlsUtil.GetCell("AccountName"), 1);
		final String tab = xlsUtil.ReadCell(xlsUtil.GetCell("Tab"), 1);
		final String recordType = xlsUtil.ReadCell(xlsUtil.GetCell("OppRecordType"), 1);
		final String oppStage = xlsUtil.ReadCell(xlsUtil.GetCell("OppStage"), 1);
		final String name = xlsUtil.ReadCell(xlsUtil.GetCell("OppName"), 1);
		final String quoteName = xlsUtil.ReadCell(xlsUtil.GetCell("QuoteName"), 1);
		final String productName = xlsUtil.ReadCell(xlsUtil.GetCell("ProductName"), 1);
		final String quantity = xlsUtil.ReadCell(xlsUtil.GetCell("Quantity"), 1);

		
		/**
		 * Begin Test
		 */
		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();
		defaultTopFrame.verifyPageLoad().changeCurrentApp(salesCloudAppName);
		salesCloudTopFrame.selectTab(tab);

		OpportunitiesDetail oppDetail = salesCloudOpportunitiesHome.clickOnNewButton()
				.selectRecordType(recordType).setOpportunityName(name).setAccountName(accountName)
				.clickOnDefaultDateLink().setOpportunityStage(oppStage).clickOnSaveButton()
				.clickOnAddProduct().verifyPageLoad().checkProductFromList(productName)
				.clickOnSelectButton().verifyPageLoad().enterQuantityForProductSelected(quantity)
				.clickOnSave().verifyPageLoad().clickOnNewQuote().verifyPageLoad()
				.setQuoteName(quoteName).clickOnSave().clickOnOpportunity();

		
		/**
		 * Assertion
		 */
		assertTrue("New Quote added not shown", oppDetail.getPresenceOfQuote(quoteName));
	}

}
