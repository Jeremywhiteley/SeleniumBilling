package com.salesforce.tests.testdataservice;

import com.salesforce.entities.User;

public class DataService
{
	public User adminUser;
	UsersFactory usersFactory;
	
	public User getAdminUser()
	{
		return usersFactory.getAdminUser();
	}
	private DataService()
    {
        usersFactory= new UsersFactory();
    }
	private static DataService instance;
	public static DataService Instance = (instance != null) ? instance : new DataService();

}

