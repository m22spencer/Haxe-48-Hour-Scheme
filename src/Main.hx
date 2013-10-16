package ;

class Main {
  static function main() {
    var args = Sys.args();
    switch (args) {
    case [lisp]:
      var ast = haxe.Timer.measure(Parse.readExpr.bind(lisp));

      Sys.println('$ast\n');
      Sys.println(Ast.showVal(ast));
    case _:
      Sys.println("Only accepts a single argument");
    }


  }
}