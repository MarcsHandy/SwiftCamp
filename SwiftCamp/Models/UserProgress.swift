import Foundation

struct UserProgress: Codable {
    var completedLessons: Set<String>
    var earnedBadges: [String]
    var totalXp: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastSessionDate: Date?
}
