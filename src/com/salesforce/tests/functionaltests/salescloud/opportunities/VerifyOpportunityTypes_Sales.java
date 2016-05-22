package com.salesforce.tests.functionaltests.salescloud.opportunities;

import static org.junit.Assert.assertTrue;

import java.io.IOException;

import jxl.read.biff.BiffException;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

import com.salesforce.pages.salescloud.opportunities.OpportunitiesSelectRecordType;
import com.salesforce.tests.functionaltests.CloudBaseTest;


@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class VerifyOpportunityTypes_Sales extends CloudBaseTest
{


	@Test
	public void testVerifyOpportunityTypes_Sales() throws BiffException, IOException,
			InterruptedException, RowsExceededException, WriteException
	{

		/**
		 * Initialize Test Data
		 */
		
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String tab = xlsUtil.ReadCell(xlsUtil.GetCell("Tab"), 1);
		final String recordTypeValues = xlsUtil.ReadCell(xlsUtil.GetCell("OppRecordType"), 1);
		
		/**
		 * Begin Test
		 */
		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();
		defaultTopFrame.verifyPageLoad().changeCurrentApp(salesCloudAppName);
		salesCloudTopFrame.selectTab(tab);

		OpportunitiesSelectRecordType recordTypePage = salesCloudOpportunitiesHome.clickOnNewButton();
		
		
		/**
		 * Assertion
		 */
		assertTrue("Record Type options don't contain the default values.",
				recordTypePage.verifyPageLoad().verifyRecordTypeValues(recordTypeValues));

	}
}
