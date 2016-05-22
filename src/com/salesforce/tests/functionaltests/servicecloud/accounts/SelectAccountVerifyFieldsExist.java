package com.salesforce.tests.functionaltests.servicecloud.accounts;

import static org.hamcrest.CoreMatchers.containsString;
import static org.junit.Assert.assertThat;
import static org.junit.Assert.assertTrue;

import java.io.IOException;

import jxl.read.biff.BiffException;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

import com.salesforce.pages.servicecloud.ServiceCloudSearchResults;
import com.salesforce.pages.servicecloud.accounts.ServiceCloudAccountsDetail;
import com.salesforce.tests.functionaltests.CloudBaseTest;


@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class SelectAccountVerifyFieldsExist extends CloudBaseTest 
{
	@Test
	public void testSelectAccountVerifyFieldsExist() throws BiffException, IOException,
			InterruptedException, RowsExceededException, WriteException 
	{

		/**
		 * Initialize Test Data
		 */
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String searchText = xlsUtil.ReadCell(xlsUtil.GetCell("SearchText"), 1);
		final String account = xlsUtil.ReadCell(xlsUtil.GetCell("Account"), 1);
		final String fields = xlsUtil.ReadCell(xlsUtil.GetCell("Fields"), 1);
		
		
		/**
		 * Begin Test
		 */
		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();
		serviceCloudTopFrame.verifyPageLoad().changeCurrentApp(serviceCloudAppName);

		ServiceCloudSearchResults results =
				serviceCloudTopFrame.enterTextAndSearch(searchText);
		
		ServiceCloudAccountsDetail detail =
				results.verifyPageLoad().selectCustomers(account);
		
		
		/**
		 * Assertion
		 */
		assertThat(detail.getAccountHeader().toUpperCase(), containsString(account.toUpperCase()));
		assertTrue("Assert that the passed in label fields exist: " + fields, detail.verifyPageLoad().verifyFieldLabelsExist(fields));

	}
	
}