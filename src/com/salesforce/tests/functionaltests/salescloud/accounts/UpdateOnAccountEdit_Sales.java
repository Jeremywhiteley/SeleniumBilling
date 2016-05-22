package com.salesforce.tests.functionaltests.salescloud.accounts;

import static org.hamcrest.CoreMatchers.containsString;
import static org.junit.Assert.assertThat;

import java.io.IOException;

import jxl.read.biff.BiffException;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

import com.salesforce.pages.salescloud.accounts.AccountDetail;
import com.salesforce.pages.salescloud.accounts.AccountsEdit;
import com.salesforce.tests.functionaltests.CloudBaseTest;


@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class UpdateOnAccountEdit_Sales extends CloudBaseTest
{

	@Test
	public void testUpdateOnAccountEdit_Sales() throws BiffException, IOException, InterruptedException,
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
		final String billingStreet = xlsUtil.ReadCell(xlsUtil.GetCell("BillingStreet"), 1);
		final String billingCity = xlsUtil.ReadCell(xlsUtil.GetCell("BillingCity"), 1);
		final String billingState = xlsUtil.ReadCell(xlsUtil.GetCell("BillingState"), 1);
		final String billingCountry = xlsUtil.ReadCell(xlsUtil.GetCell("BillingCountry"), 1);
		final String billingZip = xlsUtil.ReadCell(xlsUtil.GetCell("BillingZipCode"), 1);
		final String industry = xlsUtil.ReadCell(xlsUtil.GetCell("Industry"), 1);
		
		
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
		
		AccountDetail detail = salesCloudAccountsHome.selectFromAccountsTable(accountName);
		AccountsEdit edit = detail.clickOnEdit();
		
		edit.verifyPageLoad().setBillingStreet(billingStreet).setBillingCity(billingCity).setBillingState(billingState)
			.setBillingCountry(billingCountry).setBillingZip(billingZip)
			.setIndustry(industry).clickOnSaveButton();
		
		/**
		 * Assertion
		 */
		assertThat("Industry value not as expected.",detail.verifyPageLoad().getAccountIndustry().toUpperCase(), containsString(industry.toUpperCase()));
	}
	
}
