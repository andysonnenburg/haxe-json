package com.rational.serialization.json {
	import org.flexunit.Assert;
	
	public final class JSONTestCase {
		
		[Test(description="This tests for a private constructor", expects="Error")]
		public final function testPrivateConstructor():void {
			new JSON(null);
		}
		
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
		
		[Test(description="This tests for date serialization")]
		public final function testDate():void {
			const now:Date = new Date();
			const other:Date = JSON.decode(JSON.encode(now), Date)
			Assert.assertEquals(now.time, other.time);
			Assert.assertTrue(other is Date);
		}
	}
}