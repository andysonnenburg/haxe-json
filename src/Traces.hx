using StringTools;

class Test implements Dynamic<String> {
	public function new() {}
	private function resolve(name:String):Dynamic {
		trace("__resolve called for field " + name);
	}
}

class Traces {
	public static function main():Void {
		trace(new Test().testFieldAccess);
	}
}
