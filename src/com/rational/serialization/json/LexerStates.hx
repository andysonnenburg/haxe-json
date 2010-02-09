package com.rational.serialization.json;

typedef LexerState = Int;
class LexerStates {
	public static inline var START:LexerState = 5;
	public static inline var t:LexerState = 6;
	public static inline var tr:LexerState = 7;
	public static inline var tru:LexerState = 8;
	public static inline var f:LexerState = 9;
	public static inline var fa:LexerState = 10;
	public static inline var fal:LexerState = 11;
	public static inline var fals:LexerState = 12;
	public static inline var n:LexerState = 13;
	public static inline var nu:LexerState = 14;
	public static inline var nul:LexerState = 15;
	public static inline var QUOTATION_MARK:LexerState = 16;
	public static inline var REVERSE_SOLIDUS:LexerState = 17;
	public static inline var UNICODE_ESCAPE:LexerState = 18;
	public static inline var HEX_DIGIT1:LexerState = 19;
	public static inline var HEX_DIGIT2:LexerState = 20;
	public static inline var HEX_DIGIT3:LexerState = 21;
	public static inline var STRING:LexerState = 22;
	public static inline var MINUS:LexerState = 23;
	public static inline var LEADING_ZERO:LexerState = 24;
	public static inline var INTEGRAL:LexerState = 25;
	public static inline var LEADING_FRACTIONAL:LexerState = 26;
	public static inline var FRACTIONAL:LexerState = 27;
	public static inline var LEADING_EXPONENTIAL:LexerState = 28;
	public static inline var EXPONENTIAL:LexerState = 29;
	public static inline var NUMBER:LexerState = 30;
}
