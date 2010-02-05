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
	
	public function new(stream:Stream<Null<Int>>) {
		this.stream = stream;
	}
	
	private inline function nextCode():Int {
		return stream.pop();
	}
	
	private inline function unexpected():Void {
		throw new LexerError("Unexpected \"" + String.fromCharCode(stream.peek()) + "\"");
	}
	
	private inline function internalError():Void {
		throw new LexerError("Internal error");
	}
	
	public function next():Token {
		var state:Int = S.START;
		var buf:StringBuf = null;
		var hexBuf:StringBuf = null;
		var token:Token;
		skipWhitespace();
		while (true) {
			switch (state) {
				case S.START:
					switch (nextCode()) {
						case CC.LEFT_BRACE: return Token.LEFT_BRACE;
						case CC.RIGHT_BRACE: return Token.RIGHT_BRACE;
						case CC.LEFT_BRACKET: return Token.LEFT_BRACKET;
						case CC.RIGHT_BRACKET: return Token.RIGHT_BRACKET;
						case CC.COMMA: return Token.COMMA;
						case CC.COLON: return Token.COLON;
						case CC.t: state = S.t;
						case CC.f: state = S.f;
						case CC.n: state = S.n;
						case CC.QUOTATION_MARK:
							buf = new StringBuf();
							state = S.QUOTATION_MARK;
						case CC.MINUS:
							buf = new StringBuf();
							buf.addChar(CC.MINUS);
							state = S.MINUS;
						case CC.ZERO:
							buf = new StringBuf();
							buf.addChar(CC.ZERO);
							state = S.LEADING_ZERO;
						case CC.ONE: buf = new StringBuf();
								buf.addChar(CC.ONE);
								state = S.INTEGRAL;
case CC.TWO: buf = new StringBuf();
								buf.addChar(CC.TWO);
								state = S.INTEGRAL;
case CC.THREE: buf = new StringBuf();
								buf.addChar(CC.THREE);
								state = S.INTEGRAL;
case CC.FOUR: buf = new StringBuf();
								buf.addChar(CC.FOUR);
								state = S.INTEGRAL;
case CC.FIVE: buf = new StringBuf();
								buf.addChar(CC.FIVE);
								state = S.INTEGRAL;
case CC.SIX: buf = new StringBuf();
								buf.addChar(CC.SIX);
								state = S.INTEGRAL;
case CC.SEVEN: buf = new StringBuf();
								buf.addChar(CC.SEVEN);
								state = S.INTEGRAL;
case CC.EIGHT: buf = new StringBuf();
								buf.addChar(CC.EIGHT);
								state = S.INTEGRAL;
case CC.NINE: buf = new StringBuf();
								buf.addChar(CC.NINE);
								state = S.INTEGRAL;

						default: unexpected();
					}
				case S.t:
					switch (nextCode()) {
						case CC.r: state = S.tr;
						default: unexpected();
					}
				case S.tr:
					switch (nextCode()) {
						case CC.u: state = S.tru;
						default: unexpected();
					}
				case S.tru:
					switch (nextCode()) {
						case CC.e: return Token.TRUE;
						default: unexpected();
					}
				case S.f:
					switch (nextCode()) {
						case CC.a: state = S.fa;
						default: unexpected();
					}
				case S.fa:
					switch (nextCode()) {
						case CC.l: state = S.fal;
						default: unexpected();
					}
				case S.fal:
					switch (nextCode()) {
						case CC.s: state = S.fals;
						default: unexpected();
					}
				case S.fals:
					switch (nextCode()) {
						case CC.e: return Token.FALSE;
						default: unexpected();
					}
				case S.n:
					switch (nextCode()) {
						case CC.u: state = S.nu;
						default: unexpected();
					}
				case S.nu:
					switch (nextCode()) {
						case CC.l: state = S.nul;
						default: unexpected();
					}
				case S.nul:
					switch (nextCode()) {
						case CC.l: return Token.NULL;
						default: unexpected();
					}
				case S.QUOTATION_MARK:
					var code = stream.pop();
					switch (code) {
						case CC.REVERSE_SOLIDUS: state = S.REVERSE_SOLIDUS;
						case CC.QUOTATION_MARK:	state = S.STRING;
						default: buf.addChar(code);
					}
				case S.REVERSE_SOLIDUS:
					switch (nextCode()) {
						case CC.QUOTATION_MARK:
							buf.addChar(CC.QUOTATION_MARK);
							state = S.QUOTATION_MARK;
						case CC.REVERSE_SOLIDUS:
							buf.addChar(CC.REVERSE_SOLIDUS);
							state = S.QUOTATION_MARK;
						case CC.SOLIDUS:
							buf.addChar(CC.SOLIDUS);
							state = S.QUOTATION_MARK;
						case CC.b:
							buf.addChar(CC.BACKSPACE);
							state = S.QUOTATION_MARK;
						case CC.f:
							buf.addChar(CC.FORMFEED);
							state = S.QUOTATION_MARK;
						case CC.n:
							buf.addChar(CC.NEWLINE);
							state = S.QUOTATION_MARK;
						case CC.r:
							buf.addChar(CC.CARRIAGE_RETURN);
							state = S.QUOTATION_MARK;
						case CC.t:
							buf.addChar(CC.HORIZONTAL_TAB);
							state = S.QUOTATION_MARK;
						case CC.u:
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
					switch(nextCode()) {
						case CC.ZERO:
							buf.addChar(CC.ZERO);
							state = S.LEADING_ZERO;
						case CC.ONE: buf.addChar(CC.ONE);
								state = S.INTEGRAL;
case CC.TWO: buf.addChar(CC.TWO);
								state = S.INTEGRAL;
case CC.THREE: buf.addChar(CC.THREE);
								state = S.INTEGRAL;
case CC.FOUR: buf.addChar(CC.FOUR);
								state = S.INTEGRAL;
case CC.FIVE: buf.addChar(CC.FIVE);
								state = S.INTEGRAL;
case CC.SIX: buf.addChar(CC.SIX);
								state = S.INTEGRAL;
case CC.SEVEN: buf.addChar(CC.SEVEN);
								state = S.INTEGRAL;
case CC.EIGHT: buf.addChar(CC.EIGHT);
								state = S.INTEGRAL;
case CC.NINE: buf.addChar(CC.NINE);
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
		switch (stream.peek()) {
			case CC.ZERO: stream.skip();
					buf.addChar(CC.ZERO);
case CC.ONE: stream.skip();
					buf.addChar(CC.ONE);
case CC.TWO: stream.skip();
					buf.addChar(CC.TWO);
case CC.THREE: stream.skip();
					buf.addChar(CC.THREE);
case CC.FOUR: stream.skip();
					buf.addChar(CC.FOUR);
case CC.FIVE: stream.skip();
					buf.addChar(CC.FIVE);
case CC.SIX: stream.skip();
					buf.addChar(CC.SIX);
case CC.SEVEN: stream.skip();
					buf.addChar(CC.SEVEN);
case CC.EIGHT: stream.skip();
					buf.addChar(CC.EIGHT);
case CC.NINE: stream.skip();
					buf.addChar(CC.NINE);
case CC.A: stream.skip();
					buf.addChar(CC.A);
case CC.a: stream.skip();
					buf.addChar(CC.a);
case CC.B: stream.skip();
					buf.addChar(CC.B);
case CC.b: stream.skip();
					buf.addChar(CC.b);
case CC.C: stream.skip();
					buf.addChar(CC.C);
case CC.c: stream.skip();
					buf.addChar(CC.c);
case CC.D: stream.skip();
					buf.addChar(CC.D);
case CC.d: stream.skip();
					buf.addChar(CC.d);
case CC.E: stream.skip();
					buf.addChar(CC.E);
case CC.e: stream.skip();
					buf.addChar(CC.e);
case CC.F: stream.skip();
					buf.addChar(CC.F);
case CC.f: stream.skip();
					buf.addChar(CC.f);

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
			case CC.e: stream.skip();
					buf.addChar(CC.e);
					return S.LEADING_EXPONENTIAL;
case CC.E: stream.skip();
					buf.addChar(CC.E);
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
			case CC.e: stream.skip();
					buf.addChar(CC.e);
					return S.LEADING_EXPONENTIAL;
case CC.E: stream.skip();
					buf.addChar(CC.E);
					return S.LEADING_EXPONENTIAL;

			default: return S.NUMBER;
		}
	}
	
	private function digit(buf:StringBuf):Bool {
		switch (stream.peek()) {
			case CC.ZERO: stream.skip();
					buf.addChar(CC.ZERO);
					return true;
case CC.ONE: stream.skip();
					buf.addChar(CC.ONE);
					return true;
case CC.TWO: stream.skip();
					buf.addChar(CC.TWO);
					return true;
case CC.THREE: stream.skip();
					buf.addChar(CC.THREE);
					return true;
case CC.FOUR: stream.skip();
					buf.addChar(CC.FOUR);
					return true;
case CC.FIVE: stream.skip();
					buf.addChar(CC.FIVE);
					return true;
case CC.SIX: stream.skip();
					buf.addChar(CC.SIX);
					return true;
case CC.SEVEN: stream.skip();
					buf.addChar(CC.SEVEN);
					return true;
case CC.EIGHT: stream.skip();
					buf.addChar(CC.EIGHT);
					return true;
case CC.NINE: stream.skip();
					buf.addChar(CC.NINE);
					return true;

			default: return false;
		}
	}
	
	private inline function skipWhitespace():Void {
		while (true) {
			switch (stream.peek()) {
				case 0x0009: stream.skip();
case 0x000A: stream.skip();
case 0x000B: stream.skip();
case 0x000C: stream.skip();
case 0x000D: stream.skip();
case 0x0020: stream.skip();
case 0x0085: stream.skip();
case 0x00A0: stream.skip();
case 0x1680: stream.skip();
case 0x180E: stream.skip();
case 0x2000: stream.skip();
case 0x2001: stream.skip();
case 0x2002: stream.skip();
case 0x2003: stream.skip();
case 0x2004: stream.skip();
case 0x2005: stream.skip();
case 0x2006: stream.skip();
case 0x2007: stream.skip();
case 0x2008: stream.skip();
case 0x2009: stream.skip();
case 0x200A: stream.skip();
case 0x2028: stream.skip();
case 0x2029: stream.skip();
case 0x202F: stream.skip();
case 0x205F: stream.skip();
case 0x3000: stream.skip();

				default:
					break;
			}
		}
	}
}
