package com.salesforce.pages.setup;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;


public class SetupHome extends PageBase
{

	 
	private static SetupHome instance;
	public static SetupHome Instance = (instance != null) ? instance : new SetupHome();

	
	/** UI Mappings */

	By manageUsersLocator = By.xpath("//a[text()='Manage Users']");
	By timebasedWorkflowLocator = By.xpath("//div/a[text()='Time-Based Workflow']");

	
	/** Page Methods */

	public SetupUsersDetail manageUsers(String subMenu)
	{
		pagelogger.debug("Clicking on Manage Users");

		clickOnElement(manageUsersLocator);

		By currSubMenu = By.xpath("//a[text()='" + subMenu + "']");
		clickOnElement(currSubMenu);

		return SetupUsersDetail.Instance;
	}
}
