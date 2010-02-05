package com.rational.serialization.json;

class LexerError
#if flash
	extends flash.Error
#end
{
#if !flash
	private var message:String;
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
