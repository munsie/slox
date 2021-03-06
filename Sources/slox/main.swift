import Darwin
import Foundation

private func run(source: String) {
  let scanner = Scanner(source: source)
  let tokens = scanner.scanTokens()
  let parser = Parser(tokens: tokens)
  guard let expr = parser.parse() else { return }
  
  // stop if there was a syntax error
  if hadError {
    return
  }
  
  let astPrinter = ASTPrinter.init()
  print("\(astPrinter.print(expr: expr))")
}

private func runFile(path: String) {
  do {
    let source = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
    run(source: source)

    // indicate an error in the exit code
    if hadError {
      exit(65)
    }
  } catch {
    perror(message: error.localizedDescription)
    exit(66)
  }
}

private func runPrompt() {
  while true {
    print("> ", terminator: "")
    guard let line = readLine() else {
      break
    }
    run(source: line)
    hadError = false
  }
}

private struct StderrOutputStream: TextOutputStream {
  mutating func write(_ string: String) {
    fputs(string, stderr)
  }
}

private var standardError = StderrOutputStream()

private var hadError = false

func report(line: Int = 0, whence: String = "", message: String) {
  let progname = URL(fileURLWithPath: CommandLine.arguments[0]).lastPathComponent
  print("\(progname): ", terminator: "", to: &standardError)
  if line != 0 {
    print("[line \(line)] ", terminator: "", to: &standardError)
  }
  print("Error\(whence) - \(message)", to: &standardError)
  hadError = true
}

func perror(token: Token, message: String) {
  if token.type == .eof {
    report(line: token.line, whence: " at end", message: message)
  } else {
    report(line: token.line, whence: " at '\(token.lexeme ?? "<empty>")'", message: message)
  }
}

func perror(line: Int = 0, message: String) {
  report(line: line, whence: "", message: message)
}

if CommandLine.argc > 2 {
  print("Usage: slox [script]")
  exit(64)
} else if CommandLine.argc == 2 {
  runFile(path: CommandLine.arguments[1])
} else {
  runPrompt()
}
