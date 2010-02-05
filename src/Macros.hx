import haxe.Resource;
import haxe.Template;
import haxe.io.Output;
import neko.io.File;
import neko.io.Path;

private typedef L = Lambda;
private typedef FS = neko.FileSystem;
typedef R = Reflect;
typedef S = StringTools;
typedef T = com.rational.utils.Tools;

private class Var {
	private var name(default, null):String;
	private var value(default, null):Dynamic;
	public function new(name, value) {
		this.name = name;
		this.value = value;
	}
}

class Macros {
	private static var macros:Dynamic;
	private static function __init__():Void {
		macros = {
			const: R.makeVarArgs(function(args) {
				var resolve:String -> Dynamic = args.shift();
				var name:String = S.trim(args.shift());
				var i = new IntIter(0, -1);
				return "class " + name + " {\n" + T.concat(L.map(args, function(arg:String):String {
					return "\tpublic static inline var " + S.trim(arg) + ":Int = " + i.next() + ";\n";
				})) + "}";
			}),
			
			cases: R.makeVarArgs(function(args) {
				var resolve:String -> Dynamic = args.shift();
				var f:String = S.trim(args.shift());
				return T.concat(L.map(args, function(arg:String):String {
					var value = S.trim(arg);
					return "case " + value + ": " + f + "(" + value + ");\n";
				}));
			})
		};
	}
	
	private static function executeTemplate(path:String, ?context:Dynamic):Void {
		var template = new Template(File.getContent(path));
		T.with(File.write(Path.withExtension(path, "hx"), false), function(file) {
			file.writeString(template.execute(context, macros));
		});
	}

	public static function main():Void {
		charCodes();
		executeTemplates();
	}

	private static function namedCode(name, char) {
		return new Var(name, char.charCodeAt(0));
	}
	
	private static function executeTemplates():Void {
		walk(".", function(path) {
			if (Path.extension(path) == "thx") {
				executeTemplate(path);
			}
		});
	}
	
	private static function charCodes():Void {
		var chars = L.array(L.map(T.array(65...91).concat(T.array(97...123)),
			function(i) {
				return new Var(String.fromCharCode(i), i);
			})).concat([
			namedCode("LEFT_BRACE", "{"),
			namedCode("RIGHT_BRACE", "}"),
			namedCode("LEFT_BRACKET", "["),
			namedCode("RIGHT_BRACKET", "]"),
			namedCode("COMMA", ","),
			namedCode("COLON", ":"),
			namedCode("PERIOD", "."),
			namedCode("QUOTATION_MARK", "\""),
			namedCode("REVERSE_SOLIDUS", "\\"),
			namedCode("SOLIDUS", "/"),
			namedCode("BACKSPACE", "\x08"),
			namedCode("FORMFEED", "\x0C"),
			namedCode("NEWLINE", "\n"),
			namedCode("CARRIAGE_RETURN", "\r"),
			namedCode("HORIZONTAL_TAB", "\t"),
			namedCode("ZERO", "0"),
			namedCode("ONE", "1"),
			namedCode("TWO", "2"),
			namedCode("THREE", "3"),
			namedCode("FOUR", "4"),
			namedCode("FIVE", "5"),
			namedCode("SIX", "6"),
			namedCode("SEVEN", "7"),
			namedCode("EIGHT", "8"),
			namedCode("NINE", "9")
		]);
		var context = { chars: chars };
		executeTemplate("com/rational/utils/CharCodes.chx", context);
	}
	
	private static function walk<T>(path:String, f:String -> T):Void {
		var paths = FS.readDirectory(path);
		for (p in paths) {
			var fullPath = path + "/" + p;
			if (FS.isDirectory(fullPath)) {
				walk(fullPath, f);
			} else {
				f(fullPath);
			}
		}
	}
}
