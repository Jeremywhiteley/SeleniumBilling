package com.salesforce.entities;

import java.util.List;

public class ObjectFields {
	private String value;
	private String field;
	private String label;
	private String apiName;
	private String length;
	private String dataType;
	private String createdBy;
	private String defaultValue;
	private String externalId;
	private String caseSensitive;
	private String uniqueRequired;
	private String helpText;
	private String description;
	private String validationRules;
	private String sharingSetting;
	private String parentObjName;
	private List<String> picklistValues;

	public List<String> getPicklistValues() {
		return picklistValues;
	}

	public void setPicklistValues(List<String> picklistValues) {
		this.picklistValues = picklistValues;
	}

	public String getParentObjName() {
		return parentObjName;
	}

	public void setParentObjName(String parentObjName) {
		this.parentObjName = parentObjName;
	}

	public String getValue() {
		return value;
	}

	public void setValue(String value) {
		this.value = value;
	}

	public String getField() {
		return field;
	}

	public void setField(String field) {
		this.field = field;
	}

	public String getLabel() {
		return label;
	}

	public void setLabel(String label) {
		this.label = label;
	}

	public String getApiName() {
		return apiName;
	}

	public void setApiName(String apiName) {
		this.apiName = apiName;
	}

	public String getLength() {
		return length;
	}

	public void setLength(String length) {
		this.length = length;
	}

	public String getDataType() {
		return dataType;
	}

	public void setDataType(String dataType) {
		this.dataType = dataType;
	}

	public String getCreatedBy() {
		return createdBy;
	}

	public void setCreatedBy(String createdBy) {
		this.createdBy = createdBy;
	}

	public String getDefaultValue() {
		return defaultValue;
	}

	public void setDefaultValue(String defaultValue) {
		this.defaultValue = defaultValue;
	}

	public String getExternalId() {
		return externalId;
	}

	public void setExternalId(String externalId) {
		this.externalId = externalId;
	}

	public String getCaseSensitive() {
		return caseSensitive;
	}

	public void setCaseSensitive(String caseSensitive) {
		this.caseSensitive = caseSensitive;
	}

	public String getUniqueRequired() {
		return uniqueRequired;
	}

	public void setUniqueRequired(String uniqueRequired) {
		this.uniqueRequired = uniqueRequired;
	}

	public String getHelpText() {
		return helpText;
	}

	public void setHelpText(String helpText) {
		this.helpText = helpText;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getValidationRules() {
		return validationRules;
	}

	public void setValidationRules(String validationRules) {
		this.validationRules = validationRules;
	}

	public String getSharingSetting() {
		return sharingSetting;
	}

	public void setSharingSetting(String sharingSetting) {
		this.sharingSetting = sharingSetting;
	}

}
