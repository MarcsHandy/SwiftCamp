import SwiftUI

struct LessonView: View {
    let lesson: Lesson
    @ObservedObject var lessonManager: LessonManager
    @State private var userCode: String = ""
    @State private var showChallenge = false
    @State private var showSolution = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                theorySection
                exampleSection
                
                if let challenge = lesson.challenge {
                    challengeSection(challenge: challenge)
                }
            }
            .padding()
        }
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .fullScreenCover(isPresented: $showChallenge) { // ← CHANGED TO fullScreenCover
            if let challenge = lesson.challenge {
                ChallengeView(challenge: challenge)
            }
        }
        .onAppear {
            userCode = lesson.challenge?.starterCode ?? ""
        }
    }
    
    // ... ALL YOUR EXISTING CODE BELOW STAYS EXACTLY THE SAME
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                DifficultyBadge(difficulty: lesson.difficulty)
                Spacer()
                Text("\(lesson.estimatedTime) min")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(lesson.description)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
    
    private var theorySection: some View {
        GroupBox("Theory") {
            Text(.init(lesson.theory))
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)
        }
    }
    
    private var exampleSection: some View {
        GroupBox("Example") {
            VStack(alignment: .leading, spacing: 12) {
                CodeEditorView(code: .constant(lesson.codeExample), isEditable: false)
                
                Button {
                    showSolution.toggle()
                } label: {
                    Label(showSolution ? "Hide Explanation" : "Show Explanation", systemImage: showSolution ? "eye.slash" : "eye")
                }
                .buttonStyle(.bordered)
                
                if showSolution {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Explanation:")
                            .font(.headline)
                        Text(getCodeExplanation())
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    private func challengeSection(challenge: Challenge) -> some View {
        GroupBox("Practice") {
            VStack(alignment: .leading, spacing: 16) {
                // Instructions with fixed height and scrolling
                VStack(alignment: .leading, spacing: 8) {
                    Text("Instructions")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    ScrollView {
                        Text(challenge.instructions)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 8)
                    }
                    .frame(maxHeight: 150)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.1))
                    )
                }
                
                // Code editor with fixed height
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Solution")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    CodeEditorView(code: $userCode, isEditable: true)
                        .frame(minHeight: 200, maxHeight: 300)
                }
                
                // Buttons - always visible at the bottom
                VStack(spacing: 12) {
                    HStack {
                        Button("Start Challenge") {
                            showChallenge = true
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Spacer()
                        
                        Button("Complete Lesson") {
                            Task {
                                await lessonManager.completeLesson(lesson)
                            }
                        }
                        .buttonStyle(.bordered)
                        .disabled(lessonManager.completedLessons.contains(lesson.id))
                        .opacity(lessonManager.completedLessons.contains(lesson.id) ? 0.5 : 1.0)
                    }
                    
                    if lessonManager.completedLessons.contains(lesson.id) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Lesson Completed!")
                                .font(.subheadline)
                                .foregroundColor(.green)
                            Spacer()
                            Text("+\(calculateXp(for: lesson)) XP")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                        }
                        .padding(12)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    private func getCodeExplanation() -> String {
        switch lesson.id {
        case "variables":
            return "This example shows how to declare variables with 'var' and constants with 'let'. Variables can be changed, but constants cannot be reassigned."
        case "optionals":
            return "Optionals handle the absence of a value. We use 'if let' to safely unwrap optionals and access their values only when they exist."
        default:
            return "Study the code example to understand how this Swift concept works. Pay attention to the syntax and structure."
        }
    }
    
    private func calculateXp(for lesson: Lesson) -> Int {
        switch lesson.difficulty {
        case .beginner: return 10
        case .intermediate: return 25
        case .advanced: return 50
        }
    }
}

struct DifficultyBadge: View {
    let difficulty: Lesson.Difficulty
    
    var body: some View {
        HStack {
            Circle()
                .fill(difficultyColor)
                .frame(width: 8, height: 8)
            Text(difficulty.rawValue.capitalized)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(difficultyColor.opacity(0.2))
        .cornerRadius(6)
    }
    
    private var difficultyColor: Color {
        switch difficulty {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
}
