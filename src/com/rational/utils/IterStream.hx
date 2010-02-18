package com.rational.utils;

class IterStream<T> implements IStream<T> {
	private var i:Iterator<T>;
	private var peeked:Bool;
	private var value:Null<T>;

	public function new(iter:Iterable<T>) {
		i = iter.iterator();
		peeked = false;
	}
	
	public inline function peek():Null<T> {
		if (!peeked) {
			value = i.next();
			peeked = true;
		}
		return value;
	}	
	
	public inline function pop():Null<T> {
		if (!peeked) {
			value = i.next();
		}
		peeked = false;
		return value;
	}
	
	public inline function skip():Void {
		if (!peeked) {
			i.next();
		}
		peeked = false;
	}
	
	public inline function isEmpty():Bool {
		return !i.hasNext();
	}
}
