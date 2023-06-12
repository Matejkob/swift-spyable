import SwiftSyntaxMacrosTestSupport
import SwiftSyntax
import _SwiftSyntaxTestSupport

/*
 Source: https://github.com/apple/swift-syntax/blob/4db7cb20e63f4dba0b030068687996723e352874/Tests/SwiftSyntaxBuilderTest/Assertions.swift#L19
 */
func assertBuildResult<T: SyntaxProtocol>(
  _ buildable: T,
  _ expectedResult: String,
  trimTrailingWhitespace: Bool = true,
  file: StaticString = #file,
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
