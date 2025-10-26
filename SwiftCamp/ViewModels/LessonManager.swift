import Foundation

class LessonManager: ObservableObject {
    @Published var lessons: [Lesson] = []
    @Published var completedLessons: Set<String> = []
    @Published var userProgress: UserProgress
    @Published var currentLesson: Lesson?
    
    init() {
        self.userProgress = UserProgress(
            completedLessons: [],
            earnedBadges: [],
            totalXp: 0,
            currentStreak: 0,
            longestStreak: 0,
            lastSessionDate: nil
        )
        loadLessons()
        loadUserProgress()
    }
    
    func loadLessons() {
        if let url = Bundle.main.url(forResource: "lessons", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decodedLessons = try JSONDecoder().decode([Lesson].self, from: data)
                lessons = decodedLessons
                return 
            } catch {
                print("Error loading lessons from JSON: \(error)")
            }
        }
        
        // If JSON fails, use sample lessons
        lessons = createSampleLessons()
    }
    
    private func createSampleLessons() -> [Lesson] {
        return [
            Lesson(
                id: "variables",
                title: "Variables & Constants",
                description: "Learn about var, let, and basic data types",
                difficulty: .beginner,
                theory: "In Swift, we use 'var' for variables that can change and 'let' for constants that cannot change. Variables are fundamental building blocks for storing data in your programs.",
                codeExample: "var name = \"John\"\nlet age = 25\nname = \"Jane\"\n// age = 26 // This would cause an error because age is a constant",
                challenge: Challenge(
                    instructions: "Create a variable called 'score' with initial value 100, then update it to 150. Finally, create a constant called 'playerName' with your name.",
                    starterCode: "// Create your variables and constants here\n",
                    solution: "var score = 100\nscore = 150\nlet playerName = \"Alex\"",
                    testCases: [
                        TestCase(input: "score", expectedOutput: "150", description: "Score should be updated to 150"),
                        TestCase(input: "playerName", expectedOutput: "Alex", description: "Player name should be a constant string")
                    ],
                    hints: [
                        "Use 'var' for score since it needs to change",
                        "Use 'let' for playerName since it won't change",
                        "Don't forget the equal signs for assignment"
                    ]
                ),
                dependencies: [],
                estimatedTime: 10,
                category: "Swift Basics"
            )
        ]
    }
    
    func isLessonLocked(_ lesson: Lesson) -> Bool {
        return !lesson.dependencies.allSatisfy { completedLessons.contains($0) }
    }
    
    func canStartLesson(_ lesson: Lesson) -> Bool {
        return !isLessonLocked(lesson)
    }
    
    func completeLesson(_ lesson: Lesson) {
        print("🎯 Completing lesson: \(lesson.id)")
        guard !completedLessons.contains(lesson.id) else {
            print("⚠️ Lesson already completed")
            return
        }
        
        completedLessons.insert(lesson.id)
        userProgress.completedLessons.insert(lesson.id)
        userProgress.totalXp += calculateXp(for: lesson)
        updateStreak()
        awardBadgesIfNeeded()
        saveUserProgress()
        updateOverallProgress()
        
        print("✅ Lesson completed! Completed lessons: \(completedLessons)")
        print("📊 Total XP: \(userProgress.totalXp)")
        
        // Force UI update
        objectWillChange.send()
    }
    
    private func calculateXp(for lesson: Lesson) -> Int {
        switch lesson.difficulty {
        case .beginner: return 10
        case .intermediate: return 25
        case .advanced: return 50
        }
    }
    
    private func updateStreak() {
        let today = Date()
        let calendar = Calendar.current
        
        if let lastDate = userProgress.lastSessionDate {
            if calendar.isDateInYesterday(lastDate) {
                userProgress.currentStreak += 1
            } else if !calendar.isDateInToday(lastDate) {
                userProgress.currentStreak = 1
            }
        } else {
            userProgress.currentStreak = 1
        }
        
        userProgress.lastSessionDate = today
        userProgress.longestStreak = max(userProgress.longestStreak, userProgress.currentStreak)
    }
    
    private func awardBadgesIfNeeded() {
        let completedCount = completedLessons.count
        
        if completedCount >= 1 && !userProgress.earnedBadges.contains("first_steps") {
            userProgress.earnedBadges.append("first_steps")
        }
        
        if completedCount >= 5 && !userProgress.earnedBadges.contains("quick_learner") {
            userProgress.earnedBadges.append("quick_learner")
        }
        
        if userProgress.currentStreak >= 7 && !userProgress.earnedBadges.contains("dedicated") {
            userProgress.earnedBadges.append("dedicated")
        }
    }
    
    private func updateOverallProgress() {
        let totalLessons = lessons.count
        let completedCount = completedLessons.count
        userProgress.totalXp = completedCount * 10
    }
    
    func getNextLesson(after lesson: Lesson) -> Lesson? {
        guard let currentIndex = lessons.firstIndex(where: { $0.id == lesson.id }) else { return nil }
        let nextIndex = currentIndex + 1
        return nextIndex < lessons.count ? lessons[nextIndex] : nil
    }
    
    func getLesson(byId id: String) -> Lesson? {
        return lessons.first { $0.id == id }
    }
    
    func getCompletedLessonsCount() -> Int {
        return completedLessons.count
    }
    
    func getTotalLessonsCount() -> Int {
        return lessons.count
    }
    
    func getProgressPercentage() -> Double {
        let total = Double(lessons.count)
        let completed = Double(completedLessons.count)
        return total > 0 ? (completed / total) * 100 : 0
    }
    
    private func loadUserProgress() {
        if let data = UserDefaults.standard.data(forKey: "userProgress"),
           let progress = try? JSONDecoder().decode(UserProgress.self, from: data) {
            userProgress = progress
            completedLessons = progress.completedLessons
        }
    }
    
    private func saveUserProgress() {
        if let data = try? JSONEncoder().encode(userProgress) {
            UserDefaults.standard.set(data, forKey: "userProgress")
        }
    }
    
    func resetProgress() {
        completedLessons.removeAll()
        userProgress = UserProgress(
            completedLessons: [],
            earnedBadges: [],
            totalXp: 0,
            currentStreak: 0,
            longestStreak: 0,
            lastSessionDate: nil
        )
        UserDefaults.standard.removeObject(forKey: "userProgress")
    }
}
