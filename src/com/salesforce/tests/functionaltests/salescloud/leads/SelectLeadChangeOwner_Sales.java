package com.salesforce.tests.functionaltests.salescloud.leads;

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
import com.salesforce.pages.salescloud.leads.LeadsChangeOwner;
import com.salesforce.pages.salescloud.leads.LeadsDetail;
import com.salesforce.tests.functionaltests.CloudBaseTest;


@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class SelectLeadChangeOwner_Sales extends CloudBaseTest 
{

	@Test
	public void testSelectLeadChangeOwner_Sales() throws BiffException, IOException,
			InterruptedException, RowsExceededException, WriteException 
	{

		/**
		 * Initialize Test Data
		 */
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String searchText = xlsUtil.ReadCell(xlsUtil.GetCell("SearchText"), 1);
		final String accountName = xlsUtil.ReadCell(xlsUtil.GetCell("LeadName"), 1);
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
		LeadsDetail detail = searchResults.verifyPageLoad().searchLeadResultsForRecord(accountName);
		
		LeadsChangeOwner changeOwner = detail.clickOnChangeOwner();
		changeOwner.setOwnerType(ownerType).setOwner(ownerLookup).clickOnSave();
		
		
		/**
		 * Assertion
		 */
		assertThat(detail.getLeadOwner().trim().toUpperCase(), containsString(ownerName.trim().toUpperCase()));


	}

}