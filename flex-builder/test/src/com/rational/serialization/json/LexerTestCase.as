package com.rational.serialization.json {
	import org.flexunit.Assert;
	
	public final class LexerTestCase {
		[Test(description="This tests for proper lexing of true")]
		public final function testTrue():void {
			const lexer:Lexer = new Lexer("true");
			Assert.assertEquals(Token.TRUE, lexer.pop());
		}
		
		[Test(description="This tests for proper lexing of false")]
		public final function testFalse():void {
			const lexer:Lexer = new Lexer("false");
			Assert.assertEquals(Token.FALSE, lexer.pop());
		}
		
		[Test(description="This tests for property lexing of null")]
		public final function testNull():void {
			const lexer:Lexer = new Lexer("null");
			Assert.assertEquals(Token.NULL, lexer.pop());
		}
	}
}