import SwiftSyntax
import XCTest

@testable import SpyableMacro

final class UT_FunctionParameterListSyntaxExtensions: XCTestCase {
  func testSupportsParameterTracking() {
    XCTAssertTrue(
      FunctionParameterListSyntax {
        "param: Int"
        "param: inout Int"
        "param: @autoclosure @escaping (Int) throws async -> Void"
      }.supportsParameterTracking
    )

    XCTAssertFalse(
      FunctionParameterListSyntax {
        "param: (Int) -> Void"
      }.supportsParameterTracking
    )
  }
}
