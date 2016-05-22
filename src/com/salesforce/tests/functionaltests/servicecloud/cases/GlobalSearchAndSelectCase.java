package com.salesforce.tests.functionaltests.servicecloud.cases;

import static org.hamcrest.CoreMatchers.containsString;
import static org.junit.Assert.assertThat;

import java.io.IOException;

import jxl.read.biff.BiffException;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

import com.salesforce.pages.servicecloud.ServiceCloudSearchResults;
import com.salesforce.pages.servicecloud.cases.ServiceCloudCasesDetail;
import com.salesforce.tests.functionaltests.CloudBaseTest;


@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class GlobalSearchAndSelectCase extends CloudBaseTest 
{
	@Test
	public void testGlobalSearchAndSelectCase() throws BiffException, IOException,
			InterruptedException, RowsExceededException, WriteException 
	{

		/**
		 * Initialize Test Data
		 */
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String searchText = xlsUtil.ReadCell(xlsUtil.GetCell("SearchText"), 1);
		final String caseID = xlsUtil.ReadCell(xlsUtil.GetCell("CaseID"), 1);
		final String caseName = xlsUtil.ReadCell(xlsUtil.GetCell("CaseName"), 1);

		
		/**
		 * Begin Test
		 */
		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();
		serviceCloudTopFrame.verifyPageLoad().changeCurrentApp(serviceCloudAppName);

		ServiceCloudSearchResults results = serviceCloudTopFrame.enterTextAndSearch(searchText);
		
		ServiceCloudCasesDetail detail = results.verifyPageLoad().selectCase(caseID);
		
		
		/**
		 * Assertion
		 */
		assertThat(detail.getCaseHeader(), containsString(caseName));

	}

}