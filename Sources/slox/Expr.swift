import Foundation

protocol Expr {
}

struct Binary: Expr {
  init(left: Expr, oper: Token, right: Expr) {
    self.left = left
    self.oper = oper
    self.right = right
  }

  let left: Expr
  let oper: Token
  let right: Expr
}
