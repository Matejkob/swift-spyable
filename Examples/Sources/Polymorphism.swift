import Spyable

// MARK: - Polymorphism Example Protocol

@Spyable
protocol DataProcessorProtocol {
    // Overloaded methods with different parameter types
    func compute(value: String) -> String
    func compute(value: Int) -> String
    func compute(value: Bool) -> String
    
    // Overloaded methods with same parameter type but different return types
    func convert(value: Int) -> Bool
    func convert(value: Int) -> String
    func convert(value: Int) -> [Int]
    
    // Overloaded async methods
    func fetch(id: String) async -> String
    func fetch(id: Int) async -> String
    
    // Overloaded throwing methods
    func validate(input: String) throws -> Bool
    func validate(input: Int) throws -> Bool
    
    // Simple overloaded methods with different parameter names
    func process(data: String) -> String
    func process(item: String) -> String
    func process(content: String) -> String
}

// MARK: - Service Implementation Example

final class DataProcessor {
    private let processor: DataProcessorProtocol
    
    init(processor: DataProcessorProtocol) {
        self.processor = processor
    }
    
    // MARK: - Compute Methods with Different Parameter Types
    
    func computeStringValue(_ input: String) -> String {
        return processor.compute(value: input)
    }
    
    func computeIntValue(_ input: Int) -> String {
        return processor.compute(value: input)
    }
    
    func computeBoolValue(_ input: Bool) -> String {
        return processor.compute(value: input)
    }
    
    // MARK: - Convert Methods with Same Parameter Type, Different Return Types
    
    func convertToBool(_ value: Int) -> Bool {
        return processor.convert(value: value)
    }
    
    func convertToString(_ value: Int) -> String {
        return processor.convert(value: value)
    }
    
    func convertToArray(_ value: Int) -> [Int] {
        return processor.convert(value: value)
    }
    
    // MARK: - Async Operations
    
    func fetchStringData(id: String) async -> String {
        return await processor.fetch(id: id)
    }
    
    func fetchIntData(id: Int) async -> String {
        return await processor.fetch(id: id)
    }
    
    // MARK: - Validation with Throwing
    
    func validateString(_ input: String) throws -> Bool {
        return try processor.validate(input: input)
    }
    
    func validateInt(_ input: Int) throws -> Bool {
        return try processor.validate(input: input)
    }
    
    // MARK: - Process Methods with Different Parameter Names
    
    func processData(_ data: String) -> String {
        return processor.process(data: data)
    }
    
    func processItem(_ item: String) -> String {
        return processor.process(item: item)
    }
    
    func processContent(_ content: String) -> String {
        return processor.process(content: content)
    }
}

// MARK: - Real-World Usage Example

final class ProductService {
    private let processor: DataProcessorProtocol
    
    init(processor: DataProcessorProtocol) {
        self.processor = processor
    }
    
    func processUserInput(_ input: String) -> String {
        return processor.compute(value: input)
    }
    
    func processQuantity(_ quantity: Int) -> String {
        return processor.compute(value: quantity)
    }
    
    func processAvailability(_ available: Bool) -> String {
        return processor.compute(value: available)
    }
    
    func getProductStatus(_ id: Int) -> Bool {
        return processor.convert(value: id)
    }
    
    func getProductName(_ id: Int) -> String {
        return processor.convert(value: id)
    }
    
    func getRelatedProducts(_ id: Int) -> [Int] {
        return processor.convert(value: id)
    }
    
    func handleData(_ data: String) -> String {
        return processor.process(data: data)
    }
    
    func handleItem(_ item: String) -> String {
        return processor.process(item: item)
    }
    
    func handleContent(_ content: String) -> String {
        return processor.process(content: content)
    }
    
    func fetchUserData(id: String) async -> String {
        return await processor.fetch(id: id)
    }
    
    func fetchProductData(id: Int) async -> String {
        return await processor.fetch(id: id)
    }
    
    func validateUserInput(_ input: String) throws -> Bool {
        return try processor.validate(input: input)
    }
    
    func validateProductId(_ id: Int) throws -> Bool {
        return try processor.validate(input: id)
    }
}

// MARK: - Supporting Types

struct User: Codable {
    let id: String
    let name: String
}

struct Product: Encodable {
    let id: Int
    let title: String
}

enum ProcessingError: Error, Equatable {
    case invalidInput
    case processingFailed
    case conversionError
}