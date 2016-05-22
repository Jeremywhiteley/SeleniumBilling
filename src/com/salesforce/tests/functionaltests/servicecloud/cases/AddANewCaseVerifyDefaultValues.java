package com.salesforce.tests.functionaltests.servicecloud.cases;

import static org.junit.Assert.assertEquals;

import java.io.IOException;

import jxl.read.biff.BiffException;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

import com.salesforce.pages.servicecloud.cases.ServiceCloudCasesEdit;
import com.salesforce.pages.servicecloud.cases.ServiceCloudCasesSelectRecordType;
import com.salesforce.tests.functionaltests.CloudBaseTest;


@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class AddANewCaseVerifyDefaultValues extends CloudBaseTest 
{

	@Test
	public void testAddANewCaseVerifyDefaultValues() throws BiffException, IOException,
			InterruptedException, RowsExceededException, WriteException 
	{

		
		/**
		 * Initialize Test Data
		 */
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String tab = xlsUtil.ReadCell(xlsUtil.GetCell("Tab"), 1);
		final String caseRecordType = xlsUtil.ReadCell(xlsUtil.GetCell("CaseRecordType"), 1);
		final String caseOrigin = xlsUtil.ReadCell(xlsUtil.GetCell("CaseOrigin"), 1);
		final String priority = xlsUtil.ReadCell(xlsUtil.GetCell("Priority"), 1);
		final String status = xlsUtil.ReadCell(xlsUtil.GetCell("Status"), 1);
		final String type = xlsUtil.ReadCell(xlsUtil.GetCell("Type"), 1);

		
		
		/**
		 * Begin Test
		 */
		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();
		serviceCloudTopFrame.verifyPageLoad().changeCurrentApp(serviceCloudAppName);
		serviceCloudTopFrame.selectMainNavElement(tab);

		ServiceCloudCasesSelectRecordType recordType =
				serviceCloudCasesHome.verifyPageLoad().clickOnNewCaseButton().verifyRecordTypePageLoad();
		
		ServiceCloudCasesEdit edit =
				recordType.selectRecordType(caseRecordType).verifyPageLoad();
		

		/**
		 * Assertion
		 */
		assertEquals(caseOrigin.toUpperCase(), edit.getDefaultSelectValueCaseOrigin().toUpperCase());
		assertEquals(priority.toUpperCase(), edit.getDefaultSelectValuePriority().toUpperCase());
		assertEquals(status.toUpperCase(), edit.getDefaultSelectValueStatus().toUpperCase());
		assertEquals(type.toUpperCase(), edit.getDefaultSelectValueType().toUpperCase());

	}
}