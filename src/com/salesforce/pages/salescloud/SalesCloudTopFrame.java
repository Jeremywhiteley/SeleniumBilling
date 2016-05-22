package com.salesforce.pages.salescloud;

import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.DefaultTopFrame;
import com.salesforce.pages.setup.SetupHome;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class SalesCloudTopFrame extends DefaultTopFrame
{

	 
	private static SalesCloudTopFrame instance;
	public static SalesCloudTopFrame Instance = (instance != null) ? instance : new SalesCloudTopFrame();

	
	/** UI Mappings */

	By searchBoxLocator = By.id("phSearchInput");
	By searchBoxClearLocator = By.id("phSearchClearButton");
	By searchButtonLocator = By.cssSelector("input[value='Search']");
	By searchBoxResultsBoxLocator = By.id("phSearchInput_autoCompleteBoxId");
	By personalDropdownLocator = By.cssSelector("span[id='userNavLabel']");
	By myProfileLocator = By.linkText("My Profile");
	By mySettingsLocator = By.linkText("My Settings");
	By logoutLocator = By.linkText("Logout");
	By setupLocator = By.linkText("Setup");
	By helpAndTrainingLocator = By.linkText("Help & Training");
	By menuLocator = By.cssSelector("div[title='Force.com App Menu']");
	By showAllTabsLocator = By.cssSelector("img[title='All Tabs']");
	By librariesTabLocator = By.cssSelector("a[title='Libraries Tab']");
	By contentTabLocator = By.cssSelector("a[title='Content Tab']");
	By subscriptionsTabLocator = By.cssSelector("a[title='Subscriptions Tab']");
	By mobileAppConfigurationsTabLocator = By.cssSelector("a[title='Mobile App Configurations Tab']");
	By categoriesTabLocator = By.cssSelector("a[title='Categories Tab']");
	By contentReviewsTabLocator = By.cssSelector("a[title='Content Reviews Tab']");
	By chatterTabLocator = By.cssSelector("a[title='Chatter Tab']");
	By[] masterTabArray = { chatterTabLocator, contentReviewsTabLocator, categoriesTabLocator,
			mobileAppConfigurationsTabLocator, subscriptionsTabLocator, contentTabLocator,
			librariesTabLocator };
	public By[] userTypeOneArray = { chatterTabLocator, contentReviewsTabLocator,
			categoriesTabLocator, mobileAppConfigurationsTabLocator, subscriptionsTabLocator,
			contentTabLocator, librariesTabLocator };

	
	
	
	/** Page Methods */

	public SearchResultsDetail enterTextAndSearch(String searchText)
	{
		pagelogger.debug("Entering text into the search box and searching for: "  + searchText);

		findElement(searchBoxLocator).clear();
		findElement(searchBoxLocator).sendKeys(searchText);
		clickOnElement(searchButtonLocator);

		return SearchResultsDetail.Instance;
	}

	public boolean enterTextAndSelectFromDropdown(String searchText, String linkText)
	{

		boolean elementFound = false;

		pagelogger.debug("Entering the following text into the search box and searching: "				+ searchText);

		findElement(searchBoxLocator).clear();
		findElement(searchBoxLocator).sendKeys(searchText);

		if (findElement(searchBoxResultsBoxLocator).isDisplayed())
		{

			try
			{
				WebDriverWait wait = new WebDriverWait(driver, 5);
				pagelogger.debug("Clicking on the dropdown linktext: "  + linkText);
				wait.until(ExpectedConditions.visibilityOfElementLocated(By.linkText(linkText)))
						.click();
				elementFound = true;
			} catch (NoSuchElementException e)
			{
				elementFound = false;
			}
		}

		return elementFound;
	}

	public void viewMyProfile()
	{
		pagelogger.debug("Selecting My Profile");

		clickOnElement(personalDropdownLocator);
		clickOnElement(myProfileLocator);
	}

	public void viewMySettings()
	{
		pagelogger.debug("Selecting My Settings");

		clickOnElement(personalDropdownLocator);
		clickOnElement(mySettingsLocator);
	}

	public void logOut()
	{
		pagelogger.debug("Selecting Log Out");

		clickOnElement(personalDropdownLocator);;
		clickOnElement(logoutLocator);
	}

	public SetupHome viewSetup()
	{
		pagelogger.debug("Selecting the Setup menu link");

		clickOnElement(setupLocator);
		return SetupHome.Instance;
	}

	public void viewHelpAndTraining()
	{
		clickOnElement(helpAndTrainingLocator);
	}

	public void viewMainMenuItem(String menuItemText)
	{
		By currentItem = By.xpath("//div[@id='tsidButton']/descendant::span[1]");
		String currentMenuItem = findElement(currentItem).getText();

		pagelogger.debug("The current menu item is: " + menuItemText + " --->We want to select: "				+ menuItemText);

		if (!currentMenuItem.toUpperCase().trim().equals(menuItemText.toUpperCase().trim()))
		{
			pagelogger.debug("Selecting: "  + menuItemText);

			clickOnElement(menuLocator);
			clickOnElement(By.linkText(menuItemText));
		} else
		{
			pagelogger.debug("The menu items are the same - will not select anything");
		}

	}

	public void selectFromTabBar(String tabName) throws NoSuchElementException
	{
		pagelogger.debug("Selecting the following element from the Tab Bar (Top Frame): "+ tabName);

		clickOnElement(By.linkText(tabName));
	}

	public void showAllTabs()
	{
		clickOnElement(showAllTabsLocator);
	}

	public SalesCloudTopFrame verifyPageLoad()
	{
		pagelogger.debug("Waiting for page to load");

		SalesforcePageExtensions.waitForPageToLoad(driver);

		return this;
	}

	public void selectTab(String tabName)
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);

		String menuToSelect = "//ul[@id='tabBar']//a[contains(@title,'TabName')]";
		menuToSelect = menuToSelect.replace("TabName", tabName);

		clickOnElement(By.xpath(menuToSelect));
	}
}
