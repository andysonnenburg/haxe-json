package com.rational.serialization.json {
	import com.adobe.serialization.json.JSONEncoder;
	
	import flash.Boot;
	import flash.display.MovieClip;
	
	public final class JSON {
		private static const BOOT:Boot = new Boot(new MovieClip());
		private static const DECODER:Decoder = new Decoder();	
		/**
		 * @private
		 */
		public function JSON() {
			throw new Error("private");
		}
		
		/**
		 * Encodes a object into a JSON string.
		 *
		 * @param o The object to create a JSON string for
		 * @return the JSON string representing o
		 * @langversion ActionScript 3.0
		 * @tiptext
		 */
		public static function encode(o:Object):String {
			return new JSONEncoder(o).getString();
		}
		
		/**
		 * Decodes a JSON string into a native object.
		 *
		 * @param s The JSON string representing the object
		 * @param type The type to use as either the object type or array element type
		 * @return A native object as specified by s
		 * @throw ParseError
		 * @langversion ActionScript 3.0
		 * @tiptext
		 */
		public static function decode(s:String, type:Class=null):* {
			if (!type) {
				type = Object;
			}
			return DECODER.decode(s, type);
		}
	}
}
