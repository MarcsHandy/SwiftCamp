import SwiftUI

struct ChallengeView: View {
    let challenge: Challenge
    @State private var userCode: String
    @State private var showHints: Bool = false
    @State private var currentHintIndex: Int = 0
    @StateObject private var codeExecutor = CodeExecutor()
    @Environment(\.dismiss) private var dismiss
    
    init(challenge: Challenge) {
        self.challenge = challenge
        self._userCode = State(initialValue: challenge.starterCode)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        instructionsSection
                        codeEditorSection
                        hintsSection
                        outputSection
                    }
                    .padding()
                }
                
                actionButtons
            }
            .navigationTitle("Challenge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var instructionsSection: some View {
        GroupBox("Instructions") {
            Text(challenge.instructions)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var codeEditorSection: some View {
        GroupBox("Your Code") {
            VStack(alignment: .leading) {
                TextEditor(text: $userCode)
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .textInputAutocapitalization(.never)
                
                Text("Tip: Write your solution above and test it")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var hintsSection: some View {
        GroupBox("Hints") {
            VStack(alignment: .leading) {
                Button(showHints ? "Hide Hints" : "Show Hints") {
                    withAnimation {
                        showHints.toggle()
                    }
                }
                
                if showHints && !challenge.hints.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(0..<challenge.hints.count, id: \.self) { index in
                            HStack(alignment: .top) {
                                Text("\(index + 1).")
                                    .fontWeight(.medium)
                                Text(challenge.hints[index])
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .font(.subheadline)
                            .padding(8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
    }
    
    private var outputSection: some View {
        GroupBox("Output") {
            VStack(alignment: .leading) {
                if codeExecutor.isRunning {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Running your code...")
                            .font(.subheadline)
                    }
                }
                
                ScrollView {
                    Text(codeExecutor.output)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(minHeight: 100, maxHeight: 200)
                .padding(8)
                .background(Color.black.opacity(0.05))
                .cornerRadius(8)
                
                if let error = codeExecutor.lastError {
                    Text("Error: \(error)")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
    }
    
    private var actionButtons: some View {
        HStack {
            Button("Run Code") {
                runCode()
            }
            .disabled(codeExecutor.isRunning)
            
            Button("Check Solution") {
                checkSolution()
            }
            .disabled(codeExecutor.isRunning)
            
            Button("Reset") {
                resetCode()
            }
            .disabled(codeExecutor.isRunning)
        }
        .buttonStyle(.bordered)
        .padding()
    }
    
    private func runCode() {
        codeExecutor.executeSwiftCode(userCode, challenge: challenge)
    }
    
    private func checkSolution() {
        let cleanedUserCode = userCode.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedSolution = challenge.solution.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleanedUserCode == cleanedSolution {
            codeExecutor.output = "✅ Perfect! Your solution matches exactly!\n\n🎉 Great job! You've completed this challenge."
        } else {
            codeExecutor.output = "⚠️ Your solution doesn't match exactly, but let's test it...\n\n"
            runCode()
        }
    }
    
    private func resetCode() {
        userCode = challenge.starterCode
        codeExecutor.clearOutput()
    }
}
