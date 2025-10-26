import Foundation

struct Challenge: Codable {
    let instructions: String
    let starterCode: String
    let solution: String
    let testCases: [TestCase]
    let hints: [String]
}

struct TestCase: Codable {
    let input: String
    let expectedOutput: String
    let description: String
}
