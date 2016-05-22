package com.salesforce.pages.salescloud;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;


public class AllTabsDetail extends PageBase
{

	 
	private static AllTabsDetail instance;
	public static AllTabsDetail Instance = (instance != null) ? instance : new AllTabsDetail();

	
	/**UI Mappings */
	
	By showAllTabsLocator = By.cssSelector("img[title='All Tabs']");
	By showViewOptionsLocator = By.xpath("//td/form/h3/label[text()='View:']/following::select");
	By customizeTabsLocator = By.cssSelector("input[value='Customize My Tabs']");
	
	
	
	/**Page Methods*/
	
	public void verifyPageLoad()
	{
		findElement(customizeTabsLocator);
	}
	
	
	public void selectTabByLinkText(String tabName)
	{
		clickOnElement(By.linkText(tabName));
	}
		
	
	public void selectViewType(String viewText)
	{
		clickOnElement(showViewOptionsLocator);
		clickOnElement(By.linkText(viewText));
	}
	
	
	public void selectCustomizeTabs()
	{
		clickOnElement(customizeTabsLocator);
	}
	
	
}
