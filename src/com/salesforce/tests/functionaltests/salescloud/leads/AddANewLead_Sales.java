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
public class AddANewLead_Sales extends CloudBaseTest
{

	@Test
	public void testAddANewLead_Sales() throws BiffException, IOException,
			InterruptedException, RowsExceededException, WriteException
	{

		/**
		 * Initialize Test Data
		 */
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String tab = xlsUtil.ReadCell(xlsUtil.GetCell("Tab"), 1);
		final String recordType = xlsUtil.ReadCell(xlsUtil.GetCell("RecordType"), 1);
		final String leadStatus = xlsUtil.ReadCell(xlsUtil.GetCell("LeadStatus"), 1);
		final String lastName = xlsUtil.ReadCell(xlsUtil.GetCell("LastName"), 1);
		final String country = xlsUtil.ReadCell(xlsUtil.GetCell("Country"), 1);
		final String leadSource = xlsUtil.ReadCell(xlsUtil.GetCell("LeadSource"), 1);

		
		/**
		 * Begin Test
		 */
		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();
		defaultTopFrame.verifyPageLoad().changeCurrentApp(salesCloudAppName);
		salesCloudTopFrame.selectFromTabBar(tab);
		
		LeadsDetail detail = salesCloudLeadsHome.createNewRecord().selectRecordType(recordType)
				.verifyPageLoad().setLastName(lastName).setLeadStatus(leadStatus).setCountry(country)
				.setLeadSource(leadSource).clickOnSaveButton();
		
		
		/**
		 * Assertion
		 */
		assertThat(detail.getName().trim().toUpperCase(), containsString(lastName.trim().toUpperCase()));
	}

}
