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
import com.salesforce.tests.functionaltests.CloudBaseTest;


@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class UpdateOnLeadDetail_Sales extends CloudBaseTest
{

	@Test
	public void testUpdateOnLeadDetail_Sales() throws BiffException, IOException, InterruptedException,
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
		final String leadSource = xlsUtil.ReadCell(xlsUtil.GetCell("LeadSource"), 1);
		final String leadStatus = xlsUtil.ReadCell(xlsUtil.GetCell("LeadStatus"), 1);
		final String phone = xlsUtil.ReadCell(xlsUtil.GetCell("Phone"), 1);
		
		
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
		detail.verifyPageLoad().setLeadSource(leadSource).setLeadStatus(leadStatus).setPhone(phone).clickOnSaveButton();
		
			
		/**
		 * Assertion
		 */
		assertThat("Phone value incorrect in Leads Detail", detail.verifyPageLoad().getPhone().trim(), containsString(phone.trim()));
		assertThat("Lead Source value incorrect in Leads Detail", detail.verifyPageLoad().getLeadSource().trim(), containsString(leadSource.trim()));
		assertThat("Lead Status value incorrect in Leads Detail", detail.verifyPageLoad().getLeadStatus().trim(), containsString(leadStatus.trim()));

	}

}
