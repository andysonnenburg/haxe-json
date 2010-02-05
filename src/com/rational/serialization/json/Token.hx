package com.rational.serialization.json;

enum Token {
	LEFT_BRACE;
	RIGHT_BRACE;
	LEFT_BRACKET;
	RIGHT_BRACKET;
	COMMA;
	COLON;
	TRUE;
	FALSE;
	NULL;
	STRING(value:String);
	NUMBER(value:Float);
}
