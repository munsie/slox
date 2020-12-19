import Foundation

class ASTPrinter: ExprVisitor {
  func print(expr: Expr) -> String {
    return expr.accept(self)
  }
  
  internal func visit(_ expr: BinaryExpr) -> String {
    return parenthesize(name: expr.oper.lexeme ?? "nil", exprs: expr.left, expr.right)
  }
  
  internal func visit(_ expr: GroupingExpr) -> String {
    return parenthesize(name: "group", exprs: expr.expression)
  }
  
  internal func visit(_ expr: LiteralExpr) -> String {
    return expr.value
  }
  
  internal func visit(_ expr: UnaryExpr) -> String {
    return parenthesize(name: expr.oper.lexeme ?? "nil", exprs: expr.right)
  }
  
  private func parenthesize(name: String, exprs: Expr...) -> String {
    var out = "(\(name)"
    exprs.forEach {
      out += " \($0.accept(self))"
    }
    out += ")"
    return out
  }
}