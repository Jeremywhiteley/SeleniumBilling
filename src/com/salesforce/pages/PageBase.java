package com.salesforce.pages;

import java.util.ArrayList;
import java.util.List;

import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.custom.logger.CustomLogger;
import com.salesforce.utils.driver.DriverProvider;
import com.salesforce.utils.driver.SalesforcePageExtensions;

public class PageBase
{

	protected String URL;
	protected static WebDriver driver = DriverProvider.Driver.get();
	protected static final int DEFAULT_TIMEOUT = 90;
	public final CustomLogger pagelogger;

	private static PageBase instance;
	public static PageBase Instance = (instance != null) ? instance : new PageBase();

	public static void setDriver(WebDriver _driver)
	{
		driver = _driver;
	}

	protected String pageTitle;
	protected WebDriverWait defaultElementWait = new WebDriverWait(driver, 20);

	public PageBase()
	{
		this.pagelogger = new CustomLogger(this.getClass());
	}

	public PageBase(String pageTitle)
	{
		this();
		this.pageTitle = pageTitle;
	}

	public boolean isPageLoaded()
	{
		pagelogger.debug("Page title is: " + driver.getTitle());
		return (driver.getTitle().contains(pageTitle));
	}

	public void reloadPage()
	{
		driver.navigate().refresh();
	}

	public void open()
	{
		pagelogger.debug("Opening the page: " + "\"" + URL + "\"");
		driver.get(URL);
	}

	public void close()
	{
		pagelogger.debug("Closing the browser");
		driver.close();
	}

	public String getTitle()
	{
		pagelogger.debug("The page title is: " + "\"" + pageTitle + "\"");
		return pageTitle;
	}

	public String getURL()
	{
		pagelogger.debug("The requested URL is: " + URL);
		return URL;
	}

	protected void sendText(String cssSelector, String text)
	{
		findElement(By.cssSelector(cssSelector)).sendKeys(text);
	}

	public boolean isTextPresent(String text)
	{
		return driver.getPageSource().contains(text);
	}

	public boolean isElementPresent(By by)
	{
		try
		{
			WebElement element = findElement(by);
			return element.isDisplayed();
		} catch (NoSuchElementException e)
		{
			return false;
		}
	}

	public boolean isElementPresent(WebElement element)
	{
		try
		{
			return element.isDisplayed();
		} catch (NoSuchElementException e)
		{
			return false;
		}
	}

	public boolean isElementPresent(String _cssSelector)
	{
		try
		{
			findElement(By.cssSelector(_cssSelector));
			return true;
		} catch (NoSuchElementException e)
		{
			return false;
		}
	}

	public boolean isElementPresentAndDisplay(By by)
	{
		try
		{
			return findElement(by).isDisplayed();
		} catch (NoSuchElementException e)
		{
			return false;
		}
	}

	public WebElement getWebElement(By by)
	{
		return findElement(by);
	}

	public static boolean verifyPageNotLoading(WebDriver driver)
	{
		By loadingIndicator = By.xpath("//div[text()='Loading...']");

		int i = 0;
		boolean result = false;

		while (i < 30)
		{
			PageBase.Instance.pagelogger.debug("Checking page load status...");
			PageBase.Instance.pagelogger.debug("Current wait time is: " + i);
			result = ExpectedConditions.invisibilityOfElementLocated(loadingIndicator)
					.apply(driver);

			if (result == true)
			{
				PageBase.Instance.pagelogger
						.debug("Loading element is no longer visible. Continuing execution...");
				break;
			}

			i = i + 1;

		}

		return result;

	}

	/**
	 * Checks for the presence of the loading image commonly associated with
	 * tables loading within salesforce. In service cloud iframes also utilize
	 * this loading image (as opposed to the large Loading...overlay) with
	 * iframes. This function is a duplicate Core.verifyNotLoading that is
	 * associated with salescloud
	 * 
	 * @param driver
	 * @param timeToWait
	 * @return
	 */
	public static boolean verifyContextNotLoading(WebDriver driver, int timeToWait)
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
						.debug("Context Loading element is no longer visible. Continuing execution.");
				break;
			}

			i = i + 1;

		}

		return result;

	}

	public static void synchronize(int... timeout)
	{
		Boolean pageStatus = verifyPageNotLoading(driver);
		Boolean contextStatus = verifyContextNotLoading(driver, DEFAULT_TIMEOUT);

		if (pageStatus.equals(true) && contextStatus.equals(true))
		{
			SalesforcePageExtensions.waitForPageToLoad(driver);
		} else
		{
			PageBase.Instance.pagelogger
					.debug("The Page loading indicator did not disappear within the passed in time limit: "
							+ timeout);
		}

	}

	public static void clickOnElementIgnoreException(By element, int... timeout)
	{
		try
		{
			clickOnElement(element, timeout[0]);
		} catch (RuntimeException e)
		{
			PageBase.Instance.pagelogger
					.debug("Will Continue testcase as exception is ignored and expected.");
		}
	}

	public static WebElement findElementIgnoreException(By element, int... timeout)
	{
		try
		{
			return findElement(element, timeout[0]);
		} catch (RuntimeException e)
		{
			PageBase.Instance.pagelogger
					.debug("Will Continue testcase as exception is ignored and expected.");
		}
		return null;
	}

	public static List<WebElement> findElementsIgnoreException(By element, int... timeout)
	{
		int timeoutForFindElement = timeout.length < 1 ? DEFAULT_TIMEOUT : timeout[0];
		try
		{
			// synchronize();
			(new WebDriverWait(driver, timeoutForFindElement)).until(ExpectedConditions
					.presenceOfElementLocated(element));
			return driver.findElements(element);
		} catch (Exception e)
		{
			PageBase.Instance.pagelogger
					.debug("Will Continue testcase as exception is ignored and expected.");
			return new ArrayList<WebElement>();
		}
	}

	public static void clickOnElement(By element, int... timeout)
	{
		int timeoutForFindElement = timeout.length < 1 ? DEFAULT_TIMEOUT : timeout[0];
		try
		{
			(new WebDriverWait(driver, timeoutForFindElement)).until(ExpectedConditions
					.visibilityOfElementLocated(element));
			driver.findElement(element).click();
		} catch (Exception e)
		{
			throw new RuntimeException("Intermittent failure clicking on element");
		}
	}

	public static WebElement findElement(By element, int... timeout)
	{
		int timeoutForFindElement = timeout.length < 1 ? DEFAULT_TIMEOUT : timeout[0];
		try
		{
			// synchronize();
			(new WebDriverWait(driver, timeoutForFindElement)).until(ExpectedConditions
					.visibilityOfElementLocated(element));
			return driver.findElement(element);
		} catch (Exception e)
		{
			throw new RuntimeException("Intermittent failure finding on element");
		}
	}

	public static List<WebElement> findElements(By element, int... timeout)
	{
		int timeoutForFindElement = timeout.length < 1 ? DEFAULT_TIMEOUT : timeout[0];
		try
		{
			// synchronize();
			(new WebDriverWait(driver, timeoutForFindElement)).until(ExpectedConditions
					.presenceOfElementLocated(element));
			return driver.findElements(element);
		} catch (Exception e)
		{
			throw new RuntimeException("Intermittent failure finding elements");
		}
	}

	public static String getAttributeIDIgnoreExecption(By element, int... timeout)
	{
		try
		{
			return getAttributeID(element, timeout[0]);
		} catch (RuntimeException e)
		{
			PageBase.Instance.pagelogger
					.debug("Will Continue testcase as exception is ignored and expected.");
		}
		return null;
	}

	public static String getAttributeID(By element, int... timeout)
	{
		int timeoutForFindElement = timeout.length < 1 ? DEFAULT_TIMEOUT : timeout[0];
		try
		{
			synchronize();
			(new WebDriverWait(driver, timeoutForFindElement)).until(ExpectedConditions
					.visibilityOfElementLocated(element));
			String id = findElement(element).getAttribute("id");
			return id;
		} catch (Exception e)
		{
			throw new RuntimeException("Intermittent failure getting attribute id of an element");
		}
	}

	public static void setDriverContextToPage(WebDriver driver)
	{
		PageBase.Instance.pagelogger.debug("Setting the context mode to Page");
		driver.switchTo().defaultContent();
	}
}
