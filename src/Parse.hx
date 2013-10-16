package ;

import Ast;
import Parse.MyParsers.*;
import com.mindrocks.text.Parser;
import com.mindrocks.text.Parser.Parsers.*;
import com.mindrocks.functional.Functional;
import com.mindrocks.text.ParserMonad.ParserM.dO in P;

using Parse.MyParsers;
using com.mindrocks.text.Parser;
using com.mindrocks.text.ParserMonad;
using com.mindrocks.functional.Functional;
using com.mindrocks.macros.LazyMacro;

class Parse {
  static var symbol = oneOf("!#$%&|*+-/:<=>?@^_~");

  static var spaces1 = skipMany1(space);

  static var escapedChars = P({ char ('\\');
                                x <=  oneOf ("\\\"nrt");
                                ret (switch (x) {
                                  case '\\' | '"': x;
                                  case 'n'       : '\n';
                                  case 'r'       : '\r';
                                  case 't'       : '\t';
                                  case _         : throw "impossible";
                                  });
    });

  static var parseString = P({ char ('"');
                               x <= many (escapedChars.or (noneOf ('\\"\\\\')));
                               char ('"');
                               ret (String (x.join("")));
    });

  static var parseAtom = P({
      first <= letter.or(symbol);
      rest  <= many (ors ([letter, digit, symbol]));
      ret( switch (first+rest.join("")) {
        case "#t": Bool(true);
        case "#f": Bool(false);
        case n:
          Atom(n);
        });
    });

  static var parseDecimal = P({ option (string ("#d"));
                                num <= many1 (digit);
                                ret (Number (Std.parseInt (num.join(""))));
    });

  static var parseFloat = P({ x <= many1 (digit);
                              char ('.');
                              y <= many1 (digit);
                              ret (Float (Std.parseFloat (x.join("") + '.' + y.join(""))));
    });

  static var parseCharacter = P({ string ('#\\');
                                  x <= anyChar;
                                  ret (Character (x));
    });

  static var parseList = P({
      char("(").and(spaces);
      h <= parseExpr.sepEndBy(spaces1);
      spaces.and(char(")"));
      ret(List(h));
    });

  static var parseDottedList = P({
      char('(').and(spaces);
      h <= parseExpr.sepEndBy(spaces1);
      char ('.').and(spaces);
      t <= parseExpr;
      spaces.and (char (')'));
      ret (DottedList (h, t));
    });

  static var parseQuasiQuoted = P({ char ('`');
                                    x <= parseExpr;
                                    ret (List ([Atom ("quasiquote"), x]));
    });

  static var parseUnquote = P({ char(',');
                                x <= parseExpr;
                                ret (List ([Atom ("unquote"), x]));
    });

  static var parseVector = P({ string('\'#(');
                               x <= parseExpr.sepBy (spaces);
                               char (")");
                               ret (Vector (x));
    });

  static var parseQuoted = P({ char ('\'');
                               x <= parseExpr;
                               ret (List ([Atom ("quote"), x]));
    });
  
  static var parseExpr:LParser<LispVal> = ors([  parseString,
                                                 parseFloat,
                                                 parseDecimal,
                                                 parseCharacter,
                                                 parseVector,
                                                 parseQuoted,
                                                 parseQuasiQuoted,
                                                 parseUnquote,
                                                 parseCharacter,
                                                 parseAtom,
                                                 parseList,
                                                 parseDottedList
                                                 ]);

  public static function readExpr(input:String) {
    return switch(parseExpr() (input.reader())) {
    case Success(v,_): v;
    case Failure(a, b, c): throw 'Failed to parse $a $b $c';
    }
  }
}

class MyParsers {
  public static var space  = oneOf(" \t");
  public static var spaces = P({ x <= many(space); ret(x.join("")); });
  public static var letter = ~/[A-Za-z]/.regexParser();
  public static var digit  = ~/[0-9]/.regexParser();
  public static var anyChar = ~/./.regexParser();
  public static function oneOf(s:String) return s.split("").map(Parsers.identifier).ors();
  public static function noneOf(s:String) return new EReg('[^$s]', '').regexParser();
  public static function skipMany1(x) return P({space.oneMany(); ret(Unit);});
  public static function char(s:String) return Parsers.identifier(s);
  public static function sepEndBy<T,K>(v:LParser<T>, by:LParser<K>) return P({
      v <= v.repsep(by);
      option(by);
      ret(v);
    });
  public static var sepBy = repsep;
  public static var many1 = oneMany;
  public static var string = identifier;
}

typedef LParser<K> = Void->Parser<String, K>