package com.salesforce.tests.functionaltests.servicecloud.cases;

import static org.junit.Assert.assertEquals;

import java.io.IOException;

import jxl.read.biff.BiffException;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

import com.salesforce.pages.servicecloud.cases.ServiceCloudCasesDetail;
import com.salesforce.tests.functionaltests.CloudBaseTest;


@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class ChangeOwnerForACase extends CloudBaseTest 
{
	@Test
	public void testChangeOwnerForACase() throws BiffException, IOException,
			InterruptedException, RowsExceededException, WriteException 
	{

		/**
		 * Initialize Test Data
		 */
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String tab = xlsUtil.ReadCell(xlsUtil.GetCell("Tab"), 1);
		final String caseOwner = xlsUtil.ReadCell(xlsUtil.GetCell("CaseOwner"), 1);
		final String caseOwnerExpected = xlsUtil.ReadCell(xlsUtil.GetCell("CaseOwnerExpected"), 1);
		final String accountName = xlsUtil.ReadCell(xlsUtil.GetCell("AccountName"), 1);
		final String caseRecordType = xlsUtil.ReadCell(xlsUtil.GetCell("CaseRecordType"), 1);

		
		/**
		 * Begin Test
		 */
		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();
		serviceCloudTopFrame.verifyPageLoad().changeCurrentApp(serviceCloudAppName);
		serviceCloudTopFrame.selectMainNavElement(tab);

		ServiceCloudCasesDetail caseDetail = serviceCloudCasesHome.verifyPageLoad().clickOnNewCaseButton()
				.verifyRecordTypePageLoad().selectRecordType(caseRecordType)
				.setAccountName(accountName).clickOnSaveButton();
				

		String caseNumber = caseDetail.getCurrentTabCaseID();
		caseDetail.closeCurrentTab();

		serviceCloudTopFrame.selectMainNavElement(tab);

		serviceCloudCasesHome.verifyPageLoad().checkmarkCase(caseNumber)
				.clickOnChangeOwnerButton().setOwner(caseOwner).clickOnSaveButton();
				
		String changedOwnerName = serviceCloudCasesHome.verifyPageLoad().selectFromCaseTable(caseNumber).getCaseOwner();

		
		/**
		 * Assertion
		 */
		assertEquals("Owner change not reflected after Save.", caseOwnerExpected, changedOwnerName);

	}

}