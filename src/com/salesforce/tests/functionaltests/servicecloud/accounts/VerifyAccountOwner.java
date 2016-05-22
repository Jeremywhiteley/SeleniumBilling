package com.salesforce.tests.functionaltests.servicecloud.accounts;

import static org.junit.Assert.assertEquals;

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
public class VerifyAccountOwner extends CloudBaseTest 
{
	@Test
	public void testVerifyAccountOwner() throws BiffException, IOException,
			InterruptedException, RowsExceededException, WriteException 
	{

		/**
		 * Initialize Test Data
		 */
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String tab = xlsUtil.ReadCell(xlsUtil.GetCell("Tab"), 1);
		final String accountName = xlsUtil.ReadCell(xlsUtil.GetCell("AccountName"), 1);
		final String accountOwnerName = xlsUtil.ReadCell(xlsUtil.GetCell("Owner"), 1);
		
		
		/**
		 * Begin Test
		 */
		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();
		serviceCloudTopFrame.verifyPageLoad().changeCurrentApp(serviceCloudAppName);
		serviceCloudTopFrame.selectMainNavElement(tab);

		ServiceCloudSearchResults results = serviceCloudTopFrame.enterTextAndSearch(accountName);

		ServiceCloudAccountsDetail detail = results.verifyPageLoad().selectCustomers(accountName);
		
		
		/**
		 * Assertion
		 */
		assertEquals("Account owner doesnt match expect name", accountOwnerName, detail.verifyPageLoad().getAccountOwner());
	}
}