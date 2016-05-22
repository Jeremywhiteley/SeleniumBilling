package com.salesforce.pages.servicecloud.cases;

import java.util.Iterator;
import java.util.List;
import java.util.Set;

import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;

public class ServiceCloudChangeCaseOwner extends PageBase
{

	private static ServiceCloudChangeCaseOwner instance;
	public static ServiceCloudChangeCaseOwner Instance = (instance != null) ? instance
			: new ServiceCloudChangeCaseOwner();

	/** UI Mappings */

	public By contactLocator = By.xpath("//a[@title='Owner name']");
	public By saveButtonLocator = By.xpath("//input[@title='Save']");
	public By ownerQueueLocator = By
			.xpath("//label[contains(text(),'Owner')]/../following::select");
	By ownerNameTextBox = By.xpath("//input[@title='Owner name']");

	/** Page Methods */

	public ServiceCloudChangeCaseOwner changeOwner(String owner) throws InterruptedException
	{
		pagelogger.debug("Changing Owner.");

		new WebDriverWait(driver, 30).until(ExpectedConditions.titleContains(pageTitle));

		IframeUtils.setDriverContextToIframeWithDepth(driver, contactLocator);

		String id = getAttributeID(contactLocator);
		String mwh = driver.getWindowHandle();
		SalesforcePageExtensions.selectFromLookup(driver, owner, mwh, id);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudChangeCaseOwner enterOwnerNameDirectly(String owner)
	{
		pagelogger.debug("Entering owner name: " + owner);

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, ownerNameTextBox);

		findElement(ownerNameTextBox).clear();
		findElement(ownerNameTextBox).sendKeys(owner);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudCasesDetail clickOnSave()
	{

		IframeUtils.setDriverContextToIframeWithDepth(driver, saveButtonLocator);

		pagelogger.debug("Clicking on Save in case owner page.");

		clickOnElement(saveButtonLocator);

		setDriverContextToPage(driver);
		return ServiceCloudCasesDetail.Instance;
	}

	public ServiceCloudChangeCaseOwner selectOwnerQueue(String ownerQueue)
	{
		pagelogger.debug("Selecting owner queue.");

		SalesforcePageExtensions.waitForPageToLoad(driver);

		IframeUtils.setDriverContextToIframeWithDepth(driver, ownerQueueLocator);

		String id = getAttributeID(ownerQueueLocator);
		SalesforcePageExtensions.selectOption(driver, id, ownerQueue);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudChangeCaseOwner verifyPageLoad()
	{
		pagelogger.debug("Waiting for Service cloud change owner page to load");
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}

	public String getListOfInternalUserLookupColumns(String ownerName) throws InterruptedException
	{
		By lookupSearchBoxLocator = By.xpath("//form/descendant::div/input[@type='text']");
		By lookupGoLocator = By.xpath("//form/descendant::div/input[@type='submit']");
		By lookupSearchFrame = By.id("searchFrame");
		By lookupResultsFrame = By.id("resultsFrame");
		By lookupColumns = By.xpath("//div[@class='lookup']//tr[@class='headerRow']");

		pagelogger.debug("Invoking change owner contact lookup.");

		new WebDriverWait(driver, 30).until(ExpectedConditions.titleContains(pageTitle));

		IframeUtils.setDriverContextToIframeWithDepth(driver, contactLocator);

		String id = getAttributeID(contactLocator);
		String mwh = driver.getWindowHandle();
		final String[] valsArray = ownerName.split("\\,", -1);

		pagelogger.debug("Main window handle is: " + mwh);

		String columnHeaders = null;
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
				pagelogger.debug("~~~Current Window Handle is: " + popupHandle);

				if (!popupHandle.contains(mwh))
				{
					pagelogger.debug("New Window Handle is: " + popupHandle
							+ ". Now executing on pop-up Window");

					driver.switchTo().window(popupHandle);
					findElement(lookupSearchFrame);

					driver.switchTo().frame(findElement(lookupSearchFrame));
					findElement(lookupSearchBoxLocator, 5);
					findElement(lookupSearchBoxLocator).sendKeys(valsArray[0]);
					clickOnElement(lookupGoLocator);

					driver.switchTo().defaultContent();

					driver.switchTo().frame(findElement(lookupResultsFrame));

					columnHeaders = findElement(lookupColumns).getText();

					pagelogger.debug("Switching back to main Window: " + mwh);

					driver.switchTo().window(mwh);
				}

			}
		} else
		{
			throw new NoSuchElementException(
					"Could not locate the Lookup Button (to open new window) with the Locator ID: "
							+ id + ". Will not search for: " + valsArray[1]);
		}

		setDriverContextToPage(driver);
		return columnHeaders.replace(' ', ',');
	}

}
