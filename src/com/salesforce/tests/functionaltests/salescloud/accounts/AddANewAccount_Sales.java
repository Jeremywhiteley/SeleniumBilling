package com.salesforce.tests.functionaltests.salescloud.accounts;

import static org.hamcrest.CoreMatchers.containsString;
import static org.junit.Assert.assertThat;

import java.io.IOException;

import jxl.read.biff.BiffException;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.experimental.categories.Category;
import org.junit.runners.MethodSorters;

import com.salesforce.custom.junit.Categories.Regression;
import com.salesforce.pages.salescloud.accounts.AccountDetail;
import com.salesforce.tests.functionaltests.CloudBaseTest;
@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class AddANewAccount_Sales extends CloudBaseTest
{
	@Category(Regression.class)
	@Test
	public void testAddANewAccount_Sales() throws BiffException, IOException, InterruptedException,
			RowsExceededException, WriteException
	{

		/**
		 * Initialize Test Data
		 */
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String accountName = xlsUtil.ReadCell(xlsUtil.GetCell("AccountName"), 1);
		final String tab = xlsUtil.ReadCell(xlsUtil.GetCell("Tab"), 1);
		final String recordType = xlsUtil.ReadCell(xlsUtil.GetCell("RecordType"), 1);

		/**
		 * Begin Test
		 */
		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();
		defaultTopFrame.verifyPageLoad().changeCurrentApp(salesCloudAppName);
		salesCloudTopFrame.selectTab(tab);

		AccountDetail detail = salesCloudAccountsHome.clickOnNewButton()
				.selectRecordType(recordType).verifyPageLoad().setAccountName(accountName)
				.clickOnSaveButton();	
		/**
		 * Assertion
		 */
		assertThat("Account name shown incorrectly.",detail.getHeaderText().toUpperCase(), containsString(accountName.toUpperCase()));
	}

}
