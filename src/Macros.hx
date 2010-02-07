import com.rational.utils.Tools;
import haxe.Resource;
import haxe.Template;
import haxe.io.Output;
import neko.io.File;
import neko.io.Path;

using Reflect;
using StringTools;
using com.rational.utils.Tools;
using neko.FileSystem;
using neko.io.File;
using neko.io.Path;

private typedef L = Lambda;
private typedef T = Tools;

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
			const: function(args) {
				var resolve:String -> Dynamic = args.shift();
				var name:String = cast(args.shift(), String).trim();
				var i = 0...-1;
				var macros = {
					next: function(resolve:String -> Dynamic):String {
						return Std.string(i.next());
					}
				};
				return 
					"typedef " + name + " = Int;\n" +
					"class " + name + "s {\n" + L.map(args, function(arg:String):String {
						return "\tpublic static inline var " + arg.trim() + ":" + name +" = " + i.next() + ";\n";
					}).concat() + "}";
			}.makeVarArgs(),
			
			cases: function(args:Array<Dynamic>) {
				var resolve:String -> Dynamic = args.shift();
				var template = new Template(cast(args.pop(), String).trim());
				var first = cast(args[0], String);
				var buf = new StringBuf();
				for (i in 0...first.length) {
					if (!first.isSpace(i)) {
						break;
					}
					buf.addChar(first.charCodeAt(i));
				}
				var indent = buf.toString();
				var cases = L.map(args, function(arg:String):String {
					var matched = arg.trim();
					var block = template.execute({ matched: matched }, macros);
					return "case " + matched + ": " + block + "\n";
				});
				var firstCase = cases.pop();
				cases = L.map(cases, function(arg:String):String {
					return indent + arg;
				});
				cases.push(firstCase);
				return cases.concat();
			}.makeVarArgs()
		};
	}
	
	private static function executeTemplate(path:String, ?context:Dynamic):Void {
		var template;
		try {
			template = new Template(File.getContent(path));
		} catch (e:Dynamic) {
			neko.Lib.println(path + " failed");
			throw e;
		}
		path.withExtension("hx").write(false).with(function(file) {
			var string;
			try {
				string = template.execute(context, macros);
			} catch (e:Dynamic) {
				neko.Lib.println(path + " failed");
				throw e;
			}
			file.writeString(string);
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
		".".walk(function(path) {
			if (path.extension() == "thx") {
				executeTemplate(path, { matched: "::matched::" });
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
			namedCode("MINUS", "-"),
			namedCode("PERIOD", "."),
			namedCode("QUOTATION_MARK", "\""),
			namedCode("REVERSE_SOLIDUS", "\\"),
			namedCode("SOLIDUS", "/"),
			namedCode("BACKSPACE", "\x08"),
			namedCode("FORMFEED", "\x0C"),
			namedCode("NEWLINE", "\n"),
			namedCode("CARRIAGE_RETURN", "\r"),
			namedCode("HORIZONTAL_TAB", "\t"),
			namedCode("SPACE", " "),
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
}
