package com.salesforce.tests.suites;

import org.junit.experimental.categories.Categories;
import org.junit.runner.RunWith;
import org.junit.runners.Suite.SuiteClasses;

import com.salesforce.tests.functionaltests.Billing.Accounts.Createaccount;
import com.salesforce.tests.functionaltests.Billing.Accounts.createlightningaccount;
import com.salesforce.tests.functionaltests.Billing.Orders.Addproductfororder;
import com.salesforce.tests.functionaltests.Billing.Orders.Cloneorder;
import com.salesforce.tests.functionaltests.Billing.Orders.Createadhocinvoice;
import com.salesforce.tests.functionaltests.Billing.Orders.Createorderforonetimecharge;
import com.salesforce.tests.functionaltests.Billing.Orders.Createpaymentplan;
import com.salesforce.tests.functionaltests.Billing.Orders.Downgradesorder;
import com.salesforce.tests.functionaltests.Billing.Orders.Midtermadjustmentorder;
import com.salesforce.tests.functionaltests.Billing.Orders.Paymentplanfororder;
import com.salesforce.tests.functionaltests.Billing.Orders.Previewinvoiceoforder;
import com.salesforce.tests.functionaltests.Billing.Orders.Testgenerateinvoice;
import com.salesforce.tests.functionaltests.Billing.Orders.Testupdateorderstatus;
import com.salesforce.tests.functionaltests.Billing.Orders.Upgradesorder;
import com.salesforce.tests.functionaltests.Billing.Orders.createorderforonetimeandmonthly;
import com.salesforce.tests.functionaltests.Billing.Orders.createorderforprofarmainvoice;

@RunWith(Categories.class)
//@IncludeCategory
@SuiteClasses({Createaccount.class, Createorderforonetimecharge.class, Addproductfororder.class, Cloneorder.class,
	Previewinvoiceoforder.class, Midtermadjustmentorder.class,Upgradesorder.class, Downgradesorder.class,
	Createpaymentplan.class,Paymentplanfororder.class, Testgenerateinvoice.class, 
	Testupdateorderstatus.class , createorderforonetimeandmonthly.class, Createadhocinvoice.class, 
	createorderforprofarmainvoice.class, createlightningaccount.class})
public class CategorySuite {
}

