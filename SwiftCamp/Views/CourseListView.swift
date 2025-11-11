import SwiftUI

struct CourseListView: View {
    @StateObject private var lessonManager = LessonManager()
    @State private var showingProfile = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color for full screen
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        progressHeader
                        
                        if lessonManager.lessons.isEmpty {
                            emptyStateView
                        } else {
                            lessonsList
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("SwiftCamp")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingProfile = true
                    } label: {
                        Image(systemName: "person.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView(lessonManager: lessonManager)
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No Lessons Available")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Check if lessons.json is properly included in the app bundle.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 5)
    }
    
    private var lessonsList: some View {
        LazyVStack(spacing: 12) {
            ForEach(lessonManager.lessons) { lesson in
                // CHANGED: Use NavigationLink instead of .sheet
                NavigationLink(destination: LessonView(lesson: lesson, lessonManager: lessonManager)) {
                    LessonCard(
                        lesson: lesson,
                        isLocked: lessonManager.isLessonLocked(lesson),
                        isCompleted: lessonManager.completedLessons.contains(lesson.id)
                    )
                }
                .disabled(lessonManager.isLessonLocked(lesson))
                .buttonStyle(PlainButtonStyle())
                .opacity(lessonManager.isLessonLocked(lesson) ? 0.6 : 1.0)
            }
        }
    }
    
    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Learning Journey")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.headline)
                    Spacer()
                    Text("\(lessonManager.getCompletedLessonsCount())/\(lessonManager.getTotalLessonsCount()) lessons")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: lessonManager.getProgressPercentage() / 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                
                HStack {
                    StatView(value: "\(lessonManager.userProgress.totalXp)", label: "XP")
                    StatView(value: "\(lessonManager.userProgress.currentStreak)", label: "Day Streak")
                    StatView(value: "\(lessonManager.userProgress.earnedBadges.count)", label: "Badges")
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .gray.opacity(0.2), radius: 5)
        }
    }
}

struct LessonCard: View {
    let lesson: Lesson
    let isLocked: Bool
    let isCompleted: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(lesson.title)
                        .font(.headline)
                    Spacer()
                    Text(lesson.difficulty.rawValue.capitalized)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(difficultyColor)
                        .cornerRadius(4)
                }
                
                Text(lesson.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Label("\(lesson.estimatedTime) min", systemImage: "clock")
                    Spacer()
                    
                    if isCompleted {
                        Label("Completed", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else if isLocked {
                        Label("Locked", systemImage: "lock.fill")
                            .foregroundColor(.orange)
                    } else {
                        Label("Start", systemImage: "play.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                .font(.caption)
            }
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 5)
        .opacity(isLocked ? 0.6 : 1.0)
    }
    
    private var difficultyColor: Color {
        switch lesson.difficulty {
        case .beginner: return .green.opacity(0.2)
        case .intermediate: return .orange.opacity(0.2)
        case .advanced: return .red.opacity(0.2)
        }
    }
}

struct StatView: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CourseListView_Previews: PreviewProvider {
    static var previews: some View {
        CourseListView()
    }
}
