import Darwin
import Foundation

fileprivate func Run(source: String) {
  let scanner = Scanner(source: source)
  let tokens = scanner.scanTokens()

  // for now, just print the tokens
  tokens.forEach { print($0) }
}

fileprivate func RunFile(path: String) {
  do {
    let source = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
    Run(source: source)

    // indicate an error in the exit code
    if hadError {
      exit(65)
    }
  } catch {
    Error(message: error.localizedDescription)
    exit(66) 
  }
}

fileprivate func RunPrompt() {
  while true {
    print("> ", terminator: "") 
    guard let line = readLine() else {
      break
    }
    Run(source: line)
    hadError = false
  }
}

fileprivate struct StderrOutputStream: TextOutputStream {
  mutating func write(_ string: String) {
    fputs(string, stderr)
  }
}

fileprivate var standardError = StderrOutputStream()

fileprivate var hadError = false

func Report(line: Int = 0, whence: String = "", message: String) {
  let progname = URL(fileURLWithPath: CommandLine.arguments[0]).lastPathComponent
  print("\(progname): ", terminator: "", to: &standardError)
  if line != 0 {
    print("[line \(line)] ", terminator: "", to: &standardError)
  }
  print("Error\(whence) - \(message)", to: &standardError)
  hadError = true
}

func Error(line: Int = 0, message: String) {
  Report(line: line, whence: "", message: message)
}

if CommandLine.argc > 2 {
  print("Usage: slox [script]")
  exit(64)
} else if CommandLine.argc == 2 {
  RunFile(path: CommandLine.arguments[1])
} else {
  RunPrompt()
}
