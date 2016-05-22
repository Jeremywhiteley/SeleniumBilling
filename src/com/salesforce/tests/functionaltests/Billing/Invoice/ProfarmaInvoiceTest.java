package com.salesforce.tests.functionaltests.Billing.Invoice;

import static org.hamcrest.CoreMatchers.containsString;
import static org.junit.Assert.assertThat;

import java.io.IOException;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

import com.salesforce.tests.functionaltests.CloudBaseTest;

import jxl.read.biff.BiffException;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;


@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class ProfarmaInvoiceTest extends CloudBaseTest {

	@Test
	public void TC01() throws BiffException, IOException, InterruptedException,
	RowsExceededException, WriteException {
		
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String tab = xlsUtil.ReadCell(xlsUtil.GetCell("Tab"), 1);
		final String view = xlsUtil.ReadCell(xlsUtil.GetCell("View"), 1);
		final String filter = xlsUtil.ReadCell(xlsUtil.GetCell("Filter"), 1);
		final String ordername = xlsUtil.ReadCell(xlsUtil.GetCell("OrderName"), 1);

		
		final String preference = xlsUtil.ReadCell(xlsUtil.GetCell("ProformaInvoiceReference"), 1);
		final String reason = xlsUtil.ReadCell(xlsUtil.GetCell("CancellationReason"), 1);
		 
		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();
		defaultTopFrame.verifyPageLoad().changeCurrentApp(salesCloudAppName);
		salesCloudTopFrame.selectTab(tab);

		salesCloudLeadsHome.verifyPageLoad().setViewFilter(view).verifyPageLoad().sortLeadsTableByLetter(filter).selectFromLeadsTable(ordername);
		
		invoice.clickOnProfarmaInvoice().setReference(preference).clickOnCheckBox().clickOnProfarmaButton().clickOnPostButton().convertRegular().clickOnConfirm()
		.setCancelInvoice(reason).clickOnConfirmCancel();
		
		assertThat("Profarma Invoice has not been created.",invoice.getHeaderText().toUpperCase(), containsString("INV-".toUpperCase()));

	}

	/**@Test
	public void TC02() throws BiffException, IOException, InterruptedException,
	RowsExceededException, WriteException {

	   invoice.clickOnPostButton();
		Thread.sleep(3000);
	}
	
	@Test
	public void TC03() throws BiffException, IOException, InterruptedException,
	RowsExceededException, WriteException {

	   invoice.convertRegular();
		Thread.sleep(3000);
	}
	
	@Test
	public void TC04() throws BiffException, IOException, InterruptedException,
	RowsExceededException, WriteException {

	   
	String reason = xlsUtil.ReadCell(xlsUtil.GetCell("CancellationReason"), 1);
	invoice.setCancelInvoice(reason);
		Thread.sleep(3000);
	
	}*/

}
