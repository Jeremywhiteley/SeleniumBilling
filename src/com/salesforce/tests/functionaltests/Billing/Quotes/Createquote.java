package com.salesforce.tests.functionaltests.Billing.Quotes;

import java.io.IOException;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;
import com.salesforce.pages.Billing.Quotes.QuoteHome;
import com.salesforce.tests.functionaltests.CloudBaseTest;

import jxl.read.biff.BiffException;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;
@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class Createquote extends CloudBaseTest {

	@Test
	public void testSelectBillingQuote_Bill() throws BiffException, IOException, InterruptedException,
	RowsExceededException, WriteException {
		
		QuoteHome order = new QuoteHome();
		
		/**
		 * Initialize Test Data
		 */
		
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String tab = xlsUtil.ReadCell(xlsUtil.GetCell("Tab"), 1);
		final String quotename = xlsUtil.ReadCell(xlsUtil.GetCell("Quote Name"), 1);
	
		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();
		System.err.println("--------salesCloudAppName--------->"+ salesCloudAppName);
		defaultTopFrame.verifyPageLoad().changeCurrentApp(salesCloudAppName);
		salesCloudTopFrame.selectTab(tab);
		order.clickOnNewButton();
		
	
	}
}
