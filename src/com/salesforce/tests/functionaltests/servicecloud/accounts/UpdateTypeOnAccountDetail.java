package com.salesforce.tests.functionaltests.servicecloud.accounts;

import static org.junit.Assert.assertEquals;

import java.io.IOException;

import jxl.read.biff.BiffException;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

import com.salesforce.pages.servicecloud.accounts.ServiceCloudAccountsDetail;
import com.salesforce.tests.functionaltests.CloudBaseTest;


@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class UpdateTypeOnAccountDetail extends CloudBaseTest 
{
	@Test
	public void testUpdateTypeOnAccountDetail() throws BiffException, IOException,
			InterruptedException, RowsExceededException, WriteException 
	{

		/**
		 * Initialize Test Data
		 */
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String tab = xlsUtil.ReadCell(xlsUtil.GetCell("Tab"), 1);
		final String filter = xlsUtil.ReadCell(xlsUtil.GetCell("Filter"), 1);
		final String accountName = xlsUtil.ReadCell(xlsUtil.GetCell("AccountName"), 1);
		final String type = xlsUtil.ReadCell(xlsUtil.GetCell("Type"), 1);

		
		/**
		 * Begin Test
		 */
		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();
		serviceCloudTopFrame.verifyPageLoad().changeCurrentApp(serviceCloudAppName);
		serviceCloudTopFrame.selectMainNavElement(tab);

		ServiceCloudAccountsDetail detail =
				serviceCloudAccountsHome.filterAccountTableByLetter(filter).selectFromAccountTable(accountName);
		
		detail.verifyPageLoad().setAccountType(type).clickOnSaveButton();
		
		
		/**
		 * Assertion
		 */
		assertEquals(type.toUpperCase(), detail.verifyPageLoad().getAccountType().toUpperCase());

	}

}