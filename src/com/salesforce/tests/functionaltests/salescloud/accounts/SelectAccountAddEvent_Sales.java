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
import com.salesforce.pages.salescloud.events.EventsEdit;
import com.salesforce.tests.functionaltests.CloudBaseTest;


@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class SelectAccountAddEvent_Sales extends CloudBaseTest
{
	
	@Test
	public void testSelectAccountAddEvent_Sales() throws BiffException, IOException, InterruptedException,
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
		final String eventSubject = xlsUtil.ReadCell(xlsUtil.GetCell("EventSubject"), 1);
		final String assignedUser = xlsUtil.ReadCell(xlsUtil.GetCell("AssignedUser"), 1);
		
		
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
		
		AccountDetail detail = salesCloudAccountsHome.selectFromAccountsTable(accountName);
		EventsEdit eventEdit = detail.verifyPageLoad().clickOnNewEvent();
		eventEdit.verifyPageLoad().setAssignedTo(assignedUser).setSubject(eventSubject).clickOnSaveButton();
			
		
		/**
		 * Assertion
		 */
		assertTrue("Event was not found in the Activities related list", detail.verifyPageLoad().getPresenceOfActivity(eventSubject));
	}
	
}
