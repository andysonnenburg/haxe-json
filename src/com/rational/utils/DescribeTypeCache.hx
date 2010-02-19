package com.rational.utils;

import flash.Error;
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
