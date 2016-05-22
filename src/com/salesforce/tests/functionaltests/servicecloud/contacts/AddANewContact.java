package com.salesforce.tests.functionaltests.servicecloud.contacts;

import static org.hamcrest.CoreMatchers.containsString;
import static org.junit.Assert.assertThat;

import java.io.IOException;

import jxl.read.biff.BiffException;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

import com.salesforce.pages.servicecloud.contacts.ServiceCloudContactsDetail;
import com.salesforce.tests.functionaltests.CloudBaseTest;


@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class AddANewContact extends CloudBaseTest 
{
	@Test
	public void testAddANewContact() throws BiffException, IOException,
			InterruptedException, RowsExceededException, WriteException 
	{

		/**
		 * Initialize Test Data
		 */
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String tab = xlsUtil.ReadCell(xlsUtil.GetCell("Tab"), 1);
		final String accountName = xlsUtil.ReadCell(xlsUtil.GetCell("AccountName"), 1);
		final String contactLastName = xlsUtil.ReadCell(xlsUtil.GetCell("ContactLastName"), 1);
		final String nameOnAccount = xlsUtil.ReadCell(xlsUtil.GetCell("AccountDisplayName"), 1);
		
		
		/**
		 * Begin Test
		 */
		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();
		serviceCloudTopFrame.verifyPageLoad().changeCurrentApp(serviceCloudAppName);
		serviceCloudTopFrame.selectMainNavElement(tab);
		
		ServiceCloudContactsDetail contactDetail = 
				serviceCloudContactsHome.verifyPageLoad()
				.clickOnNewContact()
				.setLastName(contactLastName)
				.setAccountName(accountName).clickOnSave().verifyPageLoad();
				
		
		/**
		 * Assertion
		 */
		assertThat(contactDetail.getAccountName(), containsString(nameOnAccount));
		assertThat(contactDetail.getContactName(), containsString(contactLastName));

	}
}