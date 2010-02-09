import com.rational.utils.IterStream;
import com.rational.utils.Stream;
import com.rational.serialization.json.Lexer;
import com.rational.serialization.json.LexerError;
import com.rational.serialization.json.Parser;
import com.rational.serialization.json.Token;
import haxe.unit.TestCase;
import haxe.unit.TestRunner;

using com.rational.utils.Tools;

private typedef T = Token;

class Tests {
	public static function main():Void {
		var runner:TestRunner = new TestRunner();
		runner.add(new LexerTestCase());
		runner.add(new LexerSpaceTestCase());
		runner.add(new LexerHorizontalTabTestCase());
		runner.add(new LexerNewlineTestCase());
		runner.add(new LexerRandomTestCase());
		runner.add(new ParserTestCase());
		runner.run();
	}
}

class LexerTestCase extends TestCase {
	public function assertToken(string:String, token:Token) {
		var lexer = new Lexer(string.stream());
		assertEquals(token, lexer.pop());
	}
	
	public function assertStringTokenValue(string:String, expected:String) {
		var lexer = new Lexer(string.stream());
		switch (lexer.pop()) {
			case STRING(value): assertEquals(expected, value); 				
			default: assertTrue(false);
		}
	}
	
	public function assertNumberTokenValue(string:String, expected:Float) {
		var lexer = new Lexer(string.stream());
		switch (lexer.pop()) {
			case NUMBER(value): assertEquals(expected, value); 				
			default: assertTrue(false);
		}
	}
	
	private function assertLexerError(string:String, ?expected:String = null) {
		var lexer = new Lexer(string.stream());
		var erred = false;
		try {
			lexer.pop();
		} catch (e:LexerError) {
			erred = true;
			if (expected != null) {
				assertEquals(expected, e.message);
			}
		}
		assertTrue(erred);
	}

	public function testFailure() {
		assertLexerError("what?", "Unexpected \"w\"");
	}

	public function testLeftBrace() {
		assertToken("{", Token.LEFT_BRACE);
	}
	
	public function testRightBrace() {
		assertToken("}", Token.RIGHT_BRACE);
	}
	
	public function testLeftBracket() {
		assertToken("[", Token.LEFT_BRACKET);
	}
	
	public function testRightBracket() {
		assertToken("]", Token.RIGHT_BRACKET);
	}
	
	public function testTrue() {
		assertToken("true", Token.TRUE);
	}
	
	public function testFalse() {
		assertToken("false", Token.FALSE);
	}
	
	public function testNull() {
		assertToken("null", Token.NULL);
	}
	
	public function testSimpleString() {
		assertStringTokenValue("\"simple\"", "simple");
	}
	
	public function testQuotationMarkEscape() {
		assertStringTokenValue("\"\\\"\"", "\"");
	}
	
	public function testReverseSolidusEscape() {
		assertStringTokenValue("\"\\\\\"", "\\");
	}
	
	public function testSolidusEscape() {
		assertStringTokenValue("\"\\/\"", "/");
	}
	
	public function testBackspaceEscape() {
		assertStringTokenValue("\"\\b\"", "\x08");
	}
	
	public function testFormfeedEscape() {
		assertStringTokenValue("\"\\f\"", "\x0C");
	}
	
	public function testNewlineEscape() {
		assertStringTokenValue("\"\\n\"", "\n");
	}
	
	public function testCarriageReturnEscape() {
		assertStringTokenValue("\"\\r\"", "\r");
	}
	
	public function testHorizontalTabEscape() {
		assertStringTokenValue("\"\\t\"", "\t");
	}
	
	public function testUnicodeEscape() {
		assertStringTokenValue("\"\\u0000\"", "\x00");
		assertStringTokenValue("\"\\u0001\"", "\x01");
		assertStringTokenValue("\"\\u000A\"", "\x0A");
		assertStringTokenValue("\"\\u000F\"", "\x0F");
	}
	
	public function testComplexString() {
		assertStringTokenValue("\"Hello,\\tWorld2\\b\\u0021\"", "Hello,\tWorld2\x08!");
	}
	
	public function testZero() {
		assertNumberTokenValue("0", 0);
	}
	
	public function testIntegral() {
		assertNumberTokenValue("123", 123);
	}
	
	public function testLeadingZeroFractional() {
		assertNumberTokenValue("0.123", 0.123);
	}
	
	public function testIntegralFractional() {
		assertNumberTokenValue("123.123", 123.123);
	}
	
	public function testLeadingZeroExponential() {
		assertNumberTokenValue("0e10", 0);
		assertNumberTokenValue("0E11", 0);
	}
	
	public function testIntegralExponential() {
		assertNumberTokenValue("123e12", 123e12);
		assertNumberTokenValue("123E13", 123e13);
	}
	
	public function testLeadingZeroFractionalExponential() {
		assertNumberTokenValue("0.945e10", 0.945e10);
		assertNumberTokenValue("0.945E11", 0.945e11);		
	}
	
	public function testIntegralFractionalExponential() {
		assertNumberTokenValue("123.787e9", 123.787e9);
		assertNumberTokenValue("456.787e10", 456.787e10);
	}
	
	public function testUnclosedString() {
		assertLexerError("\"123", "Unexpected end of input");
	}

	public function testIncompleteKeyword() {
		assertLexerError("tru", "Unexpected end of input");
	}
}

class LexerWrappingTestCase extends LexerTestCase {
	private var wrapping:String;
	public function new(wrapping:String) {
		super();
		this.wrapping = wrapping;
	}
	
	override public function assertToken(string:String, token:Token) {
		super.assertToken(wrapping + string + wrapping, token);
	}
	
	override public function assertStringTokenValue(string:String, expected:String) {
		super.assertStringTokenValue(wrapping + string + wrapping, expected);
	}
	
	override public function assertNumberTokenValue(string:String, expected:Float) {
		super.assertNumberTokenValue(wrapping + string + wrapping, expected);
	}
}

class LexerSpaceTestCase extends LexerWrappingTestCase {
	public function new() {
		super(' ');
	}
}

class LexerHorizontalTabTestCase extends LexerWrappingTestCase {
	public function new() {
		super('\t');
	}
}

class LexerNewlineTestCase extends LexerWrappingTestCase {
	public function new() {
		super('\n');
	}	
}

class LexerRandomTestCase extends LexerTestCase {
#if neko
	private var r:neko.Random;
	
	override public function setup() {
		r = new neko.Random();
	}
	
	override public function tearDown() {
		r = null;
	}

	public function testRandomIntegral() {
		for (i in 0...100) {
			var value = r.int(-1);
			assertNumberTokenValue(Std.string(value), value);
		}
	}
#end
}

class SimpleObject {
	public function new() {}
	public var booleanField:Bool;
	public var stringField:String;
	public var numberField:Float;
}

class ComplexObject {
	public function new() {}
	public var simpleObject:SimpleObject;
}

class ParserTestCase extends TestCase {
	private var parser:Parser;
  
  public function new() {
  	super();
	}
  
	override public function setup() {
		parser = new Parser();
	}

	public function testSimpleObject() {
		var tokens:Iterable<Token> = [
			T.LEFT_BRACE,
			T.STRING("numberField"),
			T.COLON,
			T.NUMBER(3.14),
			T.COMMA,
			T.STRING("stringField"),
			T.COLON,
			T.STRING("hello, world!"),
			T.COMMA,
			T.STRING("booleanField"),
			T.COLON,
			T.TRUE,
			T.RIGHT_BRACE
		];
		var stream = new IterStream<Token>(tokens);
		var simple:SimpleObject = parser.parse(stream, SimpleObject);
		assertEquals(null, stream.peek());
		assertTrue(simple.booleanField);
		assertEquals("hello, world!", simple.stringField);
		assertEquals(3.14, simple.numberField);
	}
	
	public function testComplexObject() {
		var tokens:Iterable<Token> = [
			T.LEFT_BRACE,
			T.STRING("simpleObject"),
			T.COLON,
			T.LEFT_BRACE,
			T.STRING("booleanField"),
			T.COLON,
			T.TRUE,
			T.COMMA,
			T.STRING("numberField"),
			T.COLON,
			T.NUMBER(3.14),
			T.COMMA,
			T.STRING("stringField"),
			T.COLON,
			T.STRING("hello, world!"),
			T.RIGHT_BRACE,
			T.RIGHT_BRACE
		];
		var stream = new IterStream<Token>(tokens);
	 	var complex:ComplexObject = parser.parse(stream, ComplexObject);
	 	assertEquals(null, stream.peek());
#if flash
	 	var simple:SimpleObject = cast(complex.simpleObject, SimpleObject);
#else
		var simple = complex.simpleObject;
#end
		assertTrue(simple.booleanField);
		assertEquals("hello, world!", simple.stringField);
		assertEquals(3.14, simple.numberField);
	}
	
	public function testSimpleObjects() {
		var tokens:Iterable<Token> = [
			T.LEFT_BRACKET,
			T.LEFT_BRACE,
			T.STRING("numberField"),
			T.COLON,
			T.NUMBER(3.14),
			T.COMMA,
			T.STRING("stringField"),
			T.COLON,
			T.STRING("hello, world!"),
			T.COMMA,
			T.STRING("booleanField"),
			T.COLON,
			T.TRUE,
			T.RIGHT_BRACE,
			T.LEFT_BRACE,
			T.STRING("numberField"),
			T.COLON,
			T.NUMBER(7.3),
			T.COMMA,
			T.STRING("stringField"),
			T.COLON,
			T.STRING("goodbye, cruel world!"),
			T.COMMA,
			T.STRING("booleanField"),
			T.COLON,
			T.FALSE,
			T.RIGHT_BRACE,
			T.RIGHT_BRACKET
		];
		var simples:Array<SimpleObject> = parser.parse(new IterStream<Token>(tokens), SimpleObject);
#if flash
	 	var simple0:SimpleObject = cast(simples[0], SimpleObject);
#else
		var simple0 = simples[0];
#end
		assertTrue(simple0.booleanField);
		assertEquals("hello, world!", simple0.stringField);
		assertEquals(3.14, simple0.numberField);
#if flash
	 	var simple1:SimpleObject = cast(simples[1], SimpleObject);
#else
		var simple1 = simples[1];
#end
		assertFalse(simple1.booleanField);
		assertEquals("goodbye, cruel world!", simple1.stringField);
		assertEquals(7.3, simple1.numberField);
	}
}
