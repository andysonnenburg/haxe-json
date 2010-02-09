package com.rational.serialization.json;

typedef LexerState = Int;
class LexerStates {
	public static inline var START:LexerState = 0;
	public static inline var t:LexerState = 1;
	public static inline var f:LexerState = 2;
	public static inline var n:LexerState = 3;
	public static inline var QUOTATION_MARK:LexerState = 4;
	public static inline var REVERSE_SOLIDUS:LexerState = 5;
	public static inline var UNICODE_ESCAPE:LexerState = 6;
	public static inline var STRING:LexerState = 7;
	public static inline var MINUS:LexerState = 8;
	public static inline var LEADING_ZERO:LexerState = 9;
	public static inline var INTEGRAL:LexerState = 10;
	public static inline var LEADING_FRACTIONAL:LexerState = 11;
	public static inline var FRACTIONAL:LexerState = 12;
	public static inline var LEADING_EXPONENTIAL:LexerState = 13;
	public static inline var EXPONENTIAL:LexerState = 14;
	public static inline var NUMBER:LexerState = 15;
}
