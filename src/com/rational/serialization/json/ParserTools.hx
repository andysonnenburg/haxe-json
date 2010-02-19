package com.rational.serialization.json;

import com.rational.utils.IProperty;
import com.rational.utils.Record;
#if flash
import com.rational.utils.DescribeTypeCache;
import com.rational.utils.DescribeTypeTools;
#end

class ParserTools {

#if flash
	private static var typeCache:DescribeTypeCache<Record<Dynamic>>;
	private static function __init__() {
		typeCache = new DescribeTypeCache<Record<Dynamic>>(Record.newInstance);
	}
#else
	private static var record:Record<Dynamic>;
	private static function __init__() {
		record = new Record<Dynamic>();
	}
#end

	public static inline function getRecord(value:Dynamic):Record<Dynamic> {
#if flash
		return typeCache.describeType(value);
#else
		return record;
#end
	}
}
