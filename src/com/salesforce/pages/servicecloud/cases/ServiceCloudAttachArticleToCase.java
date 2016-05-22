package com.salesforce.pages.servicecloud.cases;

import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.driver.IframeUtils;
import com.salesforce.utils.driver.SalesforcePageExtensions;


public class ServiceCloudAttachArticleToCase extends PageBase 
{

	 
	private static ServiceCloudAttachArticleToCase instance;
	public static ServiceCloudAttachArticleToCase Instance = (instance != null) ? instance : new ServiceCloudAttachArticleToCase();

	
	/**UI Mappings */

	By searchArticleTextbox = By.xpath("//input[@id='knowledgeSearch']");
	By searchButton = By.xpath("//a[@id='searchBoxButton']");
	By loadingOverlay = By.xpath("//div[@class='articleList']//span[contains(text(),'Loading')]");
	By backToRequest = By.xpath("//a[contains(text(),'Back to request')]");
	
	
	/**Page Methods */

	public ServiceCloudAttachArticleToCase searchArticle(String articleName) 
	{
		pagelogger.debug("Searching for article to attach "  + articleName);

		synchronize(30);
		IframeUtils.setDriverContextToIframeWithDepth(driver, searchArticleTextbox);

		new WebDriverWait(driver, 30).until(ExpectedConditions.visibilityOfElementLocated(searchArticleTextbox));
		findElement(searchArticleTextbox).clear();
		findElement(searchArticleTextbox).sendKeys(articleName);
		clickOnElement(searchButton);
		
		new WebDriverWait(driver, 10).until(ExpectedConditions.visibilityOfElementLocated(loadingOverlay));
		new WebDriverWait(driver, 10).until(ExpectedConditions.invisibilityOfElementLocated(loadingOverlay));
		
		setDriverContextToPage(driver);
		return this;
	}
	
	
	public ServiceCloudAttachArticleToCase clickOnAttachArticle(String article) 
	{
		pagelogger.debug("Clicking on Edit Comment...");

		synchronize(30);
		new WebDriverWait(driver, 30).until(ExpectedConditions.titleContains(pageTitle));
		
		String actionArrow = "//a[contains(text(),'" + article + "')]/../../../..//a[contains(@class,'actionarrow')]";
		String attachToRequestOption = "//a[contains(text(),'" + article + "')]/../../../..//a[contains(text(),'Attach to request')]";

		IframeUtils.setDriverContextToIframeWithDepth(driver, By.xpath(actionArrow));
		clickOnElement(By.xpath(actionArrow));
		
		IframeUtils.setDriverContextToIframeWithDepth(driver,By.xpath(attachToRequestOption));
		clickOnElement(By.xpath(attachToRequestOption));
		
		String attachClipImage = "//a[contains(text(),'" + article + "')]/../img[@class='articleIcon']";
		new WebDriverWait(driver, 10).until(ExpectedConditions.visibilityOfElementLocated(By.xpath(attachClipImage)));
		
		setDriverContextToPage(driver);
		return ServiceCloudAttachArticleToCase.Instance;
	}

	
	public ServiceCloudCasesDetail clickOnBackToRequestLink() 
	{

		pagelogger.debug("Click on Back to request link");

		synchronize(30);
		new WebDriverWait(driver, 30).until(ExpectedConditions.titleContains(pageTitle));
		
		IframeUtils.setDriverContextToIframeWithDepth(driver, backToRequest);
		
		clickOnElement(backToRequest);
		
		setDriverContextToPage(driver);
		return ServiceCloudCasesDetail.Instance;
	}
	

	public ServiceCloudAttachArticleToCase verifyPageLoad() 
	{

		pagelogger.debug("Waiting for page load.");

		synchronize(30);
		SalesforcePageExtensions.waitForPageToLoad(driver);

		return this;
	}
	
	
}