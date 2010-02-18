package com.rational.serialization.json {
	import com.rational.utils.IStream;
	
	public final class ArrayStream implements IStream {
		private var array_:Array;
		private var index_:int;
		public function ArrayStream(array:Array) {
			array_ = array;
			index_ = 0;
		}
		
		public final function peek():Object {
			return array_[index_];
		}
		
		public final function pop():Object {
			return array_[index_++];
		}
		
		public final function skip():void {
			index_++;
		}
		
		public final function isEmpty():Boolean {
			return index_ >= array_.length;
		}
	}
}