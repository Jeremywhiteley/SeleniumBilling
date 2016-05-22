package com.salesforce.tests.functionaltests.servicecloud.cases;

import static org.hamcrest.CoreMatchers.containsString;
import static org.junit.Assert.assertThat;

import java.io.IOException;

import jxl.read.biff.BiffException;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

import com.salesforce.tests.functionaltests.CloudBaseTest;


@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class AddANewCase extends CloudBaseTest 
{
	@Test
	public void testAddANewCase() throws BiffException, IOException,
			InterruptedException, RowsExceededException, WriteException 
	{

		/**
		 * Initialize Test Data
		 */
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String tab = xlsUtil.ReadCell(xlsUtil.GetCell("Tab"), 1);
		final String accountName = xlsUtil.ReadCell(xlsUtil.GetCell("AccountName"), 1);
		final String caseRecordType = xlsUtil.ReadCell(xlsUtil.GetCell("CaseRecordType"), 1);
		final String accountNameExpected = xlsUtil.ReadCell(xlsUtil.GetCell("AccountNameExpected"), 1);
		
		
		/**
		 * Begin Test
		 */
		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();
		serviceCloudTopFrame.verifyPageLoad().changeCurrentApp(serviceCloudAppName);
		serviceCloudTopFrame.selectMainNavElement(tab);

		String accoutNameInDetailsPage = serviceCloudCasesHome.verifyPageLoad()
				.clickOnNewCaseButton().verifyRecordTypePageLoad().selectRecordType(caseRecordType)
				.setAccountName(accountName).clickOnSaveButton()
				.getCustomerDetailContent();
		
		
		/**
		 * Assertion
		 */
		assertThat(accoutNameInDetailsPage, containsString(accountNameExpected));
	}

}