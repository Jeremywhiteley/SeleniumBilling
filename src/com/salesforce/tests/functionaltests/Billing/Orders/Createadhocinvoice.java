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

public class Createadhocinvoice extends CloudBaseTest {
	
	
	@Test
	public void createAdhocInvoiceFromOrder() throws BiffException, IOException, InterruptedException,
	RowsExceededException, WriteException, ParseException {
	
	final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
	final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
	final String tab = xlsUtil.ReadCell(xlsUtil.GetCell("Tab"), 1);
	final String view = xlsUtil.ReadCell(xlsUtil.GetCell("View"), 1);
	final String filter = xlsUtil.ReadCell(xlsUtil.GetCell("Filter"), 1);
	final String name = xlsUtil.ReadCell(xlsUtil.GetCell("Order Name"), 1);		
	
	
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
	salesCloudLeadsHome.verifyPageLoad().setViewFilter(view).verifyPageLoad().sortLeadsTableByLetter(filter).selectFromLeadsTable(name);
	Adhoc.clickOnNewButton().clickOnInvoiceDate().clickOnTargetDate().clickOnGenerateInvoice();
	
	assertThat("Adhoc Invoice has not been generated", Adhoc.getHeaderText().toUpperCase(), containsString("Invoice".toUpperCase()));

	}

}
