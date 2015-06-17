//
//  An example calculator for LISP expressions.
//
//      >>> (- (^ 2 16) 1)
//      65535.0
//
//  Created by Evgeny Khomyakov on 2015-06-15.
//  Copyright © 2015 Evgeny Khomyakov. All rights reserved.
//

import Foundation

let scanner = Scanner()

enum Error : ErrorType {
    case Error(String)
}

func readList() throws -> Double {
    scanner.skipWhitespace()
    guard "(" == scanner.readCharacter() else { throw Error.Error("expected '('") }
    guard let op = scanner.readCharacter() else { throw Error.Error("unexpected eof after '('") }
    guard var rv = try readEval() else { throw Error.Error("a list need arguments") }
    while let arg = try readEval() {
        switch op {
        case "+": rv += arg
        case "-": rv -= arg
        case "*": rv *= arg
        case "^": rv = pow(rv, arg)
        case "/":
            guard arg != 0 else { throw Error.Error("division by zero") }
            rv /= arg
        default: throw Error.Error("unknown operator '\(op)'")
        }
    }
    guard ")" == scanner.readCharacter() else { throw Error.Error("expected ')'") }
    return rv
}

func readEval() throws -> Double? {
    scanner.skipWhitespace()
    if "(" == scanner.peek() {
        return try readList()
    }
    return scanner.readDouble()
}

while !scanner.eof {
    do {
        print(">>> ", appendNewline: false)
        if let v = try readEval() {
            print(v)
        } else {
            if !scanner.eof { throw Error.Error("unexpected token: \(scanner.readWord()!)") }
            print("quit")
            break
        }
    } catch Error.Error(let msg) {
        print("error: \(msg)")
        scanner.nextLine()
    }
}
