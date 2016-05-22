package com.salesforce.entities;

import java.util.List;

public class ObjectDetail {
	private List<String> standardFields;
	private List<String> customFields;
	private String apiName;
	private String objName;
	private String createdBy;
	private List<ObjectFields> standardFieldsList;
	private List<ObjectFields> customFieldsList;
	public List<ObjectFields> getStandardFieldsList() {
		return standardFieldsList;
	}

	public void setStandardFieldsList(List<ObjectFields> standardFieldsList) {
		this.standardFieldsList = standardFieldsList;
	}

	public List<ObjectFields> getCustomFieldsList() {
		return customFieldsList;
	}

	public void setCustomFieldsList(List<ObjectFields> customFieldsList) {
		this.customFieldsList = customFieldsList;
	}

	public String getCreatedBy() {
		return createdBy;
	}

	public void setCreatedBy(String createdBy) {
		this.createdBy = createdBy;
	}

	public String getObjName() {
		return objName;
	}

	public void setObjName(String objName) {
		this.objName = objName;
	}

	public String getApiName() {
		return apiName;
	}

	public void setApiName(String apiName) {
		this.apiName = apiName;
	}

	public List<String> getStandardFields() {
		return standardFields;
	}

	public void setStandardFields(List<String> standardFields) {
		this.standardFields = standardFields;
	}

	public List<String> getCustomFields() {
		return customFields;
	}

	public void setCustomFields(List<String> customFields) {
		this.customFields = customFields;
	}
}
