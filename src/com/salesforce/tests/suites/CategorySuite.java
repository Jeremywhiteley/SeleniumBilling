package com.salesforce.tests.suites;

import org.junit.experimental.categories.Categories;
import org.junit.experimental.categories.Categories.IncludeCategory;
import org.junit.runner.RunWith;
import org.junit.runners.Suite.SuiteClasses;

import com.salesforce.custom.junit.Categories.Smoke;
import com.salesforce.custom.junit.Categories.Regression;
import com.salesforce.tests.functionaltests.Billing.Accounts.Createaccount;
import com.salesforce.tests.functionaltests.Billing.Invoice.ProfarmaInvoiceTest;
import com.salesforce.tests.functionaltests.Billing.Orders.Addproductfororder;
import com.salesforce.tests.functionaltests.Billing.Orders.Cloneorder;
import com.salesforce.tests.functionaltests.Billing.Orders.Createorder;
import com.salesforce.tests.functionaltests.Billing.Orders.Downgradesorder;
import com.salesforce.tests.functionaltests.Billing.Orders.Midtermadjustmentorder;
import com.salesforce.tests.functionaltests.Billing.Orders.Upgradesorder;
import com.salesforce.tests.functionaltests.salescloud.accounts.AddANewAccount_Sales;
import com.salesforce.tests.functionaltests.salescloud.accounts.SearchSelectAccount_Sales;

@RunWith(Categories.class)
//@IncludeCategory
@SuiteClasses({Createaccount.class, Createorder.class })
public class CategorySuite {
}

