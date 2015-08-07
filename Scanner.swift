//
//  Scanner.swift
//  Copyright (c) 2015 Evgeny Khomyakov
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Darwin

class Scanner {
    
    /// Reads a floating point value, for example, -1.235e-8
    func readDouble() -> Double? {
        guard let intPart = readInt() else { return nil }
        var rv = Double(intPart)
        if peek() == "." {
            poke()
            var v = 0.0, p = (rv < 0 ? -1.0 : 1.0)
            while let ch = peek() {
                guard let val = digitValues[ch] where val < 10 else { break }
                v = v*10.0 + Double(val)
                p *= 10
                poke()
            }
            rv += v/p
        }
        if peek() == "e" || peek() == "E" {
            poke()
            guard let firstCharacter = peek() else { return nil }
            if firstCharacter == "-" || firstCharacter == "+" || (digitValues[firstCharacter] != nil && digitValues[firstCharacter]! < 10) {
                guard let exponent = readInt() else { return nil }
                rv *= pow(10, Double(exponent))
            }
        }
        return rv
    }
    
    /// Reads a 64-bit integer, with optional sign ('+' or '-') in given base (2...36, default 10).
    func readInt64(base base: Int = 10) -> Int64? {
        skipWhitespace()
        guard let signCharacter = peek() else { return nil }
        if signCharacter == "-" || signCharacter == "+" { poke() }
        guard let firstCharacter = peek() else { return nil }
        guard let firstDigit = digitValues[firstCharacter] else { return nil }
        guard firstDigit < base else { return nil }
        poke()
        var rv = Int64(firstDigit)
        while let ch = peek() {
            guard let val = digitValues[ch] where val < base else { break }
            rv = rv*Int64(base) + val
            poke()
        }
        return (signCharacter == "-" ? -rv : rv)
    }
    
    /// Reads an integer, with optional sign ('+' or '-') in given base (2...36, default 10).
    func readInt(base base: Int = 10) -> Int? {
        if let rv = readInt64(base: base) {
            return Int(rv) // whatever
        } else {
            return nil
        }
    }
    
    /// Reads the next non-whitespace character.
    func readCharacter() -> Character? {
        skipWhitespace()
        return poke()
    }
    
    /// Reads everything from current position until the end of line. Whitespace at current position is not skipped. Newlines are consumed from input, but not included into the result.
    func readLine() -> String? {
        guard let _ = peek() else { return nil }
        var rv = ""
        while let ch = peek() where !newlineCharacterSet.contains(ch) {
            rv.append(poke()!)
        }
        poke()
        return rv
    }
    
    /// Skips whitespace and returns all characters before the next whitespace or EOF.
    func readWord() -> String? {
        skipWhitespace()
        guard let _ = peek() else { return nil }
        var rv = ""
        while let ch = peek() where !whitespaceCharacterSet.contains(ch) {
            rv.append(poke()!)
        }
        return rv
    }
    
    //
    //
    
    /// Consumes all whitespace characters at the current position.
    func skipWhitespace() {
        while let ch = peek() where whitespaceCharacterSet.contains(ch) {
            poke()
        }
    }
    
    /// Skips everything until the next line.
    func nextLine() {
        while let ch = peek() where !newlineCharacterSet.contains(ch) {
            poke()
        }
        poke()
    }
    
    //
    //
    
    /// Returns the next character that would be read, without consuming it.
    func peek() -> Character? {
        if lookahead.isEmpty {
            guard !eof else { return nil }
            if let ch = characterGenerator.next() {
                lookahead.append(ch)
                return ch
            } else {
                eof = true
                return nil
            }
        } else {
            return lookahead[lookahead.startIndex]
        }
    }
    
    /// Consumes the next character and returns it.
    func poke() -> Character? {
        if lookahead.isEmpty {
            guard !eof else { return nil }
            if let ch = characterGenerator.next() {
                return ch
            } else {
                eof = true
                return nil
            }
        } else {
            let rv = lookahead[lookahead.startIndex]
            lookahead.removeAtIndex(lookahead.startIndex)
            return rv
        }
    }
    
    //
    //
    
    /// Creates Scanner that reads the standard input.
    convenience init() {
        self.init(characterGenerator: StdinCharacterGenerator())
    }
    
    /// Creates Scanner that scans a string.
    convenience init(string: String) {
        self.init(characterGenerator: string.characters.generate())
    }
    
    init<G : GeneratorType where G.Element == Character>(characterGenerator: G) {
        self.characterGenerator = CharacterGenerator(generator: characterGenerator)
    }
    
    //
    //
    
    private let characterGenerator : CharacterGeneratorType
    
    /// > Note: `String` iteration in Swift considers `\r\n` to be a single `Character`. Isn't that convenient?
    var newlineCharacterSet : Set<Character> = ["\n", "\r\n"]
    var whitespaceCharacterSet : Set<Character> = [" ", "\n", "\t", "\r", "\r\n"]
    var digitValues : [Character:Int] = [
        "0":0, "1":1, "2":2, "3":3, "4":4, "5":5, "6":6, "7":7, "8":8, "9":9,
        "A":10, "B":11, "C":12, "D":13, "E":14, "F":15,
        "G":16, "H":17, "I":18, "J":19, "K":20, "L":21, "M":22, "N":23, "O":24, "P":25,
        "Q":26, "R":27,"S":28, "T":29, "U":30, "V":31, "W":32, "X":33, "Y":34, "Z":35,
        "a":10, "b":11, "c":12, "d":13, "e":14, "f":15,
        "g":16, "h":17, "i":18, "j":19, "k":20, "l":21, "m":22, "n":23, "o":24, "p":25,
        "q":26, "r":27,"s":28, "t":29, "u":30, "v":31, "w":32, "x":33, "y":34, "z":35,
    ]
    
    var lookahead : String = ""
    var eof : Bool = false
}

class CharacterGeneratorType : GeneratorType {
    typealias Element = Character
    func next() -> Character? { assertionFailure("Thou must override this method."); return nil }
}

class CharacterGenerator<G : GeneratorType where G.Element == Character> : CharacterGeneratorType {
    var generator : G
    required init(generator: G) {
        self.generator = generator
    }
    override func next() -> Character? {
        return generator.next()
    }
}

class StdinCharacterGenerator : CharacterGeneratorType {
    var currentLineGenerator : IndexingGenerator<String.CharacterView>? = nil
    override func next() -> Character? {
        if currentLineGenerator != nil {
            if let ch = currentLineGenerator!.next() {
                return ch
            }
        }
        if let nextLine = readLine(stripNewline: false) {
            currentLineGenerator = nextLine.characters.generate()
            return currentLineGenerator!.next()
        }
        return nil
    }
}
