package com.salesforce.pages.servicecloud;

import java.util.ArrayList;
import java.util.List;

import org.openqa.selenium.Alert;
import org.openqa.selenium.By;
import org.openqa.selenium.Dimension;
import org.openqa.selenium.NoAlertPresentException;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;
import com.salesforce.utils.driver.ServiceCloudPageExtensions;

public class ServiceCloudTopFrame extends PageBase
{

	private static ServiceCloudTopFrame instance;
	public static ServiceCloudTopFrame Instance = (instance != null) ? instance
			: new ServiceCloudTopFrame();

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

	public ServiceCloudTopFrame verifyPageLoad()
	{
		synchronize(30);
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}

	public ServiceCloudTopFrame clickOnBackToCSConsole()
	{
		pagelogger.debug("Clicking on back to CS console button");

		IframeUtils.setDriverContextToIframeWithDepth(driver, backToCSConsoleTab);

		try
		{
			clickOnElement(backToCSConsoleTab);
		} catch (NoSuchElementException e)
		{
			pagelogger.debug("Continuing test as it might be in the desired page already");
		}

		setDriverContextToPage(driver);
		return this;
	}

	public void selectMainNavElement(String val)
	{
		pagelogger.debug("Selecting the Service Cloud Navigation Menu item: " + val);

		boolean found = false;
		synchronize(30);

		By pageBody = By.tagName("body");
		findElement(pageBody).sendKeys("v");

		List<WebElement> elements = driver
				.findElements(By
						.xpath("//div[id=contains(text(), 'navigator')]/ul/li/a/span[text()='"
								+ val + "']"));

		for (WebElement element : elements)
		{

			if (element.getText().length() > 1)
			{
				pagelogger.debug("Found Navigation Element: " + element.getText().toUpperCase()
						+ ". Comparing it to: " + val.toUpperCase());
			}

			if (element.getText().toUpperCase().equals(val.toUpperCase()))
			{
				clickOnElement(By
						.xpath("//div[id=contains(text(), 'navigator')]/ul/li/a/span[text()='"
								+ val + "']"));
				found = true;
				break;
			}

		}

		if (found != true)
		{
			pagelogger.debug("WARNING: The navigation element could not be found: " + val);
		}
	}

	public List<String> getConsoleTabItemsAsList()
	{
		pagelogger.debug("Getting the list of menu items as a List");

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, navigatorMenuDropDown);

		By pageBody = By.tagName("body");
		findElement(pageBody).sendKeys("v");

		List<WebElement> elements = findElements(By.xpath("//a[contains(@class,'Mru')]/span"));
		List<String> listOfItems = new ArrayList<String>();

		for (WebElement element : elements)
		{
			listOfItems.add(element.getText().trim());
		}

		setDriverContextToPage(driver);
		return listOfItems;
	}

	public void selectMenuFromSingleNavigatorTab(String tabName)
	{
		WebElement element = findElement(navigatorMenuDropDown);
		Dimension dimensions = element.getSize();
		int buttonWidth = dimensions.getWidth();
		int offset = buttonWidth - 5;

		Actions builder = new Actions(driver);
		builder.moveToElement(element, offset, 3).click().build().perform();
		clickOnElement(navigatorMenuDropDown);

		List<WebElement> elements = findElements(By
				.xpath("//div[id=contains(text(), 'navigator')]/ul/li"));

		for (WebElement loopElement : elements)
		{
			if (loopElement.getText().length() > 1)
			{
				pagelogger.debug("Found Navigation Element: " + loopElement.getText().toUpperCase()
						+ ". Comparing it to: " + tabName.toUpperCase());
			}

			if (loopElement.getText().toUpperCase().equals(tabName.toUpperCase()))
			{
				clickOnElement(By
						.xpath("//div[id=contains(text(), 'navigator')]/ul/li/a/span[text()='"
								+ tabName + "']"));
				break;
			}

		}
	}

	public void selectTab(String tabName)
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);

		String menuToSelect = "//ul[@id='tabBar']//a[contains(@title,'TabName')]";
		menuToSelect = menuToSelect.replace("TabName", tabName);

		clickOnElement(By.xpath(menuToSelect));
	}

	public ServiceCloudSearchResults enterTextAndSearch(String searchText)
	{
		synchronize(30);

		pagelogger.debug("Entering text into the search box and searching for: " + searchText);

		findElement(searchBoxLocator).clear();
		findElement(searchBoxLocator).sendKeys(searchText);
		clickOnElement(searchButtonLocator);

		return ServiceCloudSearchResults.Instance;
	}

	public ServiceCloudTopFrame closeAllNavigatorTabs(WebDriver driver)
	{
		pagelogger.debug("Closing all top level Navigation tabs");
		ServiceCloudPageExtensions.closeAllNavigatorTabs(driver);
		return this;
	}

	public ServiceCloudTopFrame closeAllNavigatorTabs()
	{
		pagelogger.debug("Closing all top level Navigation tabs");
		ServiceCloudPageExtensions.closeAllNavigatorTabs(driver);
		return this;
	}

	public boolean isDashboardComponentPresentForReportingUser()
	{
		boolean found = false;
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, casesClosedHeader);

		try
		{
			if (findElements(casesClosedHeader).size() > 0
					&& findElements(casesCreatedHeader).size() > 0
					&& findElements(dashboardImageForCaseClosed).size() > 0
					&& findElements(dashboardImageForCaseCreated).size() > 0)
			{
				found = true;
				setDriverContextToPage(driver);
			}
		} catch (org.openqa.selenium.NoSuchElementException e)
		{
			setDriverContextToPage(driver);
			return found;
		}

		return found;
	}

	public ServiceCloudTopFrame changeCurrentApp(String appName)
	{
		pagelogger.debug("Changing App to " + appName);
		synchronize(30);
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

		try
		{
			closeAllNavigatorTabs();
		} catch (Exception e)
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
