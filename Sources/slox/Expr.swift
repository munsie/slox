import Foundation

protocol Expr {
  func accept(_ visitor: ExprVisitor)
}

protocol ExprVisitor {
  func visit(_ target: Binary)
  func visit(_ target: Grouping)
  func visit(_ target: Literal)
  func visit(_ target: Unary)
}

struct Binary: Expr {
  let left: Expr
  let oper: Token
  let right: Expr

  func accept(_ visitor: ExprVisitor) {
    visitor.visit(self)
  }
}

struct Grouping: Expr {
  let expression: Expr

  func accept(_ visitor: ExprVisitor) {
    visitor.visit(self)
  }
}

struct Literal: Expr {
  let value: String

  func accept(_ visitor: ExprVisitor) {
    visitor.visit(self)
  }
}

struct Unary: Expr {
  let oper: Token
  let right: Expr

  func accept(_ visitor: ExprVisitor) {
    visitor.visit(self)
  }
}
