package com.salesforce.tests.suites;

import java.io.IOException;
import java.sql.SQLException;
import java.text.ParseException;

import org.junit.BeforeClass;
import org.junit.runner.RunWith;
import org.junit.runners.Suite;

import com.salesforce.tests.functionaltests.salescloud.accounts.AddANewAccount_Sales;
import com.salesforce.tests.functionaltests.salescloud.contacts.AddANewContact_Sales;
import com.salesforce.tests.functionaltests.salescloud.opportunities.AddANewOpportunity_Sales;
import com.salesforce.utils.datastore.MySQLConnect;

@RunWith(Suite.class)
@Suite.SuiteClasses({ AddANewAccount_Sales.class, AddANewContact_Sales.class,
		AddANewOpportunity_Sales.class })
public class DebugSuite
{

	@BeforeClass
	public static void suiteSetup() throws SQLException, IOException, ParseException
	{
		MySQLConnect.generateRunIDInDB();
	}

}
