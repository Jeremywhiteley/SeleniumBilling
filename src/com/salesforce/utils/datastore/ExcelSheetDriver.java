package com.salesforce.utils.datastore;

import java.io.File;
import java.io.IOException;
import java.util.Hashtable;

import jxl.Sheet;
import jxl.Workbook;
import jxl.read.biff.BiffException;
import jxl.write.Label;
import jxl.write.WritableCellFormat;
import jxl.write.WritableFont;
import jxl.write.WritableSheet;
import jxl.write.WritableWorkbook;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;

import com.salesforce.utils.UtilBase;

public class ExcelSheetDriver extends UtilBase
{

	private Sheet wrksheet;
	private String excelFilePath = FileIO.getConfigProperty("TestDataFile");
	private Workbook wrkbook = null;
	private WritableWorkbook wworkbook;
	private WritableSheet wsheet;
	private Label label;

	public WritableSheet getWsheet()
	{
		return wsheet;
	}

	public void setWsheet(WritableSheet wsheet)
	{
		this.wsheet = wsheet;
	}

	public WritableWorkbook getWworkbook()
	{
		return wworkbook;
	}

	public void setWworkbook(WritableWorkbook wworkbook)
	{
		this.wworkbook = wworkbook;
	}

	public Sheet getWrksheet()
	{
		return wrksheet;
	}

	public String getExcelFilePath()
	{
		return excelFilePath;
	}

	public Workbook getWrkbook()
	{
		return wrkbook;
	}

	public void setWrksheet(Sheet wrksheet)
	{
		this.wrksheet = wrksheet;
	}

	public void setExcelFilePath(String excelFilePath)
	{
		this.excelFilePath = excelFilePath;
	}

	public void setWrkbook(Workbook wrkbook)
	{
		this.wrkbook = wrkbook;
	}

	Hashtable<String, Integer> dict = new Hashtable<String, Integer>();

	public ExcelSheetDriver(String dataSheetName) throws BiffException, IOException
	{
		this.setExcelFilePath(FileIO.getConfigProperty("TestDataFile"));
		wrkbook = Workbook.getWorkbook(new File(excelFilePath));
		System.err.println("------ExcelSheetDriver------excelFilePath----------->"+ excelFilePath);
		System.err.println("------ExcelSheetDriver------dataSheetName----------->"+ dataSheetName);
		
		wrksheet = wrkbook.getSheet(dataSheetName);

	}

	public ExcelSheetDriver()
	{

	}

	public ExcelSheetDriver(String wwbook, String wsheet) throws IOException
	{
		this.wworkbook = Workbook.createWorkbook(new File(wwbook));
		this.wsheet = wworkbook.createSheet(wsheet, 0);
	}

	public void writeHeader(String[] header) throws RowsExceededException, WriteException,
			IOException
	{
		int i = 0;
		for (String headerItem : header)
		{
			this.addLabelToCellWithFont(i++, 0, headerItem);
		}
	}

	public int RowCount()
	{
		utillogger.debug("Number of worksheet rows is: " + wrksheet.getRows());
		return wrksheet.getRows();
	}

	public void addRowToSheet(String[] rowToAdd, int rowNumber) throws RowsExceededException,
			WriteException, IOException
	{
		int i = 0;
		wsheet.insertRow(rowNumber);
		for (String cellData : rowToAdd)
		{
			this.addLabelToCell(i++, rowNumber, cellData);
		}
	}

	public void addRowToSheetWithBoldFont(String[] rowToAdd, int rowNumber)
			throws RowsExceededException, WriteException, IOException
	{
		
		int i = 0;
		wsheet.insertRow(rowNumber);
		for (String cellData : rowToAdd)
		{
			this.addLabelToCellWithFont(i++, rowNumber, cellData);
		}
	}

	public void addLabelToCellWithFont(int column, int row, String text)
			throws RowsExceededException, WriteException, IOException
	{
		System.err.println("-----------addLabelToCellWithFont-------------");
		WritableFont cellFont = new WritableFont(WritableFont.COURIER, 16);
		cellFont.setBoldStyle(WritableFont.BOLD);
		WritableCellFormat cellFormat = new WritableCellFormat(cellFont);
		this.label = new Label(column, row, text, cellFormat);
		this.wsheet.addCell(label);
	}

	public void addLabelToCell(int column, int row, String text) throws RowsExceededException,
			WriteException, IOException
	{
		this.label = new Label(column, row, text);
		this.wsheet.addCell(label);
	}

	public void writeToWorkBook() throws IOException
	{
		this.wworkbook.write();
	}

	public void closeWorkBook() throws WriteException, IOException
	{
		this.wworkbook.write();
		wworkbook.close();
	}

	public String ReadCell(int column, int row)
	{
		utillogger.debug("Returning the Excel cell value: " + "\""
				+ wrksheet.getCell(column, row).getContents() + "\"");
		System.err.println("-----wrksheet.getCell(column, row).getContents()------->"+ wrksheet.getCell(column, row).getContents());
		return wrksheet.getCell(column, row).getContents();
	}

	public void ColumnDictionary()
	{
		System.err.println("--------wrksheet.getColumns()-----------"+ wrksheet.getColumns());
		for (int col = 0; col < wrksheet.getColumns(); col++)
		{
			dict.put(ReadCell(col, 0), col);
		}
	}

	public int GetCell(String colName)
	{
		try
		{
			int value;
			value = ((Integer) dict.get(colName)).intValue();
			System.err.println("----GetCell--------GetCell----------"+ value);
			return value;
		} catch (NullPointerException e)
		{
			return (0);

		}
	}

}
