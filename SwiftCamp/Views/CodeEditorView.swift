import SwiftUI

struct CodeEditorView: View {
    @Binding var code: String
    var isEditable: Bool = true
    var language: String = "swift"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Code Editor")
                    .font(.headline)
                Spacer()
                Text(language.uppercased())
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(4)
            }
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    .background(Color(.systemBackground))
                
                if isEditable {
                    TextEditor(text: $code)
                        .font(.system(.body, design: .monospaced))
                        .padding(8)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .textInputAutocapitalization(.never)
                } else {
                    ScrollView {
                        Text(code)
                            .font(.system(.body, design: .monospaced))
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)
                    }
                }
                
                if code.isEmpty && isEditable {
                    Text("Start typing your \(language) code here...")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.gray)
                        .padding(12)
                        .allowsHitTesting(false)
                }
            }
            .frame(minHeight: 150, maxHeight: 300)
        }
    }
}

struct CodeEditorView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CodeEditorView(
                code: .constant("var greeting = \"Hello, World!\"\nprint(greeting)"),
                isEditable: true,
                language: "swift"
            )
            
            CodeEditorView(
                code: .constant("let constantValue = 42\n// This is read-only"),
                isEditable: false,
                language: "swift"
            )
        }
        .padding()
    }
}
