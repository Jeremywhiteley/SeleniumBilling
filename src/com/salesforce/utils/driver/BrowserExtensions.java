package com.salesforce.utils.driver;

import java.util.ArrayList;

import org.openqa.selenium.By;
import org.openqa.selenium.Dimension;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;

import com.salesforce.pages.PageBase;

public class BrowserExtensions extends PageBase
{

	public static void gotoNextTabInBrowser()
	{
		PageBase.Instance.pagelogger.debug("Switching to next tab in the browser!");

		ArrayList<String> newTab = new ArrayList<String>(DriverProvider.Driver.get()
				.getWindowHandles());

		PageBase.Instance.pagelogger.debug("Number of window handles found: " + newTab.size());
		PageBase.Instance.pagelogger.debug("Current window handle is: " + newTab.get(0));
		PageBase.Instance.pagelogger.debug("Will switch to window with the handle: "
				+ newTab.get(1));

		DriverProvider.Driver.get().switchTo().window(newTab.get(1));
	}

	public static void closeCurrentTabAndSwitchToMainTab()
	{
		ArrayList<String> newTab = new ArrayList<String>(DriverProvider.Driver.get()
				.getWindowHandles());
		DriverProvider.Driver.get().close();
		DriverProvider.Driver.get().switchTo().window(newTab.get(0));
	}

	public static void gotoURL(String Url)
	{
		driver.get(Url);
	}

	public static void clickOnBrowserBackButton()
	{
		DriverProvider.Driver.get().navigate().back();
	}

	public static void switchToCurrentWindow(WebDriver driver)
	{
		PageBase.Instance.pagelogger.debug("Switching to new window");

		for (String winHandle : driver.getWindowHandles())
		{
			driver.switchTo().window(winHandle);
		}

	}

	public static void switchToWindowHandle(WebDriver driver, String handle)
	{
		PageBase.Instance.pagelogger.debug("Switching to window with handle " + handle);
		driver.switchTo().window(handle);
	}

	/**
	 * Method used to determine whether a dynamic SALESFORCE element that used
	 * the 'Please Wait...' graphic has finished its loading operation.
	 * Typically used on related lists or tables. NOTE: This is an almost
	 * universally required method for many related lists or tables. May want to
	 * work on an integration in the future to lessen the amount of times this
	 * needs to be called -JDAPPER
	 * 
	 * @param driver
	 * @param timeToWait
	 * @return: true/false as to whether the loading operation finished within
	 *          the passed in amount of time
	 */
	public static boolean verifyNotLoading(WebDriver driver, int timeToWait)
	{
		By loadingIndicator = By.cssSelector("img[title='Please Wait...']");

		int i = 0;
		boolean result = false;

		while (i < 30)
		{
			PageBase.Instance.pagelogger
					.debug("Waiting 1 sec then returning result. Current wait time is:" + i);
			result = ExpectedConditions.invisibilityOfElementLocated(loadingIndicator)
					.apply(driver);

			if (result == true)
			{
				PageBase.Instance.pagelogger
						.debug("Loading element is no longer visible. Continuing execution.");
				break;
			}

			i = i + 1;

		}

		return result;

	}

	/**
	 * Method used to resize and maximize the browser in order to pop certain
	 * elements within the Salesforce UI which do not display correctly after
	 * page load. This should always be tied with any table searching methods
	 * 
	 * @param driver
	 */
	public static void juggleBrowserSize(WebDriver driver)
	{
		Dimension d = new Dimension(500, 500);
		driver.manage().window().setSize(d);
		driver.manage().window().maximize();
	}
}