package com.rational.serialization.json {
	import com.rational.utils.IStream;
	
	import org.flexunit.Assert;
	
	public final class ParserTestCase {
		private var parser:Parser;
		
		[Before]
		public final function setUp():void {
			parser = new Parser();
		}
		
		[Test(description="This tests for proper boolean array parsing")]
		public final function testBoolean():void {
			var 
				tokens:Array = [Token.LEFT_BRACKET, Token.TRUE, Token.RIGHT_BRACKET],
				stream:IStream = new ArrayStream(tokens),
				array:Array,
				result:Boolean;
			array = parser.parse(stream) as Array;
			Assert.assertNotNull(array);
			Assert.assertEquals(1, array.length);
			result = array[0] as Boolean;
			Assert.assertNotNull(result);
			Assert.assertTrue(result);
			
			tokens = [Token.LEFT_BRACKET, Token.FALSE, Token.RIGHT_BRACKET];
			stream = new ArrayStream(tokens);
			array = parser.parse(stream) as Array;
			Assert.assertNotNull(array);
			Assert.assertEquals(1, array.length);
			result = array[0] as Boolean;
			Assert.assertNotNull(result);
			Assert.assertFalse(result);
		}	
			
//		[Test(description="This tests for parsing of only top level elements")]
		public final function testNonTopLevel():void {
			var
				tokens:Array = [Token.NUMBER(-97123)],
				stream:IStream = new ArrayStream(tokens),
				erred:Boolean = false,
				lexer:Lexer;
			try {
				parser.parse(stream);
			} catch (e:ParserError) {
				erred = true;
			}
			Assert.assertTrue(erred);
			
			erred = false;
			lexer = new Lexer("-97123");
			try {
				parser.parse(lexer);
			} catch (e:ParserError) {
				erred = true;
			}
			Assert.assertTrue(erred);
		}
	}
}