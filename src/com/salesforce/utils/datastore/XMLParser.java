package com.salesforce.utils.datastore;

import java.io.File;

import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

import com.salesforce.utils.UtilBase;

public class XMLParser extends DefaultHandler
{

	boolean ifParameter = false; // flag that shows that current parameter is
									// <parameter> object
	boolean ifTest = false; // flag that shows that current parameter has
							// expected name
	boolean ifTestWasFoundOnce = false;
	private String xlsFilePath = FileIO.getConfigProperty("TestDataFileXML");
	String result = null; // result value
	String expectedTest; // test name
	String expectedParameter; // parameter name

	public XMLParser(String simpleClassName)
	{
		expectedTest = simpleClassName;
	}

	/**
	 * Method used to get value from XML configuration file.
	 * 
	 * @param fieldName
	 *            : Name of field in XML (attribute 'name' for parameter element
	 *            )
	 * @return: parameter value from XML configuration file
	 * @throws Exception
	 */
	public String readParameter(String fieldName) throws Exception
	{

		result = null;
		expectedParameter = fieldName; // expected parameter name

		parseFile(xlsFilePath);

		// check that test was found in XML
		if (!ifTestWasFoundOnce)
		{
			UtilBase.Instance.utillogger.debug("ERROR: Test was not found. Test: " + expectedTest);
			throw new Exception("Test was not found. Test: " + expectedTest);
		}
		ifTestWasFoundOnce = false;

		// check if result is empty
		if (result == null)
		{
			UtilBase.Instance.utillogger.debug("WARNING: Value was not found. Test: "
					+ expectedTest + " Parameter name: " + expectedParameter);
		} else
		{
			UtilBase.Instance.utillogger.debug("Value " + result + ". Test: " + expectedTest
					+ " Parameter name: " + expectedParameter);
		}

		return result;
	}

	// process file and generate result
	private void parseFile(String uri) throws Exception
	{
		DefaultHandler saxHandler = this;
		SAXParserFactory saxFactory = SAXParserFactory.newInstance();

		try
		{
			SAXParser saxParser = saxFactory.newSAXParser();
			saxParser.parse(new File(uri), saxHandler);
		} catch (Throwable t)
		{
			UtilBase.Instance.utillogger.debug("ERROR: " + t.getMessage());
			UtilBase.Instance.utillogger.debug("ERROR: Value was not found. Test: " + expectedTest
					+ " Parameter name: " + expectedParameter);
			throw new Exception("Error during XML file parsing");
		}
	}

	// process start element
	public void startElement(String uri, String localName, String qName, Attributes attributes)
			throws SAXException
	{

		// if element name = <test>
		if (qName.equalsIgnoreCase("TEST"))
		{
			// check testname attribute
			if (attributes.getValue("testname").equalsIgnoreCase(expectedTest))
			{
				ifTestWasFoundOnce = true;
				ifTest = true; // expected test
			} else
			{
				ifTest = false; // not expected test
			}
		}

		// if on expected test - check <parameter> name
		if (ifTest && qName.equalsIgnoreCase("PARAMETER"))
		{
			// check name attribute
			if (attributes.getValue("name").equalsIgnoreCase(expectedParameter))
			{
				ifParameter = true; // expected parameter
			} else
			{
				ifParameter = false; // not expected parameter
			}
		}

	}

	// post processing
	public void endElement(String uri, String localName, String qName) throws SAXException
	{

	}

	// getting value from parameter
	public void characters(char ch[], int start, int length) throws SAXException
	{

		if (ifParameter)
		{

			if (result == null)
			{
				// get result from parameter
				result = new String(ch, start, length);
			} else
			{
				UtilBase.Instance.utillogger
						.debug("WARNING: Parameter name is not unique. Parameter name: "
								+ expectedParameter + " Test: " + expectedTest);
				result = null;
				throw new SAXException("Parameter name is not unique. Parameter name: "
						+ expectedParameter + " Test: " + expectedTest);
			}

			// uncheck flags
			ifParameter = false;
		}

	}

}