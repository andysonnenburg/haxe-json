package com.rational.utils;

class PropertyTools {
	public static inline function isWritable(property:IProperty):Bool {
		var writable = false;
		switch (property.getAccess()) {
			case "writeonly", "readwrite": writable = true;
			default: writable = false;
		}
		return writable;
	}
}
