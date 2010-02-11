package com.rational.serialization.json;

typedef LexerState = Int;
class LexerStates {
	public static inline var START:LexerState = 0;
	public static inline var t:LexerState = 1;
	public static inline var f:LexerState = 2;
	public static inline var n:LexerState = 3;
	public static inline var MINUS:LexerState = 4;
	public static inline var LEADING_ZERO:LexerState = 5;
	public static inline var INTEGRAL:LexerState = 6;
	public static inline var FRACTIONAL:LexerState = 7;
	public static inline var EXPONENTIAL:LexerState = 8;
	public static inline var NUMBER:LexerState = 9;
}
