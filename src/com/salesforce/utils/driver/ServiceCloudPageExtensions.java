package com.salesforce.utils.driver;

import java.util.List;

import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;

public class ServiceCloudPageExtensions extends PageBase
{

	public static String setDriverContextToIframeForLinkText(WebDriver driver, String text)
	{
		String val = "";
		driver.switchTo().defaultContent();
		List<WebElement> frameset = findElements(By.tagName("iframe"));

		PageBase.Instance.pagelogger.debug("Number of iframes found on current page: "
				+ frameset.size());

		for (int i = 0; i < frameset.size(); i++)
		{

			String id = frameset.get(i).getAttribute("id");
			PageBase.Instance.pagelogger.debug("Switching and attempting to interact with frame: "
					+ id);
			driver.switchTo().frame(id);

			if (findElements(By.linkText(text)).size() != 0)
			{
				PageBase.Instance.pagelogger.debug("Found it");
				val = id;
				break;
			} else
			{
				PageBase.Instance.pagelogger.debug("Didnt find it");
				driver.switchTo().defaultContent();
			}
		}

		if (val.equals(""))
		{
			PageBase.Instance.pagelogger
					.debug("Warning - no frames were found which can interact with the passed in control. Execution will probably fail!");
		}

		return val;
	}

	public static void selectNavigatorTab(WebDriver driver, String tabName)
	{
		PageBase.Instance.pagelogger
				.debug("Selecting the following tab from the main Service Cloud Navigation Tab Bar: "
						+ tabName);
		List<WebElement> elements = driver
				.findElements(By
						.xpath("//div[@id='navigatortab']/descendant::ul[1]/descendant::span/descendant::span[@class='tabText']"));
		PageBase.Instance.pagelogger.debug("index is: " + elements.size());

		for (WebElement element : elements)
		{
			PageBase.Instance.pagelogger.debug("Current <span> is: " + element.getText()
					+ " Comparing with passed in value: " + tabName);

			if (element.getText().toUpperCase().equals(tabName.toUpperCase()))
			{
				PageBase.Instance.pagelogger.debug("Found a match - clicking link");
				clickOnElement(By.linkText(tabName));
			}
		}

	}

	public static void selectFromOverlayList(WebDriver driver, By element, String item)
	{

		By linkToSelect = By.linkText(item);

		synchronize(30);

		new WebDriverWait(driver, 30).until(ExpectedConditions.visibilityOfElementLocated(element));

		PageBase.Instance.pagelogger.debug("Click on filter element: "
				+ findElement(element).getText());
		clickOnElement(element);

		List<WebElement> filterValues = findElements(By.xpath("//ul/li/a[@title='" + item + "']"));
		PageBase.Instance.pagelogger.debug("Number of filter items found: " + filterValues.size());

		if (!(filterValues.size() < 1))
		{
			new WebDriverWait(driver, 30).until(ExpectedConditions
					.visibilityOfElementLocated(linkToSelect));

			PageBase.Instance.pagelogger.debug("Selecting filter value: " + item);
			clickOnElement(linkToSelect);
		} else
		{
			PageBase.Instance.pagelogger
					.debug("The overlay list did not contain the item: " + item);
		}

	}

	public static String getDetailHeader(WebDriver driver, By articleHeaderLocator,
			By altArticleHeaderLocator)
	{
		String val = "";

		PageBase.Instance.pagelogger.debug("Getting the searched items' header...");

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, articleHeaderLocator);

		if (findElements(altArticleHeaderLocator).size() > 0)
		{
			PageBase.Instance.pagelogger
					.debug("Found an <h2> element - will get its text as the searched items' header");
			new WebDriverWait(driver, 30).until(ExpectedConditions
					.visibilityOfElementLocated(altArticleHeaderLocator));
			val = findElement(altArticleHeaderLocator).getText();
		} else
		{
			PageBase.Instance.pagelogger
					.debug("Did not an <h2> element - will get searched items' header text as <h1>");
			new WebDriverWait(driver, 30).until(ExpectedConditions
					.visibilityOfElementLocated(articleHeaderLocator));
			val = findElement(articleHeaderLocator).getText();
		}

		PageBase.Instance.pagelogger.debug("The header returned as: " + val);

		setDriverContextToPage(driver);
		return val;

	}

	public static void closeAllNavigatorTabs(WebDriver driver)
	{

		PageBase.Instance.pagelogger.debug("Closing all Service Cloud navigation tabs...");

		By tabMenuLocator = By.xpath("//div[@class='x-tab-tabmenu-right']");
		By closeTabsLinkLocator = By.xpath("//a/span[text()='Close all primary tabs']");

		clickOnElementIgnoreException(tabMenuLocator, 10);

		By closeTabsLinkStatus = By.xpath("//a/span[text()='Close all primary tabs']/..");
		String isUnselectable = getAttributeIDIgnoreExecption(closeTabsLinkStatus, 10);

		if (isUnselectable != null && isUnselectable.equals("off"))
		{
			PageBase.Instance.pagelogger
					.debug("The close all tabs link is active. Will click it...");
			clickOnElementIgnoreException(closeTabsLinkLocator, 10);

			try
			{
				By dontSaveButton = By.xpath("//button[contains(text(),'Don')]");
				IframeUtils.setDriverContextToIframeWithDepth(driver, dontSaveButton);

				clickOnElementIgnoreException(dontSaveButton, 10);

				setDriverContextToPage(driver);

			} catch (NoSuchElementException e)
			{
				PageBase.Instance.pagelogger
						.debug("No Modal dialog found to disrupt the page. Test will continue");
			}

		} else
		{
			PageBase.Instance.pagelogger.debug("The close tabs link was inactive. Skipping...");
		}
		setDriverContextToPage(driver);

	}
}