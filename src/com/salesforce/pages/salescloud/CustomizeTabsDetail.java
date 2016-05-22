package com.salesforce.pages.salescloud;

import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.Select;

import com.salesforce.pages.PageBase;

public class CustomizeTabsDetail extends PageBase
{

	private static CustomizeTabsDetail instance;
	public static CustomizeTabsDetail Instance = (instance != null) ? instance
			: new CustomizeTabsDetail();

	/** UI Mappings */

	By availableTabsSelectBoxLocator = By
			.xpath("//div/label[text()='Available Tabs']/following::select[1]");
	By addTabLocator = By.cssSelector("img[title='Add']");
	By saveTabChanges = By.cssSelector("input[title='Save']");
	By cancelTabChanges = By.cssSelector("input[title='Cancel']");

	/** Page Methods */

	public void verifyPageLoad()
	{
		findElement(saveTabChanges);
	}

	public void selectCustomApp(String tabName)
	{
		pagelogger.debug("Attempting select custom App: " + tabName);

		Select app = new Select(findElement(By.id("p4")));
		app.selectByVisibleText(tabName);
	}

	public boolean addTab(String tabName)
	{
		Boolean errFound = false;

		try
		{
			pagelogger.debug("Attempting to add the Tab: " + tabName);

			clickOnElement(By.cssSelector("option[value='" + tabName + "']"));
			clickOnElement(addTabLocator);
		} catch (Exception e)
		{
			e.printStackTrace();
			pagelogger.debug(e.toString());
			errFound = true;
		}

		if (errFound == false)
		{
			clickOnElement(saveTabChanges);
			pagelogger.debug("Saving tab changes");
		} else
		{
			clickOnElement(cancelTabChanges);
			pagelogger.debug("Canceling tab changes");

		}

		return errFound;
	}

	public boolean addMultipleTabs(String tabNames)
	{
		String[] tabArray = tabNames.split(",");
		Boolean errFound = false;

		try
		{
			for (int i = 0; i <= tabArray.length; i++)
			{
				pagelogger.debug("Attempting to add the Tab: " + tabArray[i].toString());

				clickOnElement(By.cssSelector("option[value='" + tabArray[i] + "']"));
				clickOnElement(addTabLocator);
			}

		} catch (Exception e)
		{
			e.printStackTrace();
			pagelogger.debug(e.toString());
			errFound = true;
		}

		if (errFound == false)
		{
			clickOnElement(saveTabChanges);
			pagelogger.debug("Saving tab changes");

		} else
		{
			clickOnElement(cancelTabChanges);
			PageBase.Instance.pagelogger.debug("Canceling tab changes");

		}

		return errFound;
	}

}
