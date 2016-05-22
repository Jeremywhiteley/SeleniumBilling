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

import com.salesforce.pages.salescloud.SearchResultsDetail;
import com.salesforce.pages.salescloud.accounts.AccountDetail;
import com.salesforce.tests.functionaltests.CloudBaseTest;


@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class VerifyAccountOwner_Sales extends CloudBaseTest 
{
	
	@Test
	public void testSearchAndSelectAccount_Sales() throws BiffException, IOException,
			InterruptedException, RowsExceededException, WriteException 
	{

		/**
		 * Initialize Test Data
		 */
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String searchText = xlsUtil.ReadCell(xlsUtil.GetCell("SearchText"), 1);
		final String accountName = xlsUtil.ReadCell(xlsUtil.GetCell("AccountName"), 1);
		final String accountOwner = xlsUtil.ReadCell(xlsUtil.GetCell("AccountOwner"), 1);

		
		/**
		 * Begin Test
		 */
		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();
		defaultTopFrame.verifyPageLoad().changeCurrentApp(salesCloudAppName);
		
		SearchResultsDetail searchResults = salesCloudTopFrame.enterTextAndSearch(searchText);
		AccountDetail detail = searchResults.verifyPageLoad().searchAccountResultsForRecord(accountName);
		
		/**
		 * Assertion
		 */
		assertThat("Account Owner Incorrect",detail.verifyPageLoad().getAccountOwner().toUpperCase(), containsString(accountOwner.toUpperCase()));


	}

}