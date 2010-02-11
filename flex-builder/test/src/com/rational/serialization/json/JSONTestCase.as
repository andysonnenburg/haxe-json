package com.rational.serialization.json {
	import org.flexunit.Assert;
	
	public final class JSONTestCase {
		[Test(description="This tests null array decoding")]
		public final function testNullArray():void {
			const result:Array = JSON.decode("[null]");
			Assert.assertEquals(1, result.length);
			Assert.assertEquals(null, result[0]);
		}
		
		[Test(description="This tests simple object decoding")]
		public final function testSimpleObject():void {
			const input:SimpleObject = new SimpleObject();
			input.booleanField = true;
			input.stringField = "hello, world!";
			input.numberField = 3.1415;
			const string:String = JSON.encode(input);
			const result:SimpleObject = JSON.decode(string, SimpleObject);
			Assert.assertEquals(true, result.booleanField);
			Assert.assertEquals("hello, world!", result.stringField);
			Assert.assertEquals(3.1415, result.numberField);
		}
		
		[Test(description="This tests for parsing of top level negative integers")]
		public final function testNonTopLevel():void {
			Assert.assertEquals(-97123, JSON.decode("-97123"));
		}
	}
}