import Darwin
import Foundation

private func defineVisitor(output: inout String, baseName: String, types: [String]) {
  output += """
  
  protocol \(baseName)Visitor {
    associatedtype ReturnType

  """
      
  types.forEach {
    let type = $0.components(separatedBy: ":")
    let structName = type[0].trimmingCharacters(in: .whitespacesAndNewlines)
    output += "  func visit(_ target: \(structName)\(baseName)) -> ReturnType\n"
  }
  
  output += "}\n"
}

private func defineType(output: inout String, baseName: String, structName: String, fieldList: String) {
  output += "\nstruct \(structName)\(baseName): \(baseName) {\n"
    
  // fields
  let fields = fieldList.components(separatedBy: ", ")
  fields.forEach {
    let decls = $0.components(separatedBy: .whitespacesAndNewlines)
    output += "  let \(decls[1]): \(decls[0])\n"
  }
  
  // visitor pattern
  output += """
  
    func accept<V: \(baseName)Visitor>(_ visitor: V) -> V.ReturnType {
      visitor.visit(self)
    }\n
  """
  
  output += "}\n"
}

private func defineAST(outputDir: String, baseName: String, types: [String]) {
  var output: String = """
  import Foundation
  
  protocol \(baseName) {
    func accept<V: \(baseName)Visitor>(_ visitor: V) -> V.ReturnType
  }
  
  """
  
  defineVisitor(output: &output, baseName: baseName, types: types)
  
  // the AST structs
  types.forEach {
    let type = $0.components(separatedBy: ":")
    let structName = type[0].trimmingCharacters(in: .whitespacesAndNewlines)
    let fields = type[1].trimmingCharacters(in: .whitespacesAndNewlines)
    defineType(output: &output, baseName: baseName, structName: structName, fieldList: fields)
  }
  let outputFilename = outputDir + "/" + baseName + ".swift"
  do {
    try output.write(toFile: outputFilename, atomically: true, encoding: String.Encoding.utf8)
  } catch {
    print("Error writing output file: \(error.localizedDescription)")
    exit(66)
  }
}

if CommandLine.argc != 2 {
  print("Usage: generateAST <output directory>")
  exit(64)
}
let outputDir = CommandLine.arguments[1]

defineAST(outputDir: outputDir, baseName: "Expr", types: [
  "Binary     : Expr left, Token oper, Expr right",
  "Grouping   : Expr expression",
  "Literal    : String value",
  "Unary      : Token oper, Expr right"
])
