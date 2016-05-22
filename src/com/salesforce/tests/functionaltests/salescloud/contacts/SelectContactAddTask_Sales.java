package com.salesforce.tests.functionaltests.salescloud.contacts;

import static org.junit.Assert.assertTrue;

import java.io.IOException;

import jxl.read.biff.BiffException;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

import com.salesforce.pages.salescloud.SearchResultsDetail;
import com.salesforce.pages.salescloud.contacts.ContactsDetail;
import com.salesforce.pages.salescloud.tasks.TaskEdit;
import com.salesforce.tests.functionaltests.CloudBaseTest;


@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class SelectContactAddTask_Sales extends CloudBaseTest
{

	@Test
	public void testSelectContactAddTask_Sales() throws BiffException, IOException,
			InterruptedException, RowsExceededException, WriteException
	{

		/**
		 * Initialize Test Data
		 */
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String searchText = xlsUtil.ReadCell(xlsUtil.GetCell("SearchText"), 1);
		final String contactName = xlsUtil.ReadCell(xlsUtil.GetCell("ContactName"), 1);
		final String taskSubject = xlsUtil.ReadCell(xlsUtil.GetCell("TaskSubject"), 1);
		final String taskStatus = xlsUtil.ReadCell(xlsUtil.GetCell("TaskStatus"), 1);
	
		
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

		TaskEdit taskEdit = detail.verifyPageLoad().clickOnNewTaskButton();

		taskEdit.setSubject(taskSubject).setStatus(taskStatus).clickOnSave();

		
		/**
		 * Assertion
		 */
		assertTrue("Task was found in the Activities related list", detail.verifyPageLoad()
				.getPresenceOfActivity(taskSubject));
	}

}
