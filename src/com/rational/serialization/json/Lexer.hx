package com.rational.serialization.json;

import com.rational.utils.CharCodes;
import com.rational.utils.Tools;

private typedef CC = CharCodes;
private typedef S = States;
private typedef State = Int;
private typedef T = Tools;

class Lexer {
	private var stream:Iterator<Int>;
	private var code:Int;
	
	public function new(stream:Iterator<Int>) {
		this.stream = stream;
	}
	
	private inline function thisCode():Int {
		return code;
	}
	
	private inline function nextCode():Int {
		return code = stream.next();
	}
	
	private inline function unexpected():Void {
		throw new LexerError("Unexpected " + String.fromCharCode(thisCode()));
	}
	
	private inline function internalError():Void {
		throw new LexerError("Internal error");
	}
	
	public function next():Token {
		var state:State = States.START;
		var buf:StringBuf = null;
		var hexBuf:StringBuf = null;
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
					switch (nextCode()) {
						case CC.REVERSE_SOLIDUS: state = S.REVERSE_SOLIDUS;
						case CC.QUOTATION_MARK: return Token.STRING(buf.toString());
						default: buf.addChar(thisCode());
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
				default: unexpected();
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
			}
		}
		internalError();
	}
	
	private inline function hexDigit(buf:StringBuf):Void {
		switch (nextCode()) {
			case CC.ZERO: buf.addChar(CC.ZERO);
case CC.ONE: buf.addChar(CC.ONE);
case CC.TWO: buf.addChar(CC.TWO);
case CC.THREE: buf.addChar(CC.THREE);
case CC.FOUR: buf.addChar(CC.FOUR);
case CC.FIVE: buf.addChar(CC.FIVE);
case CC.SIX: buf.addChar(CC.SIX);
case CC.SEVEN: buf.addChar(CC.SEVEN);
case CC.EIGHT: buf.addChar(CC.EIGHT);
case CC.NINE: buf.addChar(CC.NINE);
case CC.A: buf.addChar(CC.A);
case CC.a: buf.addChar(CC.a);
case CC.B: buf.addChar(CC.B);
case CC.b: buf.addChar(CC.b);
case CC.C: buf.addChar(CC.C);
case CC.c: buf.addChar(CC.c);
case CC.D: buf.addChar(CC.D);
case CC.d: buf.addChar(CC.d);
case CC.E: buf.addChar(CC.E);
case CC.e: buf.addChar(CC.e);
case CC.F: buf.addChar(CC.F);
case CC.f: buf.addChar(CC.f);

			default: unexpected();
		}
	}
}
