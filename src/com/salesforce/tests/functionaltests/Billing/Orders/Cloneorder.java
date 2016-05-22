package com.salesforce.tests.functionaltests.Billing.Orders;

import static org.hamcrest.CoreMatchers.containsString;
import static org.junit.Assert.assertThat;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

import com.salesforce.tests.functionaltests.CloudBaseTest;
@FixMethodOrder(MethodSorters.NAME_ASCENDING)

public class Cloneorder extends CloudBaseTest {
	
	@Test
	public void cloneorder_TestStepWizard() throws InterruptedException{
		
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String tab = xlsUtil.ReadCell(xlsUtil.GetCell("Tab"), 1);
		final String view = xlsUtil.ReadCell(xlsUtil.GetCell("View"), 1);
		final String filter = xlsUtil.ReadCell(xlsUtil.GetCell("Filter"), 1);
		final String ordername = xlsUtil.ReadCell(xlsUtil.GetCell("OrderName"), 1);
		
		
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
		
		corder.clickOnClone().clcikOnStepWizard().clcikOnNext().clcikOnNext().clcikOnSave();
		
		assertThat("Order name shown incorrectly.", corder.getHeaderText().toUpperCase(), containsString(ordername.toUpperCase()));

	 }
	
	
	
/** Canceling the clone order */	
	
	@Test

	public void cloneorder_TestCancel() throws InterruptedException{
		
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String tab = xlsUtil.ReadCell(xlsUtil.GetCell("Tab"), 1);
		final String view = xlsUtil.ReadCell(xlsUtil.GetCell("View"), 1);
		final String filter = xlsUtil.ReadCell(xlsUtil.GetCell("Filter"), 1);
		final String ordername = xlsUtil.ReadCell(xlsUtil.GetCell("OrderName"), 1);
		
		
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
		
		corder.clickOnClone().clickOnCancel();
		
		assertThat("Order name shown incorrectly.", corder.getHeaderText().toUpperCase(), containsString(ordername.toUpperCase()));

}	
	
/** checking the clone preview order */	
	
@Test

public void cloneorder_TestPreview() throws InterruptedException{
	
	final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
	final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
	final String tab = xlsUtil.ReadCell(xlsUtil.GetCell("Tab"), 1);
	final String view = xlsUtil.ReadCell(xlsUtil.GetCell("View"), 1);
	final String filter = xlsUtil.ReadCell(xlsUtil.GetCell("Filter"), 1);
	final String ordername = xlsUtil.ReadCell(xlsUtil.GetCell("OrderName"), 1);
	
	
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
	
	corder.clickOnClone().clickOnPreview();
   
	//assertThat("Order name shown incorrectly.", corder.getHeaderText().toUpperCase(), containsString(ordername.toUpperCase()));


    }

/** cloning order with QuickSave button */

@Test

public void cloneorder_TestQuickSave() throws InterruptedException{
	
	final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
	final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
	final String tab = xlsUtil.ReadCell(xlsUtil.GetCell("Tab"), 1);
	final String view = xlsUtil.ReadCell(xlsUtil.GetCell("View"), 1);
	final String filter = xlsUtil.ReadCell(xlsUtil.GetCell("Filter"), 1);
	final String ordername = xlsUtil.ReadCell(xlsUtil.GetCell("OrderName"), 1);
	
	
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
	
	corder.clickOnClone().clickOnQuickSave();
	
	assertThat("Order name shown incorrectly.", corder.getHeaderText().toUpperCase(), containsString(ordername.toUpperCase()));

   

    }


}
