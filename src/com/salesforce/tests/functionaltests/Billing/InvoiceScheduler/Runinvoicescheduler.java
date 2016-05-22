package com.salesforce.tests.functionaltests.Billing.InvoiceScheduler;



import static org.hamcrest.CoreMatchers.containsString;
import static org.junit.Assert.assertThat;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

import com.salesforce.tests.functionaltests.CloudBaseTest;
@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class Runinvoicescheduler extends CloudBaseTest {

	@Test
	public void testScheduler() throws InterruptedException {
		
		/**
		 * Initialize Test Data
		 */
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String tab = xlsUtil.ReadCell(xlsUtil.GetCell("Tab"), 1);
		final String name = xlsUtil.ReadCell(xlsUtil.GetCell("Invoice Scheduler Name"), 1);
		final String currency = xlsUtil.ReadCell(xlsUtil.GetCell("Invoice Currency"), 1);
		final String startdate = xlsUtil.ReadCell(xlsUtil.GetCell("Start Date and Time"), 1);

		
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
		scheduler.clickOnInvoiceScheduler().clickOnNewButton().setSchedulerName(name).setCurrency(currency).setDateAndTime(startdate).
		clickOnSave();
		
		assertThat("Scheduler name shown incorrectly.", scheduler.getHeaderText().toUpperCase(), containsString(name.toUpperCase()));
		
	}

}
