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

import com.salesforce.pages.salescloud.leads.LeadsDetail;
import com.salesforce.pages.salescloud.leads.LeadsEdit;
import com.salesforce.tests.functionaltests.CloudBaseTest;


@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class UpdateOnLeadEdit_Sales extends CloudBaseTest
{

	@Test
	public void testUpdateOnLeadEdit_Sales() throws BiffException, IOException, InterruptedException,
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
		final String leadName = xlsUtil.ReadCell(xlsUtil.GetCell("LeadName"), 1);
		final String leadStatus = xlsUtil.ReadCell(xlsUtil.GetCell("LeadStatus"), 1);
		
		/**
		 * Begin Test
		 */
		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();
		defaultTopFrame.verifyPageLoad().changeCurrentApp(salesCloudAppName);
		salesCloudTopFrame.selectTab(tab);

		salesCloudLeadsHome.verifyPageLoad().setViewFilter(view).verifyPageLoad().sortLeadsTableByLetter(filter);
		
		LeadsDetail detail = salesCloudLeadsHome.selectFromLeadsTable(leadName);
		LeadsEdit edit = detail.clickOnEditButton();
		
		edit.verifyPageLoad().setLeadStatus(leadStatus).clickOnSaveButton();
		
		/**
		 * Assertion
		 */
		assertThat("Lead Status value incorrect in Leads Detail", detail.verifyPageLoad().getLeadStatus().trim(), containsString(leadStatus.trim()));
	}
	
}
