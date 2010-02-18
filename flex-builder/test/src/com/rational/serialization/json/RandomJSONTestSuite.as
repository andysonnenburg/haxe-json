package com.rational.serialization.json {
	import org.flexunit.assertThat;
	import org.flexunit.asserts.assertEquals;
	
	[RunWith("org.flexunit.experimental.theories.Theories")]
	public final class RandomJSONTestSuite {
		private static const size:int = 10;

		private static function randRange(min:Number, max:Number):Number {
			var randomNum:Number = Math.random() * (max - min + 1) + min;
			return randomNum;
		}
		
		private static function get randomBoolean():Boolean {
			return Math.random() > 0.5;
		}
		
		private static function get randomInt():int {
			return Math.floor(randRange(-size, size));
		}
		
		private static function get randomNumber():Number {
			return randRange(-size, size);
		}
		
		private static function get randomString():String {
			var s:String = "", i:int;
			for (i = 0; i < 20; i += 1) {
				s += String.fromCharCode(uint(randRange(uint.MIN_VALUE, uint.MAX_VALUE)));
			}
			return s;
		}
		
		private static function get random():* {
			switch (uint(randRange(0, 4))) {
				case 0: return null;
				case 1: return randomBoolean;
				case 2: return randomInt;
				case 3: return randomNumber;
				case 4: return randomString;
				default: throw new Error("fallthrough");
			}
		}
		
		[DataPoints]
		[ArrayElementType("Boolean")]
		public static var randomBooleans:Array = (function():Array {
			const a:Array = new Array(size);
			var i:int;
			for (i = 0; i < size; i += 1) {
				a[i] = randomBoolean;
			}
			return a;
		})();
		
		[DataPoints]
		[ArrayElementType("int")]
		public static var randomInts:Array = (function():Array {
			const a:Array = new Array(size);
			var i:int;
			for (i = 0; i < size; i += 1) {
				a[i] = randomInt;
			}
			return a;
		})();
		
		[DataPoints]
		[ArrayElementType("Number")]
		public static var randomNumbers:Array = (function():Array {
			const a:Array = new Array(size);
			var i:int;
			for (i = 0; i < size; i += 1) {
				a[i] = randomNumber;
			}
			return a;
		})();
		
		[DataPoints]
		[ArrayElementType("String")]
		public static var randomStrings:Array = (function():Array {
			const a:Array = new Array(size);
			var i:int;
			for (i = 0; i < size; i += 1) {
				a[i] = randomString;
			}
			return a;
		})();
		
		[DataPoints]
		[ArrayElementType("Date")]
		public static var randomDates:Array = (function():Array {
			const a:Array = new Array(size);
			var i:int;
			for (i = 0; i < size; i += 1) {
				var d:Date = new Date();
				d.time = randomInt;
				a[i] = d;
			}
			return a;
		})();
		
		[DataPoints]
		[ArrayElementType("Array")]
		public static var randomArray:Array = (function():Array {
			const a1:Array = new Array(size);
			var i:int, j:int;
			for (i = 0; i < size; i += 1) {
				var a2:Array = new Array(20);
				for (j = 0; j < size; j += 1) {
					a2[j] = random;
				}
				a1[i] = a2;
			}
			return a1;
		})();
		
		[DataPoints]
		[ArrayElementType("com.rational.serialization.json.SimpleClass")]
		public static var randomSimpleObjects:Array = (function():Array {
			const a:Array = new Array(size);
			var i:int;
			for (i = 0; i < size; i += 1) {
				var o:SimpleClass = new SimpleClass();
				o.publicVar1 = randomInt;
				o.publicVar2 = randomInt;
				a[i] = o;
			}
			return a;
		})();
		
		[Theory(description="This tests random boolean deserialization")]
		public final function testRandomBoolean(b:Boolean):void {
			assertEquals(b, JSON.decode(JSON.encode(b)));
		}	
		
		[Theory(description="This tests random number deserialization")]
		public final function testRandomNumber(n:Number):void {
			assertThat(n, JSON.decode(JSON.encode(n)));
		}
		
		[Theory(description="This tests random string deserialization")]
		public final function testRandomString(s:String):void {
			assertEquals(s, JSON.decode(JSON.encode(s)));
		}
		
		[Theory(description="This tests random Date deserialization")]
		public final function testRandomDate(d:Date):void {
			assertEquals(d.time, (JSON.decode(JSON.encode(d), Date) as Date).time);
		}
		
		[Theory(description="This tests random SimpleClass deserialization")]
		public final function testRandomSimpleClass(o1:SimpleClass):void {
			const o2:SimpleClass = JSON.decode(JSON.encode(o1), SimpleClass);
			assertEquals(o1.publicVar1, o2.publicVar1);
			assertEquals(o1.publicVar2, o2.publicVar2);
		}
		
		[Theory(description="This tests random primitive array deserialization")]
		public final function testRandomArray(b:Boolean, i:int, s:String):void {
			var a:Array = [b, i, s];
			for each (var o:* in a) {
				assertEquals(o, JSON.decode(JSON.encode(o)));
			}
		}
	}
}