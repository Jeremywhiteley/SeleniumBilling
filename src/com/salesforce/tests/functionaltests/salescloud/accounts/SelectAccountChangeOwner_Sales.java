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
import com.salesforce.pages.salescloud.accounts.AccountsChangeOwner;
import com.salesforce.tests.functionaltests.CloudBaseTest;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class SelectAccountChangeOwner_Sales extends CloudBaseTest
{

	@Test
	public void testSelectAccountChangeOwner_Sales() throws BiffException, IOException,
			InterruptedException, RowsExceededException, WriteException
	{

		/**
		 * Initialize Test Data
		 */
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String searchText = xlsUtil.ReadCell(xlsUtil.GetCell("SearchText"), 1);
		final String accountName = xlsUtil.ReadCell(xlsUtil.GetCell("AccountName"), 1);
		final String ownerType = xlsUtil.ReadCell(xlsUtil.GetCell("OwnerType"), 1);
		final String ownerLookup = xlsUtil.ReadCell(xlsUtil.GetCell("OwnerLookup"), 1);
		final String ownerName = xlsUtil.ReadCell(xlsUtil.GetCell("OwnerName"), 1);

		/**
		 * Begin Test
		 */
		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();
		defaultTopFrame.verifyPageLoad().changeCurrentApp(salesCloudAppName);

		SearchResultsDetail searchResults = salesCloudTopFrame.enterTextAndSearch(searchText);
		AccountDetail detail = searchResults.verifyPageLoad().searchAccountResultsForRecord(
				accountName);

		AccountsChangeOwner changeOwner = detail.clickOnChangeOwner();
		changeOwner.setOwnerType(ownerType).setOwner(ownerLookup).clickOnSave();

		/**
		 * Assertion
		 */
		assertThat("New owner changed not shown accurately", detail.getAccountOwner().trim()
				.toUpperCase(), containsString(ownerName.trim().toUpperCase()));

	}

}