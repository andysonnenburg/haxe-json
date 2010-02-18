package com.rational.serialization.json;

import com.rational.utils.IStream;

using Reflect;
using Type;
using com.rational.serialization.json.ParserTools;

private typedef S = ParserStates;

class Parser {
	public function new() {}
	
	private static inline function unexpected(stream:IStream<Token>):Void {
		var token:Token;
		throw new ParserError(if ((token = stream.peek()) != null) {
				"Unexpected " + token;
			} else {
				"Unexpected end of input";
			}); 
	}
	
	private static inline function internalError():Void {
		throw new ParserError("Internal error");
	}
	
	public function parse(stream:IStream<Token>, ?type:Class<Dynamic> = null):Dynamic {
		if (type == null) {
			type = ParserTools.Object;
		}
		var result:Dynamic;
		switch (stream.peek()) {
			case LEFT_BRACE:
				stream.skip();
				result = parseObject(stream, type);
			case LEFT_BRACKET:
				stream.skip();
				result = parseArray(stream, type);
			case NULL: stream.skip(); result = null;
			case TRUE: stream.skip(); result = true;
			case FALSE: stream.skip(); result = false;
			case STRING(value): stream.skip(); result = value;
			case NUMBER(value): stream.skip(); result = value;
			default: unexpected(stream);
		}
		if (!stream.isEmpty()) {
			throw new ParserError("Expected end of stream");
		}
		return result;
	}
	
	private function parseObject<T>(stream:IStream<Token>, type:Class<T>):T {
		var state:Int = S.START;
		var object:T = null;
		var field:String = null;
		var value:Dynamic = null;
		while (true) {
			switch (state) {
				case S.START:
#if flash
					object = type.createInstance([]);
#else
					object = type.createEmptyInstance();
#end
					switch (stream.peek()) {
						case STRING(value): stream.skip(); field = value; state = S.NAME;
						case RIGHT_BRACE: return object;
						default: unexpected(stream);
					}
				case S.NAME:
					switch (stream.peek()) {
						case COLON: stream.skip(); state = S.COLON;
						default: unexpected(stream);		
					}
				case S.COLON:
					switch (stream.peek()) {
						case NULL:
							stream.skip();
							if (object.isWriteProperty(field)) {
								object.setField(field, null);
							}
						case TRUE:
							stream.skip();
							if (object.isWriteProperty(field)) {
								object.setField(field, true);
							}
						case FALSE:
							stream.skip();
							if (object.isWriteProperty(field)) {
								object.setField(field, false);
							}
						case STRING(value):							
							stream.skip();
							if (object.isWriteProperty(field)) {
								object.setField(field, value);
							}
						case NUMBER(value):							
							stream.skip();
							if (object.isWriteProperty(field)) {
								object.setField(field, value);
							}
						case LEFT_BRACE:
							stream.skip();
							if (object.isWriteProperty(field)) {
								object.setField(field, parseObject(stream, object.propertyType(field)));
							}
						case LEFT_BRACKET:
							stream.skip();
							if (object.isWriteProperty(field)) {
								object.setField(field, parseArray(stream, object.propertyElementType(field)));
							}
						default: unexpected(stream);
					}
					state = S.VALUE;
				case S.VALUE:
					switch (stream.peek()) {
						case COMMA: stream.skip(); state = S.COMMA;
						case RIGHT_BRACE: stream.skip(); return object;
						default: unexpected(stream);
					}
				case S.COMMA:
					switch (stream.peek()) {
						case STRING(value):
							stream.skip();
							field = value;
							state = S.NAME;
						default: unexpected(stream);
					}
				default: internalError();
			}
		}
		internalError();
	}
	
	private function parseArray(stream:IStream<Token>, elementType:Class<Dynamic>):Array<Dynamic> {
		var state:Int = S.START;
		var array:Array<Dynamic> = null;
		while (true) {
			switch (state) {
				case S.START:
					array = [];
					switch (stream.peek()) {
						case NULL:
							stream.skip();
							array.push(null);
						case TRUE:
							stream.skip();
							array.push(true);
						case FALSE:
							stream.skip();
							array.push(false);
						case STRING(value):
							stream.skip();
							array.push(value);
						case NUMBER(value):
							stream.skip();
							array.push(value);
						case LEFT_BRACE:
							stream.skip();
							array.push(parseObject(stream, elementType));
						case LEFT_BRACKET:
							stream.skip();
							array.push(parseArray(stream, ParserTools.Object));
						case RIGHT_BRACKET: return array;
						default: unexpected(stream);
					}
					state = S.VALUE;
				case S.VALUE:
					switch (stream.peek()) {
						case COMMA: stream.skip(); state = S.COMMA;
						case RIGHT_BRACKET: stream.skip(); return array;
						default: unexpected(stream);
					}
				case S.COMMA:
					switch (stream.peek()) {
						case NULL:
							stream.skip();
							array.push(null);
						case TRUE:
							stream.skip();
							array.push(true);
						case FALSE:
							stream.skip();
							array.push(false);
						case STRING(value):
							stream.skip();
							array.push(value);
						case NUMBER(value):
							stream.skip();
							array.push(value);
						case LEFT_BRACE:
							stream.skip();
							array.push(parseObject(stream, elementType));
						case LEFT_BRACKET:
							stream.skip();
							array.push(parseArray(stream, ParserTools.Object));
						default: unexpected(stream);
					}
					state = S.VALUE;
			}
		}
		internalError();
	}	
}
