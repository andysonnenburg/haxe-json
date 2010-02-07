package com.rational.serialization.json;

import com.rational.utils.CharCodes;
import com.rational.utils.Tools;
import com.rational.utils.Stream;

using StringTools;

private typedef CC = CharCodes;
private typedef S = LexerStates;
private typedef T = Tools;

class Lexer {
	private var stream:Stream<Int>;
	private var peeked:Bool;
	private var token:Null<Token>;
	
	public function new(stream:Stream<Int>) {
		this.stream = stream;
		this.peeked = false;
	}
	
	public function peek():Null<Token> {
		if (!peeked) {
			token = nextToken();
			peeked = true;
		}
		return token;
	}
	
	public function pop():Null<Token> {
		peek();
		peeked = false;
		return token;
	}
	
	public function skip():Void {
		pop();
	}
	
	private static inline function safePeek(stream:Stream<Int>):Int {
		var code;
		if ((code = stream.peek()) == null) {
			throw new LexerError("Unexpected end of input");
		}
		return code;
	}
	
	private static inline function safePop(stream:Stream<Int>):Int {
		var code;
		if ((code = stream.pop()) == null) {
			throw new LexerError("Unexpected end of input");
		}
		return code;
	}
	
	private inline function unexpected():Void {
		var code;
		throw new LexerError(if ((code = stream.peek()) != null) {
				"Unexpected \"" + String.fromCharCode(code) + "\"";
			} else {
				"Unexpected end of input";
			});
	}
	
	private inline function internalError():Void {
		throw new LexerError("Internal error");
	}
	
	private function nextToken():Null<Token> {
		var state:Int = S.START;
		var stream:Stream<Int> = this.stream;
		var code:Null<Int>;
		var buf:StringBuf = null;
		var hexBuf:StringBuf = null;
		var token:Token;
		skipWhitespace();
		while (true) {
			switch (state) {
				case S.START:
					if ((code = stream.peek()) == null) {
						return null;
					}
					switch (code) {
						case CC.LEFT_BRACE: stream.skip(); return Token.LEFT_BRACE;
						case CC.RIGHT_BRACE: stream.skip(); return Token.RIGHT_BRACE;
						case CC.LEFT_BRACKET: stream.skip(); return Token.LEFT_BRACKET;
						case CC.RIGHT_BRACKET: stream.skip(); return Token.RIGHT_BRACKET;
						case CC.COMMA: stream.skip(); return Token.COMMA;
						case CC.COLON: stream.skip(); return Token.COLON;
						case CC.t: stream.skip(); state = S.t;
						case CC.f: stream.skip(); state = S.f;
						case CC.n: stream.skip(); state = S.n;
						case CC.QUOTATION_MARK:
							stream.skip();
							buf = new StringBuf();
							state = S.QUOTATION_MARK;
						case CC.MINUS:
							skip();
							buf = new StringBuf();
							buf.addChar(CC.MINUS);
							state = S.MINUS;
						case CC.ZERO:
							stream.skip();
							buf = new StringBuf();
							buf.addChar(CC.ZERO);
							state = S.LEADING_ZERO;
						case
							CC.ONE,
							CC.TWO,
							CC.THREE,
							CC.FOUR,
							CC.FIVE,
							CC.SIX,
							CC.SEVEN,
							CC.EIGHT,
							CC.NINE:
								stream.skip();
								buf = new StringBuf();
								buf.addChar(code);
								state = S.INTEGRAL;
						default: unexpected();
					}
				case S.t:
					switch (stream.peek()) {
						case CC.r: stream.skip(); state = S.tr;
						default: unexpected();
					}
				case S.tr:
					switch (stream.peek()) {
						case CC.u: stream.skip(); state = S.tru;
						default: unexpected();
					}
				case S.tru:
					switch (stream.peek()) {
						case CC.e: stream.skip(); return Token.TRUE;
						default: unexpected();
					}
				case S.f:
					switch (stream.peek()) {
						case CC.a: stream.skip(); state = S.fa;
						default: unexpected();
					}
				case S.fa:
					switch (stream.peek()) {
						case CC.l: stream.skip(); state = S.fal;
						default: unexpected();
					}
				case S.fal:
					switch (stream.peek()) {
						case CC.s: stream.skip(); state = S.fals;
						default: unexpected();
					}
				case S.fals:
					switch (stream.peek()) {
						case CC.e: stream.skip(); return Token.FALSE;
						default: unexpected();
					}
				case S.n:
					switch (stream.peek()) {
						case CC.u: stream.skip(); state = S.nu;
						default: unexpected();
					}
				case S.nu:
					switch (stream.peek()) {
						case CC.l: stream.skip(); state = S.nul;
						default: unexpected();
					}
				case S.nul:
					switch (stream.peek()) {
						case CC.l: stream.skip(); return Token.NULL;
						default: unexpected();
					}
				case S.QUOTATION_MARK:
					switch ((code = safePop(stream))) {
						case CC.REVERSE_SOLIDUS: state = S.REVERSE_SOLIDUS;
						case CC.QUOTATION_MARK:	state = S.STRING;
						default: buf.addChar(code);
					}
				case S.REVERSE_SOLIDUS:
					code = stream.peek();
					switch (code) {
						case
							CC.QUOTATION_MARK,
							CC.REVERSE_SOLIDUS,
							CC.SOLIDUS:
								stream.skip();
								buf.addChar(code);
								state = S.QUOTATION_MARK;
						case CC.b:
							stream.skip();
							buf.addChar(CC.BACKSPACE);
							state = S.QUOTATION_MARK;
						case CC.f:
							stream.skip();
							buf.addChar(CC.FORMFEED);
							state = S.QUOTATION_MARK;
						case CC.n:
							stream.skip();
							buf.addChar(CC.NEWLINE);
							state = S.QUOTATION_MARK;
						case CC.r:
							stream.skip();
							buf.addChar(CC.CARRIAGE_RETURN);
							state = S.QUOTATION_MARK;
						case CC.t:
							stream.skip();
							buf.addChar(CC.HORIZONTAL_TAB);
							state = S.QUOTATION_MARK;
						case CC.u:
							stream.skip();
							hexBuf = new StringBuf();
							state = S.UNICODE_ESCAPE;
						default: unexpected();
					}
				case S.UNICODE_ESCAPE:
					hexDigit(hexBuf);
					state = S.HEX_DIGIT1;
				case S.HEX_DIGIT1:
					hexDigit(hexBuf);
					state = S.HEX_DIGIT2;
				case S.HEX_DIGIT2:
					hexDigit(hexBuf);
					state = S.HEX_DIGIT3;
				case S.HEX_DIGIT3:
					hexDigit(hexBuf);
					buf.addChar(T.parseHex(hexBuf.toString()));
					state = S.QUOTATION_MARK;
				case S.MINUS:
					code = stream.peek();
					switch (code) {
						case CC.ZERO:
							stream.skip();
							buf.addChar(CC.ZERO);
							state = S.LEADING_ZERO;
						case
							CC.ONE,
							CC.TWO,
							CC.THREE,
							CC.FOUR,
							CC.FIVE,
							CC.SIX,
							CC.SEVEN,
							CC.EIGHT,
							CC.NINE:
								stream.skip();
								buf.addChar(code);
								state = S.INTEGRAL;
					}
				case S.LEADING_ZERO: state = fractionalOrExponential(buf);
				case S.INTEGRAL:
					if (!digit(buf)) {
						state = fractionalOrExponential(buf);
					}
				case S.LEADING_FRACTIONAL:
					if (!digit(buf)) {
						unexpected();
					}
					state = S.FRACTIONAL;
				case S.FRACTIONAL:
					if (!digit(buf)) {
						state = exponential(buf);							
					}
				case S.LEADING_EXPONENTIAL:
					if (!digit(buf)) {
						unexpected();
					}
					state = S.EXPONENTIAL;
				case S.EXPONENTIAL:
					if (!digit(buf)) {
						state = S.NUMBER;
					}
				case S.STRING: return Token.STRING(buf.toString());
				case S.NUMBER: return Token.NUMBER(Std.parseFloat(buf.toString()));
				default: internalError();
			}
		}
		internalError();
	}
	
	private inline function hexDigit(buf:StringBuf):Void {
		var code = stream.peek();
		switch (code) {
			case
				CC.ZERO,
				CC.ONE,
				CC.TWO,
				CC.THREE,
				CC.FOUR,
				CC.FIVE,
				CC.SIX,
				CC.SEVEN,
				CC.EIGHT,
				CC.NINE,
				CC.A, CC.a,
				CC.B, CC.b,
				CC.C, CC.c,
				CC.D, CC.d,
				CC.E, CC.e,
				CC.F, CC.f:
					stream.skip();
					buf.addChar(code);
			default: unexpected();
		}
	}
	
	private function fractionalOrExponential(buf:StringBuf):Int {
		var code:Null<Int> = stream.peek();
		if (code == null) {
			return S.NUMBER;
		}
		switch (code) {
			case CC.PERIOD:
				stream.skip();
				buf.addChar(CC.PERIOD);
				return S.LEADING_FRACTIONAL;
			case CC.e, CC.E:
				stream.skip();
				buf.addChar(CC.e);
				return S.LEADING_EXPONENTIAL;
			default: return S.NUMBER;
		}
		internalError();
	}
	
	private function exponential(buf:StringBuf):Int {
		var code:Null<Int> = stream.peek();
		if (code == null) {
			return S.NUMBER;
		}
		switch (code) {
			case CC.e, CC.E:
				stream.skip();
				buf.addChar(CC.e);
				return S.LEADING_EXPONENTIAL;
			default: return S.NUMBER;
		}
	}
	
	private function digit(buf:StringBuf):Bool {
		var code = stream.peek();
		switch (code) {
			case
				CC.ZERO,
				CC.ONE,
				CC.TWO,
				CC.THREE,
				CC.FOUR,
				CC.FIVE,
				CC.SIX,
				CC.SEVEN,
				CC.EIGHT,
				CC.NINE:
					stream.skip();
					buf.addChar(code);
					return true;
			default: return false;
		}
	}
	
	private inline function skipWhitespace():Void {
		while (true) {
			switch (stream.peek()) {
				case
					0x0009,
					0x000A,
					0x000B,
					0x000C,
					0x000D,
					0x0020,
					0x0085,
					0x00A0,
					0x1680,
					0x180E,
					0x2000,
					0x2001,
					0x2002,
					0x2003,
					0x2004,
					0x2005,
					0x2006,
					0x2007,
					0x2008,
					0x2009,
					0x200A,
					0x2028,
					0x2029,
					0x202F,
					0x205F,
					0x3000:
						stream.skip();
				default:
					break;
			}
		}
	}
}
