package com.salesforce.utils.datastore;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import com.salesforce.utils.CommonMethods;
import com.salesforce.utils.UtilBase;

public class MySQLConnect extends UtilBase
{
	static int i = 1;

	/**
	 * Checks to see whether the JDBC driver is registered correctly & in the
	 * build path
	 * 
	 * @return
	 */
	public static boolean checkJDBCConfig()
	{

		boolean configStatus = false;

		try
		{
			Class.forName("com.mysql.jdbc.Driver");
			configStatus = true;
		} catch (ClassNotFoundException e)
		{
			UtilBase.Instance.utillogger
					.info("MySQL JDBC Driver not found! Make sure it is in the project buildpath.");
			e.printStackTrace();
		}

		return configStatus;

	}

	/**
	 * Connect to MySQL database
	 * 
	 * @return
	 */
	public static Connection connectToDB()
	{

		boolean config = checkJDBCConfig();
		String dbUsername = FileIO.getConfigProperty("DatabaseUsername");
		String dbPassword = FileIO.getConfigProperty("DatabasePassword");
		String dbSchema = FileIO.getConfigProperty("DatabaseSchema");
		Connection connection = null;

		if (dbPassword.isEmpty())
		{
			dbPassword = null;
		}

		if (config != false)
		{

			try
			{
				// System.out.println("Entry no:" + i);

				connection = DriverManager.getConnection("jdbc:mysql://127.0.0.1:3306/" + dbSchema,
						dbUsername, dbPassword);
				// if (connection != null)
				// {
				// System.out.println("Connection not null.Got Connection for the "
				// + i
				// + "th time");
				// }
				i++;

			} catch (SQLException e)
			{
				e.printStackTrace();

				try
				{
					throw e;
				} catch (SQLException e1)
				{
					e1.printStackTrace();
				}
			}
			if (connection != null)
			{
				UtilBase.Instance.utillogger.info("Database connection attempt succeeded!");
			} else
			{
				UtilBase.Instance.utillogger
						.info("Database connection attempt failed! Check the stack trace.");
			}

		}
		// System.out.println("Returning connection variable.");

		return connection;
	}

	/**
	 * Return hashmap with all row values for a specific passed in class/test
	 * 
	 * @throws ParseException
	 * @throws SQLException
	 */

	public static Map<String, Object> getTestDataByTestName(String testName) throws SQLException
	{

		Connection dbConnection = connectToDB();
		PreparedStatement statement = null;
		ResultSet results = null;
		Map<String, Object> dbvalues = new HashMap<String, Object>();
		String dbTableName = FileIO.getConfigProperty("TestTableName");

		String sql = "SELECT * " + "FROM " + dbTableName + " " + "WHERE test_name = '" + testName
				+ "'";

		try
		{

			if (dbConnection != null)
			{
				UtilBase.Instance.utillogger.debug("Executing SQL Statment: " + sql);
				statement = dbConnection.prepareStatement(sql);
				results = statement.executeQuery(sql);
			}

			ResultSetMetaData metadata = results.getMetaData();
			int columns = metadata.getColumnCount();

			while (results.next())
			{

				for (int i = 1; i <= columns; i++)
				{
					UtilBase.Instance.utillogger
							.debug("Entering the following key and value into hashmap: "
									+ metadata.getColumnName(i) + "-->" + results.getObject(i));
					dbvalues.put(metadata.getColumnName(i), results.getObject(i));
				}
			}

		} catch (SQLException s)
		{
			s.printStackTrace();
		} catch (Exception e)
		{
			e.printStackTrace();
		} finally
		{

			try
			{

				if (statement != null)
					statement.close();

			} catch (SQLException se2)
			{
			}

			try
			{

				if (dbConnection != null)
					dbConnection.close();

			} catch (SQLException se)
			{
				se.printStackTrace();
			}

		}

		results.close();
		statement.close();
		dbConnection.close();

		return dbvalues;
	}

	/**
	 * Get the max test run id from the test results table
	 * 
	 * @throws ParseException
	 * @throws SQLException
	 */

	public static int getMaxRunIDFromDB() throws SQLException
	{

		Connection dbConnection = connectToDB();
		PreparedStatement statement = null;
		ResultSet results = null;
		String testHistoryTable = FileIO.getConfigProperty("CurrentProject") + "_" + "Results";
		int currentMaxRunIdInTable = 0;

		String sql = "SELECT max(run_id) FROM " + testHistoryTable;

		try
		{

			if (dbConnection != null)
			{
				UtilBase.Instance.utillogger.debug("Executing SQL Statment: " + sql);
				statement = dbConnection.prepareStatement(sql);
				results = statement.executeQuery(sql);
			}

			while (results.next())
			{
				currentMaxRunIdInTable = Integer.parseInt(results.getObject(1).toString());
				break;
			}

		} catch (SQLException s)
		{
			s.printStackTrace();
		} catch (Exception e)
		{
			e.printStackTrace();
		}

		finally
		{

			try
			{

				if (statement != null)
					statement.close();

			} catch (SQLException se2)
			{
			}

			try
			{

				if (dbConnection != null)
					dbConnection.close();

			} catch (SQLException se)
			{
				se.printStackTrace();
			}

		}

		results.close();
		statement.close();
		dbConnection.close();

		return currentMaxRunIdInTable;
	}

	/**
	 * Update the log of the current test based upon current test name and test
	 * run id
	 * 
	 * @throws ParseException
	 */
	public static void updateTestLogInDB(String var) throws ParseException
	{

		Connection dbConnection = connectToDB();
		PreparedStatement pstmt = null;
		String testHistoryTable = FileIO.getConfigProperty("CurrentProject") + "_" + "Results";
		String currentRunID = FileIO.getConfigProperty("CurrentRunID");
		String currentTestName = FileIO.getConfigProperty("CurrentTestName");

		String sql = "UPDATE " + testHistoryTable + " "
				+ "SET test_log = concat(ifnull(test_log, ''), " + "'" + var + "'" + ")" + " "
				+ "WHERE run_id = '" + currentRunID + "' AND test_name = '" + currentTestName + "'";

		try
		{

			if (dbConnection != null)
			{
				pstmt = dbConnection.prepareStatement(sql);
				pstmt.executeUpdate();
				pstmt.close();
				dbConnection.close();
			}

		} catch (SQLException s)
		{
			s.printStackTrace();
		} catch (Exception e)
		{
			e.printStackTrace();
		} finally
		{

			try
			{

				if (pstmt != null)
					pstmt.close();

			} catch (SQLException se2)
			{
			}

			try
			{

				if (dbConnection != null)
					dbConnection.close();

			} catch (SQLException se)
			{
				se.printStackTrace();
			}

		}

	}

	/**
	 * Adds run_id, test_name, project_name, test_start_time
	 * 
	 * @throws ParseException
	 */
	public static void insertAllTestInitializationFieldsInDB() throws ParseException
	{

		Connection dbConnection = connectToDB();
		PreparedStatement pstmt = null;

		String testHistoryTable = FileIO.getConfigProperty("CurrentProject") + "_" + "Results";
		String currentRunID = FileIO.getConfigProperty("CurrentRunID");
		String currentTestName = FileIO.getConfigProperty("CurrentTestName");
		String currentProjectName = FileIO.getConfigProperty("CurrentProject");

		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss.SSS");
		Date parsedDate = dateFormat.parse(CommonMethods.getCurrentDate("MYSQL"));
		Timestamp currentTestStartTime = new java.sql.Timestamp(parsedDate.getTime());

		try
		{
			FileIO.writeToLogFile("Sending the following time into mysql: " + currentTestStartTime);
		} catch (IOException e1)
		{
			e1.printStackTrace();
		}

		String sql = "INSERT INTO " + testHistoryTable + " "
				+ "(run_id, test_name, project_name, test_start_time)" + " " + "VALUES('"
				+ currentRunID + "'," + "'" + currentTestName + "'," + "'" + currentProjectName
				+ "'," + "'" + currentTestStartTime + "')";

		try
		{

			if (dbConnection != null)
			{
				pstmt = dbConnection.prepareStatement(sql);
				pstmt.executeUpdate();
				pstmt.close();
				dbConnection.close();
			}

		} catch (SQLException s)
		{
			s.printStackTrace();
		} catch (Exception e)
		{
			e.printStackTrace();
		} finally
		{

			try
			{

				if (pstmt != null)
					pstmt.close();

			} catch (SQLException se2)
			{
			}

			try
			{

				if (dbConnection != null)
					dbConnection.close();

			} catch (SQLException se)
			{
				se.printStackTrace();
			}

		}

	}

	/**
	 * Update the log of the current test based upon current test name and test
	 * run id
	 * 
	 * @throws ParseException
	 */
	public static void updateTestEndFieldsInDB(String status, String stack) throws ParseException
	{

		if (FileIO.getConfigProperty("UseDB").equals("true"))
		{
			Connection dbConnection = connectToDB();
			PreparedStatement pstmt = null;

			String testHistoryTable = FileIO.getConfigProperty("CurrentProject") + "_" + "Results";
			String currentRunID = FileIO.getConfigProperty("CurrentRunID");
			String currentTestName = FileIO.getConfigProperty("CurrentTestName");
			String currentTestEnvironment = FileIO.getConfigProperty("CurrentEnvironment");

			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss.SSS");
			Date parsedDate = dateFormat.parse(CommonMethods.getCurrentDate("MYSQL"));
			Timestamp currentTestEndTime = new java.sql.Timestamp(parsedDate.getTime());

			status = status.toLowerCase();

			String sql = "UPDATE " + testHistoryTable + " " + "SET test_end_time = '"
					+ currentTestEndTime + "', test_status = '" + status + "', test_stack = '"
					+ stack + "', test_environment = '" + currentTestEnvironment + "'"
					+ " WHERE run_id = '" + currentRunID + "' AND test_name = '" + currentTestName
					+ "'";

			try
			{

				if (dbConnection != null)
				{
					pstmt = dbConnection.prepareStatement(sql);
					pstmt.executeUpdate();
					pstmt.close();
					dbConnection.close();
				}

			} catch (SQLException s)
			{
				s.printStackTrace();
			} catch (Exception e)
			{
				e.printStackTrace();
			} finally
			{

				try
				{

					if (pstmt != null)
						pstmt.close();

				} catch (SQLException se2)
				{
				}

				try
				{

					if (dbConnection != null)
						dbConnection.close();

				} catch (SQLException se)
				{
					se.printStackTrace();
				}

			}
		}
	}

	/**
	 * Insert an image into the test runs database
	 * 
	 * @throws ParseException
	 * @throws FileNotFoundException
	 */
	public static void insertPictureInDB(File image) throws ParseException, FileNotFoundException
	{

		Connection dbConnection = connectToDB();
		PreparedStatement pstmt = null;

		FileInputStream fis = null;

		String testHistoryTable = FileIO.getConfigProperty("CurrentProject") + "_" + "Results";
		String currentRunID = FileIO.getConfigProperty("CurrentRunID");
		String currentTestName = FileIO.getConfigProperty("CurrentTestName");
		int imageIndex = Integer.parseInt(FileIO
				.getConfigProperty("NumberOfPicturesInsertedThisRun")) + 1;
		String databaseColumnIndex = String.valueOf(imageIndex);

		// database can only hold max of 10 image blobs

		if (imageIndex < 10)
		{

			try
			{

				if (dbConnection != null)
				{
					fis = new FileInputStream(image);
					pstmt = dbConnection.prepareStatement("UPDATE " + testHistoryTable
							+ " SET image_" + databaseColumnIndex + "=? " + "WHERE run_id='"
							+ currentRunID + "' AND test_name ='" + currentTestName + "'");
					pstmt.setBinaryStream(1, fis, (int) image.length());
					pstmt.executeUpdate();

					pstmt.close();
					dbConnection.close();

					FileIO.setConfigProperty("NumberOfPicturesInsertedThisRun",
							String.valueOf(imageIndex));

				}

			} catch (SQLException s)
			{
				s.printStackTrace();
			} catch (Exception e)
			{
				e.printStackTrace();
			} finally
			{

				try
				{

					if (pstmt != null)
						pstmt.close();

				} catch (SQLException se2)
				{
				}

				try
				{

					if (dbConnection != null)
						dbConnection.close();

				} catch (SQLException se)
				{
					se.printStackTrace();
				}

			}

		} else
		{
			UtilBase.Instance.utillogger
					.debug("Tried to insert more than 10 images into the database - database insertion failed! You may only take 10 screenshots per test.");
		}

	}

	/**
	 * Generates a new, unique run id for the current test run. Writes to table
	 * 'Run_ID_Master', and updates the key in config.properties CurrentRunID
	 * 
	 * @throws ParseException
	 * @throws SQLException
	 */

	public static int generateRunIDInDB() throws SQLException, ParseException
	{
		int key = 0;

		if (FileIO.getConfigProperty("UseDB").equals("true"))
		{
			Connection dbConnection = connectToDB();
			PreparedStatement statement = null;
			ResultSet keys = null;

			String runIDTable = FileIO.getConfigProperty("RunIDTable");

			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss.SSS");
			Date parsedDate = dateFormat.parse(CommonMethods.getCurrentDate("MYSQL"));
			Timestamp currentInsertTime = new java.sql.Timestamp(parsedDate.getTime());

			String sql = "INSERT INTO " + runIDTable + " " + "(created_date)" + " " + "VALUES('"
					+ currentInsertTime + "')";

			try
			{

				if (dbConnection != null)
				{
					UtilBase.Instance.utillogger.info("Executing SQL Statment: " + sql);
					statement = dbConnection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
					statement.executeUpdate();
					keys = statement.getGeneratedKeys();
					keys.next();
					key = keys.getInt(1);

					statement.close();
					dbConnection.close();

					UtilBase.Instance.utillogger.info("Autogenerated run_id for this test run is: "
							+ key);
					FileIO.setConfigProperty("CurrentRunID", String.valueOf(key).toString());

				}

			} catch (SQLException s)
			{
				s.printStackTrace();
			} catch (Exception e)
			{
				e.printStackTrace();
			} finally
			{

				try
				{

					if (statement != null)
						statement.close();

				} catch (SQLException se2)
				{
				}

				try
				{

					if (dbConnection != null)
						dbConnection.close();

				} catch (SQLException se)
				{
					se.printStackTrace();
				}

			}

			return key;
		}
		return key;
	}

}