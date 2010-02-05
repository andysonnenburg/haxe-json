package com.rational.utils;

typedef Stream<T> = {
	function peek():Null<T>;
	function pop():Null<T>;
	function skip():Void;
}
