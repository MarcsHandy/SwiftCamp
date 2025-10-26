import SwiftUI

struct LessonView: View {
    let lesson: Lesson
    @ObservedObject var lessonManager: LessonManager
    @State private var userCode: String = ""
    @State private var showChallenge = false
    @State private var showSolution = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
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
            .sheet(isPresented: $showChallenge) {
                if let challenge = lesson.challenge {
                    ChallengeView(challenge: challenge)
                }
            }
        }
        .onAppear {
            userCode = lesson.challenge?.starterCode ?? ""
        }
    }
    
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
            Text(lesson.theory)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
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
            VStack(alignment: .leading, spacing: 12) {
                Text(challenge.instructions)
                    .font(.body)
                
                CodeEditorView(code: $userCode, isEditable: true)
                
                HStack {
                    Button("Start Challenge") {
                        showChallenge = true
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Complete Lesson") {
                        lessonManager.completeLesson(lesson)
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .disabled(lessonManager.completedLessons.contains(lesson.id)) // FIXED: Disable when already completed
                    .opacity(lessonManager.completedLessons.contains(lesson.id) ? 0.5 : 1.0) // FIXED: Fade when completed
                }
                
                if lessonManager.completedLessons.contains(lesson.id) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Lesson Completed!")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                    .padding(8)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
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

struct LessonView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleLesson = Lesson(
            id: "variables",
            title: "Variables & Constants",
            description: "Learn about var, let, and basic data types",
            difficulty: .beginner,
            theory: "In Swift, we use 'var' for variables that can change and 'let' for constants that cannot change.",
            codeExample: "var name = \"John\"\nlet age = 25",
            challenge: Challenge(
                instructions: "Create a variable and a constant",
                starterCode: "// Your code here",
                solution: "var score = 100\nlet player = \"Alex\"",
                testCases: [],
                hints: []
            ),
            dependencies: [],
            estimatedTime: 10,
            category: "Swift Basics"
        )
        
        LessonView(lesson: sampleLesson, lessonManager: LessonManager())
    }
}
