package com.rational.serialization.json;

class ParserError
#if flash
	extends flash.Error
#end
{
#if !flash
	public var message(default, null):String;
#end
	public function new(message) {
#if flash
		super(message);
#else
		this.message = message;
#end
	}
	
#if !flash
	public function toString():String {
		return message;
	}
#end
}
