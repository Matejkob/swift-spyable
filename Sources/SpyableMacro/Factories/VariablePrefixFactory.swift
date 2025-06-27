import SwiftSyntax
import SwiftSyntaxBuilder
import Foundation

/// The `VariablePrefixFactory` struct is responsible for creating a unique textual representation
/// for a given function declaration. This representation can be used as a prefix when naming variables
/// associated with that function. It could add the return type inside the textual representation
///
/// The factory constructs the representation by combining the function name with the first names of its parameters.
///
/// For example:
/// ```swift
/// func display(text: String, color: Color)
/// func display(text: String, color: Color) -> String
/// ```
/// will produce the following when using `shouldAddReturnType: false`:
/// ```
/// displayTextColor
/// displayTextColor
/// ```
/// and the following when using `shouldAddReturnType: true`:
/// ```
/// displayTextColor
/// displayTextColorString
/// ```
/// Parameter names are capitalized and appended to the function name.
/// Anonymous parameters (`_`) are ignored.
/// The return type, if exist, is only appended if `shouldAddReturnType` is set to `true`.
struct VariablePrefixFactory {
  func text(for functionDeclaration: FunctionDeclSyntax, shouldAddReturnType: Bool = false) -> String {
    var parts: [String] = [functionDeclaration.name.text]

    let parameterList = functionDeclaration.signature.parameterClause.parameters

    let parameters =
      parameterList
      .map { $0.firstName.text }
      .filter { $0 != "_" }
      .map { $0.capitalizingFirstLetter() }

    parts.append(contentsOf: parameters)

    if shouldAddReturnType {
      var returnTypeText = functionDeclaration.signature.returnClause?.type.trimmedDescription ?? ""
      
      if returnTypeText.isOptional {
        returnTypeText.removeLast()
        returnTypeText = "Optional\(returnTypeText)"
      }

      returnTypeText = returnTypeText
        .replacingOccurrences(of: "?", with: "Optional")
        .removeCharacters(in: [":", "[", "]", "<", ">", "(", ")", ",", " "])

      return parts.joined() + returnTypeText
    }

    return parts.joined()
  }
}

extension String {
  fileprivate func capitalizingFirstLetter() -> String {
    return prefix(1).uppercased() + dropFirst()
  }
}

fileprivate extension String {
  var isOptional: Bool {
      self.last == "?"
  }

  func removeCharacters(in set: CharacterSet) -> String {
    return self.unicodeScalars
      .filter { !set.contains($0) }
      .map(String.init)
      .joined()
  }
}
