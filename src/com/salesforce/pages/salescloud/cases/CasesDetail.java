package com.salesforce.pages.salescloud.cases;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class CasesDetail extends PageBase
{

	 
	private static CasesDetail instance;
	public static CasesDetail Instance = (instance != null) ? instance : new CasesDetail();

	/** UI Mappings */

	
	/** Page Methods */

	public CasesDetail verifyPageLoad()
	{
		pagelogger.debug("Waiting for page to load...");

		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}

}
