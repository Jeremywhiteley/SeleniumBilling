package com.salesforce.tests.functionaltests;

import java.io.IOException;

import jxl.read.biff.BiffException;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;

import org.junit.After;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

import com.salesforce.pages.servicecloud.questions.ServiceCloudQuestionsDetail;
import com.salesforce.pages.servicecloud.questions.ServiceCloudQuestionsHome;
import com.salesforce.utils.datastore.FileIO;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class Scratchpad extends CloudBaseTest
{

	@Test
	public void scratchpad() throws BiffException, IOException, InterruptedException,
			RowsExceededException, WriteException
	{

		/**
		 * Initialize Test Data
		 */
		final String email = xlsUtil.ReadCell(xlsUtil.GetCell("Email"), 1);
		final String password = xlsUtil.ReadCell(xlsUtil.GetCell("Password"), 1);
		final String tab = xlsUtil.ReadCell(xlsUtil.GetCell("Tab"), 1);

		/**
		 * Begin Test
		 */
		LoginPage.open();
		LoginPage.enterUsername(email);
		LoginPage.enterPassword(password);
		LoginPage.submitForm();
		serviceCloudTopFrame.verifyPageLoad().changeCurrentApp(serviceCloudAppName);
		serviceCloudTopFrame.selectMainNavElement(tab);

		/**
		 * ServiceCloudKnowledgeHome knowledge = new
		 * ServiceCloudKnowledgeHome(driver); knowledge.verifyPageLoad();
		 * knowledge.sortBy("Title: A to Z");
		 * knowledge.selectStatusFilter("Published"); knowledge.reset();
		 * //knowledge.selectFromLeftNav("My Draft");
		 * knowledge.getArticleRating("How do I extend my Service Warranty?*");
		 * knowledge.getArticleScore("How do I extend my Service Warranty?*");
		 * //knowledge.searchKnowledge("How do I extend my Service Warranty");
		 * 
		 * ServiceCloudKnowledgeDetail detail =
		 * knowledge.selectArticle("How do I extend my Service Warranty?*");
		 * detail.verifyPageLoad(); detail.selectLanguage("German");
		 */

		ServiceCloudQuestionsHome questions = ServiceCloudQuestionsHome.Instance;
		// questions.selectQuestionFilter("All Questions");
		questions.filterQuestionsBySearchText("Can");
		// questions.refreshQuestionTable();

		ServiceCloudQuestionsDetail detail = questions
				.selectFromQuestionTable("Can someone help me understand how to Reset my Portal password?");
		detail.getQuestionText();

		// ServiceCloudCasesHome cases = new ServiceCloudCasesHome(driver);
		// cases.verifyPageLoad();
		// cases.selectCaseFilter("All Open Cases");
		// cases.refreshCaseTable();
		// cases.selectFromCaseTable("00001203");
		// cases.selectAccountTab("Morpon Brothers");
		//
		// ServiceCloudCasesDetail detail = new ServiceCloudCasesDetail(driver);
		// detail.verifyPageLoad();
		// //detail.selectDetailTab("Details");
		// detail.getCustomerDetailContent();

		// ServiceCloudSearchResults results =
		// topFrame.enterTextAndSearch("all");

		/**
		 * Assertion
		 */
		// assertEquals("Account owner doesnt match expect name",
		// accountOwnerName, detail.verifyPageLoad().getAccountOwner());

	}

	@After
	public void tearDownTest()
	{
		FileIO.takeScreenShot(driver, testName.getMethodName());
		testlogger.debug("ENDING TEST: " + testName.getMethodName() + "()");
		CloudBaseTest.terminate(true, true);
	}
}
