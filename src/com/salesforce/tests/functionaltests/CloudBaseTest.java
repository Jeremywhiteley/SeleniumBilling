package com.salesforce.tests.functionaltests;

import java.io.File;
import java.io.IOException;
import java.net.URISyntaxException;
import java.net.URL;
import java.text.ParseException;

import org.apache.log4j.PropertyConfigurator;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.rules.ExpectedException;
import org.junit.rules.TestName;
import org.junit.rules.TestWatcher;
import org.junit.runner.Description;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.firefox.FirefoxProfile;
import org.openqa.selenium.ie.InternetExplorerDriver;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.openqa.selenium.remote.RemoteWebDriver;
import org.openqa.selenium.safari.SafariDriver;

import com.salesforce.custom.logger.CustomLogger;
import com.salesforce.pages.DefaultTopFrame;
import com.salesforce.pages.Login;
import com.salesforce.pages.PageBase;
import com.salesforce.pages.Billing.Accounts.CreatesAccount;
import com.salesforce.pages.Billing.Invoices.Invoicescheduler;
import com.salesforce.pages.Billing.Invoices.ProfarmaInvoice;
import com.salesforce.pages.Billing.Orders.Addpaymentplanfororder;
import com.salesforce.pages.Billing.Orders.Adhocinvoicepage;
import com.salesforce.pages.Billing.Orders.Cloneorder;
import com.salesforce.pages.Billing.Orders.OrderHome;
import com.salesforce.pages.Billing.Orders.Paymentplan;
import com.salesforce.pages.Billing.Orders.orderpreviewinvoice;
import com.salesforce.pages.salescloud.SalesCloudHomePage;
import com.salesforce.pages.salescloud.SalesCloudTopFrame;
import com.salesforce.pages.salescloud.accounts.AccountsHome;
import com.salesforce.pages.salescloud.contacts.ContactsHome;
import com.salesforce.pages.salescloud.leads.LeadsHome;
import com.salesforce.pages.salescloud.opportunities.OpportunitiesHome;
import com.salesforce.pages.servicecloud.ServiceCloudTopFrame;
import com.salesforce.pages.servicecloud.accounts.ServiceCloudAccountsHome;
import com.salesforce.pages.servicecloud.activities.ServiceCloudActivityHome;
import com.salesforce.pages.servicecloud.cases.ServiceCloudCasesHome;
import com.salesforce.pages.servicecloud.contacts.ServiceCloudContactsHome;
import com.salesforce.pages.servicecloud.knowledge.ServiceCloudKnowledgeHome;
import com.salesforce.pages.servicecloud.leads.ServiceCloudLeadsHome;
import com.salesforce.pages.servicecloud.questions.ServiceCloudQuestionsHome;
import com.salesforce.pages.setup.SetupProfileHome;
import com.salesforce.pages.setup.users.UserProfileHome;
import com.salesforce.utils.CommonMethods;
import com.salesforce.utils.datastore.ExcelSheetDriver;
import com.salesforce.utils.datastore.FileIO;
import com.salesforce.utils.datastore.MySQLConnect;
import com.salesforce.utils.datastore.XMLParser;
import com.salesforce.utils.driver.DriverProvider;

import jxl.read.biff.BiffException;

public class CloudBaseTest
{
	protected static ExcelSheetDriver xlsUtil;
	protected static XMLParser xmlUtil;
	protected static String caseNumber;
	public static String salesCloudAppName;
	public static String serviceCloudAppName;
	protected String dataFileType;

	protected WebDriver driver;
	protected Login LoginPage;
	protected OrderHome Order;
	protected Paymentplan plan;
	protected Adhocinvoicepage Adhoc;
	protected orderpreviewinvoice previewinvoice;
	protected Cloneorder corder;
	protected ProfarmaInvoice invoice;
	protected CreatesAccount account;
	protected Invoicescheduler scheduler;
	protected Addpaymentplanfororder pplan;
	protected UserProfileHome userProfile;
	protected DefaultTopFrame defaultTopFrame;
	protected SetupProfileHome profileHome;
	protected LeadsHome salesCloudLeadsHome;
	protected AccountsHome salesCloudAccountsHome;
	protected ContactsHome salesCloudContactsHome;
	protected OpportunitiesHome salesCloudOpportunitiesHome;
	protected SalesCloudTopFrame salesCloudTopFrame;
	protected ServiceCloudCasesHome serviceCloudCasesHome;
	protected ServiceCloudQuestionsHome serviceCloudQuestionsHome;
	protected ServiceCloudAccountsHome serviceCloudAccountsHome;
	protected ServiceCloudLeadsHome serviceCloudLeadsHome;
	protected ServiceCloudContactsHome serviceCloudContactsHome;
	protected ServiceCloudKnowledgeHome serviceCloudKnowledgeHome;
	protected ServiceCloudActivityHome serviceCloudActivityHome;
	protected ServiceCloudTopFrame serviceCloudTopFrame;
	protected SalesCloudHomePage homePage;
	protected final CustomLogger testlogger = new CustomLogger(this.getClass());

	private static CloudBaseTest instance;
	public static CloudBaseTest Instance = (instance != null) ? instance : new CloudBaseTest();

	@Rule
	public TestName testName = new TestName();
	public ExpectedException exception = ExpectedException.none();

	@Rule
	public TestWatcher watchman = new TestWatcher() {

		@Override
		protected void failed(Throwable e, Description description)
		{

			try
			{
				String stack = CommonMethods.getCustomStackTrace(e);
				MySQLConnect.updateTestEndFieldsInDB("fail", stack.replace("'", ""));

			} catch (ParseException e1)
			{
				e1.printStackTrace();
			}
		}

		@Override
		protected void succeeded(Description description)
		{
			try
			{
				MySQLConnect.updateTestEndFieldsInDB("pass", "N/A");
			} catch (ParseException e1)
			{
				e1.printStackTrace();
			}
		}

	};

	@Before
	public void initializeClass() throws IOException, BiffException, URISyntaxException
	{

		/** Initialize WebDriver Object */
		PropertyConfigurator.configure("resources/log4j.properties");
		setup(testName.getMethodName());
		System.err.println("---------------1------------------");
		salesCloudAppName = FileIO.getConfigProperty("SalesCloudAppName");
		System.err.println("---------------2------------------");
		serviceCloudAppName = FileIO.getConfigProperty("ServiceCloudAppName");
		System.err.println("---------------3------------------");
		dataFileType = FileIO.getConfigProperty("DataSourceType");
		System.err.println("---------------4------------------");
		driver = CloudBaseTest.initDriver(driver);
		System.err.println("---------------5------------------");
		testlogger.debug("Driver version: " + driver);
		System.err.println("---------------6------------------");
		xlsUtil = CloudBaseTest.initDataIO(xlsUtil, getSimpleClassName());
		System.err.println("---------------7------------------");
		FileIO.loadIframeIdPropFile();
		System.err.println("---------------8------------------");

		if (dataFileType.equalsIgnoreCase("XML"))
		{
			xmlUtil = new XMLParser(getSimpleClassName());
		} else
		{
			xlsUtil = CloudBaseTest.initDataIO(xlsUtil, getSimpleClassName());
		}

		/** Initialize All Base Pages */

		this.LoginPage = (this.LoginPage != null) ? this.LoginPage : new Login();
		this.account = (this.account!= null)? this.account : new CreatesAccount();
		this.Order = (this.Order!= null)? this.Order : new OrderHome();
		this.Adhoc = (this.Adhoc!= null)? this.Adhoc : new Adhocinvoicepage();
		this.previewinvoice = (this.previewinvoice!= null)? this.previewinvoice : new orderpreviewinvoice();
		this.plan = (this.plan!= null)? this.plan : new Paymentplan();
		this.pplan = (this.pplan!= null)? this.pplan : new Addpaymentplanfororder();
		this.corder = (this.corder!= null)? this.corder : new Cloneorder();
		this.invoice = (this.invoice!=null)?this.invoice : new ProfarmaInvoice();
		this.scheduler = (this.scheduler!= null)? this.scheduler : new Invoicescheduler();
		this.homePage = (this.homePage != null) ? this.homePage : SalesCloudHomePage.Instance;
		this.defaultTopFrame = (this.defaultTopFrame != null) ? this.defaultTopFrame
				: DefaultTopFrame.Instance;
		this.userProfile = (this.userProfile != null) ? this.userProfile : UserProfileHome.Instance;
		this.serviceCloudTopFrame = (this.serviceCloudTopFrame != null) ? this.serviceCloudTopFrame
				: ServiceCloudTopFrame.Instance;
		this.salesCloudTopFrame = (this.salesCloudTopFrame != null) ? this.salesCloudTopFrame
				: SalesCloudTopFrame.Instance;
		this.serviceCloudCasesHome = (this.serviceCloudCasesHome != null) ? this.serviceCloudCasesHome
				: ServiceCloudCasesHome.Instance;
		this.serviceCloudQuestionsHome = (this.serviceCloudQuestionsHome != null) ? this.serviceCloudQuestionsHome
				: ServiceCloudQuestionsHome.Instance;
		this.serviceCloudAccountsHome = (this.serviceCloudAccountsHome != null) ? this.serviceCloudAccountsHome
				: com.salesforce.pages.servicecloud.accounts.ServiceCloudAccountsHome.Instance;
		this.serviceCloudLeadsHome = (this.serviceCloudLeadsHome != null) ? this.serviceCloudLeadsHome
				: ServiceCloudLeadsHome.Instance;
		this.serviceCloudContactsHome = (this.serviceCloudContactsHome != null) ? this.serviceCloudContactsHome
				: ServiceCloudContactsHome.Instance;
		this.serviceCloudKnowledgeHome = (this.serviceCloudKnowledgeHome != null) ? this.serviceCloudKnowledgeHome
				: ServiceCloudKnowledgeHome.Instance;
		this.serviceCloudActivityHome = (this.serviceCloudActivityHome != null) ? this.serviceCloudActivityHome
				: ServiceCloudActivityHome.Instance;
		this.profileHome = (this.profileHome != null) ? this.profileHome
				: SetupProfileHome.Instance;
		this.salesCloudOpportunitiesHome = (this.salesCloudOpportunitiesHome != null) ? this.salesCloudOpportunitiesHome
				: OpportunitiesHome.Instance;
		this.salesCloudLeadsHome = (this.salesCloudLeadsHome != null) ? this.salesCloudLeadsHome
				: LeadsHome.Instance;
		this.salesCloudAccountsHome = (this.salesCloudAccountsHome != null) ? this.salesCloudAccountsHome
				: AccountsHome.Instance;
		this.salesCloudContactsHome = (this.salesCloudContactsHome != null) ? this.salesCloudContactsHome
				: ContactsHome.Instance;
	}

	public String getSimpleClassName()
	{
		return this.getClass().getSimpleName();
	}

	@After
	public void tearDownTest()
	{
		FileIO.takeScreenShot(driver, testName.getMethodName());
		testlogger.debug("ENDING TEST: " + testName.getMethodName() + "()");
		CloudBaseTest.terminate(true, true);
	}

	public static void terminate(boolean cookies, boolean quit)
	{
		CloudBaseTest.Instance.testlogger.debug("Starting test class teardown");

		if (cookies == true)
		{
			DriverProvider.Driver.get().manage().deleteAllCookies();
			CloudBaseTest.Instance.testlogger.debug("Clearing all browser cookies");
		}

		if (quit == true)
		{
			DriverProvider.Driver.get().quit();
			CloudBaseTest.Instance.testlogger.debug("Terminating browser");
		}
	}

	/**
	 * Method used to write the images directory to disk, read in the current
	 * browser type, and start the initial log session
	 * 
	 * @param testName
	 *            : Parameter that holds the name of the current test being
	 *            executed
	 * @throws IOException
	 * @throws ParseException
	 */
	private void setup(String testName) throws IOException
	{
		FileIO.setConfigProperty("CurrentTestName", testName);

		if (FileIO.getConfigProperty("UseDB").equals("true"))
		{
			try
			{
				MySQLConnect.insertAllTestInitializationFieldsInDB();
			} catch (ParseException e)
			{
				e.printStackTrace();
			}
		}
		FileIO.createImagesDirectory(testName);
		FileIO.writeToLogFile("Executing test {" + testName + "}");

		FileIO.getConfigProperty("Browser");
		testlogger.debug("------------------------------------------------------");
		testlogger.debug("Executing Test: " + testName + "()...");
		testlogger.debug("------------------------------------------------------");

	}

	/**
	 * WebDriver initialization Method
	 * 
	 * @param driver
	 *            : Holds current platform and other instance properties to
	 *            enable consistent execution. Primary actor in all test classes
	 * @return driver object
	 * @throws IOException
	 * @throws URISyntaxException
	 */
	public static WebDriver initDriver(WebDriver driver) throws IOException, URISyntaxException
	{

		CloudBaseTest.Instance.testlogger
				.debug("------------------------------------------------------");
		CloudBaseTest.Instance.testlogger.debug("Initializing... ");
		CloudBaseTest.Instance.testlogger
				.debug("------------------------------------------------------");

		if (FileIO.getConfigProperty("UseGrid").equals("true"))
		{

			DesiredCapabilities capability = DesiredCapabilities.firefox();
			driver = new RemoteWebDriver(new URL(FileIO.getConfigProperty("GridHubIP")), capability);

			CloudBaseTest.Instance.testlogger.debug("Driver object used is" + driver.toString());
			CloudBaseTest.Instance.testlogger.debug("Kicking off remote browser ["
					+ capability.toString() + "] at ip: " + FileIO.getConfigProperty("GridHubIP"));
		} else
		{

			CloudBaseTest.Instance.testlogger
					.debug("Grid is set to OFF. All browsers will launch browser locally...");

			if (Integer.parseInt(FileIO.getConfigProperty("Browser")) == 1)
			{
				if (Boolean.parseBoolean(FileIO.getConfigProperty("EnableFirebug")) == true)
				{
					final String firebugPath = "config/firebug.xpi";
					FirefoxProfile profile = new FirefoxProfile();

					profile.addExtension(new File(CommonMethods.class.getResource(firebugPath)
							.toURI()));
					profile.setPreference("browser.helperApps.neverAsk.openFile", "application/pdf");
					profile.setPreference("browser.helperApps.neverAsk.saveToDisk",
							"application/pdf");
					profile.setPreference("browser.helperApps.alwaysAsk.force", false);
					profile.setPreference("browser.download.manager.showWhenStarting", false);
					profile.setPreference("browser.download.folderList", 2);
					profile.setPreference("browser.download.dir",

					FileIO.getDownloadDirectoryPath());

					profile.setPreference("pdfjs.disabled", true);
					profile.setPreference("plugin.disable_full_page_plugin_for_types",
							"application/pdf");

					driver = new FirefoxDriver(profile);
				} else
				{
					FirefoxProfile profile = new FirefoxProfile();

					profile.setPreference("browser.helperApps.neverAsk.openFile", "application/pdf");
					profile.setPreference("browser.helperApps.neverAsk.saveToDisk",
							"application/pdf");
					profile.setPreference("browser.helperApps.alwaysAsk.force", false);
					profile.setPreference("browser.download.manager.showWhenStarting", false);
					profile.setPreference("browser.download.folderList", 2);
					profile.setPreference("browser.download.dir",

					FileIO.getDownloadDirectoryPath());

					profile.setPreference("pdfjs.disabled", true);
					profile.setPreference("plugin.disable_full_page_plugin_for_types",
							"application/pdf");

					driver = new FirefoxDriver(profile);
				}

				CloudBaseTest.Instance.testlogger.debug("Launching Firefox Browser");

				driver.manage().window().maximize();

			} else if (Integer.parseInt(FileIO.getConfigProperty("Browser")) == 2)
			{
				System.setProperty("webdriver.chrome.driver",
						FileIO.getConfigProperty("ChromePath"));

				CloudBaseTest.Instance.testlogger.debug("Launching Chrome Browser");

				driver = new ChromeDriver();
			} else if (Integer.parseInt(FileIO.getConfigProperty("Browser")) == 3)
			{
				CloudBaseTest.Instance.testlogger.debug("Launching Safari Browser");

				driver = new SafariDriver();
			} else if (Integer.parseInt(FileIO.getConfigProperty("Browser")) == 4)
			{
				System.setProperty("webdriver.ie.driver", FileIO.getConfigProperty("IEPath"));

				CloudBaseTest.Instance.testlogger.debug("Launching Internet Explorer Browser");

				driver = new InternetExplorerDriver();

			} else
			{
				throw new RuntimeException(
						"An appropriate browser was not defined in config.properties. Use 1 for Firefox, 2 for Chrome!");
			}

		}

		final WebDriver tDriver = driver;
		DriverProvider.Driver = new ThreadLocal<WebDriver>() {

			@Override
			protected WebDriver initialValue()
			{
				WebDriver threadLocalDriver = tDriver;
				return threadLocalDriver;
			}
		};
		DriverProvider.Driver.set(tDriver);
		PageBase.setDriver(tDriver);
		return driver;

	}

	/**
	 * Method used to setup read access to the associated Excel data sheet
	 * (testdata.xls) that holds all test data for a specific project
	 * 
	 * @param xlsUtil
	 * @param className
	 * @return
	 * @throws BiffException
	 * @throws IOException
	 */
	public static ExcelSheetDriver initDataIO(ExcelSheetDriver xlsUtil, String className)
			throws BiffException, IOException
			
	{
		System.err.println("-------------initDataIO---------777-------");
		CloudBaseTest.Instance.testlogger.debug("Initializing Excel data sheet...");
		xlsUtil = new ExcelSheetDriver(className);
		xlsUtil.ColumnDictionary();

		return xlsUtil;
	}
}
