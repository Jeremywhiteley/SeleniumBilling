package com.salesforce.pages.salescloud.tasks;

import java.util.List;

import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.Select;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.CommonMethods;
import com.salesforce.utils.driver.SalesforcePageExtensions;

public class TaskEdit extends PageBase
{

	private static TaskEdit instance;
	public static TaskEdit Instance = (instance != null) ? instance : new TaskEdit();

	/** UI Mappings */

	By saveButtonLocator = By.cssSelector("input[title='Save']");
	public By typeLocator = By
			.xpath("//td[class=contains(text(), 'labelCol')]/span/label[text()='Type']/../following::td[1]/div/span/select");
	public By statusLocator = By
			.xpath("//td[class=contains(text(), 'labelCol')]/label[text()='Status']/../following::td[1]/div/span/select");
	public By priorityLocator = By
			.xpath("//td[class=contains(text(), 'labelCol')]/label[text()='Priority']/../following::td[1]/div/span/select");
	public By relatedToLocator = By
			.xpath("//td[class=contains(text(), 'labelCol')]/span/label[text()='Related To']/following::td[1]/div/select");
	public By nameLocator = By
			.xpath("//td[class=contains(text(), 'labelCol')]/span/label[text()='Name']/following::td[1]/div/select");
	By subjectLocator = By.xpath("//label[text()='Subject']/../following::input");

	/** Page Methods */

	public TaskEdit verifyPageLoad()
	{
		findElement(saveButtonLocator);
		return this;
	}

	public TaskDetail clickOnSave()
	{
		pagelogger.debug("Saving the Task...");

		clickOnElement(saveButtonLocator);
		return TaskDetail.Instance;
	}

	public TaskEdit setSubject(String subject)
	{
		pagelogger.debug("Entering the Task Subject");

		String id = SalesforcePageExtensions.getControlIDByXpath(driver, "Subject");
		findElement(By.id(id)).clear();
		findElement(By.id(id)).sendKeys(subject);

		return this;
	}

	public TaskEdit setStatus(String status)
	{
		pagelogger.debug("Entering the Task Status");

		String id = SalesforcePageExtensions.getControlIDByXpath(driver, "Status");
		SalesforcePageExtensions.selectOption(driver, id, status);

		return this;
	}

	public boolean verifySubjectEquals(String value)
	{

		String id = SalesforcePageExtensions.getControlIDByXpath(driver, "Subject");
		boolean val = false;

		if (findElement(By.id(id)).getAttribute("value").toUpperCase()
				.equals(value.toUpperCase().trim()))
		{
			val = true;
			pagelogger
					.debug("The Subject Field value was confirmed as matching the passed in value: "
							+ value);
		} else
		{
			pagelogger
					.debug("The Subject Field value was different than the passed in value. Found value: "
							+ findElement(By.id(id)).getText().toString()
							+ " The passed in value: " + value);
		}

		return val;
	}

	public boolean verifyDueDateEqualsToday()
	{
		String id = SalesforcePageExtensions.getControlIDByXpath(driver, "Due Date");
		boolean val = false;

		if (findElement(By.id(id)).getAttribute("value").toUpperCase()
				.equals(CommonMethods.getCurrentDate("SHORTDAYMONTH")))
		{
			val = true;
			pagelogger.debug("The Due Date field value matches today date: "
					+ findElement(By.id(id)).getText());
		} else
		{
			pagelogger
					.debug("The Due Date Field value was different than the expected value. Found value: "
							+ findElement(By.id(id)).getAttribute("value").toString()
							+ " The expected value: " + CommonMethods.getCurrentDate("STANDARD"));
		}

		return val;
	}

	public boolean verifyTypeEquals(String value)
	{
		String id = SalesforcePageExtensions.getControlIDByXpath(driver, "Type");
		boolean val = false;

		WebElement select = findElement(By.id(id));
		Select dropdown = new Select(select);

		if (dropdown.getFirstSelectedOption().getText().toUpperCase()
				.equals(value.toUpperCase().trim()))
		{
			val = true;
			pagelogger.debug("The Type Field value was confirmed as matching the passed in value: "
					+ value);
		} else
		{
			pagelogger
					.debug("The Type Field value was different than the passed in value. Found value: "
							+ dropdown.getFirstSelectedOption().getText().toString()
							+ " The passed in value: " + value);
		}

		return val;
	}

	public List<String> returnAllAccountRecordLabels()
	{
		List<String> labels = SalesforcePageExtensions.returnAllLabelsAsList(driver);
		return labels;
	}

	public List<String> returnAllSelectOptions(By parent)
	{
		List<String> fields = SalesforcePageExtensions.returnSelectOptionsAsList(driver, parent);
		return fields;
	}

}
