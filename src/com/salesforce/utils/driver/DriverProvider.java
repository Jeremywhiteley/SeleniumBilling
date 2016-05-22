package com.salesforce.utils.driver;

import org.openqa.selenium.WebDriver;


public class DriverProvider {

	public static ThreadLocal<WebDriver> Driver;

	public static void setDriver(ThreadLocal<WebDriver> driver)
	{
		Driver = driver;
	}

	public WebDriver getDriver() {
		return Driver.get();
	}
}
