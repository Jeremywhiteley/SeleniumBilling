package com.salesforce.utils.datastore;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.text.ParseException;
import java.util.Date;
import java.util.Properties;

import org.apache.commons.io.FileUtils;
import org.openqa.selenium.OutputType;
import org.openqa.selenium.TakesScreenshot;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebDriverException;

import com.salesforce.utils.UtilBase;
import com.salesforce.utils.driver.SalesforcePageExtensions;

public class FileIO extends UtilBase
{

	private static Properties prop = new Properties();
	private static InputStream input = null;
	private static OutputStream output = null;

	/**
	 * Method used to create an images directory (for screenshots) within the
	 * filesystem
	 * 
	 * @param directory
	 */
	public static void createImagesDirectory(String directory)
	{
		directory = FileIO.getConfigProperty("ReportImagesDir");

		try
		{

			UtilBase.Instance.utillogger
					.debug("Directory: " + "\"" + directory + "\"" + " created");

		} catch (Exception e)
		{
			UtilBase.Instance.utillogger.debug("Error: " + "\"" + e.getMessage() + "\"");
		}
	}

	/**
	 * Method used to take a screenshot and move it to the appropriate test
	 * class directory
	 * 
	 * @param driver
	 * @param className
	 * @throws ParseException
	 */
	public static void takeScreenShot(WebDriver driver, String className)
	{
		UtilBase.Instance.utillogger
				.debug("Taking screenshot for test: " + "\"" + className + "\"");

		boolean sendToDatabase = Boolean.parseBoolean(FileIO.getConfigProperty("UseDB"));
		SalesforcePageExtensions.waitForPageToLoad(driver);

		try
		{
			File screenshot = ((TakesScreenshot) driver).getScreenshotAs(OutputType.FILE);
			File destination = new File(FileIO.getConfigProperty("ReportImagesDir") + className);

			if (sendToDatabase == true)
			{
				MySQLConnect.insertPictureInDB(screenshot);
			}

			FileUtils.copyFileToDirectory(screenshot, destination);
			screenshot.delete();

		} catch (WebDriverException e)
		{
			UtilBase.Instance.utillogger
					.debug("There was an issue taking a screenshot (Base64 Error Type). An image will not be taken at this step.");
			e.printStackTrace();
		} catch (IOException f)
		{
			UtilBase.Instance.utillogger
					.debug("There was an issue with the method copyFileToDirectory of the library commons-io-2.2-File copy failed");
			f.printStackTrace();
		} catch (ParseException p)
		{
			UtilBase.Instance.utillogger
					.debug("There was an issue reading the image file into the DB.");
			p.printStackTrace();
		}

	}

	public static String getDownloadDirectoryPath()
	{
		UtilBase.Instance.utillogger.debug("Getting the download directory path...");

		String workingDir = System.getProperty("user.dir");
		return workingDir + "/file_downloads";
	}

	public static boolean checkIfFileExists(String path) throws InterruptedException
	{
		UtilBase.Instance.utillogger.debug("Checking to see if the file exists at the path: "
				+ path);

		File f = new File(path);
		Thread.sleep(5000);
		if (f.exists())
		{
			return true;
		} else
			return false;
	}

	public static boolean deleteFile(String path)
	{
		UtilBase.Instance.utillogger.debug("Deleting the file at the path: " + path);

		File file = new File(path);

		if (file.delete())
		{
			return true;
		} else
		{
			return false;
		}

	}

	/**
	 * Function used to write very specific strings to a text file associated
	 * with each test run. Typically only used in edge cases where very specific
	 * debugging needs are required.
	 * 
	 * @param errorMsg
	 * @throws IOException
	 */
	public static void writeToLogFile(String errorMsg) throws IOException
	{
		Date date = new Date();
		FileUtils.writeStringToFile(new File(FileIO.getConfigProperty("SystemLogFile")),
				date.toString() + ": " + errorMsg + "\n", true);
	}

	/**
	 * Method used to search a text file for a specific string.
	 * 
	 * @param textFileName
	 * @param searchText
	 * @return: True/False whether the search text was found
	 * @throws IOException
	 */
	public static String searchTextFile(String textFileName, String searchText) throws IOException
	{
		BufferedReader br = new BufferedReader(new FileReader(textFileName));
		String line;
		Boolean found = false;
		int counter = 1;

		while ((line = br.readLine()) != null)
		{

			if (line.indexOf(searchText) != -1)
			{
				found = true;
				UtilBase.Instance.utillogger.debug("Found the text at line: " + counter
						+ ". Returning the line's text.");
				break;
			} else
			{
				counter++;
			}
		}

		br.close();

		if (found == false)
		{
			line = "VALUE NOT FOUND IN SPECIFIED TEXT FILE!";
		}

		return line;
	}

	/**
	 * Method used to read/return a property value from config.properties
	 * 
	 * @param propertyName
	 * @return: Value associated with passed in Key
	 */
	public static String getConfigProperty(String propertyName)
	{

		Properties prop = new Properties();
		String propertyValue = null;

		try
		{
			prop.load(FileIO.class.getClassLoader()
					.getResourceAsStream(("config_local.properties")));
			propertyValue = prop.getProperty(propertyName);

		} catch (FileNotFoundException e)
		{
			e.printStackTrace();

		} catch (IOException e)
		{
			e.printStackTrace();
		}

		return propertyValue;
	}

	public static String getIFrameId(String methodName)
	{
		return prop.getProperty(methodName);
	}

	public static void setIframeId(String methodName, String id)
	{

		try
		{
			output = new FileOutputStream("config/IframeIdMap.properties");
			prop.setProperty(methodName, id);
			prop.store(output, null);
			output.close();
		} catch (FileNotFoundException e)
		{
			e.printStackTrace();
		} catch (IOException e)
		{
			e.printStackTrace();
		}
	}

	public static void loadIframeIdPropFile()
	{
		UtilBase.Instance.utillogger.debug("Loading iFrame ID Cache...");

		try
		{
			input = new FileInputStream("config/IframeIdMap.properties");
			prop.load(input);
		} catch (FileNotFoundException e)
		{
			e.printStackTrace();
		} catch (IOException e)
		{
			e.printStackTrace();
		}
	}

	public static void closeIFrameIdPropFile()
	{
		try
		{
			input.close();
		} catch (IOException e)
		{
			e.printStackTrace();
		}

	}

	/**
	 * Method used to SET a property values within config.properties based upon
	 * a passed in KEY
	 * 
	 * @param propertyName
	 * @param propertyValue
	 * @return: NA NOTE: Perhaps change return to success/failure? -JDAPPER
	 */
	public static String setConfigProperty(String propertyName, String propertyValue)
	{

		UtilBase.Instance.utillogger.info("Setting the Config Property Key [" + propertyName
				+ "] to Value: " + propertyValue);

		final File propFile = new File("./config/config_local.properties");
		Properties prop = new Properties();

		try
		{
			prop.load(new FileInputStream(propFile));
			prop.setProperty(propertyName, propertyValue);
			prop.store(new FileOutputStream(propFile), "");

		} catch (FileNotFoundException e)
		{
			e.printStackTrace();

		} catch (IOException e)
		{
			e.printStackTrace();
		}

		return propertyValue;
	}

}
