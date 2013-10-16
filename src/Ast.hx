package ;

class Ast {
  public static function unwordsList(a:Array<LispVal>) return a.map(showVal).join(" ");

  public static function showVal(l:LispVal) return
    switch (l) {
    case String (contents) : '"$contents"';
    case Character (c)     : '\'$c\'';
    case Number (contents) : '$contents';
    case Float (contents)  : '$contents';
    case Bool (contents)   : '$contents';
    case Atom (name)       : name;
    case List (rest)       : "(" + unwordsList (rest) + ")";
    case DottedList (h, t) :  "(" + unwordsList (h) + " . " + showVal (t) + ")";
    case Vector (rest)     : "#(" + unwordsList (rest) + ")";
    }
}

enum LispVal {
  Character(x:String);
  Number(d:Int);
  Float(d:Float);
  Bool(f:Bool);
  String(x:String);
  Atom(id:String);
  List(a:Array<LispVal>);
  DottedList(a:Array<LispVal>, b:LispVal);
  Vector(a:Array<LispVal>);
}
