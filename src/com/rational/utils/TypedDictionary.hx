package com.rational.utils;

import flash.utils.Dictionary;

class TypedDictionary<K, T> extends Dictionary, implements Dynamic<T> {

	public inline function get(k : K):Null<T> {
		return this[cast k];
	}

	public inline function set(k:K, v:T) {
		this[cast k] = v;
	}

	public inline function exists(k:K) {
		return this[cast k] != null;
	}

	public inline function delete(k:K) {
		untyped __delete__(this,k);
	}

	public inline function keys():Array<K> {
		return untyped __keys__(this);
	}

	public function iterator() :Iterator<K> {
		return keys().iterator();
	}
}
