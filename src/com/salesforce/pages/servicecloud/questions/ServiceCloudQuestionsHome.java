package com.salesforce.pages.servicecloud.questions;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;

public class ServiceCloudQuestionsHome extends PageBase
{

	private static ServiceCloudQuestionsHome instance;
	public static ServiceCloudQuestionsHome Instance = (instance != null) ? instance
			: new ServiceCloudQuestionsHome();

	/** UI Mappings */

	By viewLabelLocator = By.xpath("//span[text()='View:']");
	By questionFilterLocator = By.xpath("//div[@class='controls']/select");
	By searchQuestionsInputLocator = By.xpath("//div/descendant::input[@title='Quick search']");
	By newQuestionButtonLocator = By.xpath("//li/input[@title='New Question']");
	By refreshButtonLocator = By.xpath("//li/input[@title='Refresh']");

	/** Page Methods */

	public ServiceCloudQuestionsHome verifyPageLoad()
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}

	public ServiceCloudQuestionsSelectRecordType createNewQuestion()
	{

		pagelogger.debug("Creating a new question...");

		IframeUtils.setDriverContextToIframeWithDepth(driver, viewLabelLocator);

		clickOnElement(newQuestionButtonLocator);

		setDriverContextToPage(driver);
		return ServiceCloudQuestionsSelectRecordType.Instance;

	}

	public ServiceCloudQuestionsHome selectQuestionFilter(String filter)
	{
		pagelogger.debug("Selecting the question filter: " + filter);

		IframeUtils.setDriverContextToIframeWithDepth(driver, viewLabelLocator);

		String id = getAttributeID(questionFilterLocator);
		pagelogger.debug("The filter id is: " + id);
		SalesforcePageExtensions.selectOption(driver, id, filter);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudQuestionsHome filterQuestionsBySearchText(String filter)
	{
		pagelogger.debug("Entering text into the question filter: " + filter);

		IframeUtils.setDriverContextToIframeWithDepth(driver, viewLabelLocator);

		String id = getAttributeID(searchQuestionsInputLocator);
		SalesforcePageExtensions.enterInputValue(driver, id, filter);

		setDriverContextToPage(driver);
		return this;
	}

	public void refreshQuestionTable()
	{
		pagelogger.debug("Refreshing the Questions Home page");

		IframeUtils.setDriverContextToIframeWithDepth(driver, viewLabelLocator);

		clickOnElement(refreshButtonLocator);

		setDriverContextToPage(driver);
	}

	public ServiceCloudQuestionsDetail selectFromQuestionTable(String question)
	{
		synchronize(30);
		pagelogger.debug("Selecting the following item from the Questions table...");

		IframeUtils.setDriverContextToIframeWithDepth(driver, viewLabelLocator);

		SalesforcePageExtensions.selectFromRecordTable(driver, question);

		setDriverContextToPage(driver);

		return ServiceCloudQuestionsDetail.Instance;

	}

}
