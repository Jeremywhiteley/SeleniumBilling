package com.salesforce.tests.functionaltests.servicecloud.cases;

import static org.junit.Assert.assertEquals;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

import com.salesforce.pages.servicecloud.cases.ServiceCloudCasesChangeStatus;
import com.salesforce.pages.servicecloud.cases.ServiceCloudCasesDetail;
import com.salesforce.tests.functionaltests.CloudBaseTest;


@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class ChangeCaseStatus extends CloudBaseTest 
{
	@Test
	public void testChangeCaseStatus() throws InterruptedException  
	{

		/**
		 * Initialize Test Data
		 */
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String tab = xlsUtil.ReadCell(xlsUtil.GetCell("Tab"), 1);
		final String caseRecordType = xlsUtil.ReadCell(xlsUtil.GetCell("CaseRecordType"), 1);
		final String caseStatus = xlsUtil.ReadCell(xlsUtil.GetCell("CaseStatus"), 1);
		final String accountName = xlsUtil.ReadCell(xlsUtil.GetCell("AccountName"), 1);
		
		
		/**
		 * Begin Test
		 */
		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();
		serviceCloudTopFrame.verifyPageLoad().changeCurrentApp(serviceCloudAppName);
		serviceCloudTopFrame.selectMainNavElement(tab);
		
		ServiceCloudCasesDetail caseDetail = serviceCloudCasesHome.verifyPageLoad()
				.clickOnNewCaseButton().verifyRecordTypePageLoad().selectRecordType(caseRecordType)
				.setAccountName(accountName).clickOnSaveButton();

		String currentTabID = caseDetail.verifyPageLoad().getCurrentTabCaseID();
		serviceCloudTopFrame.selectMainNavElement(tab);
		
		ServiceCloudCasesChangeStatus changeStatus = serviceCloudCasesHome.verifyPageLoad()
				.checkmarkCase(currentTabID).clickOnChangeStatusButton();
				
		changeStatus.verifyPageLoad().setCaseStatus(caseStatus).clickOnSaveButton();
		String changedStatus = serviceCloudCasesHome.getStatusOfACase(currentTabID);			
		
		
		/**
		 * Assertion
		 */
		assertEquals("Status change not reflected after save!", caseStatus, changedStatus);
			
	}

}