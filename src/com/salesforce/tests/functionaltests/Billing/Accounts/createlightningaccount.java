package com.salesforce.tests.functionaltests.Billing.Accounts;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import java.io.IOException;

import org.junit.Test;

import com.salesforce.tests.functionaltests.CloudBaseTest;

import jxl.read.biff.BiffException;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;

public class createlightningaccount extends CloudBaseTest{
	
	@Test
	public void lightningAccount() throws BiffException, IOException, InterruptedException,
	RowsExceededException, WriteException {
		
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String name = xlsUtil.ReadCell(xlsUtil.GetCell("Account Name"), 1);
		final String phonenumber = xlsUtil.ReadCell(xlsUtil.GetCell("Phone"), 1);
		final String website = xlsUtil.ReadCell(xlsUtil.GetCell("Website"), 1);

		
		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();
		
		lightning.clickOnUser().clickOnSwitchLighrning().clickOnCheckbox().clickOnSwitch().clickOnAccounts().clickOnNew().setAccountName(name).setPhoneNum(phonenumber)
		.clickOnDefaultPaymentGateway().setgateway().setWebsiteName(website).clickOnSave();
		
		/**
		 * Assertion
		 */
		assertFalse("Account is not created", lightning.verifyPageLoad().getPresenceOfActivity(name));
			
				
	}
	
	@Test
	public void lightningAccount1() throws BiffException, IOException, InterruptedException,
	RowsExceededException, WriteException {
		
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String phonenumber = xlsUtil.ReadCell(xlsUtil.GetCell("Phone"), 1);
		final String website = xlsUtil.ReadCell(xlsUtil.GetCell("Website"), 1);

		
		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();
		
		lightning.clickOnUser().clickOnSwitchLighrning().clickOnCheckbox().clickOnSwitch().clickOnAccounts().clickOnNew().setPhoneNum(phonenumber)
		.clickOnDefaultPaymentGateway().setgateway().setWebsiteName(website).clickOnSave();
			

		/**
		 * Assertion
		 */
		assertTrue("Account is not created", lightning.verifyPageLoad().getPresenceOfActivity(phonenumber));
	}

}
