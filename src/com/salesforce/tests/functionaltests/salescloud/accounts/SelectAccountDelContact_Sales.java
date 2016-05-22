package com.salesforce.tests.functionaltests.salescloud.accounts;

import static org.junit.Assert.assertFalse;

import java.io.IOException;

import jxl.read.biff.BiffException;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

import com.salesforce.pages.salescloud.accounts.AccountDetail;
import com.salesforce.tests.functionaltests.CloudBaseTest;


@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class SelectAccountDelContact_Sales extends CloudBaseTest
{

	@Test
	public void testSelectAccountDelContact_Sales() throws BiffException, IOException, InterruptedException,
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
		final String contactName = xlsUtil.ReadCell(xlsUtil.GetCell("ContactName"), 1);

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
		
		AccountDetail accountDetail = salesCloudAccountsHome.selectFromAccountsTable(accountName);
		accountDetail.deleteContact(contactName);
		
		
		/**
		 * Assertion
		 */
		assertFalse("Contact was found in the Opportunities related list", accountDetail.verifyPageLoad().getPresenceOfContact(contactName));
	}

}
