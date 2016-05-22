package com.salesforce.pages.Billing.Quotes;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.pages.salescloud.accounts.AccountDetail;
import com.salesforce.pages.salescloud.accounts.AccountsSelectRecordType;
import com.salesforce.pages.salescloud.contacts.ContactsEdit;
import com.salesforce.utils.driver.SalesforcePageExtensions;

public class QuoteHome extends PageBase {

	private static QuoteHome instance;
	public static QuoteHome Instance = (instance != null) ? instance : new QuoteHome();

	By clickNewButton = By.cssSelector("input[name='new']");

	public QuoteHome clickOnNewButton() {
		pagelogger.debug("Clicking on the New button...");
		clickOnElement(clickNewButton);
		return QuoteHome.Instance;
	}
	
	

}
