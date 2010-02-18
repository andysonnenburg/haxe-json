package com.rational.serialization.json;

#if flash
import com.rational.utils.DescribeTypeCache;
import com.rational.utils.DescribeTypeTools;
import flash.Error;
import flash.utils.TypedDictionary;
import flash.xml.XML;
import flash.xml.XMLList;

using Type;
#end

class ParserTools {
	private static var initialized = false;
	public static inline var Object = 
#if flash
		DescribeTypeTools.Object;
#else
		Dynamic;
#end

#if flash
	private static var typeCache:DescribeTypeCache;
	private static function __init__() {
		typeCache = new DescribeTypeCache();
	}
	
	public static function isWriteProperty_(value:Dynamic, name:String):Bool {
		var typeDescription:XML = typeCache.describeType(value);
		var names:XMLList = typeDescription.elements("variable").attribute("name");
		for (i in 0...names.length()) {
			if (names[i].toString() == name) {
				return true;
			}
		}
		var accessors:XMLList = typeDescription.elements("accessor");
		for (i in 0...accessors.length()) {
			var accessor:XML;
			if ((accessor = accessors[i]).attribute("name").toString() == name) {
				switch (accessor.attribute("access").toString()) {
					case "writeonly", "readwrite": return true;
					default: return false;
				}
			}
		}
		if (typeDescription.attribute("isDynamic").toString() == "true") {
			return true;
		}
		throw new Error("No such field");
	}
	
	public static function propertyType_(value:Dynamic, name:String):Class<Dynamic> {
		var typeDescription:XML = typeCache.describeType(value);
		var variables:XMLList = typeDescription.elements("variable");
		for (i in 0...variables.length()) {
			var variable:XML;
			if ((variable = variables[i]).attribute("name").toString() == name) {
				return variable.attribute("type").toString().resolveClass();
			}
		}
		var accessors:XMLList = typeDescription.elements("accessor");
		for (i in 0...accessors.length()) {
			var accessor:XML;
			if ((accessor = accessors[i]).attribute("name").toString() == name) {
				return accessor.attribute("type").toString().resolveClass();
			}
		}
		if (typeDescription.attribute("isDynamic").toString() == "true") {
			return Object;
		}
		throw new Error("No such field");
	}
	
	public static function propertyElementType_(value:Dynamic, name:String):Class<Dynamic> {
		var typeDescription:XML = typeCache.describeType(value);
		var variables:XMLList = typeDescription.elements("variable");
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
				return Object;
			}
		}
		if (typeDescription.attribute("isDynamic").toString() == "true") {
			return Object;
		}
		throw new Error("No such field");
	}

#end
	public static inline function isWriteProperty(value:Dynamic, name:String):Bool {
#if flash
		return isWriteProperty_(value, name);	
#else
		return true;
#end
	}

	public static inline function propertyType(value:Dynamic, name:String):Class<Dynamic> {
#if flash
		return propertyType_(value, name);
#else
		return Object;
#end
	}

	public static inline function propertyElementType(value:Dynamic, name:String):Class<Dynamic> {
#if flash
		return propertyElementType_(value, name);
#else
		return Object;
#end
	}
}
