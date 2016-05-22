package com.salesforce.utils.driver;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import java.util.concurrent.TimeUnit;

import org.openqa.selenium.Alert;
import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.StaleElementReferenceException;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.support.ui.ExpectedCondition;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.Select;
import org.openqa.selenium.support.ui.Wait;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.CommonMethods;

public class SalesforcePageExtensions extends PageBase
{

	/**
	 * Enter value into standard Input box
	 * 
	 * @param driver
	 * @param id
	 * @param val
	 */
	public static void enterInputValue(WebDriver driver, String id, String val)
	{

		List<WebElement> elements = null;
		elements = findElements(By.id(id));

		if (!elements.isEmpty())
		{
			findElement(By.id(id)).clear();
			findElement(By.id(id)).sendKeys(val);
		} else
		{
			throw new NoSuchElementException(
					"Could not locate the Input Element with the Locator ID: " + id
							+ " Entry of Value: " + val + " failed.");
		}
	}

	/**
	 * Select an <option> from a <select> WebElement
	 * 
	 * @param driver
	 * @param selectName
	 * @param optionName
	 */
	public static boolean selectOption(WebDriver driver, String id, String optionName)
	{
		PageBase.Instance.pagelogger
				.debug("Selecting the following Option from the passed in dropdown: " + optionName);

		boolean val = false;
		boolean useXpath = false;
		List<WebElement> elements = null;
		elements = findElements(By.id(id));

		if (elements.isEmpty())
		{
			elements = findElements(By.xpath(id));
			useXpath = true;
		}

		if (!elements.isEmpty())
		{
			WebElement select;

			if (useXpath)
			{
				select = findElement(By.xpath(id));
			} else
			{
				select = findElement(By.id(id));
			}

			Select dropdown = new Select(select);

			List<WebElement> Options = dropdown.getOptions();

			PageBase.Instance.pagelogger.debug("The number of options found in the <select> is: "
					+ Options.size());

			for (WebElement option : Options)
			{
				PageBase.Instance.pagelogger.debug("Current <option> value being compared is: "
						+ option.getText().trim() + " --> Comparing against: " + optionName);

				if (option.getText().trim().equals(optionName))
				{
					PageBase.Instance.pagelogger.debug("Found the select option we want");
					option.click();
					val = true;
					break;
				}
			}

		} else
		{
			throw new NoSuchElementException("Could not locate the <select> Element with the id: "
					+ id + " Selection of <option>: " + optionName + " failed.");
		}

		if (val == false)
		{
			PageBase.Instance.pagelogger.debug("No Option values could be matched!");
			throw new NoSuchElementException(
					"Could not locate the passed in <select> option value with the name: "
							+ optionName + " Selection of <option>: " + optionName + " failed.");
		}
		return val;
	}

	/**
	 * Select an <option> from a Multi-Select <select> within SALESFORCE
	 * 
	 * @param driver
	 * @param selectName
	 * @param id
	 * @param optionName
	 */
	public static void selectPicklistValue(WebDriver driver, String id, String optionName)
	{

		String leftBox = id + "_unselected";
		String addArrow = id + "_right_arrow";

		List<WebElement> elements = null;
		elements = findElements(By.id(id));

		if (!elements.isEmpty())
		{
			WebElement select = findElement(By.id(leftBox));
			Select picklist = new Select(select);
			List<WebElement> Options = picklist.getOptions();

			for (WebElement option : Options)
			{
				if (option.getText().equals(optionName))
				{
					PageBase.Instance.pagelogger.debug("Selecting value from Picklist: "
							+ optionName);
					option.click();
					clickOnElement(By.id(addArrow));
					break;
				}
			}
		} else
		{
			throw new NoSuchElementException(
					"Could not locate the Select Element with the Locator ID: " + id
							+ " Entry of Value: " + optionName + " failed.");
		}

	}

	/**
	 * Search and select a value within a Pop-Up Window associated with a Lookup
	 * within SALESFORCE
	 * 
	 * @throws InterruptedException
	 */
	public static void selectFromLookup(WebDriver driver, String vals, String mwh, String id)
			throws InterruptedException
	{
		By lookupSearchBoxLocator = By.xpath("//form/descendant::div/input[@type='text']");
		By lookupGoLocator = By.xpath("//form/descendant::div/input[@type='submit']");
		By lookupSearchFrame = By.id("searchFrame");
		By lookupResultsFrame = By.id("resultsFrame");
		final String[] valsArray = vals.split("\\,", -1);

		PageBase.Instance.pagelogger.debug("Main window handle is: " + mwh);

		List<WebElement> elements = null;
		elements = findElements(By.id(id));

		if (!elements.isEmpty())
		{
			clickOnElement(By.id(id));
			Set<String> s = driver.getWindowHandles();
			Iterator<String> ite = s.iterator();

			while (ite.hasNext())
			{
				String popupHandle = ite.next().toString();
				PageBase.Instance.pagelogger.debug("Current window handle is: " + popupHandle);

				if (!popupHandle.contains(mwh))
				{
					PageBase.Instance.pagelogger.debug("New window handle is: " + popupHandle
							+ ". Now executing on pop-up window...");
					PageBase.Instance.pagelogger.debug("Now executing on pop-up window...");

					driver.switchTo().window(popupHandle);

					findElement(lookupSearchFrame);
					driver.switchTo().frame(findElement(lookupSearchFrame));

					findElement(lookupSearchBoxLocator);
					findElement(lookupSearchBoxLocator).sendKeys(valsArray[0]);
					clickOnElement(lookupGoLocator);
					driver.switchTo().defaultContent();
					driver.switchTo().frame(findElement(lookupResultsFrame));

					PageBase.Instance.pagelogger.debug("Selecting search result value: "
							+ valsArray[0]);
					clickOnElement(By.linkText(valsArray[1].trim()));

					PageBase.Instance.pagelogger.debug("Switching back to main window: " + mwh);
					driver.switchTo().window(mwh);
				}

			}
		} else
		{
			throw new NoSuchElementException(
					"Could not locate the Lookup Button (to open new window) with the Locator ID: "
							+ id + ". Will not search for: " + valsArray[1]);
		}

	}

	/**
	 * Search and select a value within a Pop-Up Window associated with a Lookup
	 * within SALESFORCE
	 * 
	 * @throws InterruptedException
	 */
	public static void selectFromComboBoxLookup(WebDriver driver, String linkToSelect, String mwh)
			throws InterruptedException
	{
		By popupLinkToSelect = By.linkText(linkToSelect);

		Set<String> s = driver.getWindowHandles();
		Iterator<String> iterate = s.iterator();

		while (iterate.hasNext())
		{
			String popupHandle = iterate.next().toString();
			PageBase.Instance.pagelogger.debug("Current Window Handle is: " + popupHandle);

			if (!popupHandle.contains(mwh))
			{
				PageBase.Instance.pagelogger.debug("New Window Handle is: " + popupHandle
						+ ". Now executing on pop-up Window");
				driver.switchTo().window(popupHandle);

				PageBase.Instance.pagelogger.debug("Selecting link in new window: " + linkToSelect);
				clickOnElement(popupLinkToSelect);

				PageBase.Instance.pagelogger.debug("Switching back to main window: " + mwh);
				driver.switchTo().window(mwh);
			}
		}

	}

	public static void selectFromTreeStructuredLookup(WebDriver driver, List<String> linkToSelect,
			String mwh) throws InterruptedException
	{
		Set<String> s = driver.getWindowHandles();
		Iterator<String> iterate = s.iterator();

		while (iterate.hasNext())
		{
			String popupHandle = iterate.next().toString();

			PageBase.Instance.pagelogger.debug("Current Window Handle is: " + popupHandle);

			By okButton = By.xpath("//button[text()='OK']");

			if (!popupHandle.contains(mwh))
			{
				PageBase.Instance.pagelogger.debug("New Window Handle is: " + popupHandle
						+ ". Now executing on pop-up Window");
				driver.switchTo().window(popupHandle);

				By popupLinkToSelect;
				By addDomainButton = By.xpath("//table[@id='addCategory']//button");

				for (String link : linkToSelect)
				{
					popupLinkToSelect = By.xpath("//span[text()='" + link + "']");

					new WebDriverWait(driver, 30).until(ExpectedConditions
							.presenceOfElementLocated(popupLinkToSelect));

					PageBase.Instance.pagelogger.debug("Selecting link in new window: "
							+ linkToSelect);
					clickOnElement(popupLinkToSelect);
					clickOnElement(addDomainButton);

				}
				clickOnElement(okButton);

				PageBase.Instance.pagelogger.debug("Switching back to main window: " + mwh);

				driver.switchTo().window(mwh);
			}
		}

	}

	/**
	 * Check or Un-check a Checkbox
	 * 
	 * @param driver
	 * @param by
	 * @param status
	 *            On/Off
	 */
	public static void selectCheckbox(WebDriver driver, String id, String status)
	{
		List<WebElement> elements = null;
		elements = findElements(By.id(id));

		if (!elements.isEmpty())
		{

			if (status.toUpperCase().equals("ON"))
			{

				if (!findElement(By.id(id)).isSelected())
				{
					PageBase.Instance.pagelogger.debug("Checking the passed in checkbox");
					clickOnElement(By.id(id));
				}

			} else if (status.toUpperCase().equals("OFF"))
			{

				if (findElement(By.id(id)).isSelected())
				{
					PageBase.Instance.pagelogger.debug("Unchecking the passed in checkbox");
					clickOnElement(By.id(id));
				}
			}

		} else
		{
			throw new NoSuchElementException(
					"Could not locate the Checkbox Element with the Locator ID: " + id);
		}

	}

	public static String getCurrentSelectOption(By by)
	{
		Select select = new Select(findElement(by));
		WebElement option = select.getFirstSelectedOption();

		PageBase.Instance.pagelogger.debug("The current value of the <select> is: "
				+ option.getText());

		String val = option.getText();

		return val;

	}

	/**
	 * Method used to get the number of pages associated with a data table
	 * within SALESFORCE. Only to be used with record tables in SALESFORCE
	 * 
	 * @param driver
	 * @return: Number of pages of tabular data in SALESFORCE
	 */
	public static int getNumberOfRecordPages(WebDriver driver)
	{
		String val = "";
		By numOfRecordPagesLocator = By.xpath("//span[@class='right']");

		int index = -1;
		int rtrn = -1;

		BrowserExtensions.verifyNotLoading(driver, 30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, numOfRecordPagesLocator);
		val = findElement(numOfRecordPagesLocator).getText();

		PageBase.Instance.pagelogger.debug("The Number of Pages locator text is" + val);
		index = val.indexOf("of ");

		if (index != -1)
		{
			rtrn = Integer.parseInt(val.substring(index + 3).trim());
		} else
		{
			PageBase.Instance.pagelogger.debug("Couldnt find the number of pages locator");
			rtrn = -1;
		}

		return rtrn;
	}

	/**
	 * Method used to select a record for a SALESFORCE table. NOTE: Uses
	 * linktext currently instead of column names/rows. In the event of multiple
	 * entries of the record text, the first value will be selected. NOTE: May
	 * want to improve this function to look based upon a certain column
	 * -JDAPPER NOTE: Use appropriate test data that does not have multiple
	 * entries to ensure proper test flow -JDAPPER
	 * 
	 * @param driver
	 * @param searchValue
	 *            : Value to search for within the record table
	 * @return
	 */
	public static boolean selectFromRecordTable(WebDriver driver, String searchValue)
	{
		BrowserExtensions.juggleBrowserSize(driver);

		boolean val = false;
		By nextLocator = By.linkText("Next");
		int nextCounter = 0;

		do
		{
			if (nextCounter != 0)
			{
				int attempts = 0;
				while (attempts < 2)
				{

					try
					{
						clickOnElement(nextLocator);
						break;
					} catch (StaleElementReferenceException e)
					{
					}

					attempts++;
				}

			}

			BrowserExtensions.verifyNotLoading(driver, 30);

			List<WebElement> elements = null;
			elements = findElements(By.linkText(searchValue));

			if (!elements.isEmpty())
			{
				PageBase.Instance.pagelogger.debug("Found the table value: " + searchValue);
				int attempts = 0;

				while (attempts < 2)
				{
					try
					{
						clickOnElement(By.linkText(searchValue));
						break;
					} catch (StaleElementReferenceException e)
					{
					}

					attempts++;
				}

				val = true;
				break;
			} else
			{
				PageBase.Instance.pagelogger.debug("DID NOT find table value: " + searchValue
						+ " Will loop back!");

			}
			nextCounter++;

		} while (findElements(nextLocator).size() > 0);

		if (val == false)
		{
			PageBase.Instance.pagelogger.debug("ERROR: Table value was not found: " + searchValue);
		}

		return val;
	}

	/**
	 * Method used to return a record from a SALESFORCE table based upon column
	 * class ID. Search record table for a value then find an associated column
	 * value Note: The following column value must come AFTER the searched for
	 * table value within the DOM
	 * 
	 * @param driver
	 * @param searchValue
	 *            : Value to search for within the record table
	 * @param columnID
	 *            : Possible values->Leads:
	 *            LEAD_STATUS,LEAD_EMAIL,LEAD_PHONE,LEAD_COMPANY
	 * @param columnID
	 *            : Possible values->Cases:
	 * @return
	 */
	public static String getRecordTableColumnValue(WebDriver driver, String searchValue,
			String columnID)
	{
		BrowserExtensions.juggleBrowserSize(driver);
		int numOfPages = SalesforcePageExtensions.getNumberOfRecordPages(driver);
		String val = "";
		By nextLocator = By.linkText("Next");

		if (numOfPages != -1)
		{

			for (int i = 1; i <= numOfPages; i++)
			{
				BrowserExtensions.verifyNotLoading(driver, 30);

				List<WebElement> elements = null;
				elements = findElements(By.linkText(searchValue));

				if (!elements.isEmpty())
				{
					PageBase.Instance.pagelogger
							.debug("Found the table value - getting value for column with partial class id: "
									+ columnID);
					val = findElement(
							By.xpath("//tr/td/descendant::a/span[text()='" + searchValue
									+ "']/following::td[contains(@class, '" + columnID
									+ "')][1]/div")).getText();
					PageBase.Instance.pagelogger.debug("Found column value is: " + val);
					break;
				} else
				{
					PageBase.Instance.pagelogger.debug("DID NOT find table value: " + searchValue
							+ " Will loop back!");
					if (i == numOfPages)
					{
						val = "";
					}

					findElement(nextLocator);
					clickOnElement(nextLocator);
				}

			}
		}

		if (val.equals(""))
		{
			PageBase.Instance.pagelogger
					.debug("ERROR: Table Column was not found with the passed in partial class id: "
							+ columnID);
		}

		return val;
	}

	/**
	 * Method used to checkmark a record within a SALESFORCE table. NOTE: Use
	 * appropriate test data that does not have multiple entries to ensure
	 * proper test flow -JDAPPER
	 * 
	 * @param driver
	 * @param accountName
	 *            : Value to search for within the record table
	 * @return
	 */
	public static boolean checkmarkRecordFromRecordTable(WebDriver driver, String accountName)
	{
		BrowserExtensions.juggleBrowserSize(driver);
		int numOfPages = SalesforcePageExtensions.getNumberOfRecordPages(driver);
		boolean val = false;
		By nextLocator = By.linkText("Next");

		if (numOfPages != -1)
		{

			for (int i = 0; i < numOfPages; i++)
			{
				BrowserExtensions.verifyNotLoading(driver, 30);
				PageBase.Instance.pagelogger
						.debug("Number of pages in the table is: " + numOfPages);

				List<WebElement> elements = null;
				elements = findElements(By.xpath("//tr/td/descendant::a/span[text()='"
						+ accountName + "']/../../../../td/descendant::input[@type='checkbox']"));

				if (!elements.isEmpty())
				{
					PageBase.Instance.pagelogger.debug("Found the table value: " + accountName);
					elements.get(i).click();
					val = true;
					break;
				} else
				{
					PageBase.Instance.pagelogger.debug("DID NOT find table value: " + accountName
							+ " Will loop back!");

					if (numOfPages > 1)
					{
						clickOnElement(nextLocator);
					}
				}

			}
		}

		if (val == false)
		{
			PageBase.Instance.pagelogger.debug("ERROR: Table value was not found: " + accountName);
		}

		return val;
	}

	public static boolean checkmarkCaseRecordFromRecordTable(WebDriver driver, String accountName)
	{
		BrowserExtensions.juggleBrowserSize(driver);
		int numOfPages = SalesforcePageExtensions.getNumberOfRecordPages(driver);
		boolean val = false;
		By nextLocator = By.linkText("Next");

		if (numOfPages != -1)
		{

			for (int i = 0; i < numOfPages; i++)
			{

				BrowserExtensions.verifyNotLoading(driver, 30);
				PageBase.Instance.pagelogger
						.debug("Number of pages in the table is: " + numOfPages);

				List<WebElement> elements = null;
				elements = findElements(By.xpath("//a[text()='" + accountName
						+ "']/../../..//input[@type='checkbox']"));

				if (!elements.isEmpty())
				{
					PageBase.Instance.pagelogger.debug("Found the table value: " + accountName);
					elements.get(i).click();
					val = true;
					break;
				} else
				{
					PageBase.Instance.pagelogger.debug("DID NOT find table value: " + accountName
							+ " Will loop back!");

					if (numOfPages > 1)
					{
						clickOnElement(nextLocator);
					}
				}

			}
		}

		if (val == false)
		{
			PageBase.Instance.pagelogger.debug("ERROR: Table value was not found: " + accountName);
		}

		return val;
	}

	/**
	 * Method used to sort a SALESFORCE record table by a alphabetic character.
	 * Expects the alphabetic selector to be available, which it essentially
	 * always is within SALESFORCE
	 * 
	 * @param driver
	 * @param letter
	 *            : Letter to sort the table contents by
	 */
	public static void sortRecordTableByLetter(WebDriver driver, String letter)
	{
		BrowserExtensions.verifyNotLoading(driver, 30);

		PageBase.Instance.pagelogger.debug("Sorting Activity contents by letter: " + letter);
		clickOnElement(By.linkText(letter.toUpperCase().trim()));
	}

	/**
	 * Method used to select a string from a vertically expanding table/page
	 * NOTE: May want to rename this method as some pages contain elements that
	 * can be expanded that are not specifically tables Note: May want to make
	 * this slightly less generic/generate smaller more specific functions as
	 * any linktext will be selected as soon as it is found. In the event of
	 * multiple linktexts found the first will be selected. -JDAPPER
	 * 
	 * @param driver
	 * @param searchValue
	 *            : Linktext to look for and select
	 * @return
	 */
	public static boolean selectFromVerticallyExpandingTable(WebDriver driver, String searchValue)
	{
		boolean val = false;
		By nextLocator = By.linkText("more");
		boolean moreFlag = true;

		BrowserExtensions.verifyNotLoading(driver, 30);

		List<WebElement> elements = null;
		elements = findElements(By.linkText(searchValue));

		while (moreFlag != false)
		{

			if (!elements.isEmpty())
			{
				PageBase.Instance.pagelogger.debug("found table value");
				clickOnElement(By.linkText(searchValue));
				val = true;
				break;
			} else
			{

				try
				{
					PageBase.Instance.pagelogger.debug("Did not find the search value: "
							+ searchValue + "Clicking on the more button");
					clickOnElement(nextLocator);
				} catch (NoSuchElementException e)
				{
					PageBase.Instance.pagelogger
							.debug("More button was not found - exiting function - Search Value: "
									+ searchValue + " will not be found");
					moreFlag = false;
				}
			}
		}

		return val;
	}

	/**
	 * Method used to get ALL labels on the given page. Currently there are 4
	 * xpaths necessary to get every single element. No other specific xpaths
	 * have been determined necessary at this time.
	 * 
	 * @param driver
	 * @return: All labels on a specific page as a List object
	 */
	public static List<String> returnAllLabelsAsList(WebDriver driver)
	{

		PageBase.Instance.pagelogger.debug("Returning all page field labels as a List<String>");

		String temp = "";
		List<String> labelList = new ArrayList<String>();

		List<WebElement> deepElements = null;
		IframeUtils.setDriverContextToIframeWithDepth(driver, By.xpath("//td/span/label"));
		deepElements = findElements(By.xpath("//td/span/label"));

		for (WebElement element : deepElements)
		{
			temp = element.getText().toString();

			if (!temp.trim().toString().equals(""))
			{
				labelList.add(temp);
			}

		}

		setDriverContextToPage(driver);

		List<WebElement> shallowElements = null;
		IframeUtils.setDriverContextToIframeWithDepth(driver, By.xpath("//td/label"));
		shallowElements = findElements(By.xpath("//td/label"));

		for (WebElement selement : shallowElements)
		{
			temp = selement.getText().toString();

			if (!temp.trim().toString().equals(""))
			{
				labelList.add(temp);
			}

		}

		setDriverContextToPage(driver);

		List<WebElement> deepHeaderElements = null;
		IframeUtils.setDriverContextToIframeWithDepth(driver, By.xpath("//th/span/label"));
		deepHeaderElements = findElements(By.xpath("//th/span/label"));

		for (WebElement dthelement : deepHeaderElements)
		{
			temp = dthelement.getText().toString();

			if (!temp.trim().toString().equals(""))
			{
				labelList.add(temp);
			}

		}

		setDriverContextToPage(driver);

		List<WebElement> shallowHeaderElements = null;
		IframeUtils.setDriverContextToIframeWithDepth(driver, By.xpath("//th/label"));
		shallowHeaderElements = findElements(By.xpath("//th/label"));

		for (WebElement sthselement : shallowHeaderElements)
		{
			temp = sthselement.getText().toString();

			if (!temp.trim().toString().equals(""))
			{
				labelList.add(temp);
			}

		}

		setDriverContextToPage(driver);

		List<WebElement> tdElements = null;
		IframeUtils.setDriverContextToIframeWithDepth(driver,
				By.xpath("//tr/td[@class='labelCol']"));
		tdElements = findElements(By.xpath("//tr/td[@class='labelCol']"));

		for (WebElement tdelement : tdElements)
		{
			temp = tdelement.getText().toString();

			if (!temp.trim().toString().equals(""))
			{
				labelList.add(temp);
			}
		}

		setDriverContextToPage(driver);

		List<WebElement> tdLastElements = null;
		IframeUtils.setDriverContextToIframeWithDepth(driver,
				By.xpath("//tr/td[@class='labelCol last']"));
		tdLastElements = findElements(By.xpath("//tr/td[@class='labelCol last']"));

		for (WebElement lastelement : tdLastElements)
		{
			temp = lastelement.getText().toString();

			if (!temp.trim().toString().equals(""))
			{
				labelList.add(temp);
			}
		}

		setDriverContextToPage(driver);

		CommonMethods.sortListAlphabetically(labelList);

		return labelList;
	}

	/**
	 * Method used to get ALL REQUIRED fields on the given page. Currently there
	 * are 2 xpaths necessary to get every single element. No other specific
	 * xpaths have been determined necessary at this time.
	 * 
	 * @param driver
	 * @return: All required fields on a specific page as a List object
	 */
	public static List<String> returnAllRequiredFieldsAsList(WebDriver driver)
	{
		String temp = "";
		List<String> labelList = new ArrayList<String>();

		List<WebElement> reqElementsLabel = null;
		reqElementsLabel = findElements(By.xpath("//tr/td[@class='labelCol requiredInput']/label"));

		List<WebElement> reqElementsLabelSpan = null;
		reqElementsLabelSpan = findElements(By
				.xpath("//tr/td[@class='labelCol requiredInput']/span/label"));

		for (WebElement element : reqElementsLabel)
		{
			PageBase.Instance.pagelogger.debug("Found Required Field: "
					+ element.getText().trim().toString());
			temp = element.getText().toString();
			labelList.add(temp);
		}

		for (WebElement selement : reqElementsLabelSpan)
		{
			PageBase.Instance.pagelogger.debug("Found Required Field: "
					+ selement.getText().trim().toString());
			temp = selement.getText().toString();
			labelList.add(temp);
		}

		CommonMethods.sortListAlphabetically(labelList);

		return labelList;
	}

	/**
	 * Method used to return all option values associated with a passed in
	 * <select>
	 * 
	 * @param driver
	 * @param parent
	 * @return: All <options> sorted alphabetically
	 */
	public static List<String> returnSelectOptionsAsList(WebDriver driver, By parent)
	{
		List<String> labelList = new ArrayList<String>();

		WebElement select = findElement(parent);
		Select dropdown = new Select(select);
		List<WebElement> Options = dropdown.getOptions();

		PageBase.Instance.pagelogger.debug("The number of options found in the <select> is: "
				+ Options.size());

		for (WebElement option : Options)
		{
			labelList.add(option.getText());
		}

		CommonMethods.sortListAlphabetically(labelList);

		return labelList;

	}

	/**
	 * Method used to return all SALESFORCE picklist option values associated
	 * with a passed in <select>
	 * 
	 * @param driver
	 * @param parent
	 * @return: All <options> sorted alphabetically
	 */
	public static List<String> returnPicklistOptionsAsList(WebDriver driver, By parent)
	{
		List<String> labelList = new ArrayList<String>();
		IframeUtils.setDriverContextToIframeWithDepth(driver, parent);
		WebElement select = findElement(parent);
		Select picklist = new Select(select);

		List<WebElement> webElement = picklist.getOptions();

		for (int i = 0; i < webElement.size(); i++)
		{
			labelList.add(webElement.get(i).getText());
		}

		CommonMethods.sortListAlphabetically(labelList);

		return labelList;
	}

	/**
	 * Method used to edit a value on the record detail page (do not need to
	 * EDIT the record first, even though that is a perfectly ok way of doing
	 * things). This does not update the value of the record, only 'double
	 * click' it so that it is able to be acted upon
	 * 
	 * @param driver
	 * @param id
	 */
	public static void editInlineTD(WebDriver driver, String id)
	{
		WebElement element = findElement(By.id(id));

		PageBase.Instance.pagelogger
				.debug("Double-clicking to enable editing of the <td> with the id: " + id);

		Actions action = new Actions(driver);
		action.moveToElement(element).doubleClick().build().perform();
	}

	/**
	 * Method used to automatically click accept on any modal Yes/No Accept/Deny
	 * modal dialogs
	 * 
	 * @param driver
	 */
	public static void acceptModalDialog(WebDriver driver)
	{
		PageBase.Instance.pagelogger.debug("Auto-Accepting a modal dialog!");

		Alert alert = driver.switchTo().alert();
		alert.accept();
	}

	/**
	 * Method used to determine whether a page has finished loading dynamic
	 * assets based upon the JavaScript readyState property
	 * 
	 * @param driver
	 */
	public static void waitForPageToLoad(WebDriver driver)
	{
		PageBase.Instance.pagelogger.debug("Waiting for page to load!");

		ExpectedCondition<Boolean> expectation = new ExpectedCondition<Boolean>() {

			public Boolean apply(WebDriver driver)
			{
				return ((JavascriptExecutor) driver).executeScript("return document.readyState")
						.equals("complete");
			}

		};

		Wait<WebDriver> wait = new WebDriverWait(driver, 10);

		try
		{
			wait.until(expectation);
			PageBase.Instance.pagelogger.debug("Returned a ready state of complete");
		} catch (Throwable error)
		{
			PageBase.Instance.pagelogger
					.debug("JavaScript readyState query timeout - The page has not finished loading. This may cause the test to fail!");
		}
	}

	/**
	 * All-encompassing function that can determine the corresponding id of an
	 * element within BASE SALESFORCE ONLY through the use of labels. Only
	 * elements that have corresponding labels will return properly
	 * 
	 * @param driver
	 * @param labelName
	 *            : Name of label that has a corresponding element whos' id you
	 *            want
	 * @return: id (as String) of the element found
	 */
	public static String getControlIDByXpath(WebDriver driver, String labelName)
	{
		String val = "";
		driver.manage().timeouts().implicitlyWait((long) .2, TimeUnit.SECONDS);

		List<WebElement> elementsFPath = findElementsIgnoreException(By
				.xpath("//td/span/label[text()='" + labelName + "']"));
		List<WebElement> elementsSPath = findElementsIgnoreException(By.xpath("//td/label[text()='"
				+ labelName + "']"));
		List<WebElement> elementsDPath = findElementsIgnoreException(By
				.xpath("//div/span/label[text()='" + labelName + "']"));

		if (elementsFPath.size() > 0)
		{
			val = findElement(By.xpath("//td/span/label[text()='" + labelName + "']"))
					.getAttribute("for");
			PageBase.Instance.pagelogger.debug("Got class name for the input by using XPath: "
					+ val.toString());
		} else if (elementsSPath.size() > 0)
		{
			val = findElement(By.xpath("//td/label[text()='" + labelName + "']")).getAttribute(
					"for");
			PageBase.Instance.pagelogger
					.debug("Had to use alternate DOM structure to get the class name for the input. Input class is: "
							+ val.toString());
		} else if (elementsDPath.size() > 0)
		{
			val = findElement(By.xpath("//div/span/label[text()='" + labelName + "']"))
					.getAttribute("for");
			PageBase.Instance.pagelogger
					.debug("Had to use alternate DOM structure to get the class name for the input within a DIV. Input class is: "
							+ val.toString());
		} else
		{
			PageBase.Instance.pagelogger
					.debug("ERORR: COULD NOT FIND A PASSED IN FIELD WITH THE NAME: " + labelName);

			throw new NoSuchElementException(
					"Could not map the ID for the Input Element using the Label Name: " + labelName
							+ " Entry of Value: " + val + " failed.");
		}

		driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
		return val;

	}
}