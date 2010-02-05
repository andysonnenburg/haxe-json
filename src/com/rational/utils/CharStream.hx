package com.rational.utils;

class CharStream {
	private var string:String;
	private var index:Int;

	public function new(string:String) {
		this.string = string;
		index = 0;
	}
	
	public inline function peek():Null<Int> {
		return string.charCodeAt(index);
	}
	
	public inline function pop():Null<Int> {
		return string.charCodeAt(index++);
	}
	
	public inline function skip():Void {
		index++;
	}
}
