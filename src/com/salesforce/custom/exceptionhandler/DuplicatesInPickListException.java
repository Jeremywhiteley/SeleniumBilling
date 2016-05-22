package com.salesforce.custom.exceptionhandler;

public class DuplicatesInPickListException extends Exception {
 
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String message = null;
 
    public DuplicatesInPickListException() {
        super();
    }
 
    public DuplicatesInPickListException(String message) {
        super(message);
        this.message = message;
    }
 
    public DuplicatesInPickListException(Throwable cause) {
        super(cause);
    }
 
    @Override
    public String toString() {
        return message;
    }
 
    @Override
    public String getMessage() {
        return message;
    }
}