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
	
	public function new(stream:Stream<Null<Int>>) {
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
	
	private inline function unexpected():Void {
		throw new LexerError("Unexpected \"" + String.fromCharCode(stream.peek()) + "\"");
	}
	
	private inline function internalError():Void {
		throw new LexerError("Internal error");
	}
	
	private function nextToken():Token {
		var state:Int = S.START;
		var stream:Stream<Int> = this.stream;
		var buf:StringBuf = null;
		var hexBuf:StringBuf = null;
		var token:Token;
		skipWhitespace();
		while (true) {
			switch (state) {
				case S.START:
					switch (stream.peek()) {
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
						case CC.ONE: stream.skip();
								buf = new StringBuf();
								buf.addChar(CC.ONE);
								state = S.INTEGRAL;

							case CC.TWO: stream.skip();
								buf = new StringBuf();
								buf.addChar(CC.TWO);
								state = S.INTEGRAL;

							case CC.THREE: stream.skip();
								buf = new StringBuf();
								buf.addChar(CC.THREE);
								state = S.INTEGRAL;

							case CC.FOUR: stream.skip();
								buf = new StringBuf();
								buf.addChar(CC.FOUR);
								state = S.INTEGRAL;

							case CC.FIVE: stream.skip();
								buf = new StringBuf();
								buf.addChar(CC.FIVE);
								state = S.INTEGRAL;

							case CC.SIX: stream.skip();
								buf = new StringBuf();
								buf.addChar(CC.SIX);
								state = S.INTEGRAL;

							case CC.SEVEN: stream.skip();
								buf = new StringBuf();
								buf.addChar(CC.SEVEN);
								state = S.INTEGRAL;

							case CC.EIGHT: stream.skip();
								buf = new StringBuf();
								buf.addChar(CC.EIGHT);
								state = S.INTEGRAL;

							case CC.NINE: stream.skip();
								buf = new StringBuf();
								buf.addChar(CC.NINE);
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
					var code = stream.pop();
					switch (code) {
						case CC.REVERSE_SOLIDUS: state = S.REVERSE_SOLIDUS;
						case CC.QUOTATION_MARK:	state = S.STRING;
						default: buf.addChar(code);
					}
				case S.REVERSE_SOLIDUS:
					switch (stream.peek()) {
						case CC.QUOTATION_MARK: stream.skip();
								buf.addChar(CC.QUOTATION_MARK);
								state = S.QUOTATION_MARK;

							case CC.REVERSE_SOLIDUS: stream.skip();
								buf.addChar(CC.REVERSE_SOLIDUS);
								state = S.QUOTATION_MARK;

							case CC.SOLIDUS: stream.skip();
								buf.addChar(CC.SOLIDUS);
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
					switch(stream.peek()) {
						case CC.ZERO:
							stream.skip();
							buf.addChar(CC.ZERO);
							state = S.LEADING_ZERO;
						case CC.ONE: stream.skip();
								buf.addChar(CC.ONE);
								state = S.INTEGRAL;

							case CC.TWO: stream.skip();
								buf.addChar(CC.TWO);
								state = S.INTEGRAL;

							case CC.THREE: stream.skip();
								buf.addChar(CC.THREE);
								state = S.INTEGRAL;

							case CC.FOUR: stream.skip();
								buf.addChar(CC.FOUR);
								state = S.INTEGRAL;

							case CC.FIVE: stream.skip();
								buf.addChar(CC.FIVE);
								state = S.INTEGRAL;

							case CC.SIX: stream.skip();
								buf.addChar(CC.SIX);
								state = S.INTEGRAL;

							case CC.SEVEN: stream.skip();
								buf.addChar(CC.SEVEN);
								state = S.INTEGRAL;

							case CC.EIGHT: stream.skip();
								buf.addChar(CC.EIGHT);
								state = S.INTEGRAL;

							case CC.NINE: stream.skip();
								buf.addChar(CC.NINE);
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
