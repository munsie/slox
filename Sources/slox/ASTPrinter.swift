import Foundation

class ASTPrinter: ExprVisitor {
  func print(expr: Expr) -> String {
    return expr.accept(self)
  }
  
  internal func visit(_ target: BinaryExpr) -> String {
    return parenthesize(name: target.oper.lexeme ?? "nil", exprs: target.left, target.right)
  }
  
  internal func visit(_ target: GroupingExpr) -> String {
    return parenthesize(name: "group", exprs: target.expression)
  }
  
  internal func visit(_ target: LiteralExpr) -> String {
    return target.value
  }
  
  internal func visit(_ target: UnaryExpr) -> String {
    return parenthesize(name: target.oper.lexeme ?? "nil", exprs: target.right)
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