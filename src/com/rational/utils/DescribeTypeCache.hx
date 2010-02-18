package com.rational.utils;

import flash.Error;
import flash.utils.TypedDictionary;
import flash.xml.XML;
import flash.xml.XMLList;

using Type;

private typedef Map = TypedDictionary<String, XML>;

class DescribeTypeCache {
		
	private var typeCache:Map;

	public function new() {
		typeCache = new Map();
	}

	public function describeType(value:Dynamic):XML {
		var className:String = DescribeTypeTools.getQualifiedClassName(value);
		var typeDescription:XML;
		if ((typeDescription = typeCache.get(className)) != null) {
			return typeDescription;
		}
		typeDescription = DescribeTypeTools.describeType(value);
		typeCache.set(className, typeDescription);
		return typeDescription;
	}		
}
