package com.rational.utils;

import flash.Error;
import flash.utils.Dictionary;
import flash.xml.XML;
import flash.xml.XMLList;

using Type;

class DescribeTypeCache<T> {
	
	private var factory:Class<Dynamic> -> XML -> T;
	private var recordCache:TypedDictionary<Class<Dynamic>, T>;

	public function new(factory:Class<Dynamic> -> XML -> T) {
		this.factory = factory;
		recordCache = new TypedDictionary<Class<Dynamic>, T>();
	}

	public function describeType(type:Class<Dynamic>):T {
		var record:T;
		if ((record = recordCache.get(type)) != null) {
			return record;
		}
		var typeDescription:XML = DescribeTypeTools.describeType(type);
		record = factory(type, typeDescription);
		recordCache.set(type, record);
		return record;
	}		
}

class TypedDictionary<K,T> extends Dictionary, implements Dynamic<T> {

	public inline function get( k : K ) : Null<T> {
		return this[cast k];
	}

	public inline function set( k : K, v : T ) {
		this[cast k] = v;
	}

	public inline function exists( k : K ) {
		return this[cast k] != null;
	}

	public inline function delete( k : K ) {
		untyped __delete__(this,k);
	}

	public inline function keys() : Array<K> {
		return untyped __keys__(this);
	}

	public function iterator() : Iterator<K> {
		return keys().iterator();
	}

}
