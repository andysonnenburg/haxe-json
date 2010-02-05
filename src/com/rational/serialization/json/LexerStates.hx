package com.rational.serialization.json;

typedef LexerState = Int;
class LexerStates {
	public static inline var START:LexerState = 0;
	public static inline var t:LexerState = 1;
	public static inline var tr:LexerState = 2;
	public static inline var tru:LexerState = 3;
	public static inline var f:LexerState = 4;
	public static inline var fa:LexerState = 5;
	public static inline var fal:LexerState = 6;
	public static inline var fals:LexerState = 7;
	public static inline var n:LexerState = 8;
	public static inline var nu:LexerState = 9;
	public static inline var nul:LexerState = 10;
	public static inline var QUOTATION_MARK:LexerState = 11;
	public static inline var REVERSE_SOLIDUS:LexerState = 12;
	public static inline var UNICODE_ESCAPE:LexerState = 13;
	public static inline var HEX_DIGIT1:LexerState = 14;
	public static inline var HEX_DIGIT2:LexerState = 15;
	public static inline var HEX_DIGIT3:LexerState = 16;
	public static inline var STRING:LexerState = 17;
	public static inline var MINUS:LexerState = 18;
	public static inline var LEADING_ZERO:LexerState = 19;
	public static inline var INTEGRAL:LexerState = 20;
	public static inline var LEADING_FRACTIONAL:LexerState = 21;
	public static inline var FRACTIONAL:LexerState = 22;
	public static inline var LEADING_EXPONENTIAL:LexerState = 23;
	public static inline var EXPONENTIAL:LexerState = 24;
	public static inline var NUMBER:LexerState = 25;
}
