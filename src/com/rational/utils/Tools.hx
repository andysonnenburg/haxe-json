package com.rational.utils;

import haxe.Template;
import haxe.io.Output;

#if neko
using neko.FileSystem;
using neko.io.File;
using neko.io.Path;
#end

using Reflect;

private typedef L = Lambda;

class Tools {

	public static function array<T>(i:Iterator<T>):Array<T> {
		var a:Array<T> = [];
		for (e in i) {
			a.push(e);
		}
		return a;
	}
	
	public static function with<T>(o:Output, f:Output -> T):T {
		try {
			return f(o);
		} catch(unknown:Dynamic) {
			o.close();
			throw unknown;
		}
	}
	
	public static function concat<T>(it:Iterable<T>):String {
		return L.fold(it, function(a, b) {
			return Std.string(b) + Std.string(a);
		}, "");
	}
	
	public static inline function parseHex(x:String):Null<Int> {
#if flash
		return (untyped __global__["parseInt"])(x, 16);
#else
		return Std.parseInt("0x" + x);
#end
	}
	
	public static inline function parseFloat(x:String):Float {
#if flash
		return (untyped __global__["parseFloat"])(x);
#else
		return Std.parseFloat(x);
#end
	}

#if neko
	public static function walk<T>(path:String, f:String -> T):Void {
		var paths = path.readDirectory();
		for (p in paths) {
			var fullPath = path + "/" + p;
			if (fullPath.isDirectory()) {
				walk(fullPath, f);
			} else {
				f(fullPath);
			}
		}
	}
#end
}
