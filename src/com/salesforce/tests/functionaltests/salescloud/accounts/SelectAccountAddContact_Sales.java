package com.salesforce.tests.functionaltests.salescloud.accounts;

import static org.junit.Assert.assertTrue;

import java.io.IOException;

import jxl.read.biff.BiffException;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

import com.salesforce.pages.salescloud.accounts.AccountDetail;
import com.salesforce.pages.salescloud.contacts.ContactsDetail;
import com.salesforce.pages.salescloud.contacts.ContactsEdit;
import com.salesforce.tests.functionaltests.CloudBaseTest;


@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class SelectAccountAddContact_Sales extends CloudBaseTest
{

	@Test
	public void testSelectAccountAddContact_Sales() throws BiffException, IOException, InterruptedException,
			RowsExceededException, WriteException
	{

		/**
		 * Initialize Test Data
		 */
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String tab = xlsUtil.ReadCell(xlsUtil.GetCell("Tab"), 1);
		final String view = xlsUtil.ReadCell(xlsUtil.GetCell("View"), 1);
		final String filter = xlsUtil.ReadCell(xlsUtil.GetCell("Filter"), 1);
		final String accountName = xlsUtil.ReadCell(xlsUtil.GetCell("AccountName"), 1);
		final String lastName = xlsUtil.ReadCell(xlsUtil.GetCell("ContactLastName"), 1);
		final String contactAccountName = xlsUtil.ReadCell(xlsUtil.GetCell("ContactAccountName"), 1);
		final String contactEmail = xlsUtil.ReadCell(xlsUtil.GetCell("ContactEmail"), 1);
		final String contactPhone = xlsUtil.ReadCell(xlsUtil.GetCell("ContactPhone"), 1);
		final String contactTitle = xlsUtil.ReadCell(xlsUtil.GetCell("ContactTitle"), 1);
		final String leadSource = xlsUtil.ReadCell(xlsUtil.GetCell("LeadSource"), 1);
		
		/**
		 * Begin Test
		 */
		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();
		defaultTopFrame.verifyPageLoad().changeCurrentApp(salesCloudAppName);
		salesCloudTopFrame.selectTab(tab);

		salesCloudAccountsHome.verifyPageLoad().setViewFilter(view).verifyPageLoad().sortAccountsTableByLetter(filter);
		
		AccountDetail accountDetail = salesCloudAccountsHome.selectFromAccountsTable(accountName);
		ContactsEdit contactEdit = accountDetail.clickOnNewContact();
		
		ContactsDetail contactDetail = contactEdit.verifyPageLoad().setLastName(lastName).setAccountName(contactAccountName)
				.setEmail(contactEmail).setPhone(contactPhone).setLeadSource(leadSource)
				.setTitle(contactTitle).clickOnSaveButton();
		
		contactDetail.verifyPageLoad();
		salesCloudTopFrame.selectTab(tab);
		salesCloudAccountsHome.verifyPageLoad().setViewFilter(view).verifyPageLoad().sortAccountsTableByLetter(filter);
		salesCloudAccountsHome.selectFromAccountsTable(accountName);
		
		
		/**
		 * Assertion
		 */
		assertTrue("Contact was not found in the Contacts related list", accountDetail.verifyPageLoad().getPresenceOfContact(lastName));
	}
	
}
