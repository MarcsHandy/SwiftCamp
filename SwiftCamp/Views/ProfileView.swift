import SwiftUI

struct ProfileView: View {
    @ObservedObject var lessonManager: LessonManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    statsSection
                    badgesSection
                    actionsSection
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Reset Progress", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    lessonManager.resetProgress()
                }
            } message: {
                Text("Are you sure you want to reset all your progress? This cannot be undone.")
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            VStack(spacing: 4) {
                Text("Swift Learner")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Level \(calculateLevel())")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.2), radius: 5)
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Learning Stats")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCard(title: "Lessons Completed", value: "\(lessonManager.getCompletedLessonsCount())", systemImage: "checkmark.circle.fill", color: .green)
                StatCard(title: "Total XP", value: "\(lessonManager.userProgress.totalXp)", systemImage: "star.fill", color: .yellow)
                StatCard(title: "Current Streak", value: "\(lessonManager.userProgress.currentStreak) days", systemImage: "flame.fill", color: .orange)
                StatCard(title: "Longest Streak", value: "\(lessonManager.userProgress.longestStreak) days", systemImage: "trophy.fill", color: .purple)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.2), radius: 5)
    }
    
    private var badgesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Badges Earned")
                .font(.headline)
            
            if lessonManager.userProgress.earnedBadges.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "medal")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("No badges yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Complete lessons to earn badges!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(lessonManager.userProgress.earnedBadges, id: \.self) { badge in
                        BadgeView(badgeId: badge)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.2), radius: 5)
    }
    
    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Actions")
                .font(.headline)
            
            Button {
                showingResetAlert = true
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Reset All Progress")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                }
                .foregroundColor(.red)
            }
            .padding()
            .background(Color.red.opacity(0.1))
            .cornerRadius(12)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.2), radius: 5)
    }
    
    private func calculateLevel() -> Int {
        return lessonManager.userProgress.totalXp / 100 + 1
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let systemImage: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct BadgeView: View {
    let badgeId: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: badgeIcon)
                .font(.title2)
                .foregroundColor(badgeColor)
            
            Text(badgeName)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(badgeColor.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var badgeName: String {
        switch badgeId {
        case "first_steps": return "First Steps"
        case "quick_learner": return "Quick Learner"
        case "dedicated": return "Dedicated"
        default: return "Achievement"
        }
    }
    
    private var badgeIcon: String {
        switch badgeId {
        case "first_steps": return "1.circle.fill"
        case "quick_learner": return "bolt.fill"
        case "dedicated": return "flame.fill"
        default: return "medal.fill"
        }
    }
    
    private var badgeColor: Color {
        switch badgeId {
        case "first_steps": return .blue
        case "quick_learner": return .yellow
        case "dedicated": return .orange
        default: return .purple
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let lessonManager = LessonManager()
        lessonManager.userProgress.earnedBadges = ["first_steps", "quick_learner"]
        lessonManager.userProgress.totalXp = 150
        lessonManager.userProgress.currentStreak = 5
        lessonManager.userProgress.longestStreak = 10
        
        return ProfileView(lessonManager: lessonManager)
    }
}
