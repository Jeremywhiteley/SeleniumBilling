package com.salesforce.tests.functionaltests.salescloud.contacts;

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
import com.salesforce.pages.salescloud.contacts.ContactsChangeOwner;
import com.salesforce.pages.salescloud.contacts.ContactsDetail;
import com.salesforce.tests.functionaltests.CloudBaseTest;


@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class SelectContactChangeOwner_Sales extends CloudBaseTest 
{

	@Test
	public void testSelectContactChangeOwner_Sales() throws BiffException, IOException,
			InterruptedException, RowsExceededException, WriteException 
	{

		/**
		 * Initialize Test Data
		 */
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String searchText = xlsUtil.ReadCell(xlsUtil.GetCell("SearchText"), 1);
		final String contactName = xlsUtil.ReadCell(xlsUtil.GetCell("ContactName"), 1);
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
		ContactsDetail detail = searchResults.verifyPageLoad().searchContactResultsForRecord(
				contactName);
		
		ContactsChangeOwner changeOwner = detail.clickOnChangeOwner();
		detail = changeOwner.setOwnerType(ownerType).setOwner(ownerLookup).clickOnSave();
		
		
		/**
		 * Assertion
		 */
		assertThat("New owner changed not shown accurately",detail.getContactOwner().trim().toUpperCase(), containsString(ownerName.trim().toUpperCase()));

	}

}