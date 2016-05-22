package com.salesforce.tests.testdataservice;

import com.salesforce.entities.User;

public class UsersFactory
{
	public UsersFactory()
	{
		initialiseAdminUser();
	}

	public User admin;

	public User getAdminUser()
	{
		return admin;
	}

	private void initialiseAdminUser()
	{
		final String username = "sseshadri@salesforce.com.demo";
		final String password = "services123";
		admin = new User(username, password);
	}
}
