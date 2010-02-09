package com.rational.serialization.json;

typedef ParserState = Int;
class ParserStates {
	public static inline var START:ParserState = 0;
	public static inline var NAME:ParserState = 1;
	public static inline var COLON:ParserState = 2;
	public static inline var VALUE:ParserState = 3;
	public static inline var COMMA:ParserState = 4;
}
