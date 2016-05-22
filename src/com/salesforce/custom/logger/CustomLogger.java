package com.salesforce.custom.logger;

import java.text.ParseException;
import java.util.Date;

import org.apache.log4j.Logger;

import com.salesforce.utils.datastore.FileIO;
import com.salesforce.utils.datastore.MySQLConnect;

public class CustomLogger
{

	private final Logger logger;

	public CustomLogger(String name)
	{
		logger = Logger.getLogger(name);
	}

	public CustomLogger(@SuppressWarnings("rawtypes") Class clazz)
	{
		logger = Logger.getLogger(clazz);
	}

	public void debug(Object message)
	{
		Date date = new Date();
		String isUsingDB = FileIO.getConfigProperty("UseDB");
		String messageToStore = ">>" + date.toString() + "::" + message;
		if (Boolean.parseBoolean(isUsingDB) == true)
		{
			try
			{
				MySQLConnect.updateTestLogInDB(messageToStore.toString());
			} catch (ParseException e)
			{
				e.printStackTrace();
			}

		}
		StackTraceElement[] stackTraceElements = Thread.currentThread().getStackTrace();
		String className = stackTraceElements[2].getClassName();
		// String currentMethodName = stackTraceElements[2].getMethodName();
		int lineNumber = stackTraceElements[2].getLineNumber();
		logger.debug(className + ":" + lineNumber + ":" + message);
	}

	public void info(Object message)
	{
		StackTraceElement[] stackTraceElements = Thread.currentThread().getStackTrace();
		String className = stackTraceElements[2].getClassName();
		// String currentMethodName = stackTraceElements[2].getMethodName();
		int lineNumber = stackTraceElements[2].getLineNumber();
		logger.info(className + ":" + lineNumber + ":" + message);
	}
}
