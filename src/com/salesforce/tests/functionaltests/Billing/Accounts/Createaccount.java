package com.salesforce.tests.functionaltests.Billing.Accounts;



import static org.hamcrest.CoreMatchers.containsString;
import static org.junit.Assert.*;

//import static org.hamcrest.CoreMatchers.containsString;
//import static org.junit.Assert.*;

import java.io.IOException;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;


import com.salesforce.tests.functionaltests.CloudBaseTest;

import jxl.read.biff.BiffException;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class Createaccount extends CloudBaseTest  {

	@Test
	public void testSelectBillingAccount_Bil() throws BiffException, IOException, InterruptedException,
	RowsExceededException, WriteException {
		
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String tab = xlsUtil.ReadCell(xlsUtil.GetCell("Tab"), 1);
		final String name = xlsUtil.ReadCell(xlsUtil.GetCell("Account Name"), 1);


		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();
		defaultTopFrame.verifyPageLoad().changeCurrentApp(salesCloudAppName);
		salesCloudTopFrame.selectTab(tab);	
		account.clickOnAccounts().clickOnNew().setAccountName(name).clickOnSave();
		
		
		
		
		/** 
		 * 
		 * Assertions
		 */
		//assertThat("Account is not created",account.getHeaderText().toUpperCase(), containsString(name.toUpperCase()));
		
        //assertTrue("Account is not created", driver.getCurrentUrl().contains("001"));	
		
	}
}
