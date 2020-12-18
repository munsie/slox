import Foundation

enum TokenType {
  // single-character tokens
  case leftParen, rightParen, leftBrace, rightBrace
  case comma, dot, minus, plus, semicolon, slash, star

  // one or two character tokens
  case bang, bangEqual
  case equal, equalEqual
  case greater, greaterEqual
  case less, lessEqual

  // literals
  case identifier, string, number

  // keywords
  case and, `class`, `else`, `false`, fun, `for`, `if`, `nil`, or
  case print, `return`, `super`, this, `true`, `var`, `while`

  case eof
}

struct Token: CustomStringConvertible {
  let type: TokenType
  let lexeme: String?
  let literal: String?
  let line: Int

  var description: String {
    return "\(type) \(lexeme ?? "nil") \(literal ?? "nil")"
  }
}
