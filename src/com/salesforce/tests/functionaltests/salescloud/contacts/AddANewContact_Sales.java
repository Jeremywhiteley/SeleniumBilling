package com.salesforce.tests.functionaltests.salescloud.contacts;

import static org.hamcrest.CoreMatchers.containsString;
import static org.junit.Assert.assertThat;

import java.io.IOException;

import jxl.read.biff.BiffException;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.experimental.categories.Category;
import org.junit.runners.MethodSorters;

import com.salesforce.custom.junit.Categories.Smoke;
import com.salesforce.pages.salescloud.contacts.ContactsDetail;
import com.salesforce.tests.functionaltests.CloudBaseTest;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class AddANewContact_Sales extends CloudBaseTest
{

	@Test
	@Category(Smoke.class)
	public void testAddANewContact_Sales() throws BiffException, IOException, InterruptedException,
			RowsExceededException, WriteException
	{

		/**
		 * Initialize Data
		 */
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
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
		defaultTopFrame.verifyPageLoad().changeCurrentApp(salesCloudAppName);
		salesCloudTopFrame.selectTab("Contacts");

		ContactsDetail contactDetail = salesCloudContactsHome.verifyPageLoad().clickOnNewContact()
				.setLastName(contactLastName).setAccountName(accountName).clickOnSaveButton()
				.verifyPageLoad();

		/**
		 * Assertion
		 */
		assertThat("Account Name in Contact is incorrect.", contactDetail.getAccountName(),
				containsString(nameOnAccount));
		assertThat("Contact Name saved is incorrect", contactDetail.getContactName(),
				containsString(contactLastName));

	}

}