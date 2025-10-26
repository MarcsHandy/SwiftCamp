import Foundation

struct Lesson: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let difficulty: Difficulty
    let theory: String
    let codeExample: String
    let challenge: Challenge?
    let dependencies: [String]
    let estimatedTime: Int
    let category: String
    
    enum Difficulty: String, Codable {
        case beginner, intermediate, advanced
    }
}
