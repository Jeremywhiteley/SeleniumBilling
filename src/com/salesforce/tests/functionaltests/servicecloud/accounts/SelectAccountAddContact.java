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
import com.salesforce.pages.servicecloud.contacts.ServiceCloudContactsDetail;
import com.salesforce.pages.servicecloud.contacts.ServiceCloudContactsEdit;
import com.salesforce.pages.servicecloud.contacts.ServiceCloudContactsSelectRecordType;
import com.salesforce.tests.functionaltests.CloudBaseTest;


@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class SelectAccountAddContact extends CloudBaseTest 
{
	@Test
	public void testSelectAccountAddContact() throws BiffException, IOException,
			InterruptedException, RowsExceededException, WriteException, ParseException 
	{

		/**
		 * Initialize Test Data
		 */
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String searchText = xlsUtil.ReadCell(xlsUtil.GetCell("SearchText"), 1);
		final String account = xlsUtil.ReadCell(xlsUtil.GetCell("Account"), 1);
		final String recordType = xlsUtil.ReadCell(xlsUtil.GetCell("RecordType"), 1);
		final String lastName = xlsUtil.ReadCell(xlsUtil.GetCell("LastName"), 1);
		
		
		
		/**
		 * Begin Test
		 */
		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();
		serviceCloudTopFrame.verifyPageLoad().changeCurrentApp(serviceCloudAppName);
		
		ServiceCloudSearchResults results =
				serviceCloudTopFrame.enterTextAndSearch(searchText);
		
		ServiceCloudAccountsDetail detail =
				results.verifyPageLoad().selectCustomers(account);
				
		ServiceCloudContactsSelectRecordType type =
				detail.verifyPageLoad().clickOnNewContactButton().verifyPageLoad();
				
		ServiceCloudContactsEdit edit = 
				type.selectRecordType(recordType);
			
		ServiceCloudContactsDetail contactDetail = 
				edit.setLastName(lastName).clickOnSave();
		

		/**
		 * Assertion
		 */
		assertEquals(account.toUpperCase(), contactDetail.getHeaderText().toUpperCase().trim());
	}
	
}