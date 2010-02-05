package com.rational.serialization.json;

import com.rational.utils.CharSequence;

class JSON {	
	public function decodeObject(s, type) {
		new Lexer(new CharSequence(s));
	}
	
	public function decodeArray(s, elementType) {
	}
}
