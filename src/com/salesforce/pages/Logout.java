package com.salesforce.pages;

import org.openqa.selenium.WebDriver;

import com.salesforce.utils.UtilBase;

public class Logout extends PageBase
{

	/** UI Mappings */

	/** Page Methods */
	public static void logOut(WebDriver driver)
	{
		UtilBase.Instance.utillogger.debug("Logging out!");
		driver.get("https://org62.my.salesforce.com/home/home.jsp");
	}

}
