package com.salesforce.tests.functionaltests.servicecloud.accounts;

import static org.junit.Assert.assertEquals;

import java.io.IOException;
import java.text.ParseException;

import jxl.read.biff.BiffException;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

import com.salesforce.pages.servicecloud.ServiceCloudSearchResults;
import com.salesforce.pages.servicecloud.accounts.ServiceCloudAccountsDetail;
import com.salesforce.pages.servicecloud.opportunities.ServiceCloudOpportunitiesDetail;
import com.salesforce.pages.servicecloud.opportunities.ServiceCloudOpportunitiesEdit;
import com.salesforce.pages.servicecloud.opportunities.ServiceCloudOpportunitiesSelectRecordType;
import com.salesforce.tests.functionaltests.CloudBaseTest;


@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class SelectAccountAddOpportunity extends CloudBaseTest 
{
	@Test
	public void testSelectAccountAddOpportunity() throws BiffException, IOException,
			InterruptedException, RowsExceededException, WriteException, ParseException 
	{

		/**
		 * Initialize Test Data
		 */
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String tab = xlsUtil.ReadCell(xlsUtil.GetCell("Tab"), 1);
		final String searchText = xlsUtil.ReadCell(xlsUtil.GetCell("SearchText"), 1);
		final String account = xlsUtil.ReadCell(xlsUtil.GetCell("Account"), 1);
		final String recordType = xlsUtil.ReadCell(xlsUtil.GetCell("RecordType"), 1);
		final String opportunityName = xlsUtil.ReadCell(xlsUtil.GetCell("OpportunityName"), 1);
		final String amount = xlsUtil.ReadCell(xlsUtil.GetCell("Amount"), 1);
		final String closeDate = xlsUtil.ReadCell(xlsUtil.GetCell("CloseDate"), 1);
		final String stage = xlsUtil.ReadCell(xlsUtil.GetCell("Stage"), 1);
		
		
		/**
		 * Begin Test
		 */
		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();
		serviceCloudTopFrame.verifyPageLoad().changeCurrentApp(serviceCloudAppName);
		serviceCloudTopFrame.selectMainNavElement(tab);
		
		ServiceCloudSearchResults results =
				serviceCloudTopFrame.enterTextAndSearch(searchText);
		
		ServiceCloudAccountsDetail detail =
				results.verifyPageLoad().selectCustomers(account);
				
		ServiceCloudOpportunitiesSelectRecordType type =
				detail.clickOnNewOpportunity().verifyRecordTypePageLoad();
		
		ServiceCloudOpportunitiesEdit edit =
				type.selectRecordType(recordType);
		
		ServiceCloudOpportunitiesDetail opportunityDetail =
				edit.verifyPageLoad().enterOpportunityName(opportunityName).enterAmount(amount)
				.enterCloseDate(closeDate).setStage(stage).clickOnSaveButton();
	
		
		/**
		 * Assertion
		 */
		assertEquals(opportunityName.toUpperCase(), opportunityDetail.verifyPageLoad().getHeaderText().toUpperCase().trim());
	}
}