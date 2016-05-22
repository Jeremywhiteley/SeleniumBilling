package com.salesforce.tests.functionaltests.salescloud.leads;

import static org.junit.Assert.assertTrue;

import java.io.IOException;

import jxl.read.biff.BiffException;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

import com.salesforce.pages.salescloud.accounts.AccountDetail;
import com.salesforce.pages.salescloud.leads.LeadsDetail;
import com.salesforce.tests.functionaltests.CloudBaseTest;


@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class VerifyLeadConvert_Sales extends CloudBaseTest
{

	@Test
	public void testVerifyLeadConvert_Sales() throws BiffException, IOException, InterruptedException,
			RowsExceededException, WriteException
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
		final String subject = xlsUtil.ReadCell(xlsUtil.GetCell("Subject"), 1);
		final String accountName = xlsUtil.ReadCell(xlsUtil.GetCell("AccountName"), 1);
		
		
		/**
		 * Begin Test
		 */
		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();
		defaultTopFrame.verifyPageLoad().changeCurrentApp(salesCloudAppName);
		salesCloudTopFrame.selectFromTabBar(tab);
		
		LeadsDetail leadDetail = salesCloudLeadsHome.createNewRecord().selectRecordType(recordType)
				.verifyPageLoad().setLastName(lastName).setLeadStatus(leadStatus).clickOnSaveButton();
		
		AccountDetail accDetail = leadDetail.clickOnConvertButton().setSubject(subject).setAccountName(accountName)
				.clickOnConvertLeadButton();

		
		/**
		 * Assertion
		 */
		assertTrue("Lead was not converted into account after clicking on convert.", !(accDetail
				.verifyPageLoad().getHeaderText().isEmpty()));

	}

}
