package com.salesforce.tests.functionaltests.servicecloud.contacts;

import static org.junit.Assert.assertEquals;

import java.io.IOException;

import jxl.read.biff.BiffException;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

import com.salesforce.pages.servicecloud.ServiceCloudSearchResults;
import com.salesforce.pages.servicecloud.contacts.ServiceCloudContactsDetail;
import com.salesforce.tests.functionaltests.CloudBaseTest;


@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class UpdateTitleOnContactDetail extends CloudBaseTest 
{

	@Test
	public void testUpdateTitleOnContactDetail() throws BiffException, IOException,
			InterruptedException, RowsExceededException, WriteException 
	{

		/**
		 * Initialize Test Data
		 */
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String searchText = xlsUtil.ReadCell(xlsUtil.GetCell("SearchText"), 1);
		final String contact = xlsUtil.ReadCell(xlsUtil.GetCell("Contact"), 1);
		final String title = xlsUtil.ReadCell(xlsUtil.GetCell("Title"), 1);

		
		/**
		 * Begin Test
		 */
		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();
		serviceCloudTopFrame.verifyPageLoad().changeCurrentApp(serviceCloudAppName);

		ServiceCloudSearchResults results = serviceCloudTopFrame.enterTextAndSearch(searchText);
		
		ServiceCloudContactsDetail detail = results.verifyPageLoad().selectContact(contact);
		detail.setContactTitle(title).clickOnSave();
		
		
		/**
		 * Assertion
		 */
		assertEquals(title.toUpperCase(), detail.verifyPageLoad().getContactTitle().toUpperCase());

	}
}