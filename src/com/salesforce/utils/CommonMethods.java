package com.salesforce.utils;

import java.text.DateFormat;
import java.text.DecimalFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Random;
import java.util.Set;

import org.openqa.selenium.WebElement;

import com.salesforce.utils.datastore.FileIO;

public class CommonMethods extends UtilBase
{
	/**
	 * Method used to determine the current date
	 * 
	 * @param formatStyle
	 *            : Parameter utilized to format the date into the style which
	 *            it will be returned as
	 * @return date
	 */

	public static String getCurrentDate(String formatStyle)
	{
		String dateValue = null;
		if (formatStyle.toUpperCase() == "VERBOSE")
		{
			dateValue = new SimpleDateFormat("yyyyMMdd_HHmmss").format(Calendar.getInstance()
					.getTime());
		} else if (formatStyle.toUpperCase() == "CALENDAR")
		{
			dateValue = new SimpleDateFormat("MM/dd/yyyy").format(Calendar.getInstance().getTime());
		} else if (formatStyle.toUpperCase() == "CLEAN")
		{
			dateValue = new SimpleDateFormat("h:mm a, MMMM dd, yyyy").format(Calendar.getInstance()
					.getTime());
		} else if (formatStyle.toUpperCase() == "STANDARD")
		{
			dateValue = new SimpleDateFormat("MM/dd/yyyy").format(Calendar.getInstance().getTime());
		} else if (formatStyle.toUpperCase() == "SHORTDAYMONTH")
		{
			dateValue = new SimpleDateFormat("M/d/yyyy").format(Calendar.getInstance().getTime());
		} else if (formatStyle.toUpperCase() == "LONGYEAR")
		{
			dateValue = new SimpleDateFormat("yyyy").format(Calendar.getInstance().getTime());
		} else if (formatStyle.toUpperCase() == "MYSQL")
		{
			dateValue = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(Calendar
					.getInstance().getTime());
		}

		return dateValue;
	}

	public static boolean doesListContainString(List<String> list, String searchTerm)
	{
		searchTerm = searchTerm.toLowerCase();

		for (String str : list)
		{
			if (str.trim().toLowerCase().contains(searchTerm))
				return true;
		}

		return false;
	}

	public static boolean VerifyIfList1ContainsList2(List<String> one, List<String> two)
	{
		UtilBase.Instance.utillogger.debug("Will now verify the union of two list objects...");
		UtilBase.Instance.utillogger.debug("List one contents: " + one.toString());
		UtilBase.Instance.utillogger.debug("List two contents: " + two.toString());

		if (one.containsAll(two))
		{
			UtilBase.Instance.utillogger.debug("The union of list 1 and 2 was found to be exact!");
			return true;
		} else
		{
			UtilBase.Instance.utillogger.debug("Differences were found!");
		}

		return false;
	}

	public static String[] trimElementsInAArray(String[] elements)
	{
		UtilBase.Instance.utillogger.debug("Trimming all elements in the array!");

		for (int i = 0; i < elements.length; i++)
		{
			elements[i] = elements[i].trim();
		}

		return elements;
	}

	/**
	 * Method used to format a passed in string
	 * 
	 * @param formatStyle
	 *            : Parameter utilized to format the date into the style which
	 *            it will be returned as
	 * @return date
	 * @throws ParseException
	 */
	public static String formatDate(String formatStyle, String inputDate) throws ParseException
	{
		String dateValue = "";

		DateFormat convertToDate = new SimpleDateFormat("MM/dd/yyyy");
		Date passedInDate = convertToDate.parse(inputDate);

		if (formatStyle.toUpperCase() == "VERBOSE")
		{
			DateFormat style = new SimpleDateFormat("yyyyMMdd_HHmmss");
			dateValue = style.format(passedInDate);

		} else if (formatStyle.toUpperCase() == "SHORTDAYMONTH")
		{
			DateFormat style = new SimpleDateFormat("M/d/yyyy");
			dateValue = style.format(passedInDate);
		}

		return dateValue;
	}

	/**
	 * Method used to format a string into a decimal with x number of decimal
	 * places
	 * 
	 * @param formatStyle
	 *            - value associated with the number of decimal places the
	 *            passed in val should be rounded to
	 * @param val
	 * @return
	 * @throws ParseException
	 */
	public static String formatDecimal(String formatStyle, double val) throws ParseException
	{
		String rtrn = "";

		if (formatStyle.toUpperCase() == "2 DECIMAL")
		{
			DecimalFormat style = new DecimalFormat("##.00");
			rtrn = style.format(val);

		} else if (formatStyle.toUpperCase() == "3 DECIMAL")
		{
			DecimalFormat style = new DecimalFormat("##.000");
			rtrn = style.format(val);
		}

		return rtrn;
	}

	/**
	 * Method used to format a passed in date
	 * 
	 * @param formatStyle
	 *            : Parameter utilized to format the date into the style which
	 *            it will be returned as
	 * @return date
	 * @throws ParseException
	 */
	public static String formatTime(String formatStyle, String time) throws ParseException
	{
		String timeValue = "";

		DateFormat convertToDate = new SimpleDateFormat("hh:mm aa");
		Date passedInTime = convertToDate.parse(time);

		if (formatStyle.toUpperCase() == "24-WITH-AMPM")
		{
			DateFormat style = new SimpleDateFormat("HH:mm a");
			timeValue = style.format(passedInTime);

		} else if (formatStyle.toUpperCase() == "12-WITH-AMPM")
		{
			DateFormat style = new SimpleDateFormat("hh:mm a");
			timeValue = style.format(passedInTime);
		}

		return timeValue;
	}

	/**
	 * Method used to return a future date value
	 * 
	 * @param formatStyle
	 *            : Pamarater utilized to determine the format of the returned
	 *            date
	 * @param numDaysInFuture
	 *            : How far into the future (in days) that the date will be
	 *            returned as
	 * @return a future date
	 */
	public static String getFutureDate(String formatStyle, int numDaysInFuture)
	{
		String dateValue = null;
		Date date = new Date();

		Calendar c = Calendar.getInstance();
		c.setTime(date);
		c.add(Calendar.DATE, numDaysInFuture);
		date = c.getTime();

		if (formatStyle.toUpperCase() == "VERBOSE")
		{
			dateValue = new SimpleDateFormat("yyyyMMdd_HHmmss").format(date);
		} else if (formatStyle.toUpperCase() == "CALENDAR")
		{
			dateValue = new SimpleDateFormat("MM/dd/yyyy").format(date);
		} else if (formatStyle.toUpperCase() == "CLEAN")
		{
			dateValue = new SimpleDateFormat("h:mm a, MMMM dd, yyyy").format(date);
		} else if (formatStyle.toUpperCase() == "STANDARD")
		{
			dateValue = new SimpleDateFormat("MM/dd/yyyy").format(date);
		} else if (formatStyle.toUpperCase() == "SHORTDAYMONTH")
		{
			dateValue = new SimpleDateFormat("M/d/yyyy").format(date);
		} else if (formatStyle.toUpperCase() == "LONGYEAR")
		{
			dateValue = new SimpleDateFormat("yyyy").format(date);
		} else if (formatStyle.toUpperCase() == "STANDARD_TIME")
		{
			dateValue = new SimpleDateFormat("MM/dd/yyyy hh:mm aaa").format(date);
		}

		return dateValue;
	}

	/**
	 * Convert a passed in string date to a date.date
	 * 
	 * @param strDate
	 * @return
	 * @throws ParseException
	 */
	public static Date convertStringToDate(String strDate) throws ParseException
	{
		Date date = new SimpleDateFormat("M/d/yyyy", Locale.ENGLISH).parse(strDate);

		return date;
	}

	/**
	 * Method used to convert a List object to an Array object
	 * 
	 * @param listName
	 *            : Name of the passed in List object
	 * @return: New Array object holding the List object contents
	 */
	public static String[] convertListToArray(List<WebElement> listName)
	{
		Object[] objTemp = listName.toArray();
		String[] newArray = new String[objTemp.length];

		UtilBase.Instance.utillogger.debug("Converting List to Array of the length (Base Zero): "
				+ (listName.size() - 1));

		for (int i = 0; i < objTemp.length; i++)
		{
			newArray[i] = ((WebElement) objTemp[i]).getText();
			UtilBase.Instance.utillogger.debug("Added value: " + newArray[i].toString()
					+ " at index: " + i);
		}

		return newArray;
	}

	/**
	 * Method used to sort a List object Alphabetically
	 * 
	 * @param listName
	 *            : Name of passed in List object
	 * @return: New List object holding the contents of the passed in List,
	 *          sorted Alphabetically
	 */
	public static List<String> sortListAlphabetically(List<String> listName)
	{
		UtilBase.Instance.utillogger.debug("Now Sorting List alphabetically");
		Collections.sort(listName);

		return listName;
	}

	/**
	 * Method used to determine the difference between two arrays. Also sets a
	 * property flag (1/2) noting whether the operation found a difference
	 * 
	 * @param searchValues
	 *            : First array to be compared
	 * @param foundOptions
	 *            : Second array to be compared
	 * @return: new Set<String> with the difference.
	 */
	public static Set<String> getArrayDifference(String[] searchValues, String[] foundOptions)
	{
		UtilBase.Instance.utillogger.debug("Now comparing arrays and returning the difference");

		Set<String> base = new HashSet<String>(Arrays.asList(searchValues));
		base.addAll(Arrays.asList(foundOptions));

		Set<String> intersection = new HashSet<String>(Arrays.asList(searchValues));
		intersection.retainAll(Arrays.asList(foundOptions));

		base.removeAll(intersection);

		if (base.isEmpty())
		{
			UtilBase.Instance.utillogger.debug("The array difference was empty!");
		} else
		{
			FileIO.setConfigProperty("ArrayDifferenceFoundFlag", "1");
		}
		return base;
	}

	/**
	 * Method used to determine the intersection of two arrays.
	 * 
	 * @param searchValues
	 *            : First array to be compared
	 * @param foundOptions
	 *            : Second array to be compared
	 * @return: new array with the intersection of the type Set<String>
	 */
	public static Set<String> getArrayIntersection(String[] searchValues, String[] foundOptions)
	{
		UtilBase.Instance.utillogger.debug("Now comparing arrays and returning the intersection");

		Set<String> s1 = new HashSet<String>(Arrays.asList(searchValues));
		Set<String> s2 = new HashSet<String>(Arrays.asList(foundOptions));
		s1.retainAll(s2);

		String[] result = s1.toArray(new String[s1.size()]);
		Set<String> base = new HashSet<String>(Arrays.asList(result));

		return base;
	}

	/**
	 * Method used to determine the union of two arrays.
	 * 
	 * @param searchValues
	 *            : First array to be compared
	 * @param foundOptions
	 *            : Second array to be compared
	 * @return: new array with the union of the type Set<String>.
	 */
	public static Set<String> getArrayUnion(String[] searchValues, String[] foundOptions)
	{
		UtilBase.Instance.utillogger.debug("Now comparing arrays and returning the union");

		Set<String> s1 = new HashSet<String>(Arrays.asList(searchValues));
		Set<String> s2 = new HashSet<String>(Arrays.asList(foundOptions));
		s1.addAll(s2);

		String[] result = s1.toArray(new String[s1.size()]);
		Set<String> base = new HashSet<String>(Arrays.asList(result));

		return base;
	}

	public static boolean isSortedList(List<String> list)
	{

		if (list == null || list.isEmpty())
		{
			return false;
		}

		if (list.size() == 1)
		{
			return true;
		}

		for (int i = 1; i < list.size(); i++)
		{
			if (list.get(i).compareToIgnoreCase(list.get(i - 1)) < 0)
			{
				return false;
			}
		}

		return true;
	}

	/**
	 * Method used to generate a random Alphabetic string of a passed in length
	 * 
	 * @param length
	 *            : Length of the returned string
	 * @return: Randomly generated Alphabetic String
	 */
	public static String generateRandomString(int length)
	{
		Random rnd = new Random();

		String characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
		char[] text = new char[length];

		for (int i = 0; i < length; i++)
		{
			text[i] = characters.charAt(rnd.nextInt(characters.length()));
		}

		return new String(text);
	}

	/**
	 * Method used to generate a random Numeric string of a passed in length
	 * 
	 * @param length
	 *            : Length of the returned string
	 * @return: Randomly generated Numeric String
	 */
	public static String generateRandomNumber(int length)
	{
		Random rnd = new Random();

		String characters = "123456789";
		char[] text = new char[length];

		for (int i = 0; i < length; i++)
		{
			text[i] = characters.charAt(rnd.nextInt(characters.length()));
		}

		return new String(text);
	}

	public static String getCustomStackTrace(Throwable t)
	{
		StringBuilder result = new StringBuilder("Exception: ");
		result.append(t.toString());

		String NEW_LINE = System.getProperty("line.separator");
		result.append(NEW_LINE);
		result.append(NEW_LINE);

		for (StackTraceElement element : t.getStackTrace())
		{
			result.append(element);
			result.append(NEW_LINE);
		}

		return result.toString();
	}

}