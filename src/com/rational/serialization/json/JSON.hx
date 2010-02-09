package com.rational.serialization.json;

using com.rational.utils.Tools;

class JSON {	
	public static function decode(string:String, type:Class<Dynamic>):Dynamic {
		var parser:Parser = new Parser();
		return parser.parse(new Lexer(string.stream()), type);
	}
}
