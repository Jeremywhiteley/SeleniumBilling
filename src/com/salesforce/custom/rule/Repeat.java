package com.salesforce.custom.rule;

import org.junit.rules.TestRule;
import org.junit.runner.Description;
import org.junit.runners.model.Statement;

/**
 * Rule class that repeats the same test 'n' number of times
 * Example Usage: 
 * ~~~~~~~
 * @Rule
 * int n: //number of times to repeat
 * public Repeat repeat = new Repeat(n);
 * ~~~~~~~~
 */

public class Repeat implements TestRule 
{
    private int count;
    
    public Repeat(int count) 
    {
        this.count = count;
    }
    
    
    @Override
    public Statement apply(final Statement base, Description description) 
    {
        return new Statement() 
        {
            @Override
            public void evaluate() throws Throwable 
            {
                for (int i = 0; i < count; i++) 
                {
                    base.evaluate();
                }
            }
        };
    }

}