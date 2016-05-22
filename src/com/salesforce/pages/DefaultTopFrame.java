package com.salesforce.pages;

import org.openqa.selenium.Alert;
import org.openqa.selenium.By;
import org.openqa.selenium.NoAlertPresentException;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.TimeoutException;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.tests.functionaltests.CloudBaseTest;
import com.salesforce.utils.driver.SalesforcePageExtensions;
import com.salesforce.utils.driver.ServiceCloudPageExtensions;

public class DefaultTopFrame extends PageBase
{

	private static DefaultTopFrame instance;
	public static DefaultTopFrame Instance = (instance != null) ? instance : new DefaultTopFrame();

	/** UI Mappings */

	By searchBoxLocator = By.xpath("//input[@id='phSearchInput']");
	By searchButtonLocator = By.cssSelector("input[value='Search']");
	By navigatorMenu = By.xpath("//ul[@id='tabBar']//a[contains(@title,'TabName')]");
	By navigatorMenuDropDown = By.xpath("//div[@id='navigatortab']//td[@class='x-btn-mc']/em");
	By navigatorLink = By.xpath("//li[contains(@class,'menu-list')]//span[text()='Cases']");
	By currentAppLabel = By.xpath("//span[@id='tsidLabel']");
	By changeAppArrow = By.xpath("//div[@id='tsid-arrow']");
	By appToSelect;
	By casesClosedHeader = By
			.xpath("//h2[contains(text(),'Current FY - Month to Month - Case Status Trending')]");
	By dashboardImageForCaseClosed = By
			.xpath("//img[contains(@alt,'Cases Last Modified Today - Click to go to full report.')]");
	By casesCreatedHeader = By.xpath("//h2[contains(text(),'Longest Case Statuses')]");
	By dashboardImageForCaseCreated = By
			.xpath("//img[contains(@alt,'Current FY - Month to Month - Case Status Trending - Click to go to full report.')]");
	By personalDropdownLocator = By.cssSelector("span[id='userNavLabel']");
	By logoutLocator = By.linkText("Logout");
	By backToCSConsoleTab = By.xpath("//a[text()='Back to CS Console']");

	/** Page Methods */

	public DefaultTopFrame verifyPageLoad()
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}

	public DefaultTopFrame closeAllNavigatorTabs(WebDriver driver)
	{
		pagelogger.debug("Closing all top level Navigation tabs");
		ServiceCloudPageExtensions.closeAllNavigatorTabs(driver);
		return this;
	}

	public DefaultTopFrame closeAllNavigatorTabs()
	{
		pagelogger.debug("Closing all top level Navigation tabs");
		try
		{
			ServiceCloudPageExtensions.closeAllNavigatorTabs(driver);
		} catch (NoSuchElementException e)
		{
			pagelogger.debug("Navigator tabs not applicable to the current app. Continuing test");
		}
		return this;
	}

	public DefaultTopFrame changeCurrentApp(String appName)
	{
		pagelogger.debug("Changing App to " + appName);
		try
		{
			String currentApp = findElement(currentAppLabel).getText();

			if (!currentApp.equals(appName))
			{
				clickOnElement(changeAppArrow);
				String appToSelectLocator = "//a[text()='{AppName}' and contains(@class,'menuButtonMenuLink')]";
				appToSelectLocator = appToSelectLocator.replace("{AppName}", appName);
				appToSelect = By.xpath(appToSelectLocator);

				clickOnElement(appToSelect);

				Alert alert = driver.switchTo().alert();
				alert.accept();
				new WebDriverWait(driver, 30).until(ExpectedConditions.titleContains(pageTitle));
			}
		} catch (NoSuchElementException e)
		{
			pagelogger.debug("App selector not found. Case may fail");
		} catch (NoAlertPresentException e)
		{
			pagelogger.debug("Alert not found. Case will continue");
		} catch (Exception e)
		{
			pagelogger.debug("Some other uncaught exception happened. Might fail" + e.getMessage());
		}
		if (appName.equals(CloudBaseTest.serviceCloudAppName))
			try
			{
				closeAllNavigatorTabs();
			} catch (TimeoutException e)
			{
				pagelogger.debug("No primary tabs found. Test will continue");
			}

		return this;
	}

	public void logOut()
	{
		pagelogger.debug("Selecting Log Out");

		clickOnElement(personalDropdownLocator);
		clickOnElement(logoutLocator);
	}

}
