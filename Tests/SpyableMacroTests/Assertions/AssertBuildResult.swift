import SwiftSyntax
import SwiftSyntaxMacrosTestSupport
import XCTest

func assertBuildResult<T: SyntaxProtocol>(
  _ buildable: T,
  _ expectedResult: String,
  trimTrailingWhitespace: Bool = true,
  file: StaticString = #filePath,
  line: UInt = #line
) {
  var buildableDescription = buildable.formatted().description
  var expectedResult = expectedResult
  if trimTrailingWhitespace {
    buildableDescription = buildableDescription.trimmingTrailingWhitespace()
    expectedResult = expectedResult.trimmingTrailingWhitespace()
  }
  assertStringsEqualWithDiff(
    buildableDescription,
    expectedResult,
    file: file,
    line: line
  )
}

/*
 Source: https://github.com/apple/swift-syntax/blob/4db7cb20e63f4dba0b030068687996723e352874/Tests/SwiftSyntaxBuilderTest/Assertions.swift#L19
 */

/// Asserts that the two strings are equal, providing Unix `diff`-style output if they are not.
///
/// - Parameters:
///   - actual: The actual string.
///   - expected: The expected string.
///   - message: An optional description of the failure.
///   - additionalInfo: Additional information about the failed test case that will be printed after the diff
///   - file: The file in which failure occurred. Defaults to the file name of the test case in
///     which this function was called.
///   - line: The line number on which failure occurred. Defaults to the line number on which this
///     function was called.
private func assertStringsEqualWithDiff(
  _ actual: String,
  _ expected: String,
  _ message: String = "",
  additionalInfo: @autoclosure () -> String? = nil,
  file: StaticString = #filePath,
  line: UInt = #line
) {
  if actual == expected {
    return
  }
  failStringsEqualWithDiff(
    actual,
    expected,
    message,
    additionalInfo: additionalInfo(),
    file: file,
    line: line
  )
}

/// `XCTFail` with `diff`-style output.
private func failStringsEqualWithDiff(
  _ actual: String,
  _ expected: String,
  _ message: String = "",
  additionalInfo: @autoclosure () -> String? = nil,
  file: StaticString = #filePath,
  line: UInt = #line
) {
  // Use `CollectionDifference` on supported platforms to get `diff`-like line-based output. On
  // older platforms, fall back to simple string comparison.
  if #available(macOS 10.15, *) {
    let actualLines = actual.components(separatedBy: .newlines)
    let expectedLines = expected.components(separatedBy: .newlines)

    let difference = actualLines.difference(from: expectedLines)

    var result = ""

    var insertions = [Int: String]()
    var removals = [Int: String]()

    for change in difference {
      switch change {
      case .insert(let offset, let element, _):
        insertions[offset] = element
      case .remove(let offset, let element, _):
        removals[offset] = element
      }
    }

    var expectedLine = 0
    var actualLine = 0

    while expectedLine < expectedLines.count || actualLine < actualLines.count {
      if let removal = removals[expectedLine] {
        result += "–\(removal)\n"
        expectedLine += 1
      } else if let insertion = insertions[actualLine] {
        result += "+\(insertion)\n"
        actualLine += 1
      } else {
        result += " \(expectedLines[expectedLine])\n"
        expectedLine += 1
        actualLine += 1
      }
    }

    let failureMessage = "Actual output (+) differed from expected output (-):\n\(result)"
    var fullMessage = message.isEmpty ? failureMessage : "\(message) - \(failureMessage)"
    if let additionalInfo = additionalInfo() {
      fullMessage = """
        \(fullMessage)
        \(additionalInfo)
        """
    }
    XCTFail(fullMessage, file: file, line: line)
  } else {
    // Fall back to simple message on platforms that don't support CollectionDifference.
    let failureMessage = "Actual output differed from expected output:"
    let fullMessage = message.isEmpty ? failureMessage : "\(message) - \(failureMessage)"
    XCTFail(fullMessage, file: file, line: line)
  }
}
