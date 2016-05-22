package com.salesforce.pages.salescloud.opportunities;

import java.util.ArrayList;
import java.util.List;

import org.openqa.selenium.Alert;
import org.openqa.selenium.By;
import org.openqa.selenium.NoAlertPresentException;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.WebElement;

import com.salesforce.pages.PageBase;
import com.salesforce.pages.salescloud.contacts.ContactsDetail;
import com.salesforce.pages.salescloud.tasks.TaskEdit;
import com.salesforce.utils.CommonMethods;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;
import com.salesforce.utils.driver.VerifyPageElementsExtensions;

public class OpportunitiesDetail extends PageBase
{

	private static OpportunitiesDetail instance;
	public static OpportunitiesDetail Instance = (instance != null) ? instance
			: new OpportunitiesDetail();

	/** UI Mappings */

	By editButtonLocator = By.cssSelector("input[title='Edit']");
	By cancelButtonLocator = By.cssSelector("input[title='Cancel']");
	By addProductButtonLocator = By.cssSelector("input[name='addProd']");
	By addQuoteButtonLocator = By.cssSelector("input[name='newQuote']");
	By newTaskButtonLocator = By.cssSelector("input[title='New Task']");
	By amountLocator = By.xpath("//td[text()='Amount']/following::td[1]/descendant::div[1]");
	By okButtonLocator = By.cssSelector("input[value='OK']");
	By closeDateValueTDLocator = By.xpath("//td[text()='Close Date']/following-sibling::td/div[1]");
	By closeDateValueInputLocator = By
			.xpath("//td[text()='Close Date']/following-sibling::td/div[2]/input");
	By saveButtonLocator = By.cssSelector("input[title='Save']");
	By stageLocator = By.xpath("//td[text()='Stage']/following::td[1]/div");
	By stageSelectLocator = By
			.xpath("//td[text()='Stage']/following-sibling::td[1]/div/span/select");
	By probabilityInputLocator = By
			.xpath("//td[text()='Probability (%)']/following-sibling::td/div/input");
	By probabilityLocator = By.xpath("//td[text()='Probability (%)']/following::div");
	By errorLocator = By.xpath("//tr/td[@id='bodyCell']/descendant::div[@id='errorDiv_ep']");
	By recordTypeLocator = By
			.xpath("//tr/td[text()='Opportunity Record Type']/following::td[1]/div");
	By stageErrorLocator = By
			.xpath("//tr/td[text()='Stage']/following::td[1]/div[@class='errorMsg']");
	By opportunityHeaderLocator = By.xpath("//h2[contains(@class,'Description')]");
	By changeOwnerLocator = By.xpath("//a[text()='[Change]']");
	By opportunityOwnerLocator = By
			.xpath("//td[text()='Opportunity Owner']/..//a[contains(@id,'lookup')]");
	By logACallButtonLocator = By.cssSelector("input[value='Log a Call']");
	By keyFieldsLocator = By.xpath("//table[@class='detailList']//th");
	By guidanceToSellLinksLocator = By.xpath("//div[text()='Guidance to Sell']/following::a");

	/** Page Methods */

	public String getOpportunityOwner()
	{
		pagelogger.debug("Getting the Opportunity Owner...");

		String accountOwnerName = findElement(opportunityOwnerLocator).getText();
		return accountOwnerName;
	}

	public String getProbability()
	{
		pagelogger.debug("Getting the Opportunity Probability...");

		String probability = findElement(probabilityLocator).getText();
		return probability;
	}

	public OpportunitiesEdit clickOnEditButton()
	{
		pagelogger.debug("Editing the current Opportunity record...");

		clickOnElement(editButtonLocator);
		return OpportunitiesEdit.Instance;
	}

	public TaskEdit clickOnLogACallButton()
	{
		pagelogger.debug("Clicking on log a call...");

		clickOnElement(logACallButtonLocator);

		return TaskEdit.Instance;
	}

	public OpportunitiesChangeOwner clickOnChangeOwner()
	{
		pagelogger.debug("Clicking on Change Owner...");

		clickOnElement(changeOwnerLocator);
		return OpportunitiesChangeOwner.Instance;
	}

	public OpportunitiesDetail clickOnCancelButton()
	{
		pagelogger.debug("Canceling the editing of the current opportunity record...");
		clickOnElement(cancelButtonLocator);
		return this;
	}

	public OpportunitiesDetail clickOnSaveButton()
	{
		pagelogger.debug("Saving the current opportunity record");

		clickOnElement(saveButtonLocator);

		return this;
	}

	public String getOpportunityStage()
	{
		pagelogger.debug("Getting the Opportunity stage.");

		String val = findElement(stageLocator).getText();

		return val;
	}

	public TaskEdit clickOnNewTask()
	{
		pagelogger.debug("Clicking on New Task...");

		SalesforcePageExtensions.waitForPageToLoad(driver);
		clickOnElement(newTaskButtonLocator);

		return TaskEdit.Instance;
	}

	public OpportunitiesDetail verifyPageLoad()
	{
		findElement(editButtonLocator);

		return this;
	}

	public OpportunitiesProductSelection clickOnAddProduct()
	{
		pagelogger
				.debug("Clicking on Add Product Button within the opportunity record detail page");

		clickOnElement(addProductButtonLocator);

		return OpportunitiesProductSelection.Instance;
	}

	public OpportunitiesNewQuote clickOnNewQuote()
	{
		pagelogger.debug("Clicking on Add Quote Button within the opportunity record detail page");

		clickOnElement(addQuoteButtonLocator);

		return OpportunitiesNewQuote.Instance;
	}

	public String getAmount()
	{
		pagelogger.debug("Getting the Opportunity Amount...");

		String val = findElement(amountLocator).getText();

		return val;
	}

	public String getProductQuantity(String product)
	{
		pagelogger.debug("Getting the Quantity for the Product: " + product);

		By quantityLocator = By.xpath("//a[text()='" + product
				+ "']/../..//td[contains(@class,'numericalColumn')]");
		String quantity = findElement(quantityLocator).getText();
		return quantity;
	}

	public boolean verifyOpportunityRecordType(String record)
	{
		pagelogger.debug("Verifying that Opportunity Record Type is: " + record);

		boolean val = false;
		String currentValue = findElement(recordTypeLocator).getText();

		if (currentValue.indexOf("[Change]") != -1)
		{
			currentValue = currentValue.replace("[Change]", "");
		}

		if (currentValue.toUpperCase().trim().equals(record.toUpperCase().trim()))
		{
			pagelogger.debug("Record Type was verified as: " + record);
			val = true;
		} else
		{
			pagelogger.debug("Verify Record Type failed - Found value: " + currentValue);
		}

		return val;
	}

	public OpportunitiesDetail changeCloseDateToFutureDate(int daysInFuture)
	{
		pagelogger.debug("Updating Close Date to be the following number of days in the future: "
				+ daysInFuture);

		String id = getAttributeID(closeDateValueTDLocator);

		SalesforcePageExtensions.editInlineTD(driver, id);
		findElement(closeDateValueInputLocator).sendKeys(
				CommonMethods.getFutureDate("STANDARD", daysInFuture));

		return this;
	}

	public boolean verifyStageUpdateFailure()
	{
		pagelogger.debug("Checking for the Stage update failure message...");

		boolean val = false;
		findElement(stageErrorLocator);

		if (findElement(stageErrorLocator).isDisplayed() == true)
		{
			val = true;
			pagelogger.debug("Found the expected Stage error message");
		} else
		{
			pagelogger.debug("Did not find the expected Stage error message");
		}

		return val;
	}

	public String getOpportunityHeader()
	{
		pagelogger.debug("Getting the Opportunity Header text");
		String val = "";
		val = findElement(opportunityHeaderLocator).getText();
		return val;
	}

	public boolean getPresenceOfActivity(String activityName)
	{
		pagelogger.debug("Searching Activity Related List for entry: " + activityName);

		boolean val = false;
		List<WebElement> rows = findElementsIgnoreException(By
				.xpath("//div[contains(@id, 'RelatedHistoryList')]/div/div/div[contains(@id, '_body')]/table/tbody/tr[contains(@class, 'dataRow')]/th/a"));

		for (int i = 1; i <= rows.size(); i++)
		{
			pagelogger.debug("Searching row [" + i + "] for value: " + activityName);

			if (rows.get(i - 1).getText().toUpperCase().trim()
					.equals(activityName.toUpperCase().trim()))
			{
				val = true;
				break;
			} else
			{
				pagelogger.debug("Did not find the passed in row. Found: " + rows.get(i).getText()
						+ " wanted to find: " + activityName.toUpperCase().trim());
			}
		}
		return val;

	}

	public OpportunitiesEdit setOpportunityStage(String stage)
	{
		pagelogger.debug("Setting Opportunity Stage to: " + stage);

		String id = getAttributeID(stageLocator);
		SalesforcePageExtensions.editInlineTD(driver, id);

		String selectid = getAttributeID(stageSelectLocator);
		SalesforcePageExtensions.selectOption(driver, selectid, stage);
		clickOnElement(okButtonLocator);

		return OpportunitiesEdit.Instance;
	}

	public boolean getPresenceOfProduct(String productName)
	{
		pagelogger.debug("Searching Product Related List for entry: " + productName);

		boolean val = false;
		List<WebElement> rows = findElementsIgnoreException(By
				.xpath("//div[contains(@id, 'RelatedLineItemList')]/div/div/div[contains(@id, '_body')]/table/tbody/tr[contains(@class, 'dataRow')]/th/a"));

		for (int i = 1; i <= rows.size(); i++)
		{
			pagelogger.debug("Searching row [" + i + "] for value: " + productName);

			if (rows.get(i - 1).getText().toUpperCase().trim()
					.equals(productName.toUpperCase().trim()))
			{
				val = true;
				break;
			} else
			{
				pagelogger.debug("Did not find the passed in row. Found: "
						+ rows.get(i - 1).getText() + " wanted to find: " + productName.trim());
			}
		}

		return val;
	}

	public boolean getPresenceOfQuote(String quoteName)
	{
		pagelogger.debug("Searching Quote Related List for entry: " + quoteName);

		boolean val = false;
		List<WebElement> rows = driver
				.findElements(By
						.xpath("//div[contains(@id, 'RelatedQuoteList')]//td[contains(@class,'dataCell')]/a"));

		for (int i = 1; i <= rows.size(); i++)
		{
			pagelogger.debug("Searching row [" + i + "] for value: " + quoteName);

			if (rows.get(i - 1).getText().toUpperCase().trim()
					.equals(quoteName.toUpperCase().trim()))
			{
				val = true;
				break;
			} else
			{
				pagelogger.debug("Did not find the passed in row. Found: " + rows.get(i).getText()
						+ " wanted to find: " + quoteName.toUpperCase().trim());
			}
		}

		return val;

	}

	public ContactsDetail deleteProduct(String prodName)
	{
		pagelogger.debug("Deleting Product from the related list: " + prodName);

		if (this.getPresenceOfProduct(prodName))
		{
			pagelogger.debug("Found the Product in the related list. Will delete!");
			Alert alert;

			findElement(By.xpath("//a[text()='" + prodName + "']/../../td/a[text()='Del']"))
					.click();

			try
			{
				alert = driver.switchTo().alert();
				alert.accept();
			} catch (NoAlertPresentException e)
			{
				pagelogger
						.debug("WARNING: Product Delete confirmation box was not present after selecting Del...");
				throw e;
			}

		} else
		{
			pagelogger.debug("Could not find Product in the related list: " + prodName);
			throw new NoSuchElementException("Product not found in related list: " + prodName);
		}

		return ContactsDetail.Instance;
	}

	public boolean verifyTDValuesExist(String fields)
	{
		pagelogger.debug("Verifying if TD values exist...");

		boolean noErrorsFound = true;

		String[] arrFields = fields.split("\\,", -1);
		List<String> result = VerifyPageElementsExtensions
				.verifyAllTDValuesExist(driver, arrFields);
		pagelogger.debug("Size: " + result.size());

		if (result.size() > 0)
		{
			noErrorsFound = false;
		}

		return noErrorsFound;
	}

	public boolean verifyIfKeyFieldsExist(String fields)
	{
		pagelogger.debug("Verifying if Key Fields values exist...");

		boolean noErrorsFound = true;

		String[] arrFields = fields.split("\\,", -1);

		boolean found = false;
		List<String> errorList = new ArrayList<String>();

		List<WebElement> elements = null;
		IframeUtils.setDriverContextToIframeWithDepth(driver, keyFieldsLocator);
		elements = findElements(keyFieldsLocator);

		if (arrFields.length < 1)
		{
			pagelogger.debug("You must pass at least one value into verifyIfKeyFieldsExist()!");
			throw new IllegalArgumentException(
					"No fields were passed into function: verifyIfKeyFieldsExist()");
		}

		for (int i = 0; i < arrFields.length; i++)
		{

			for (WebElement element : elements)
			{

				if (element.getText().trim().equals(arrFields[i].trim()))
				{
					pagelogger.debug("Found the passed in field: " + arrFields[i]);
					found = true;
					break;
				}
			}

			if (found == false)
			{
				pagelogger.debug("ERROR: Field was not found: " + arrFields[i].toString());
				errorList.add(arrFields[i].toString());
			} else
			{
				found = false;
			}
		}

		if (errorList.size() > 0)
		{
			noErrorsFound = false;
		}

		return noErrorsFound;
	}

	public boolean verifyIfGuidanceToSellLinksExist(String links)
	{
		pagelogger.debug("Verifying if Key Fields values exist...");

		boolean noErrorsFound = true;

		String[] arrLinks = links.split("\\,", -1);

		boolean found = false;
		List<String> errorList = new ArrayList<String>();

		List<WebElement> elements = null;
		IframeUtils.setDriverContextToIframeWithDepth(driver, guidanceToSellLinksLocator);
		elements = findElements(guidanceToSellLinksLocator);

		if (arrLinks.length < 1)
		{
			pagelogger
					.debug("You must pass at least one value into verifyIfGuidanceToSellLinksExist()!");
			throw new IllegalArgumentException(
					"No fields were passed into function: verifyIfGuidanceToSellLinksExist()");
		}

		for (int i = 0; i < arrLinks.length; i++)
		{

			for (WebElement element : elements)
			{

				if (element.getText().trim().contains(arrLinks[i].trim()))
				{
					pagelogger.debug("Found the passed in field: " + arrLinks[i]);
					found = true;
					break;
				}
			}

			if (found == false)
			{
				pagelogger.debug("ERROR: Field was not found: " + arrLinks[i].toString());
				errorList.add(arrLinks[i].toString());
			} else
			{
				found = false;
			}
		}

		if (errorList.size() > 0)
		{
			noErrorsFound = false;
		}

		return noErrorsFound;
	}
}
