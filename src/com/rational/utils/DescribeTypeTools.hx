package com.rational.utils;

import flash.Error;
import flash.xml.XML;
import flash.xml.XMLList;

using Type;

class DescribeTypeTools {	
	private static inline function describeType(value:Dynamic):XML {
		return (untyped __global__["flash.utils.describeType"])(value);
	}
	
	public static function fieldType(object:Dynamic, name:String):Class<Dynamic> {
		var type:XML = describeType(object);
		var variables:XMLList = type.elements("variable");
		for (i in 0...variables.length()) {
			var variable:XML;
			if ((variable = variables[i]).attribute("name").toString() == name) {
				return variable.attribute("type").toString().resolveClass();
			}
		}
		if (type.attribute("isDynamic").toString() == "true") {
			return Dynamic;
		}
		throw new Error("No such field");
	}
	
	public static function fieldElementType(object:Dynamic, name:String):Class<Dynamic> {
		var variables:XMLList = describeType(object).elements("variable");
		for (i in 0...variables.length()) {
			var variable:XML;
			if ((variable = variables[i]).attribute("name").toString() == name) {
				var metadatas:XMLList = variable.elements("metadata");
				for (j in 0...metadatas.length()) {
					var metadata:XML;
					if ((metadata = metadatas[j]).attribute("name").toString() == "ArrayElementType") {
						var args:XMLList = metadata.elements("arg");
						for (k in 0...args.length()) {
							var arg:XML;
							if ((arg = args[k]).attribute("key").toString() == "") {
								return arg.attribute("value").toString().resolveClass();
							}
						}
						throw new Error("ArrayElementType metadata missing single unnamed argument");
					}
				}
				return Dynamic;
			}
		}
		throw new Error("No such field");
	}
}
