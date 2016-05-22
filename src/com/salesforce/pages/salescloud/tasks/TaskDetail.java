package com.salesforce.pages.salescloud.tasks;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.SalesforcePageExtensions;

public class TaskDetail extends PageBase
{

	private static TaskDetail instance;
	public static TaskDetail Instance = (instance != null) ? instance : new TaskDetail();

	/** UI Mappings */

	By editButtonLocator = By.cssSelector("input[title='Edit']");
	By saveButtonLocator = By.cssSelector("input[title='Save']");
	By recordTypeLocator = By.xpath("//tr/td[text()='Task Record Type']/following::td[1]/div");
	By typeTDLocator = By.xpath("//tr/descendant::*[text()='Type']/following::td[1]");
	By typeOptionIDLocator = By
			.xpath("//td[class=contains(text(),'labelCol')]/span[text()='Type']/../following-sibling::td[1]/div[@class='inlineEditRequiredDiv']/span/select");
	By createFollowUpTaskButton = By.cssSelector("input[value='Create Follow-Up Task']");

	/** Page Methods */

	public TaskDetail verifyPageLoad()
	{
		pagelogger.debug("Waiting for page to load");

		findElement(editButtonLocator);
		return this;
	}

	public TaskEdit edit()
	{
		pagelogger.debug("Clicking on TaskEdit");

		clickOnElement(editButtonLocator);

		return TaskEdit.Instance;
	}

	public TaskDetail save()
	{
		pagelogger.debug("Clicking on Save");

		clickOnElement(saveButtonLocator);

		return this;
	}

	public void editTypeField(String type)
	{
		pagelogger.debug("Setting Type to: " + type);

		String id = getAttributeID(typeTDLocator);

		pagelogger.debug("id is: " + id);

		SalesforcePageExtensions.editInlineTD(driver, id);
		String leadSourceOptID = getAttributeID(typeOptionIDLocator);
		SalesforcePageExtensions.selectOption(driver, leadSourceOptID, type);
	}

	public boolean verifyRecordType(String type)
	{
		boolean val = false;

		String currentValue = findElement(recordTypeLocator).getText();

		if (currentValue.indexOf("[Change]") != -1)
		{
			currentValue = currentValue.replace("[Change]", "");
		}

		if (findElement(recordTypeLocator).getText().toUpperCase().trim()
				.equals(type.toUpperCase().trim()))
		{
			pagelogger.debug("Found the expected Record Type! " + type);
			val = true;
		} else
		{
			pagelogger.debug("Did not find the expected record type! Found: "
					+ findElement(recordTypeLocator).getText());
		}

		return val;
	}

	public TaskEdit clickOnFollowUpTaskButton()
	{
		pagelogger.debug("Clicking on the follow up task button");
		clickOnElement(createFollowUpTaskButton);
		return TaskEdit.Instance;
	}

}
