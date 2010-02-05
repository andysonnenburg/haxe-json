import com.rational.serialization.json.Lexer;
import com.rational.serialization.json.LexerError;
import com.rational.serialization.json.Token;
import haxe.unit.TestCase;
import haxe.unit.TestRunner;

using com.rational.utils.Tools;

class Tests {
	public static function main():Void {
		var runner:TestRunner = new TestRunner();
		runner.add(new LexerTestCase());
		runner.add(new LexerWrappingTestCase(" "));
		runner.add(new LexerWrappingTestCase("\t"));
		runner.add(new LexerWrappingTestCase("\n"));
		runner.add(new LexerRandomTestCase());
		runner.run();
	}
}

class LexerTestCase extends TestCase {
	public function assertToken(string:String, token:Token) {
		var lexer = new Lexer(string.stream());
		assertEquals(token, lexer.next());
	}
	
	public function assertStringTokenValue(string:String, expected:String) {
		var lexer = new Lexer(string.stream());
		switch (lexer.next()) {
			case STRING(value): assertEquals(expected, value); 				
			default: assertTrue(false);
		}
	}
	
	public function assertNumberTokenValue(string:String, expected:Float) {
		var lexer = new Lexer(string.stream());
		switch (lexer.next()) {
			case NUMBER(value): assertEquals(expected, value); 				
			default: assertTrue(false);
		}
	}
	
	private function assertLexerError(string:String) {
		var lexer = new Lexer(string.stream());
		var erred = false;
		try {
			lexer.next();
		} catch (e:LexerError) {
			erred = true;
		}
		assertTrue(true);
	}

	public function testFailure() {
		assertLexerError("what?");
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
		assertNumberTokenValue("123.987e9", 123.987e9);
		assertNumberTokenValue("456.987e10", 456.987e10);
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
