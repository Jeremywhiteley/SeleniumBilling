package com.salesforce.tests.functionaltests.Billing.Orders;

import static org.hamcrest.CoreMatchers.containsString;
import static org.junit.Assert.assertThat;

//import static org.hamcrest.CoreMatchers.containsString;
//import static org.junit.Assert.assertThat;

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
public class Createorderforonetimecharge extends CloudBaseTest {

	@Test
	public void test_CreateOrder() throws BiffException, IOException, InterruptedException,
	RowsExceededException, WriteException, ParseException {
		
				
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String tab = xlsUtil.ReadCell(xlsUtil.GetCell("Tab"), 1);
		final String name = xlsUtil.ReadCell(xlsUtil.GetCell("Order Name"), 1);
		//final String terms = xlsUtil.ReadCell(xlsUtil.GetCell("Terms (Months)"), 1);
		final String renew = xlsUtil.ReadCell(xlsUtil.GetCell("Auto Renew?"), 1);
		//final String preferredbillingdayofmonth = xlsUtil.ReadCell(xlsUtil.GetCell("PBDM"), 1);
		//final String paymentterms = xlsUtil.ReadCell(xlsUtil.GetCell("Payment Terms"), 1);
		final String startdate = xlsUtil.ReadCell(xlsUtil.GetCell("Service Start Date"), 1);
		final String orderAccountName = xlsUtil.ReadCell(xlsUtil.GetCell("orderAccountName"), 1);
		final String addproduct = xlsUtil.ReadCell(xlsUtil.GetCell("ProductName"), 1);


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
		Order.clickOnNewButton().setOrderName(name).setAccountName(orderAccountName)
		.clickOnNextButton().addProducts(addproduct).clickOnAddButton().clickOnNextStep2Button().clickOnSaveButton();
		
		assertThat("Order has not been created.", Order.getHeaderText().toUpperCase(), containsString(name.toUpperCase()));
		
		
		//verifying order subtotal 
		assertThat("subtotal is wrong.",  Order.getSubTotal(), containsString("330"));
		
		
	}
	
	@Test
	public void test_CreateOrderForTCV() throws BiffException, IOException, InterruptedException,
	RowsExceededException, WriteException, ParseException {
		
				
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String tab = xlsUtil.ReadCell(xlsUtil.GetCell("Tab"), 1);
		final String name = xlsUtil.ReadCell(xlsUtil.GetCell("Order Name"), 1);
		//final String terms = xlsUtil.ReadCell(xlsUtil.GetCell("Terms (Months)"), 1);
		final String renew = xlsUtil.ReadCell(xlsUtil.GetCell("Auto Renew?"), 1);
		//final String preferredbillingdayofmonth = xlsUtil.ReadCell(xlsUtil.GetCell("PBDM"), 1);
		//final String paymentterms = xlsUtil.ReadCell(xlsUtil.GetCell("Payment Terms"), 1);
		final String startdate = xlsUtil.ReadCell(xlsUtil.GetCell("Service Start Date"), 1);
		final String orderAccountName = xlsUtil.ReadCell(xlsUtil.GetCell("orderAccountName"), 1);
		final String addproduct = xlsUtil.ReadCell(xlsUtil.GetCell("ProductName"), 1);


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
		Order.clickOnNewButton().setOrderName(name).setAccountName(orderAccountName)
		.clickOnNextButton().addProducts(addproduct).clickOnAddButton().clickOnNextStep2Button().clickOnSaveButton();
		
		assertThat("Order has not been created.", Order.getHeaderText().toUpperCase(), containsString(name.toUpperCase()));
		
		//verifying order TCV 
	   assertThat("TCV is wrong.",  Order.getTCV(), containsString("300"));
		
		
	}
}
