package com.salesforce.tests.functionaltests.Billing.Orders;

import static org.hamcrest.CoreMatchers.containsString;
import static org.junit.Assert.assertThat;

import java.io.IOException;
import java.text.ParseException;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

import com.salesforce.tests.functionaltests.CloudBaseTest;

import jxl.read.biff.BiffException;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;
@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class Createpaymentplan extends CloudBaseTest{
	
	@Test
	public void paymentplansTest() throws BiffException, IOException, InterruptedException,
	RowsExceededException, WriteException, ParseException {
						
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String planname = xlsUtil.ReadCell(xlsUtil.GetCell("Payment Plan Name"), 1);
		final String noofinstallments = xlsUtil.ReadCell(xlsUtil.GetCell("No of Installments"), 1);
		final String downpayment = xlsUtil.ReadCell(xlsUtil.GetCell("Down Payment (%)"), 1);
		final String mininstallments = xlsUtil.ReadCell(xlsUtil.GetCell("Minimum Installments"), 1);
		final String maxinstallments = xlsUtil.ReadCell(xlsUtil.GetCell("Maximum Installments"), 1);
		
		/**
		 * Begin Test
		 */
		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();
		System.err.println("--------salesCloudAppName--------->"+ salesCloudAppName);
		defaultTopFrame.verifyPageLoad().changeCurrentApp(salesCloudAppName);
		plan.clickOnArrowButton().clickOnPaymentPlanTab().clickOnNewButton().setPaymentPlanName(planname).clickOnStartDate().setNoOfInstallments(noofinstallments).
		setDownPayment(downpayment).setMinInstallments(mininstallments).setMaxInstallments(maxinstallments).setSave();
				
		assertThat("Payment plan has not been created", plan.getHeaderText().toUpperCase(), containsString(planname.toUpperCase()));
		
	}	
	

}
