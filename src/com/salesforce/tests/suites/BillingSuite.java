package com.salesforce.tests.suites;

import org.junit.experimental.categories.Categories;
import org.junit.runner.RunWith;
import org.junit.runners.Suite.SuiteClasses;

import com.salesforce.tests.functionaltests.Billing.Accounts.Createaccount;
import com.salesforce.tests.functionaltests.Billing.Invoice.ProfarmaInvoiceTest;
import com.salesforce.tests.functionaltests.Billing.Orders.Addproductfororder;
import com.salesforce.tests.functionaltests.Billing.Orders.Cloneorder;
import com.salesforce.tests.functionaltests.Billing.Orders.Createorder;
import com.salesforce.tests.functionaltests.Billing.Orders.Downgradesorder;
import com.salesforce.tests.functionaltests.Billing.Orders.Midtermadjustmentorder;
import com.salesforce.tests.functionaltests.Billing.Orders.Upgradesorder;


@RunWith(Categories.class)
//@IncludeCategory
@SuiteClasses({ Createaccount.class, Midtermadjustmentorder.class})
public class BillingSuite {

}
