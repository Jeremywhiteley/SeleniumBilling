package com.salesforce.tests.functionaltests.servicecloud.cases;

import static org.junit.Assert.assertFalse;

import java.io.IOException;

import jxl.read.biff.BiffException;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

import com.salesforce.pages.servicecloud.cases.ServiceCloudCasesDetail;
import com.salesforce.tests.functionaltests.CloudBaseTest;
import com.salesforce.utils.driver.SalesforcePageExtensions;


@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class CloseCase extends CloudBaseTest 
{

	@Test
	public void testCloseCase() throws BiffException, IOException,
			InterruptedException, RowsExceededException, WriteException 
	{

		/**
		 * Initialize Test Data
		 */
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String tab = xlsUtil.ReadCell(xlsUtil.GetCell("Tab"), 1);
		final String caseFilter = xlsUtil.ReadCell(xlsUtil.GetCell("CaseFilter"), 1);
		final String accountName = xlsUtil.ReadCell(xlsUtil.GetCell("AccountName"), 1);
		final String closingStatus = xlsUtil.ReadCell(xlsUtil.GetCell("ClosingStatus"), 1);;
		final String closingReason = xlsUtil.ReadCell(xlsUtil.GetCell("ClosingReason"), 1);;
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
				
		String caseID = caseDetail.getCurrentTabCaseID();
		
		serviceCloudTopFrame.closeAllNavigatorTabs().selectMainNavElement(tab);
		serviceCloudCasesHome.verifyPageLoad().selectCaseFilter(caseFilter);
		
		serviceCloudCasesHome.verifyPageLoad().checkmarkCase(caseID).
			clickOnCloseCaseButton().setCaseClosingStatus(closingStatus).setCaseCloseReason(closingReason)
			.clickOnSaveButton();
		
		serviceCloudCasesHome.verifyPageLoad().selectCaseFilter(caseFilter);
		boolean isCasePresentAfterClosed = SalesforcePageExtensions.selectFromRecordTable(driver, caseID);
		
		
		/**
		 * Assertion
		 */
		assertFalse("Case still present after being closed.", isCasePresentAfterClosed);
	}

}