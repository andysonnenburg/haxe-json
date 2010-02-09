package com.rational.serialization.json;

import com.rational.utils.CharCodes;
import com.rational.utils.Tools;
import com.rational.utils.CharStream;
import com.rational.utils.IStream;

using StringTools;

private typedef CC = CharCodes;
private typedef S = LexerStates;
private typedef T = Tools;
private typedef Stream = CharStream;

class Lexer implements IStream<Token> {
	private var stream:Stream;
	private var peeked:Bool;
	private var token:Null<Token>;
	
	public function new(stream:Stream) {
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
	
	private static inline function safePop(stream:Stream):Int {
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
		var stream:Stream = this.stream;
		var code:Null<Int>;
		var buf:StringBuf = null;
		var hexBuf:StringBuf = null;
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
						default: switch (Std.int(code - CC.ZERO)) {
							case 0:
								stream.skip();
								buf = new StringBuf();
								buf.addChar(CC.ZERO);
								state = S.LEADING_ZERO;
							case 1, 2, 3, 4, 5, 6, 7, 8, 9:
								stream.skip();
								buf = new StringBuf();
								buf.addChar(code);
								state = S.INTEGRAL;
							default: unexpected();
						}
					}
				case S.t:
					char(CC.r);
					char(CC.u);
					char(CC.e);
					return Token.TRUE;
				case S.f:
					char(CC.a);
					char(CC.l);
					char(CC.s);
					char(CC.e);
					return Token.FALSE;
				case S.n:
					char(CC.u);
					char(CC.l);
					char(CC.l);
					return Token.NULL;
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
					hexDigits(hexBuf);
					buf.addChar(T.parseHex(hexBuf.toString()));
					state = S.QUOTATION_MARK;
				case S.STRING: return Token.STRING(buf.toString());
				case S.MINUS:
					code = stream.peek();
					switch (Std.int(code - CC.ZERO)) {
						case 0:
							stream.skip();
							buf.addChar(CC.ZERO);
							state = S.LEADING_ZERO;
						case 1, 2, 3, 4, 5, 6, 7, 8, 9:
							stream.skip();
							buf.addChar(code);
							state = S.INTEGRAL;
					}
				case S.LEADING_ZERO: state = fractionalOrExponential(buf);
				case S.INTEGRAL:
					digits(buf);
					state = fractionalOrExponential(buf);
				case S.LEADING_FRACTIONAL:
					if (!digit(buf)) {
						unexpected();
					}
					state = S.FRACTIONAL;
				case S.FRACTIONAL:
					digits(buf);
					state = exponential(buf);
				case S.LEADING_EXPONENTIAL:
					if (!digit(buf)) {
						unexpected();
					}
					state = S.EXPONENTIAL;
				case S.EXPONENTIAL:
					digits(buf);
					state = S.NUMBER;
				case S.NUMBER: return Token.NUMBER(Std.parseFloat(buf.toString()));
				default: internalError();
			}
		}
		internalError();
	}
	
	private inline function char(code:Int):Void {
		if (stream.peek() != code) {
			unexpected();
		}
		stream.skip();
	}
	
	private inline function hexDigits(buf:StringBuf):Void {
		hexDigit(buf);
		hexDigit(buf);
		hexDigit(buf);
		hexDigit(buf);
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
	
	private inline function digits(buf:StringBuf):Void {
		while (digit(buf)) {}
	}
		
	private function digit(buf:StringBuf):Bool {
		var code:Null<Int> = stream.peek();
		if (code == null) {
			return false;
		}		
		switch (Std.int(code - CC.ZERO)) {
			case 0, 1, 2, 3, 4, 5, 6, 7, 8, 9:
				stream.skip();
				buf.addChar(code);
				return true;
			default: return false;
		}
	}
	
	private inline function skipWhitespace():Void {
		while (true) {
			switch (stream.peek()) {
				case CC.SPACE, CC.HORIZONTAL_TAB, CC.NEWLINE, CC.CARRIAGE_RETURN:
					stream.skip();
				default:
					break;
			}
		}
	}
}
