package com.salesforce.pages.servicecloud.cases;

import java.util.List;

import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.pages.servicecloud.activities.ServiceCloudActivityDetail;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;

public class ServiceCloudCasesDetail extends PageBase
{

	private static ServiceCloudCasesDetail instance;
	public static ServiceCloudCasesDetail Instance = (instance != null) ? instance
			: new ServiceCloudCasesDetail();

	/** UI Mappings */

	By viewButtonLocator = By.xpath("//td/input[@title='View']");
	By detailTab = By
			.xpath("//div[@id='navigatortab']/descendant::ul[1]/descendant::span/descendant::span[@class='tabText']");
	By customerInformationPane = By.xpath("//div[text()='Account Name']/following::div//a");
	By currentActiveCaseTab = By
			.xpath("//li[contains(@id,navigator) and contains(@class,'active')]//span[@class='tabText']");
	By caseOwner = By.xpath("//div[text()='Case Owner']/following::div//img/../../following::a");
	By caseAccount = By.xpath("//td[text()='Account Name']/following::a");
	By parentcase = By.xpath("//td[text()='Parent Case']/../td[@class='dataCol']/a");
	By caseArticleTitle = By.xpath("//td[text()='Article Title']/following::td");
	By caseCreatedBy = By.xpath("//td[text()='Created By']/following::a");
	By casePrimaryContactName = By.xpath("//span[text()='Contact Name']/../following::a");
	By caseDueDate = By.xpath("//td[text()='Case Due Date']/following::td");
	By caseEscalationStartDate = By.xpath("//td[text()='Escalation Start Date']/following::td");
	By caseStatus = By.xpath("//td[contains(text(),'Status')]/following::td");
	By caseTeam = By.xpath("//td[contains(text(),'Team')]/following::td");
	By currentTabClose = By
			.xpath("//li[contains(@class,'strip-active')]/a[contains(@class,'close')]");
	By caseHeaderLocator = By.xpath("//div[@class='efhpTitle']");
	By altCaseHeaderLocator = By
			.xpath("//div[@class='content']/descendant::img[@title='Article']/following-sibling::h2");
	By priorityFieldLocator = By
			.xpath("//div[text()='Priority']/following::div[1]/descendant::div[1]");
	By prioritySelectLocator = By
			.xpath("//div[text()='Priority']/following::div[1]/descendant::div[2]/descendant::select[1]");
	By saveButtonLocator = By.cssSelector("input[title='Save']");
	By editButtonLocator = By.cssSelector("input[title='Edit']");
	By newCaseButton = By.xpath("//span[@id='newCaseLabel']");
	By closeCaseButtonLocator = By.cssSelector("input[title='Close Case']");
	By newCommentButton = By.xpath("//input[@name='newComment']");
	By newTaskButton = By.xpath("//input[@name='task']");
	By newActivity = By.xpath("//span[text()='New Activity']");
	By newEventButton = By.xpath("//input[@name='event']");
	By logACallButton = By.xpath("//input[@value='Log a Call']");
	By caseCommentsLink = By.xpath("//a[contains(text(),'Case Comments')]");
	By teamMembersRelatedList = By
			.xpath("//div[contains(@id,'RelatedTeam')]//th[contains(@class,'dataCell')]//a");
	By caseCommentsInDetail = By
			.xpath("//div[contains(@id,'RelatedComments')]//td[contains(@class,'dataCell')]");
	String caseCommentEdit = "//div[contains(@id,'RelatedComments')]//td[contains(@class,'dataCell') and text()='{commentText}']/../td[@class='actionColumn']/a[text()='Edit']";
	String caseActivityEdit = "//div[contains(@id,'RelatedActivity')]//th[contains(@class,'dataCell')]/a[text()='{taskText}']/../../td[@class='actionColumn']/a[text()='Edit']";
	By editLinkInCasesDetail;
	By imageExpandArrow = By.xpath("//img[@name='Activities'][contains(@class,'show')]");
	By accountNameSectionLocator = By.xpath("//div[@class='labelCol' and text()='Account Name']");
	By contactNameSectionLocator = By.xpath("//div[@class='labelCol' and text()='Contact Name']");
	By contactEmailSectionLocator = By.xpath("//div[text()='Email']");
	By contactPhoneSectionLocator = By.xpath("//div[@class='labelCol' and text()='Phone']");
	By changeOwnerLink = By.xpath("//a[contains(text(),'Change')]");

	// verify these locators- JD
	By volumeOfTargetContacts = By
			.xpath("//td[contains(text(),'Volume of Target Contacts')]/following::td");
	By productSearchContainerLocator = By.xpath("//div[@id='SearchContainer']");
	By productSearchContainerMinimizeButtonLocator = By
			.xpath("//div[contains(@class, 'minimize_icon')]");
	By countrySelectOnProductSearchLocator = By
			.xpath("//div[@id='SearchContainer']/descendant::div[contains(text(),'Product Search')]/following::select[1]");
	By productSearchboxLocator = By
			.xpath("//div[@id='SearchContainer']/descendant::div[contains(text(),'Product Search')]/following::div[@class='searchBar']/descendant::input");
	By productSearchResultsCountLocator = By
			.xpath("//div[@id='SearchContainer']/descendant::div[contains(text(),'Product Search')]/following::div[@class='searchBar']/descendant::span[@class='processingTime']");
	By productSearchResultsListLocator = By.xpath("//ul[@id='ui-id-1']/li/a");
	By productSearchResultsCommentCodeInputLocator = By
			.xpath("//input[@placeholder='Search Comment Code...']");
	By caseHistoryDescription = By
			.xpath("//div[contains(@id,'RelatedEntityHistoryList')]//td[contains(@class,'cellCol3')]");
	String targetContactUserName = "//h3[text()='Target Contacts']/../../../../following::div//a[text()='{UserName}']";
	By rightHandSideAccountRelatedKnowledgeTab = By.xpath("//td[text()='Account Related']");
	By knowledgeArticleSearchInput = By.xpath("//input[@id='searchText']");
	By knowledgeArticleSearchButton = By.xpath("//button[@class='searchButton']");
	By knowledgeArticlesSearchResult = By
			.xpath("//tbody[contains(@id,'results')]//td[contains(@class,'articleTitle')]");
	By newTargetContactNameButton = By.xpath("//input[@name='new_target_contact']");
	By shareWithTargetContactButton = By.xpath("//input[@value='Share with Contacts']");
	By recentActivityLink = By
			.xpath("//td[contains(@id,'activity')]/span[@class='activityLink']/span");

	/** Page Methods */

	public ServiceCloudCasesDetail verifyPageLoad()
	{
		pagelogger.debug("Waiting for page to load");

		synchronize(30);
		SalesforcePageExtensions.waitForPageToLoad(driver);

		return this;
	}

	public ServiceCloudCasesCommentsEdit clickOnEditComment(String comment)
	{
		pagelogger.debug("Clicking on Edit Comment!");

		caseCommentEdit = caseCommentEdit.replace("{commentText}", comment);
		editLinkInCasesDetail = By.xpath(caseCommentEdit);
		IframeUtils.setDriverContextToIframeWithDepth(driver, editLinkInCasesDetail);
		clickOnElement(editLinkInCasesDetail);

		setDriverContextToPage(driver);
		return ServiceCloudCasesCommentsEdit.Instance;
	}

	public ServiceCloudCasesTaskEdit clickOnEditTask(String activity)
	{
		pagelogger.debug("Clicking on Edit Task!");

		caseActivityEdit = caseActivityEdit.replace("{taskText}", activity);
		editLinkInCasesDetail = By.xpath(caseActivityEdit);

		IframeUtils.setDriverContextToIframeWithDepth(driver, editLinkInCasesDetail);

		clickOnElement(editLinkInCasesDetail);
		setDriverContextToPage(driver);

		return ServiceCloudCasesTaskEdit.Instance;
	}

	public ServiceCloudActivityDetail clickOnRecentActivity()
	{
		pagelogger.debug("Clicking on Recent Activity!");

		IframeUtils.setDriverContextToIframeWithDepth(driver, recentActivityLink, 2);

		try
		{
			clickOnElement(recentActivityLink);
		} catch (NoSuchElementException e)
		{
			pagelogger.debug("Auto Activity not created ");
			throw e;
		}

		return ServiceCloudActivityDetail.Instance;
	}

	public ServiceCloudCasesEventEdit clickOnEditEvent(String activity)
	{
		pagelogger.debug("Clicking on Edit Event!");

		caseActivityEdit = caseActivityEdit.replace("{taskText}", activity);
		editLinkInCasesDetail = By.xpath(caseActivityEdit);

		IframeUtils.setDriverContextToIframeWithDepth(driver, editLinkInCasesDetail);

		clickOnElement(editLinkInCasesDetail);

		setDriverContextToPage(driver);
		return ServiceCloudCasesEventEdit.Instance;
	}

	public boolean verifyIfCommentPresent(String comment)
	{
		pagelogger.debug("Verifying that the following comment is present: " + comment);

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, caseCommentsInDetail);

		List<WebElement> listofCaseComments = findElements(caseCommentsInDetail);

		for (WebElement caseComment : listofCaseComments)
		{
			String caseCommentText = caseComment.getText();

			if (caseCommentText.contains(comment))
			{
				setDriverContextToPage(driver);
				return true;
			}
		}

		setDriverContextToPage(driver);
		return false;
	}

	public ServiceCloudCasesTaskEdit clickOnNewTaskToCase()
	{
		pagelogger.debug("Click on New Task to Case Button");

		IframeUtils.setDriverContextToIframeWithDepth(driver, newTaskButton);

		clickOnElement(newTaskButton);
		setDriverContextToPage(driver);
		return ServiceCloudCasesTaskEdit.Instance;
	}

	public ServiceCloudCasesActivitySelectRecordType clickOnNewActivityToCase()
	{
		pagelogger.debug("Click on New Activity to Case Button");

		IframeUtils.setDriverContextToIframeWithDepth(driver, imageExpandArrow, 1);

		try
		{
			clickOnElement(imageExpandArrow);
		} catch (NoSuchElementException e)
		{
			pagelogger.debug("Activity Image arrow already expanded");
		}

		IframeUtils.setDriverContextToIframeWithDepth(driver, newActivity, 2);

		try
		{
			clickOnElement(newActivity);
		} catch (NoSuchElementException e)
		{
			pagelogger
					.debug("Click on New Activity to Case Button xpath is different. Trying a new one");
			newActivity = By.xpath("//input[@title='New Activity']");
			IframeUtils.setDriverContextToIframeWithDepth(driver, newActivity, 1);
			clickOnElement(newActivity);
		}

		setDriverContextToPage(driver);

		return ServiceCloudCasesActivitySelectRecordType.Instance;
	}

	public ServiceCloudCasesTaskEdit clickOnLogACallToCase()
	{
		pagelogger.debug("Click on Log a Call to Case Button");

		IframeUtils.setDriverContextToIframeWithDepth(driver, logACallButton);

		clickOnElement(logACallButton);

		setDriverContextToPage(driver);
		return ServiceCloudCasesTaskEdit.Instance;
	}

	public ServiceCloudCasesEventEdit clickOnNewEventToCase()
	{
		pagelogger.debug("Click on New Event to Case Button");

		IframeUtils.setDriverContextToIframeWithDepth(driver, newEventButton);

		clickOnElement(newEventButton);

		setDriverContextToPage(driver);
		return ServiceCloudCasesEventEdit.Instance;
	}

	public ServiceCloudCasesCommentsEdit clickOnNewCommentToCase()
	{
		pagelogger.debug("Click on New Comment to Case Button");

		IframeUtils.setDriverContextToIframeWithDepth(driver, caseCommentsLink);

		clickOnElement(caseCommentsLink);

		setDriverContextToPage(driver);
		IframeUtils.setDriverContextToIframeWithDepth(driver, newCommentButton);

		clickOnElement(newCommentButton);

		setDriverContextToPage(driver);
		return ServiceCloudCasesCommentsEdit.Instance;
	}

	public ServiceCloudCasesEdit clickOnEditButton()
	{
		pagelogger.debug("Clicking on the Edit button");

		IframeUtils.setDriverContextToIframeWithDepth(driver, editButtonLocator);

		clickOnElement(editButtonLocator);
		setDriverContextToPage(driver);

		return ServiceCloudCasesEdit.Instance;
	}

	public ServiceCloudCasesSelectRecordType clickOnNewCase()
	{
		pagelogger.debug("Clicking on the New Case button");

		IframeUtils.setDriverContextToIframeWithDepth(driver, newCaseButton);

		clickOnElement(newCaseButton);
		setDriverContextToPage(driver);

		return ServiceCloudCasesSelectRecordType.Instance;
	}

	public ServiceCloudChangeCaseOwner clickOnChangeOwner()
	{
		pagelogger.debug("Clicking on the Change owner link");

		IframeUtils.setDriverContextToIframeWithDepth(driver, changeOwnerLink);

		clickOnElement(changeOwnerLink);
		setDriverContextToPage(driver);

		return ServiceCloudChangeCaseOwner.Instance;
	}

	public ServiceCloudCloseCase clickOnCloseCaseButton()
	{
		pagelogger.debug("Clicking on the Close Case button");

		IframeUtils.setDriverContextToIframeWithDepth(driver, closeCaseButtonLocator);

		clickOnElement(closeCaseButtonLocator);
		setDriverContextToPage(driver);

		return ServiceCloudCloseCase.Instance;
	}

	public void selectDetailTab(String tab)
	{
		synchronize(30);

		By pageBody = By.tagName("body");
		By link = By.xpath("//span[@class='tabText'][text()='" + tab + "']");

		pagelogger.debug("Opening the Details Section dropdown menu to select detail tab..." + tab);

		findElement(pageBody).sendKeys("s");
		findElement(pageBody).sendKeys("d");

		clickOnElement(link);
	}

	public ServiceCloudCasesDetail closeCurrentTab()
	{
		synchronize(30);

		driver.switchTo().defaultContent();

		Actions action = new Actions(driver);
		WebElement we = findElement(currentActiveCaseTab);
		action.moveToElement(we).moveToElement(findElement(currentTabClose)).click().build()
				.perform();

		return this;
	}

	public String getCurrentTabCaseID()
	{
		synchronize(30);
		pagelogger.debug("Getting current Case ID...");

		new WebDriverWait(driver, 30).until(ExpectedConditions.titleContains("Case:"));

		IframeUtils.setDriverContextToIframeWithDepth(driver, currentActiveCaseTab);

		String caseId = findElement(currentActiveCaseTab).getText();
		pagelogger.debug("Found the Case ID: " + caseId);
		setDriverContextToPage(driver);
		return caseId;
	}

	public String getCaseOwner()
	{
		pagelogger.debug("Getting the case owner text");

		synchronize(30);
		new WebDriverWait(driver, 30).until(ExpectedConditions.titleContains(pageTitle));

		IframeUtils.setDriverContextToIframeWithDepth(driver, caseOwner);

		String ownerName = findElement(caseOwner).getText();

		setDriverContextToPage(driver);
		return ownerName;
	}

	public String getCaseAccount()
	{
		pagelogger.debug("Getting the case Account name");

		synchronize(30);
		new WebDriverWait(driver, 30).until(ExpectedConditions.titleContains(pageTitle));

		IframeUtils.setDriverContextToIframeWithDepth(driver, caseAccount);

		String accountName = findElement(caseAccount).getText();

		setDriverContextToPage(driver);
		return accountName;
	}

	public String getParentCase()
	{
		pagelogger.debug("Getting the Parent case number");

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, parentcase);
		String parentCase = findElement(parentcase).getText();
		setDriverContextToPage(driver);

		return parentCase;
	}

	public ServiceCloudCasesDetail clickOnParentCaseLink()
	{
		pagelogger.debug("Clicking on the parent case link");

		IframeUtils.setDriverContextToIframeWithDepth(driver, parentcase);

		clickOnElement(parentcase);
		setDriverContextToPage(driver);

		return ServiceCloudCasesDetail.Instance;
	}

	public String getCaseArticleTitle()
	{
		pagelogger.debug("Getting the case article title");
		synchronize(30);
		new WebDriverWait(driver, 30).until(ExpectedConditions.titleContains(pageTitle));

		IframeUtils.setDriverContextToIframeWithDepth(driver, caseArticleTitle);

		String articleTitle = findElement(caseArticleTitle).getText();

		setDriverContextToPage(driver);
		return articleTitle;
	}

	public String getCaseCreatedBy()
	{
		pagelogger.debug("Getting the case created by text");

		synchronize(30);
		new WebDriverWait(driver, 30).until(ExpectedConditions.titleContains(pageTitle));

		IframeUtils.setDriverContextToIframeWithDepth(driver, caseCreatedBy);

		String caseCreatorName = findElement(caseCreatedBy).getText();
		setDriverContextToPage(driver);
		return caseCreatorName;
	}

	public String getCasePrimaryContactName()
	{

		pagelogger.debug("Getting the case primary contact text");

		synchronize(30);
		new WebDriverWait(driver, 30).until(ExpectedConditions.titleContains(pageTitle));

		IframeUtils.setDriverContextToIframeWithDepth(driver, casePrimaryContactName);

		String casePrimaryContact = findElement(casePrimaryContactName).getText();

		setDriverContextToPage(driver);
		return casePrimaryContact;
	}

	public String getCaseDueDate()
	{
		synchronize(30);
		new WebDriverWait(driver, 30).until(ExpectedConditions.titleContains(pageTitle));

		IframeUtils.setDriverContextToIframeWithDepth(driver, caseDueDate);

		String dueDate = findElement(caseDueDate).getText();

		setDriverContextToPage(driver);
		return dueDate;
	}

	public String getCaseEscalationStartDate()
	{
		synchronize(30);
		new WebDriverWait(driver, 20).until(ExpectedConditions.titleContains(pageTitle));

		IframeUtils.setDriverContextToIframeWithDepth(driver, caseEscalationStartDate);

		String startDate = findElement(caseEscalationStartDate).getText().trim();

		setDriverContextToPage(driver);
		return startDate;
	}

	public String getCaseStatus()
	{
		synchronize(30);
		new WebDriverWait(driver, 20).until(ExpectedConditions.titleContains(pageTitle));

		IframeUtils.setDriverContextToIframeWithDepth(driver, caseStatus);

		String status = findElement(caseStatus).getText();

		setDriverContextToPage(driver);
		return status;
	}

	public String getCustomerDetailContent()
	{
		String temp = "";

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, customerInformationPane);

		new WebDriverWait(driver, 20).until(ExpectedConditions.titleContains(pageTitle));

		temp = findElement(customerInformationPane).getText();

		pagelogger.debug(temp);

		setDriverContextToPage(driver);
		return temp;
	}

	public String getCaseHeader()
	{
		pagelogger.debug("Getting the Case Header text...");

		String val = "";

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, caseHeaderLocator);

		val = findElement(caseHeaderLocator).getText();

		setDriverContextToPage(driver);
		return val;
	}

	public ServiceCloudCasesDetail updateCasePriority(String priority)
	{
		pagelogger.debug("Updating case priority to: " + priority);

		IframeUtils.setDriverContextToIframeWithDepth(driver, priorityFieldLocator);

		String id = getAttributeID(priorityFieldLocator);
		SalesforcePageExtensions.editInlineTD(driver, id);

		String selectid = getAttributeID(prioritySelectLocator);
		SalesforcePageExtensions.selectOption(driver, selectid, priority);

		clickOnElement(saveButtonLocator);

		setDriverContextToPage(driver);
		return this;
	}

	public String getCasePriority()
	{
		pagelogger.debug("Getting the case priority...");

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, priorityFieldLocator);

		String val = findElement(priorityFieldLocator).getText();

		pagelogger.debug("The case priority was found to be: " + val);

		setDriverContextToPage(driver);

		return val;
	}

	public boolean isFieldPresent(String fieldLabelName)
	{
		boolean isFound = false;
		synchronize(30);

		String labelLocator = "//td[@class='labelCol'][text()='" + fieldLabelName + "']";
		By labelXpath = By.xpath(labelLocator);

		IframeUtils.setDriverContextToIframeWithDepth(driver, labelXpath);

		try
		{
			if (findElements(labelXpath).size() > 0)
			{
				isFound = true;
			}
		} catch (NoSuchElementException e)
		{
			pagelogger.debug("Label with name " + fieldLabelName + " not found");
		}

		return isFound;
	}

	public ServiceCloudCasesDetail selectFromLeftNav(String tabName)
	{
		Boolean val = false;
		pagelogger.debug("Selecting the left navigation tab: " + tabName);

		By tabsLocator = By
				.xpath("(//div[contains(@class, 'tabContextPane')]/descendant::ul)[1]/li");

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, tabsLocator);

		List<WebElement> Elements = findElements(tabsLocator);

		for (WebElement element : Elements)
		{
			if (element.getText().toUpperCase().equals(tabName.toUpperCase()))
			{
				pagelogger.debug("Found left navigation element - will click it");
				clickOnElement(By.linkText(element.getText()));
				val = true;
				break;
			} else
			{
				pagelogger.debug("Found left navigation element: " + element.getText()
						+ ". This is the not the element we want. Will loop back");
			}
		}

		if (val.equals(false))
		{
			throw new NoSuchElementException(
					"Could not locate the Cases Left Navigation element with the text: " + tabName);
		}

		setDriverContextToPage(driver);
		return this;

	}

	public boolean verifyIfSearchResultsAreValid(String searchTerm)
	{

		pagelogger.debug("Verifying Article Search Results: " + searchTerm);

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, knowledgeArticlesSearchResult);

		new WebDriverWait(driver, 30).until(ExpectedConditions
				.visibilityOfElementLocated(knowledgeArticlesSearchResult));

		List<WebElement> searchResults = findElements(knowledgeArticlesSearchResult);

		for (WebElement result : searchResults)
		{
			String articleTitle = result.getText();
			if (articleTitle.isEmpty() || articleTitle.contains(searchTerm))
			{
				continue;
			} else
			{
				return false;
			}

		}

		setDriverContextToPage(driver);
		return true;
	}

	public ServiceCloudCasesDetail searchForArticle(String searchTerm)
	{
		pagelogger.debug("Searching for the article: " + searchTerm);

		IframeUtils.setDriverContextToIframeWithDepth(driver, knowledgeArticleSearchInput);

		findElement(knowledgeArticleSearchInput).clear();
		findElement(knowledgeArticleSearchInput).sendKeys(searchTerm);
		clickOnElement(knowledgeArticleSearchButton);

		setDriverContextToPage(driver);
		return this;
	}

	public List<String> returnAllCaseRecordLabels()
	{

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, caseHeaderLocator);

		List<String> labels = SalesforcePageExtensions.returnAllLabelsAsList(driver);

		setDriverContextToPage(driver);
		return labels;
	}

	public boolean getAccountNameDisplayStatus()
	{
		pagelogger.debug("Checking the display status of Account Name...");

		synchronize(30);
		return findElement(accountNameSectionLocator).isDisplayed();
	}

	public boolean getContactNameDisplayStatus()
	{
		pagelogger.debug("Checking the display status of Contact Name...");
		synchronize(30);
		return findElement(contactNameSectionLocator).isDisplayed();
	}

	public boolean getContactEmailDisplayStatus()
	{
		pagelogger.debug("Checking the display status of Email...");
		synchronize(30);
		return findElement(contactEmailSectionLocator).isDisplayed();
	}

	public boolean getContactPhoneDisplayStatus()
	{
		pagelogger.debug("Checking the display status of Phone...");
		synchronize(30);
		return findElement(contactPhoneSectionLocator).isDisplayed();
	}

}
