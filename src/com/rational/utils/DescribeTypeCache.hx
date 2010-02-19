package com.rational.utils;

import flash.Error;
import flash.utils.TypedDictionary;
import flash.xml.XML;
import flash.xml.XMLList;

using Type;

class DescribeTypeCache<T> {
	
	private var factory:Class<Dynamic> -> XML -> T;
	private var recordCache:TypedDictionary<String, T>;

	public function new(factory:Class<Dynamic> -> XML -> T) {
		this.factory = factory;
		recordCache = new TypedDictionary<String, T>();
	}

	public function describeType(type:Class<Dynamic>):T {
		var className:String = DescribeTypeTools.getQualifiedClassName(type);
		var record:T;
		if ((record = recordCache.get(className)) != null) {
			return record;
		}
		var typeDescription:XML = DescribeTypeTools.describeType(type);
		record = factory(type, typeDescription);
		recordCache.set(className, record);
		return record;
	}		
}
