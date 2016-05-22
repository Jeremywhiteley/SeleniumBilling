package com.salesforce.utils.driver;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.Select;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.CommonMethods;

public class VerifyPageElementsExtensions extends PageBase
{

	/**
	 * Compares a defined array of Strings with found <Options> for the passed
	 * in parent <Select> object
	 * 
	 * @param parent
	 * @param searchValues
	 * @return true / false, logs any values that did not match up as expected
	 */
	public static boolean verifySelectOptions(WebDriver driver, By parent, String[] searchValues)
	{
		boolean val = false;

		PageBase.Instance.pagelogger.debug("Number of passed in Options to verify: "
				+ searchValues.length);

		IframeUtils.setDriverContextToIframeWithDepth(driver, parent);
		WebElement select = findElement(parent);
		Select dropdown = new Select(select);

		List<WebElement> Options = dropdown.getOptions();
		String[] foundOptions = CommonMethods.convertListToArray(Options);
		foundOptions = CommonMethods.trimElementsInAArray(foundOptions);
		searchValues = CommonMethods.trimElementsInAArray(searchValues);

		Set<String> diffs = CommonMethods.getArrayDifference(searchValues, foundOptions);

		if (diffs.size() > 0)
		{
			PageBase.Instance.pagelogger
					.debug("Your Select Options did not match up with Options found!. The following differences were returned: "
							+ diffs.toString());
			val = false;
		} else
		{
			PageBase.Instance.pagelogger
					.debug("No differences were found between the passed in Select Options and found Options!");
			val = true;
		}

		setDriverContextToPage(driver);
		return val;
	}

	/**
	 * Method used to validate whether all passed in field labels exist on the
	 * current page NOTE: This method uses the <span> element to point to the
	 * field label. Field labels are typically housed within a span or table
	 * cell <td>
	 * 
	 * @param driver
	 * @param fields
	 * @return: List object containing all labels not found
	 */
	public static List<String> verifyAllFieldLabelsExist(WebDriver driver, String[] fields)
	{
		boolean found = false;
		List<String> errorList = new ArrayList<String>();

		List<WebElement> elements = null;
		elements = findElements(By.tagName("span"));

		if (fields.length < 1)
		{
			PageBase.Instance.pagelogger
					.debug("You must pass at least one value into verifyAllFieldsExist()!");
			throw new IllegalArgumentException(
					"No fields were passed into function: verifyAllFieldsExist()");
		}

		for (int i = 0; i < fields.length; i++)
		{

			for (WebElement element : elements)
			{
				if (element.getText().trim().equals(fields[i].trim()))
				{
					PageBase.Instance.pagelogger.debug("Found the passed in field: " + fields[i]);
					found = true;
					break;
				}
			}

			if (found == false)
			{
				PageBase.Instance.pagelogger.debug("ERROR: Field was not found: "
						+ fields[i].toString());
				errorList.add(fields[i].toString());
			} else
			{
				found = false;
			}
		}

		return errorList;
	}

	/**
	 * Method used to validate whether all passed in field labels exist on the
	 * current page NOTE: This method uses the <td>element to point to the field
	 * label. Field labels are typically housed within a span or table cell <td>
	 * 
	 * @param driver
	 * @param fields
	 * @return: List object containing all labels not found
	 */
	public static List<String> verifyAllTDValuesExist(WebDriver driver, String[] fields)
	{
		boolean found = false;
		List<String> errorList = new ArrayList<String>();

		List<WebElement> elements = null;
		elements = findElements(By.tagName("td"));

		if (fields.length < 1)
		{
			PageBase.Instance.pagelogger
					.debug("You must pass at least one value into verifyAllFieldsExist()!");
			throw new IllegalArgumentException(
					"No fields were passed into function: verifyAllFieldsExist()");
		}

		for (int i = 0; i < fields.length; i++)
		{

			for (WebElement element : elements)
			{

				if (element.getText().trim().equals(fields[i].trim()))
				{
					PageBase.Instance.pagelogger.debug("Found the passed in field: " + fields[i]);
					found = true;
					break;
				}
			}

			if (found == false)
			{
				PageBase.Instance.pagelogger.debug("ERROR: Field was not found: "
						+ fields[i].toString());
				errorList.add(fields[i].toString());
			} else
			{
				found = false;
			}
		}

		return errorList;
	}

	/**
	 * Method used to validate whether all passed in field labels exist on the
	 * current page NOTE: This method uses the <td>element AND <span> element to
	 * point to the field label. Field labels are typically housed within a span
	 * or table cell <td>in almost all cases NOTE: This method can be used
	 * instead of verifyalltd/verifyalllabel methods without issue NOTE: May
	 * want to deprecate above mentioned methods -JDAPPER
	 * 
	 * @param driver
	 * @param fields
	 * @return: List object containing all labels not found
	 */
	public static List<String> verifyAllFieldLabelsAndTDsExist(WebDriver driver, String[] fields)
	{
		boolean found = false;
		List<String> errorList = new ArrayList<String>();

		List<WebElement> elements = null;
		elements = findElements(By.tagName("span"));

		List<WebElement> elementstd = null;
		elementstd = findElements(By.tagName("td"));

		if (fields.length < 1)
		{
			PageBase.Instance.pagelogger
					.debug("You must pass at least one value into verifyAllFieldsExist()!");
			throw new IllegalArgumentException(
					"No fields were passed into function: verifyAllFieldsExist()");
		}

		for (int i = 0; i < fields.length; i++)
		{

			for (WebElement element : elements)
			{
				if (element.getText().trim().equals(fields[i].trim()))
				{
					PageBase.Instance.pagelogger.debug("Found the passed in field: " + fields[i]);
					found = true;
					break;
				}
			}

			if (found == false)
			{

				for (int y = 0; y < fields.length; y++)
				{

					for (WebElement elementtd : elementstd)
					{
						if (elementtd.getText().trim().equals(fields[y].trim()))
						{
							PageBase.Instance.pagelogger.debug("Found the passed in field: "
									+ fields[y]);
							found = true;
							break;
						}
					}
				}

			}

			if (found == false)
			{
				PageBase.Instance.pagelogger.debug("ERROR: Field was not found: "
						+ fields[i].toString());
				errorList.add(fields[i].toString());
			} else
			{
				found = false;
			}
		}

		return errorList;
	}

	/**
	 * Method used to validate whether all passed in Header labels exist on the
	 * current page
	 * 
	 * @param driver
	 * @param fields
	 * @return: List object containing all headers not found
	 */
	public static List<String> verifyAllHeaderValuesExist(WebDriver driver, String[] fields)
	{
		boolean found = false;
		List<String> errorList = new ArrayList<String>();

		List<WebElement> elements = null;
		elements = findElements(By.tagName("h3"));

		if (fields.length < 1)
		{
			PageBase.Instance.pagelogger
					.debug("You must pass at least one value into verifyAllFieldsExist()!");
			throw new IllegalArgumentException(
					"No fields were passed into function: verifyAllFieldsExist()");
		}

		for (int i = 0; i < fields.length; i++)
		{

			for (WebElement element : elements)
			{

				if (element.getText().trim().equals(fields[i].trim()))
				{
					PageBase.Instance.pagelogger.debug("Found the passed in field: " + fields[i]);
					found = true;
					break;
				}
			}

			if (found == false)
			{
				PageBase.Instance.pagelogger.debug("ERROR: Field was not found: "
						+ fields[i].toString());
				errorList.add(fields[i].toString());
			} else
			{
				found = false;
			}
		}

		return errorList;
	}

	/**
	 * Method used to determine whether an array of field names are located and
	 * ENABLED on the current page
	 * 
	 * @param driver
	 * @param fields
	 * @return: List of fields that are NOT enabled on the current page
	 */
	public static List<String> verifyFieldsAreEnabled(WebDriver driver, String[] fields)
	{
		List<String> errorList = new ArrayList<String>();
		String convertedFieldID = "";

		if (fields.length < 1)
		{
			PageBase.Instance.pagelogger
					.debug("You must pass at least one value into verifyAllFieldsExist()!");
			throw new IllegalArgumentException(
					"No fields were passed into function: verifyAllFieldsExist()");
		}

		for (int i = 0; i < fields.length; i++)
		{
			convertedFieldID = SalesforcePageExtensions.getControlIDByXpath(driver, fields[i]
					.trim().toString());

			if (findElement(By.id(convertedFieldID)).isEnabled() == false)
			{
				PageBase.Instance.pagelogger
						.debug("ERROR: The following field was found to be disabled: " + fields[i]);
				errorList.add(fields[i].toString());
			}
		}

		return errorList;
	}

	/**
	 * Method used to determine whether a field on a record page is LOCKED or
	 * not
	 * 
	 * @param driver
	 * @param id
	 * @return: Boolean indicating whether a field is locked or not (true=yes,
	 *          false=no)
	 */
	public static boolean verifyInlineFieldLockStatus(WebDriver driver, String id)
	{
		boolean rtrn = false;
		String val = findElement(By.id(id)).getAttribute("class");

		if (val.indexOf("inlineEditLock") != -1)
		{
			PageBase.Instance.pagelogger.debug("Lock status returned TRUE");
			rtrn = true;
		} else
		{
			PageBase.Instance.pagelogger.debug("Lock status returned FALSE");
		}

		return rtrn;
	}
}