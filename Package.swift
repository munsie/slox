// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "slox",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "slox",
            dependencies: [],
            exclude: [ "main.swift~", "Scanner.swift~", "Token.swift~", "Expr.swift~", "ASTPrinter.swift~", "Parser.swift~" ]),
        .target(
            name: "generateAST",
            dependencies: [],
            exclude: [ "main.swift~" ]),
        .testTarget(
            name: "sloxTests",
            dependencies: ["slox"])
    ]
)
