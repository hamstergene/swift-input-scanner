# Easy Input Scanner for Swift

A simple, easy to use input scanner for Swift 2.

    // Example input:
    //
    //      4
    //      apple blueberry orange watermelon
    //      0.4 0.35 0.15 0.1

    let scanner = Scanner()
    var words : [String] = []
    var probs : [Double] = []
    let N = scanner.readInt()!
    for _ in 1...N {
        words.append(scanner.readWord()!)
    }
    for _ in 1...N {
        probs.append(scanner.readDouble()!)
    }

The `ExampleListCalc/` folder contains an example project, which calculates arithmetic expressions in LISP syntax:

    >>> (- (^ 2 16) 6)
    65530.0

### Build

Compile `Scanner.swift` with your project.

`ScannerTests/` folder of this repository contains unit-tests and an Xcode project to run them.

### Initialization

`init()` creates scanner that reads the standard input.

`init(string: String)` creates scanner that reads from a string.

`init<G>(characterGenerator: G)` creates scanner from any generator that produces `Character` values.

### Usage

Reading values:

* `readDouble() -> Double?`
* `readInt64(base base: Int = 10) -> Int64?`
* `readInt(base base: Int = 10) -> Int?`
* `readCharacter() -> Character?` reads exactly one non-whitespace character.
* `readWord() -> String?` reads a sequence of non-whitespace characters.
* `readLine() -> String?` reads the rest of the current line. Returns string without the trailing newline.

Control:

* `skipWhitespace()` advances to the next non-whitespace character.
* `nextLine()` advances to the next line.
* `var newlineCharacterSet : Set<Character>` controls what is considered a newline.
* `var whitespaceCharacterSet : Set<Character>` controls what is considered a whitespace.
* `var digitValues : [Character:Int]` controls what is accepted as a digit for `readInt()` and `readInt64()`.

Core interface:

* `peek() -> Character?` returns the next character without consuming it, or `nil` if EOF.
* `poke() -> Character?` consumes the next character and returns it, or returns `nil` if EOF.

### Error handling

All functions return `nil` if parsing failed, or EOF is reached. The `eof` property can be used to distinguish between those two.

The value reading functions stop at first bad character, which means it will be the next character seen by the scanner. For example, calling `readDouble()` on "1eX" string will consume "1e" and return nil, the following `readCharacter()` call will return "X".

## License

The standard MIT license. See [LICENSE] file.

