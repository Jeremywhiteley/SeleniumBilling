package com.salesforce.tests.functionaltests.servicecloud.cases;

import static org.junit.Assert.assertEquals;

import java.io.IOException;

import jxl.read.biff.BiffException;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

import com.salesforce.pages.servicecloud.ServiceCloudSearchResults;
import com.salesforce.pages.servicecloud.cases.ServiceCloudCasesDetail;
import com.salesforce.pages.servicecloud.cases.ServiceCloudCasesEdit;
import com.salesforce.tests.functionaltests.CloudBaseTest;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class UpdateCasePriorityOnEdit extends CloudBaseTest
{
	@Test
	public void testUpdateCasePriorityOnEdit() throws BiffException, IOException,
			InterruptedException, RowsExceededException, WriteException
	{

		/**
		 * Initialize Test Data
		 */
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String searchText = xlsUtil.ReadCell(xlsUtil.GetCell("SearchText"), 1);
		final String caseID = xlsUtil.ReadCell(xlsUtil.GetCell("CaseID"), 1);
		final String priority = xlsUtil.ReadCell(xlsUtil.GetCell("Priority"), 1);
		final String leftNavigationTab = xlsUtil.ReadCell(xlsUtil.GetCell("LeftNavigationTab"), 1);

		/**
		 * Begin Test
		 */
		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();
		serviceCloudTopFrame.verifyPageLoad().changeCurrentApp(serviceCloudAppName);
		ServiceCloudSearchResults results = serviceCloudTopFrame.enterTextAndSearch(searchText);

		ServiceCloudCasesEdit editCase = results.verifyPageLoad().editCase(caseID);

		ServiceCloudCasesDetail caseDetail = editCase.verifyPageLoad().updateCasePriority(priority)
				.clickOnSaveButton();

		/**
		 * Assertion
		 */
		assertEquals(priority.toUpperCase(), caseDetail.selectFromLeftNav(leftNavigationTab)
				.verifyPageLoad().getCasePriority().toUpperCase());

	}
}