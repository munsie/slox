import Foundation

class Scanner {
  private let source: String
  private var tokens = [] as [Token]

  private var startIndex: String.Index
  private var currentIndex: String.Index

  private var line = 1

  init(source: String) {
    self.source = source
    startIndex = source.startIndex
    currentIndex = source.startIndex
  }

  func scanTokens() -> [Token] {
    while !isAtEnd() {
      scanToken()
    }
    addToken(.eof)
    return tokens
  }

  private func scanToken() {
    let c = advance()
    switch c {
    case "(": addToken(.leftParen)
    case ")": addToken(.rightParen)
    case "{": addToken(.leftBrace)
    case "}": addToken(.rightBrace)
    case ",": addToken(.comma)
    case ".": addToken(.dot)
    case "-": addToken(.minus)
    case "+": addToken(.plus)
    case ";": addToken(.semicolon)
    case "*": addToken(.star)
    case "!": addToken(match("=") ? .bangEqual : .bang)
    case "=": addToken(match("=") ? .equalEqual : .equal)
    case "<": addToken(match("=") ? .lessEqual : .less)
    case ">": addToken(match("=") ? .greaterEqual : .greater)
    case "/":
      if match("/") {
        comment()
      } else if match("*") {
        multilineComment()
      } else {
        addToken(.slash)
      }
    // ignore whitespace
    case "\n":
      line += 1
      fallthrough
    case " ", "\r", "\t":
      discardToken()
    case "\"":
      string()
    default:
      if isDigit(c) {
        number()
      } else if isAlpha(c) {
        identifier()
      } else {
        perror(line: line, message: "Unexpected character.")
        discardToken()
      }
    }
  }

  private func identifier() {
    while isAlphaNumeric(peek()) {
      _  = advance()
    }
    switch text() {
    case "and":    addToken(.and)
    case "class":  addToken(.class)
    case "else":   addToken(.else)
    case "false":  addToken(.false)
    case "for":    addToken(.for)
    case "fun":    addToken(.fun)
    case "if":     addToken(.if)
    case "nil":    addToken(.nil)
    case "or":     addToken(.or)
    case "print":  addToken(.print)
    case "return": addToken(.return)
    case "super":  addToken(.super)
    case "this":   addToken(.this)
    case "true":   addToken(.true)
    case "var":    addToken(.var)
    case "while":  addToken(.while)
    default:       addToken(.identifier)
    }
  }

  private func number() {
    while isDigit(peek()) {
      _ = advance()
    }

    // look for a fractional part
    if peek() == "." && isDigit(peekNext()) {
      // consume the "."
      _ = advance()

      while isDigit(peek()) {
        _ = advance()
      }
    }

    addToken(.number, literal: text())
  }

  private func string() {
    while !isAtEnd() && peek() != "\"" {
      if peek() == "\n" {
        line += 1
      }
      _ = advance()
    }

    if isAtEnd() {
      perror(line: line, message: "Unterminated string.")
      discardToken()
      return
    }

    // the closing "
    _ = advance()

    // trim the surrounding quotes
    addToken(.string, literal: String(text()!.dropFirst().dropLast()))
  }

  private func comment() {
    // a comment goes until the end of the line
    while !isAtEnd() && peek() != "\n" {
      _ = advance()
    }
    discardToken()
  }

  private func multilineComment() {
    var depth = 1
    while !isAtEnd() {
      // break out once we find the trailing */
      if peek() == "*" && peekNext() == "/" {
        // consume the */
        _ = advance()
        _ = advance()
        depth -= 1
        if depth == 0 {
          // we found the last */, break out
          break
        }
      } else if peek() == "/" && peekNext() == "*" {
        // consume the /*
        _ = advance()
        _ = advance()
        depth += 1
      } else {
        _ = advance()
      }
    }
    if depth != 0 {
      perror(line: line, message: "Unterminated multi-line comment.")
    }
    discardToken()
  }

  private func match(_ expected: Character) -> Bool {
    if peek() != expected {
      return false
    }
    _ = advance()
    return true
  }

  private func peek() -> Character? {
    return isAtEnd() ? nil : source[currentIndex]
  }

  private func peekNext() -> Character? {
    if isAtEnd() {
      return nil
    }
    let i = source.index(after: currentIndex)
    return i == source.endIndex ? nil : source[i]
  }

  private func advance() -> Character? {
    let c = peek()
    currentIndex = source.index(after: currentIndex)
    return c
  }

  private func isDigit(_ c: Character?) -> Bool {
    return c != nil && c!.isASCII && c!.isNumber
  }

  private func isAlpha(_ c: Character?) -> Bool {
    return (c != nil && c!.isASCII && c!.isLetter) || c == "_"
  }

  private func isAlphaNumeric(_ c: Character?) -> Bool {
    return isAlpha(c) || isDigit(c)
  }

  private func addToken(_ type: TokenType, literal: String? = nil) {
    tokens.append(Token(type: type, lexeme: text(), literal: literal, line: line))
    startIndex = currentIndex
  }

  private func discardToken() {
    startIndex = currentIndex
  }

  private func text() -> String? {
    return startIndex == currentIndex ? nil : String(source[startIndex..<currentIndex])
  }

  private func isAtEnd() -> Bool {
    return currentIndex >= source.endIndex
  }
}
