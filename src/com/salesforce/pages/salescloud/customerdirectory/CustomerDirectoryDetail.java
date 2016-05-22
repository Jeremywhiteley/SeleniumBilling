package com.salesforce.pages.salescloud.customerdirectory;

import org.openqa.selenium.By;

import com.salesforce.pages.PageBase;

public class CustomerDirectoryDetail extends PageBase {

	 
	private static CustomerDirectoryDetail instance;
	public static CustomerDirectoryDetail Instance = (instance != null) ? instance : new CustomerDirectoryDetail();

	/** UI Mappings */

	By streetAddressLocator = By.xpath("//tr/td[text()='Residential Street']/following::td[@class='dataCol']	");
	By cityLocator = By.xpath("//tr/td[text()='Residential City']/following::td[@class='dataCol']");
	By stateLocator = By.xpath("//tr/td[text()='Residential State']/following::td[@class='dataCol']");
	By zipCodeLocator = By.xpath("//tr/td[text()='Residential Zip Code']/following::td[@class='dataCol']");

	/** Page Methods */

	public CustomerDirectoryDetail verifyPageLoad() {
		pagelogger.debug("Waiting for page to load");

		findElement(streetAddressLocator);
		return this;
	}

	public String getStreetAddress() {
		pagelogger.debug("Getting the Customer Street address.");

		String val = findElement(streetAddressLocator).getText();

		return val.trim();
	}

	public String getCity() {
		pagelogger.debug("Getting the city.");

		String val = findElement(cityLocator).getText();

		return val.trim();
	}

	public String getState() {
		pagelogger.debug("Getting the State..");

		String val = findElement(stateLocator).getText();

		return val.trim();
	}

	public String getZipcode() {
		pagelogger.debug("Getting the Zipcode");

		String val = findElement(zipCodeLocator).getText();

		return val.trim();
	}

}
