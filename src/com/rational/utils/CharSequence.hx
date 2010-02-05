package com.rational.utils;

class CharSequence {
	private var length:Int;
	private var string:String;
	private var index:Int;

	public function new(string:String) {
		length = string.length;
		this.string = string;
		index = 0;
	}
	
	public inline function hasNext():Bool {
		return index < length;
	}
	
	public inline function next():Int {
		return string.charCodeAt(index++);
	}
}
