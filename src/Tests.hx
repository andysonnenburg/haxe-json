import com.rational.serialization.json.Lexer;
import com.rational.serialization.json.LexerError;
import com.rational.serialization.json.Token;
import com.rational.utils.CharSequence;
import haxe.unit.TestCase;
import haxe.unit.TestRunner;

class Tests {
	public static function main():Void {
		var runner:TestRunner = new TestRunner();
		runner.add(new LexerTestCase());
		runner.run();
	}
}

class LexerTestCase extends TestCase {
	private function assertToken(string:String, token:Token) {
		var lexer = new Lexer(new CharSequence(string));
		assertEquals(token, lexer.next());
	}
	
	private function assertStringTokenValue(string:String, expected:String) {
		var lexer = new Lexer(new CharSequence(string));
		switch (lexer.next()) {
			case STRING(value): assertEquals(expected, value); 				
			default: assertTrue(false);
		}
	}
	
	private function assertLexerError(string:String) {
		var lexer = new Lexer(new CharSequence(string));
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
	
	public function testIntegral() {
		assertNumberTokenValue("
	}
}
