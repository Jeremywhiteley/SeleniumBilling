package com.salesforce.custom.annotation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;


@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)

public @interface Custom 
{
	String page() default "";
	String createdBy() default "";
	String createdDate() default "";

}