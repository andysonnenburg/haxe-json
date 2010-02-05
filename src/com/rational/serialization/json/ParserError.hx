package com.rational.serialization.json;

import flash.Error;

class ParserError extends Error {
	public function new(unexpected:Token, expected:Array<Token>) {
		super("Unexpected " + unexpected + ", expecting " + expected.join(", "));
	}
}
