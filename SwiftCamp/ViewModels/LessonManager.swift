import Foundation

class LessonManager: ObservableObject {
    @Published var lessons: [Lesson] = []
    @Published var completedLessons: Set<String> = []
    @Published var userProgress: UserProgress
    
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
        guard let url = Bundle.main.url(forResource: "lessons", withExtension: "json") else {
            print("❌ Could not find lessons.json file")
            lessons = []
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decodedLessons = try JSONDecoder().decode([Lesson].self, from: data)
            lessons = decodedLessons
            print("✅ Successfully loaded \(lessons.count) lessons from JSON")
        } catch {
            print("❌ Error loading lessons from JSON: \(error)")
            lessons = []
        }
    }
    
    func isLessonLocked(_ lesson: Lesson) -> Bool {
        return !lesson.dependencies.allSatisfy { completedLessons.contains($0) }
    }
    
    func canStartLesson(_ lesson: Lesson) -> Bool {
        return !isLessonLocked(lesson)
    }
    
    func completeLesson(_ lesson: Lesson) {
        guard !completedLessons.contains(lesson.id) else { return }
        
        completedLessons.insert(lesson.id)
        userProgress.completedLessons.insert(lesson.id)
        userProgress.totalXp += calculateXp(for: lesson)
        updateStreak()
        awardBadgesIfNeeded()
        saveUserProgress()
        updateOverallProgress()
        
        print("✅ Completed lesson: \(lesson.id)")
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

