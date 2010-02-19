package com.rational.utils;

#if flash
import com.rational.utils.DescribeTypeTools;
import flash.Error;
import flash.utils.TypedDictionary;
import flash.xml.XML;
import flash.xml.XMLList;
#end

using Type;

#if flash
private typedef Properties = TypedDictionary<String, IProperty>;
#end

class Record<T> {
	public static inline var objectType:Class<Dynamic> = 
#if flash
		DescribeTypeTools.Object;
#else
		Dynamic;
#end

#if flash
	private var type:Class<T>;
	private var typeDescription:XML;
	private var variables:XMLList;
	private var accessors:XMLList;
	public var properties(default, null):Properties;
	private function new(type:Class<T>, typeDescription:XML) {
		this.type = type;
		this.typeDescription = typeDescription;
		var factory:XML = typeDescription.elements("factory")[0];
		variables = factory.elements("variable");
		accessors = factory.elements("accessor");
		properties = new Properties();
	}
	
	public static inline function newInstance<T>(type:Class<T>, typeDescription:XML) {
		return new Record<T>(type, typeDescription);
	}
#else
	public function new() {}
#end

	public inline function createInstance():T {
#if flash
		return type.createInstance([]);
#else
		return untyped {};
#end
	}

	public function getProperty(name:String):IProperty {
#if flash
		var property:IProperty;
		if ((property = properties.get(name)) != null) {
			return property;
		}
		var variables:XMLList = this.variables;
		for (i in 0...variables.length()) {
			var variable = variables[i];
			if ((variable = variables[i]).attribute("name").toString() == name) {
				property = new VariableProperty(variable);
				properties.set(name, property);
				return property;
			}
		}
		var accessors:XMLList = this.accessors;
		for (i in 0...accessors.length()) {
			var accessor:XML;
			if ((accessor = accessors[i]).attribute("name").toString() == name) {
				property = new AccessorProperty(accessor);
				properties.set(name, property);
				return property;
			}
		}
		if (typeDescription.attribute("type").toString() == "Object" ||
		    typeDescription.attribute("isDynamic").toString() == "true") {
			property = DynamicProperty.INSTANCE;
			properties.set(name, property);
			return property;
		}
		throw new Error("No such field");
#else
		return DynamicProperty.INSTANCE;
#end
	}
}

#if flash
class VariableProperty implements IProperty {
	private var variable:XML;
	private var type:Class<Dynamic>;
	private var elementType:Class<Dynamic>;
	
	public function new(variable:XML) {
		this.variable = variable;
		type = null;
		elementType = null;
	}
	
	public function getAccess():String {
		return "readwrite";
	}
	
	public function getType():Class<Dynamic> {
		if (type != null) {
			return type;
		}
		type = variable.attribute("type").toString().resolveClass();
		return type;
	}
	
	public function getElementType():Class<Dynamic> {
		if (elementType != null) {
			return elementType;
		}
		var metadatas:XMLList = variable.elements("metadata");
		for (j in 0...metadatas.length()) {
			var metadata:XML;
			if ((metadata = metadatas[j]).attribute("name").toString() == "ArrayElementType") {
				var args:XMLList = metadata.elements("arg");
				for (k in 0...args.length()) {
					var arg:XML;
					if ((arg = args[k]).attribute("key").toString() == "") {
						elementType = arg.attribute("value").toString().resolveClass();
						return elementType;
					}
				}
				throw new Error("ArrayElementType metadata missing single unnamed argument");
			}
		}
		elementType = Record.objectType;
		return elementType;
	}
}

class AccessorProperty implements IProperty {
	private var accessor:XML;
	private var access:String;
	private var type:Class<Dynamic>;
	private var elementType:Class<Dynamic>;
	
	public function new(accessor:XML) {
		this.accessor = accessor;
		access = null;
		type = null;
		elementType = null;
	}
	
	public function getAccess():String {
		if (access != null) {
			return access;
		}
		access = accessor.attribute("access").toString();
		return access;
	}
	
	public function getType():Class<Dynamic> {
		if (type != null) {
			return type;
		}
		type = accessor.attribute("type").toString().resolveClass();
		return type;
	}
	
	public function getElementType():Class<Dynamic> {
		if (elementType != null) {
			return elementType;
		}
		var metadatas:XMLList = accessor.elements("metadata");
		for (j in 0...metadatas.length()) {
			var metadata:XML;
			if ((metadata = metadatas[j]).attribute("name").toString() == "ArrayElementType") {
				var args:XMLList = metadata.elements("arg");
				for (k in 0...args.length()) {
					var arg:XML;
					if ((arg = args[k]).attribute("key").toString() == "") {
						elementType = arg.attribute("value").toString().resolveClass();
						return elementType;
					}
				}
				throw new Error("ArrayElementType metadata missing single unnamed argument");
			}
		}
		elementType = Record.objectType;
		return elementType;
	}
}
#end

class DynamicProperty implements IProperty {
	public static var INSTANCE(default, null):DynamicProperty;
	private static function __init__() {
		INSTANCE = new DynamicProperty();
	}

	private function new() {}

	public function getAccess():String {
		return "readwrite";
	}
	
	public function getType():Class<Dynamic> {
		return Record.objectType;
	}
	
	public function getElementType():Class<Dynamic> {
		return Record.objectType;
	}
}
