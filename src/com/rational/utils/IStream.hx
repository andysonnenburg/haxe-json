package com.rational.utils;

interface IStream<T> {
	function peek():Null<T>;
	function pop():Null<T>;
	function skip():Void;
}

