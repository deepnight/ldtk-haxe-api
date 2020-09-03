#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
using haxe.macro.TypeTools;
#end

class Assert {
	public static macro function check(code:Expr) {
		return macro {
			if( !${buildCheckExpr(code)} ) {
				Test.print( $v{printCode(code)}+" ... FAILED!");
				Test.die();
			}
			else
				Test.print( $v{printCode(code)}+" ... Ok");
		};
	}

	public static macro function failIf(code:Expr) {
		return macro {
			if( ${buildCheckExpr(code)} ) {
				Test.print( $v{printCode(code)}+" ... FAILED!");
				Test.die();
			}
			else
				Test.print( $v{printCode(code)}+" ... Ok");
		};
	}


	#if macro
	// Build expr of: "code==true"
	static function buildCheckExpr(code:Expr) {
		var eCheck : Expr = {
			expr: EBinop(OpEq, code, macro true),
			pos: Context.currentPos(),
		}

		// Does "code" actually returns a Bool?
		try Context.typeExpr(eCheck)
		catch(e:Dynamic) {
			Context.fatalError("Parameter should return a Bool value", code.pos);
		}

		return eCheck;
	}

	// Print code expr in human-readable fashion
	static function printCode(code:Expr) : String {
		var printer = new haxe.macro.Printer();
		var codeStr = printer.printExpr(code);
		return "[" + Context.getLocalModule() + "] \"" + codeStr + "\"";
	}
	#end
}