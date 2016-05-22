package com.salesforce.tests.functionaltests.salescloud.contacts;

import static org.junit.Assert.assertTrue;

import java.io.IOException;

import jxl.read.biff.BiffException;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

import com.salesforce.pages.salescloud.contacts.ContactsDetail;
import com.salesforce.pages.servicecloud.ServiceCloudSearchResults;
import com.salesforce.tests.functionaltests.CloudBaseTest;
import com.salesforce.utils.datastore.FileIO;


@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class VerifyContactDetailField_Sales extends CloudBaseTest
{
	@Test
	public void testFieldExistInContactDetail_Sales() throws BiffException, IOException,
			InterruptedException, RowsExceededException, WriteException
	{

		/**
		 * Initialize Test Data
		 */
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String contactName = xlsUtil.ReadCell(xlsUtil.GetCell("ContactName"), 1);
		final String labelNames = xlsUtil.ReadCell(xlsUtil.GetCell("LabelNames"), 1);
		final String searchText = xlsUtil.ReadCell(xlsUtil.GetCell("SearchText"), 1);

		
		/**
		 * Begin Test
		 */
		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();

		defaultTopFrame.verifyPageLoad().changeCurrentApp(salesCloudAppName);
		salesCloudTopFrame.selectTab("Contacts");

		ServiceCloudSearchResults searchResults = serviceCloudTopFrame.enterTextAndSearch(searchText);

		FileIO.takeScreenShot(driver, testName.getMethodName());
		searchResults.selectContact(contactName);

		ContactsDetail detail = ContactsDetail.Instance;

		
		/**
		 * Assertion
		 */
		assertTrue("Assert label fields <td> were found successfully on the page: " + labelNames,
				detail.verifyTDValuesExist(labelNames));
	}

}
