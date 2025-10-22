import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

/// The `VariablePrefixFactory` struct is responsible for creating a unique textual representation
/// for a given function declaration. This representation can be used as a prefix when naming variables
/// associated with that function. It could add the return type inside the textual representation
///
/// The factory constructs the representation by combining the function name with the first names of its parameters.
///
/// For example:
/// ```swift
/// func display(text: Int, name: String)
/// func display(text: String, name: String)
/// func display(text: String, name: String) -> String
/// ```
/// will produce the following when using `descriptive: false`:
/// ```
/// displayTextName
/// displayTextName
/// displayTextName
/// ```
/// and the following when using `descriptive: true`:
/// ```
/// displayTextIntNameString
/// displayTextStringNameString
/// displayTextStringNameStringString
/// ```
/// Parameter names are capitalized and appended to the function name.
/// Anonymous parameters (`_`) are ignored.
/// The return type and the parameters type are only appended if `descriptive` is set to `true`.
struct VariablePrefixFactory {
  func text(for functionDeclaration: FunctionDeclSyntax, descriptive: Bool = false) -> String {
    var parts: [String] = [functionDeclaration.name.text]

    let parameterList = functionDeclaration.signature.parameterClause.parameters

    let parameters =
      if descriptive {
        parameterList
          .compactMap { parameter -> String? in
            let firstName = parameter.firstName.text
            if firstName == "_" {
              return nil
            }
            let type = TypeSyntaxSanitizer.sanitize(parameter.type)
            return "\(firstName.capitalizingFirstLetter())\(type)"
          }
      } else {
        parameterList
          .map { $0.firstName.text }
          .filter { $0 != "_" }
          .map { $0.capitalizingFirstLetter() }
      }

    parts.append(contentsOf: parameters)

    if descriptive {
      if let returnType = functionDeclaration.signature.returnClause?.type {
        let sanitizedReturnType = TypeSyntaxSanitizer.sanitize(returnType)
        return parts.joined() + sanitizedReturnType
      }
    }

    return parts.joined()
  }
}

extension String {
  fileprivate func capitalizingFirstLetter() -> String {
    return prefix(1).uppercased() + dropFirst()
  }
}
