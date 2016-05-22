package com.salesforce.utils;

import com.salesforce.custom.logger.CustomLogger;

public class UtilBase
{

	public final CustomLogger utillogger;
	private static UtilBase instance;
	public static UtilBase Instance = (instance != null) ? instance : new UtilBase();

	public UtilBase()
	{
		this.utillogger = new CustomLogger(this.getClass());
	}

}
