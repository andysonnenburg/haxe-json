package com.rational.serialization.json;

class Decoder {
	private var parser:Parser;
	public function new() {
		parser = new Parser();
	}
	
	public function decode(string:String, ?type:Class<Dynamic> = null):Dynamic {
		return parser.parse(new Lexer(string), type);
	}
}
