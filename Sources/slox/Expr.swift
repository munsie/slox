import Foundation

protocol Expr {
  func accept<V: ExprVisitor>(_ visitor: V) -> V.ReturnType
}

protocol ExprVisitor {
  associatedtype ReturnType
  func visit(_ target: BinaryExpr) -> ReturnType
  func visit(_ target: GroupingExpr) -> ReturnType
  func visit(_ target: LiteralExpr) -> ReturnType
  func visit(_ target: UnaryExpr) -> ReturnType
}

struct BinaryExpr: Expr {
  let left: Expr
  let oper: Token
  let right: Expr

  func accept<V: ExprVisitor>(_ visitor: V) -> V.ReturnType {
    visitor.visit(self)
  }
}

struct GroupingExpr: Expr {
  let expression: Expr

  func accept<V: ExprVisitor>(_ visitor: V) -> V.ReturnType {
    visitor.visit(self)
  }
}

struct LiteralExpr: Expr {
  let value: String

  func accept<V: ExprVisitor>(_ visitor: V) -> V.ReturnType {
    visitor.visit(self)
  }
}

struct UnaryExpr: Expr {
  let oper: Token
  let right: Expr

  func accept<V: ExprVisitor>(_ visitor: V) -> V.ReturnType {
    visitor.visit(self)
  }
}
