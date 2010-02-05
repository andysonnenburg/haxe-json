package com.rational.serialization.json;

using com.rational.utils.Tools;

class JSON {	
	public function decodeObject(string, type) {
		new Lexer(string.stream());
	}
	
	public function decodeArray(s, elementType) {
	}
}
