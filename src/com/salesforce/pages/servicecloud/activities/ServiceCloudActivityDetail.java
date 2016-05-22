package com.salesforce.pages.servicecloud.activities;

import java.util.List;

import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;

public class ServiceCloudActivityDetail extends PageBase
{

	private static ServiceCloudActivityDetail instance;
	public static ServiceCloudActivityDetail Instance = (instance != null) ? instance
			: new ServiceCloudActivityDetail();

	/** UI Mappings */

	By editButtonLocator = By.xpath("//td[@id='topButtonRow']/descendant::input[@name='edit'][1]");
	By activityHeaderLocator = By.xpath("//h1[text()='Activity']");
	By activityNo = By.xpath("//td[contains(text(),'Activity Number')]/following::td");
	String currentActiveCaseTab = "//span[contains(text(),'{AN}')]/../../../../../../li[contains(@class,'strip-active')]/a[contains(@class,'close')]";
	By fcrCheckboxChecked = By
			.xpath("//h2[text()='Activity Detail']/../../../../../..//td[text()='FCR']/../td[contains(@class,'dataCol')]//img");
	By contactName = By.xpath("//td[text()='Contact']/following::a");
	By errorMsgForIncorrectDueDate = By
			.xpath("//body[contains(@class,'editPage')]//div[contains(@id,'errorDiv')]");
	By changeOwner = By.xpath("//td[text()='Owner']/following::td//a[contains(text(),'Change')]");

	/** Page Methods */

	public ServiceCloudActivityDetail verifyPageLoad()
	{
		synchronize(30);
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}

	public ServiceCloudChangeActivityOwner clickOnChangeOwner()
	{
		pagelogger.debug("Clicking on the Change owner link");

		IframeUtils.setDriverContextToIframeWithDepth(driver, changeOwner);

		clickOnElement(changeOwner);
		setDriverContextToPage(driver);

		return ServiceCloudChangeActivityOwner.Instance;
	}

	public ServiceCloudActivityDetail clickOnEdit()
	{
		pagelogger.debug("Selecting the activity edit button");

		IframeUtils.setDriverContextToIframeWithDepth(driver, activityHeaderLocator);

		clickOnElement(editButtonLocator);

		return this;
	}

	public boolean isFCRCheckBoxChecked()
	{
		boolean isFound = false;
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, fcrCheckboxChecked);
		try
		{
			if (findElements(fcrCheckboxChecked).size() > 0)
			{
				isFound = true;
			}
		} catch (NoSuchElementException e)
		{
			pagelogger.debug("FCR Checkbox not checked In activity Page");
		}
		return isFound;
	}

	public ServiceCloudActivityDetail closeCurrentActivityTab(String activityNumber)
	{
		synchronize(30);
		currentActiveCaseTab = currentActiveCaseTab.replace("{AN}", activityNumber);
		By currentTabLocator = By.xpath(currentActiveCaseTab);
		IframeUtils.setDriverContextToIframeWithDepth(driver, currentTabLocator);
		WebElement we = findElement(currentTabLocator);
		String id = we.getAttribute("id");
		((JavascriptExecutor) driver).executeScript("window.document.getElementById('" + id
				+ "').click()", we);

		return this;
	}

	public String getActivityNumber()
	{
		pagelogger.debug("Getting the activity number");
		String val = "";

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, activityNo);

		new WebDriverWait(driver, 30).until(ExpectedConditions
				.visibilityOfElementLocated(activityNo));

		val = findElement(activityNo).getText();

		setDriverContextToPage(driver);

		return val;
	}

	public String getContact()
	{
		pagelogger.debug("Getting the activity Contact");
		String val = "";

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, contactName);

		val = findElement(contactName).getText();

		setDriverContextToPage(driver);

		return val;
	}

	public boolean findEntryInHistoryListByKeyword(String keyword)
	{
		boolean rtrn = false;
		By activityListHeader = By.xpath("//h3[text()='Activity History']");

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, activityListHeader);

		new WebDriverWait(driver, 10).until(ExpectedConditions
				.visibilityOfElementLocated(activityListHeader));

		pagelogger
				.debug("Verifying an entry exists within the activity history table with the keyword: "
						+ keyword);

		List<WebElement> entryCount = driver
				.findElements(By
						.xpath("//div/descendant::h3[text()='Activity History']/following::div[1]/descendant::strong[text()='"
								+ keyword + "']"));

		if (entryCount.size() > 0)
		{
			pagelogger.debug("The entry with the keyword [ " + keyword
					+ " ] was found in the history table");
			rtrn = true;
		} else
		{
			pagelogger.debug("The entry was not found in the activity history table!");
		}

		return rtrn;
	}

	public List<String> returnAllActivityRecordLabels()
	{

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, activityHeaderLocator);
		List<String> labels = SalesforcePageExtensions.returnAllLabelsAsList(driver);
		setDriverContextToPage(driver);

		return labels;
	}

	public boolean isErrorMsgForIncorrectDueDatePresent(String expectedErrorMsg)
	{

		pagelogger
				.debug("Checking to see if the following Error Message for incorrect due date is present: "
						+ expectedErrorMsg);
		boolean found = false;
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, errorMsgForIncorrectDueDate);
		try
		{
			String errorMsg = findElement(errorMsgForIncorrectDueDate).getText();
			if (errorMsg.contains(expectedErrorMsg))
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

}
