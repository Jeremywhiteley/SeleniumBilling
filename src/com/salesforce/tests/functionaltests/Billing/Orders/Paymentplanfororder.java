package com.salesforce.tests.functionaltests.Billing.Orders;

import static org.hamcrest.CoreMatchers.containsString;
import static org.junit.Assert.assertThat;

import java.io.IOException;
import java.text.ParseException;

import org.junit.Test;

import com.salesforce.tests.functionaltests.CloudBaseTest;

import jxl.read.biff.BiffException;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;

public class Paymentplanfororder extends CloudBaseTest {
	
	@Test
	public void paymentplantoorder() throws BiffException, IOException, InterruptedException,
	RowsExceededException, WriteException, ParseException {
						
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String tab = xlsUtil.ReadCell(xlsUtil.GetCell("Tab"), 1);
		final String view = xlsUtil.ReadCell(xlsUtil.GetCell("View"), 1);
		final String filter = xlsUtil.ReadCell(xlsUtil.GetCell("Filter"), 1);
		final String ordername = xlsUtil.ReadCell(xlsUtil.GetCell("OrderName"), 1);
		final String planname = xlsUtil.ReadCell(xlsUtil.GetCell("Payment Plan"), 1);

		
		
		/**
		 * Begin Test
		 */
		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();
		System.err.println("--------salesCloudAppName--------->"+ salesCloudAppName);
		defaultTopFrame.verifyPageLoad().changeCurrentApp(salesCloudAppName);
        salesCloudTopFrame.selectTab(tab);
		salesCloudLeadsHome.verifyPageLoad().setViewFilter(view).verifyPageLoad().sortLeadsTableByLetter(filter).selectFromLeadsTable(ordername);
		pplan.clickOnPaymentplan().setPaymentplan(planname).clickOnShowPlan().clickOnGenerateInstallments().clickOnSave();
				
		assertThat("Payment plan has not been added to order", pplan.getHeaderText().toUpperCase(), containsString("3 Months Plan".toUpperCase()));
	}
}
