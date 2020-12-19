import Foundation

enum ParseError: Error {
  case error(Token, String)
}

class Parser {
  private let tokens: [Token]
  private var current = 0
  
  init(tokens: [Token]) {
    self.tokens = tokens
  }
  
  func parse() -> Expr? {
    do {
      return try expression()
    } catch {
      return nil
    }
  }
  
  private func expression() throws -> Expr {
    return try equality()
  }
  
  private func equality() throws -> Expr {
    var expr = try comparison()
    while match(.bangEqual, .equalEqual) {
      let oper = previous()
      let right = try comparison()
      expr = BinaryExpr(left: expr, oper: oper, right: right)
    }
    return expr
  }
  
  private func comparison() throws -> Expr {
    var expr = try term()
    while match(.greater, .greaterEqual, .less, .lessEqual) {
      let oper = previous()
      let right = try term()
      expr = BinaryExpr(left: expr, oper: oper, right: right)
    }
    return expr
  }
  
  private func term() throws -> Expr {
    var expr = try factor()
    while match(.minus, .plus) {
      let oper = previous()
      let right = try factor()
      expr = BinaryExpr(left: expr, oper: oper, right: right)
    }
    return expr
  }
  
  private func factor() throws -> Expr {
    var expr = try unary()
    while match(.slash, .star) {
      let oper = previous()
      let right = try unary()
      expr = BinaryExpr(left: expr, oper: oper, right: right)
    }
    return expr
  }
  
  private func unary() throws -> Expr {
    if match(.bang, .minus) {
      let oper = previous()
      let right = try unary()
      return UnaryExpr(oper: oper, right: right)
    }
    return try primary()
  }
  
  private func primary() throws -> Expr {
    if match(.false) {
      return LiteralExpr(value: "false")
    }
    if match(.true) {
      return LiteralExpr(value: "true")
    }
    if match(.nil) {
      return LiteralExpr(value: "nil")
    }
    if match(.number, .string) {
      return LiteralExpr(value: previous().literal)
    }
    if match(.leftParen) {
      let expr = try expression()
      _ = try consume(.rightParen, message: "Expect ')' after expression.")
      return GroupingExpr(expression: expr)
    }
    throw error(token: peek(), message: "Expect expression.")
  }
  
  private func match(_ types: TokenType...) -> Bool {
    for type in types {
      if check(type) {
        _ = advance()
        return true
      }
    }
    return false
  }
  
  private func consume(_ type: TokenType, message: String) throws -> Token {
    if check(type) {
      return advance()
    }
    throw error(token: peek(), message: message)
  }
  
  private func check(_ type: TokenType) -> Bool {
    return isAtEnd() ? false : peek().type == type
  }
  
  private func advance() -> Token {
    if !isAtEnd() {
      current += 1
    }
    return previous()
  }
  
  private func isAtEnd() -> Bool {
    return peek().type == .eof
  }
  
  private func peek() -> Token {
    return tokens[current]
  }
  
  private func previous() -> Token {
    return tokens[current - 1]
  }
  
  private func error(token: Token, message: String) -> ParseError {
    perror(token: token, message: message)
    return ParseError.error(token, message)
  }
  
  private func synchronize() {
    _ = advance()
    while !isAtEnd() {
      if previous().type == .semicolon {
        return
      }
      switch peek().type {
      case .class, .fun, .var, .for, .if, .while, .print, .return:
        return
      default:
        break
      }
      _ = advance()
    }
  }
}