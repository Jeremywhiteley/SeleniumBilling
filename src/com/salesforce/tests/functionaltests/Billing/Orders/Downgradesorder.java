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

public class Downgradesorder extends CloudBaseTest {
	
	@Test
	public void downgrade() throws BiffException, IOException, InterruptedException,
	RowsExceededException, WriteException, ParseException {
		
				
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String tab = xlsUtil.ReadCell(xlsUtil.GetCell("Tab"), 1);
		final String view = xlsUtil.ReadCell(xlsUtil.GetCell("View"), 1);
		final String filter = xlsUtil.ReadCell(xlsUtil.GetCell("Filter"), 1);
		final String name = xlsUtil.ReadCell(xlsUtil.GetCell("Order Name"), 1);			
		final String decreaseqty = xlsUtil.ReadCell(xlsUtil.GetCell("Decrease Qty"), 1);


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
		
		Order.clickOnMidTerm().changeQty().increaseQty(decreaseqty).clickOnMidtermSaveButton();
		
		assertThat("Quantity is not decreased to the line", Order.getHeaderText().toUpperCase(), containsString(name.toUpperCase()));

   }
	

}
