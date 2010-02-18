package com.rational.serialization.json {
	import flash.errors.IllegalOperationError;
	
	import mx.rpc.http.AbstractOperation;
	import mx.rpc.http.SerializationFilter;

	use namespace json_internal;

	public final class JSONSerializationFilter extends SerializationFilter {		
		public function JSONSerializationFilter() {
			super();
		}
		
		override public final function deserializeResult(operation:AbstractOperation, result:Object):Object {
			checkContentType(operation);
			const string:String = result as String;
			if (!string) {
				throw new IllegalOperationError("result must be a String");
			}
			const type:Class = operation.resultType || operation.resultElementType;
			return JSON.decoder.decode(string, type);
		}
		
		override public final function getRequestContentType(operation:AbstractOperation, obj:Object, contentType:String):String {
			return "application/json";
		}
		
		override public final function serializeBody(operation:AbstractOperation, obj:Object):Object {
			checkContentType(operation);
			return JSON.encode(obj);
		}
		
		private static function checkContentType(operation:AbstractOperation):void {
			if (operation.contentType !== "application/json") {
				throw new IllegalOperationError("unsupported content type");
			}
		}
	}
}