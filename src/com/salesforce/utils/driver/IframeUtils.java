package com.salesforce.utils.driver;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import jxl.read.biff.BiffException;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

import com.salesforce.pages.PageBase;
import com.salesforce.utils.UtilBase;
import com.salesforce.utils.datastore.FileIO;

public class IframeUtils extends PageBase
{

	public IframeUtils() throws BiffException, IOException
	{
	}

	public static String setDriverContextToIframeWithDepth(WebDriver driver, By by, int... depth)
	{
		PageBase.synchronize();
		StackTraceElement[] stackTraceElements = Thread.currentThread().getStackTrace();
		String currentMethodName = stackTraceElements[2].getMethodName();
		List<String> parentBreadCrumb = new ArrayList<String>();
		int passedInDepth = depth.length < 1 ? 1 : depth[0];
		PageBase.Instance.pagelogger.debug("Currently searching at depth :" + passedInDepth);
		String val = setDriverContextToIframeFromCacheWithDepth(driver, by, currentMethodName,
				true, passedInDepth, 1, parentBreadCrumb);
		return val;
	}

	public static String setDriverContextToIframeFromCacheWithDepth(WebDriver driver, By by,
			String methodKey, boolean switchToDefault, int desiredDepth, int currentDepth,
			List<String> parentIframeId)
	{

		String val = "";
		boolean isListOfIframesDone = false;

		if (switchToDefault)
		{
			driver.switchTo().defaultContent();
		}
		PageBase.Instance.pagelogger.debug("Currently at depth:" + currentDepth
				+ " Desired Depth is:" + desiredDepth);

		List<WebElement> frameset = findElementsIgnoreException(By.tagName("iframe"));
		if (currentDepth == desiredDepth && !isListOfIframesDone)
		{
			PageBase.Instance.pagelogger
					.debug("Reached Desired Depth. Total number of iframes at this level:"
							+ frameset.size());
			PageBase.Instance.pagelogger.debug("Iframes present are:");
			int indexForIframes = 1;
			for (WebElement element : frameset)
			{
				UtilBase.Instance.utillogger.debug("Iframe" + indexForIframes + ":"
						+ element.getAttribute("id"));
				indexForIframes++;
			}
			isListOfIframesDone = true;
		}

		WebElement element = null;

		for (int i = 0; i < frameset.size(); i++)
		{
			if (!val.isEmpty())
			{
				return val;
			}

			String id = frameset.get(i).getAttribute("id");

			if (id.isEmpty())
			{
				element = frameset.get(i);
			}

			if (id.isEmpty())
			{
				driver.switchTo().frame(element);
			} else
			{
				driver.switchTo().frame(id);
			}

			if (desiredDepth == currentDepth)
			{
				PageBase.Instance.pagelogger
						.debug("Switching and attempting to interact with frame: " + id);

				if (findElementsIgnoreException(by).size() != 0)
				{
					PageBase.Instance.pagelogger.debug("Found the value in iframe:" + id);
					val = id;
					FileIO.setIframeId(methodKey, id);
					break;
				} else
				{
					PageBase.Instance.pagelogger.debug("Didn't find the value in iframe:" + id);
					driver.switchTo().defaultContent();

					for (String iframe : parentIframeId)
					{
						driver.switchTo().frame(iframe);
					}

					if (switchToDefault)
					{
						driver.switchTo().defaultContent();
					}
				}
			} else
			{
				parentIframeId.add(id);
				val = setDriverContextToIframeFromCacheWithDepth(driver, by, methodKey, false,
						desiredDepth, ++currentDepth, parentIframeId);
				if (val.isEmpty())
				{
					parentIframeId.remove(parentIframeId.size() - 1);
					currentDepth = 1;
					driver.switchTo().defaultContent();

					for (String iframe : parentIframeId)
					{
						driver.switchTo().frame(iframe);
						++currentDepth;
					}
				}
			}
		}

		if (val.isEmpty())
		{
			PageBase.Instance.pagelogger
					.debug("WARNING: Element not found under any iframes at depth." + desiredDepth
							+ ".Execution will probably fail!");
		}

		return val;
	}

	public static String setDriverContextToIframeForLinkText(WebDriver driver, String text)
	{
		String val = "";
		driver.switchTo().defaultContent();
		List<WebElement> frameset = findElementsIgnoreException(By.tagName("iframe"));

		PageBase.Instance.pagelogger.debug("Number of iframes found on current page: "
				+ frameset.size());

		for (int i = 0; i < frameset.size(); i++)
		{

			String id = frameset.get(i).getAttribute("id");
			PageBase.Instance.pagelogger.debug("Switching and attempting to interact with frame: "
					+ id);
			driver.switchTo().frame(id);

			if (findElementsIgnoreException(By.linkText(text)).size() != 0)
			{
				PageBase.Instance.pagelogger.debug("Found it");
				val = id;
				break;
			} else
			{
				PageBase.Instance.pagelogger.debug("Didnt find it");
				driver.switchTo().defaultContent();
			}
		}

		if (val.isEmpty())
		{
			PageBase.Instance.pagelogger
					.debug("Warning - no frames were found which can interact with the passed in control. Execution will probably fail!");
		}

		return val;
	}

}