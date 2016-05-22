package com.salesforce.pages.servicecloud.knowledge;

import java.util.List;

import org.openqa.selenium.By;
import org.openqa.selenium.Keys;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.TimeoutException;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;
import com.salesforce.utils.driver.ServiceCloudPageExtensions;

public class ServiceCloudKnowledgeHome extends PageBase
{

	private static ServiceCloudKnowledgeHome instance;
	public static ServiceCloudKnowledgeHome Instance = (instance != null) ? instance
			: new ServiceCloudKnowledgeHome();

	/** UI Mappings */

	String articleAnchor = "//a[contains(.,'{ArticleName}')]";
	By publishedStatusFilterLocator = By
			.xpath("//div[@id='filters_filters']/descendant::span[@id='PublishStatusFilterMenu']");
	By languageFilterLocator = By
			.xpath("//div[@id='filters_filters']/descendant::span[@id='LanguageFilterMenu']");
	By communityFilterLocator = By
			.xpath("//div[@id='filters_filters']/descendant::span[@id='CommunitiesMenu']");
	By audienceFilterLocator = By
			.xpath("//div[@id='filters_filters']/descendant::span[@id='IntendedAudienceMenu']");
	By marketFilterLocator = By
			.xpath("//div[@id='filters_filters']/descendant::span[@id='Market_SegmentMenu']");
	By articleTypeFilterLocator = By.xpath("//span[@id='ArticleTypeFilterMenu']");
	By validationStatusFilterLocator = By
			.xpath("//div[@id='filters_filters']/descendant::span[@id='ValidationStatusFilterMenu']");
	By resetLocator = By.linkText("Reset");
	By createArticleLocator = By
			.xpath("//div[@id='createNew']/descendant::span[text()='Create Article']");
	By sortByLocator = By.xpath("//h3/descendant::a[@class='sortclick zen-trigger']");
	By searchBoxLocator = By.xpath("//input[@id='knowledgeSearch']");
	By articleTypeFilterArrow = By
			.xpath("//div[@id='ArticleTypeFilterDropdown']//span[@class='arrow']");
	By articleTypeList = By.xpath("//ul[@id='ArticleTypeFilterOverlayList']/li");
	By allArticleTypeCheckBox = By.xpath("//input[@title='All Article Types']");
	By articleTypeApplyLink = By.xpath("//a[@title='Apply']");
	By articleTypeAllCheckbox = By.xpath("//label[text()='All Article Types']/../input");
	By knowledgeResults = By.xpath("//div[@class='articleList']//div");
	By productTypeFilterLocator = By
			.xpath("//div[@id='filters_filters']/descendant::span[@id='Product_TypeMenu']");
	String articleFilter = "//label[text()='{filter}']/../input";

	/** Page Methods */

	public ServiceCloudKnowledgeHome verifyPageLoad()
	{
		SalesforcePageExtensions.waitForPageToLoad(driver);
		return this;
	}

	public ServiceCloudKnowledgeHome selectPublishedStatusFilter(String filter)
	{
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, publishedStatusFilterLocator);

		pagelogger.debug("Selecting the Status filter: " + filter);

		ServiceCloudPageExtensions.selectFromOverlayList(driver, publishedStatusFilterLocator,
				filter);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudKnowledgeHome selectLanguageFilter(String filter)
	{
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, languageFilterLocator);

		pagelogger.debug("Selecting the Language filter: " + filter);

		ServiceCloudPageExtensions.selectFromOverlayList(driver, languageFilterLocator, filter);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudKnowledgeHome selectCommunityFilter(String filter)
	{
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, communityFilterLocator);

		pagelogger.debug("Selecting the Community filter: " + filter);

		ServiceCloudPageExtensions.selectFromOverlayList(driver, communityFilterLocator, filter);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudKnowledgeHome selectAudienceFilter(String filter)
	{
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, audienceFilterLocator);

		pagelogger.debug("Selecting the Audience filter: " + filter);

		ServiceCloudPageExtensions.selectFromOverlayList(driver, audienceFilterLocator, filter);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudKnowledgeHome selectProductTypeFilter(String filter)
	{
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, productTypeFilterLocator);

		pagelogger.debug("Selecting the Product Type filter: " + filter);

		ServiceCloudPageExtensions.selectFromOverlayList(driver, productTypeFilterLocator, filter);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudKnowledgeHome selectMarketFilter(String filter)
	{
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, marketFilterLocator);

		pagelogger.debug("Selecting the Market filter: " + filter);

		ServiceCloudPageExtensions.selectFromOverlayList(driver, marketFilterLocator, filter);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudKnowledgeHome selectArticleTypeFilters(List<String> articleTypeFilters)
	{
		IframeUtils.setDriverContextToIframeWithDepth(driver, articleTypeFilterArrow);

		clickOnElement(articleTypeFilterArrow);
		clickOnElement(allArticleTypeCheckBox);
		List<WebElement> listofArticleTypes = findElements(articleTypeList);

		for (WebElement articleType : listofArticleTypes)
		{
			WebElement element = articleType.findElement(By.tagName("input"));
			String title = element.getAttribute("title");

			if (articleTypeFilters.contains(title))
			{
				element.click();
			}
		}

		clickOnElement(articleTypeApplyLink);
		return this;
	}

	public ServiceCloudKnowledgeHome selectArticleTypeFilter(String filter)
	{
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, articleTypeFilterLocator);

		pagelogger.debug("Selecting the Article Type filter: " + filter);

		ServiceCloudPageExtensions.selectFromOverlayList(driver, articleTypeFilterLocator, filter);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudKnowledgeHome selectArticleTypeArrow()
	{
		IframeUtils.setDriverContextToIframeWithDepth(driver, articleTypeFilterLocator);

		clickOnElement(articleTypeFilterLocator);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudKnowledgeHome unCheckStartAllArticleType()
	{
		pagelogger.debug("Unchecking the All Article type checkbox");

		IframeUtils.setDriverContextToIframeWithDepth(driver, articleTypeAllCheckbox);

		if (findElement(articleTypeAllCheckbox).isSelected())
		{
			clickOnElement(articleTypeAllCheckbox);
		} else
		{
			pagelogger.debug("The all article type checkbox was already unchecked!");
		}

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudKnowledgeHome selectArticleTypeFilerFromOverLay(String filter)
	{
		By filterLocator = By.xpath(articleFilter.replace("{filter}", filter));

		IframeUtils.setDriverContextToIframeWithDepth(driver, filterLocator);

		clickOnElement(filterLocator);
		clickOnElement(articleTypeApplyLink);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudKnowledgeHome selectValidationStatusFilter(String filter)
	{

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, validationStatusFilterLocator);

		pagelogger.debug("Selecting the Validation Status filter: " + filter);

		new WebDriverWait(driver, 30).until(ExpectedConditions
				.visibilityOfElementLocated(validationStatusFilterLocator));

		ServiceCloudPageExtensions.selectFromOverlayList(driver, validationStatusFilterLocator,
				filter);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudKnowledgeDetail selectArticle(String article)
	{
		articleAnchor = articleAnchor.replace("{ArticleName}", article);
		By articleLink = By.xpath(articleAnchor);

		IframeUtils.setDriverContextToIframeWithDepth(driver, articleLink);

		clickOnElement(articleLink);

		setDriverContextToPage(driver);
		return ServiceCloudKnowledgeDetail.Instance;
	}

	public String getArticleScore(String article)
	{
		String score = "";

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, sortByLocator);

		List<WebElement> articles = findElements(By.linkText(article.trim()));
		// can also use syntax: //a[contains(., '" + article + "')]

		if (!(articles.size() < 1))
		{
			pagelogger.debug("Found article: " + article + ". Now getting the article Score...");
			score = driver
					.findElement(
							By.xpath("//a[contains(., '" + article
									+ "')]/../descendant::span[1]/img[@class='viewStat']"))
					.getAttribute("title").replace("View Score: ", "");

			pagelogger.debug("The score value: " + score);
		} else
		{
			pagelogger.debug("Could not locate the article with the text: " + article);
		}

		setDriverContextToPage(driver);
		return score;
	}

	public String getArticleRating(String article)
	{
		String rating = "";

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, sortByLocator);

		List<WebElement> articles = findElements(By.linkText(article.trim()));
		// can also use syntax: //a[contains(., '" + article + "')], but above
		// is an absolute link v.s. a potential partial

		if (!(articles.size() < 1))
		{
			pagelogger.debug("Found article: " + article + ". Now getting the article Rating...");
			rating = driver
					.findElement(
							By.xpath("//a[contains(., '" + article
									+ "')]/../descendant::span[1]/img[@class='voteStat']"))
					.getAttribute("title").replace("Rating: ", "");

			pagelogger.debug("The rating value: " + rating);
		} else
		{
			pagelogger.debug("Could not locate the article with the text: " + article);
		}

		setDriverContextToPage(driver);
		return rating;
	}

	public ServiceCloudKnowledgeHome searchKnowledge(String searchText)
	{

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, sortByLocator);

		new WebDriverWait(driver, 30).until(ExpectedConditions
				.presenceOfElementLocated(searchBoxLocator));

		pagelogger.debug("Entering and searching for text: " + searchText);

		findElement(searchBoxLocator).clear();
		findElement(searchBoxLocator).sendKeys(searchText);
		findElement(searchBoxLocator).sendKeys(Keys.RETURN);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudKnowledgeHome sortBy(String sortType)
	{

		synchronize(30);

		for (int i = 1; i < 4; i++)
		{
			try
			{
				IframeUtils.setDriverContextToIframeWithDepth(driver, sortByLocator);

				new WebDriverWait(driver, 20).until(ExpectedConditions
						.presenceOfElementLocated(sortByLocator));
				break;
			} catch (TimeoutException e)
			{
				pagelogger.debug("Browser timed out trying to find the sort by element");

			}

			i = i + 1;

		}

		pagelogger.debug("Sorting Knowledge contents as: " + sortType);

		ServiceCloudPageExtensions.selectFromOverlayList(driver, sortByLocator, sortType);
		setDriverContextToPage(driver);

		return this;
	}

	public ServiceCloudKnowledgeHome reset()
	{
		IframeUtils.setDriverContextToIframeWithDepth(driver, sortByLocator);

		pagelogger.debug("Resetting the search form...");

		clickOnElement(resetLocator);

		setDriverContextToPage(driver);
		return this;
	}

	public ServiceCloudKnowledgeHome selectFromLeftNav(String navItem)
	{
		Boolean found = false;

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, sortByLocator);

		List<WebElement> links = findElements(By.xpath("//div[@id='left-column']/descendant::a"));

		for (WebElement link : links)
		{

			pagelogger.debug("Comparing found link [" + link.getText() + "] to passed in value ["
					+ navItem + "]");

			if (link.getText().toUpperCase().equals(navItem.toUpperCase()))
			{
				pagelogger.debug("Found the nav bar link on Knowledge - will click it");
				link.click();
				found = true;
				break;
			} else
			{
				pagelogger.debug("Found nav bar link: " + link.getText() + " This does not match "
						+ navItem + ". Will loop back");
			}
		}

		setDriverContextToPage(driver);

		if (!found.equals(true))
		{
			throw new NoSuchElementException(
					"The passed in link was not found within the Knowledge articles left Link bar: "
							+ navItem);
		}

		return this;
	}

	public boolean isKnowledgeResultPresent()
	{
		boolean isFound = false;
		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, knowledgeResults);

		try
		{
			if (findElements(knowledgeResults).size() > 0)
			{
				isFound = true;
			}
		} catch (NoSuchElementException e)
		{
			pagelogger.debug("No Knowledge Result found");
		}

		return isFound;
	}

}
