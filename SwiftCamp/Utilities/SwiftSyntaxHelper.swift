import Foundation

class SwiftSyntaxHelper {
    
    static func validateSwiftSyntax(_ code: String) -> Bool {
        let swiftKeywords = ["func", "var", "let", "if", "else", "for", "while", "switch", "case", "default", "struct", "class", "enum", "protocol", "extension"]
        
        let lines = code.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.isEmpty || trimmedLine.hasPrefix("//") {
                continue
            }
            
            if !isValidSwiftLine(trimmedLine) {
                return false
            }
        }
        
        return true
    }
    
    private static func isValidSwiftLine(_ line: String) -> Bool {
        if line.hasSuffix("{") || line.hasSuffix("}") {
            return true
        }
        
        if line.contains("=") && !line.contains("==") {
            return hasValidAssignmentSyntax(line)
        }
        
        if line.contains("if") || line.contains("for") || line.contains("while") {
            return hasValidControlFlowSyntax(line)
        }
        
        return true
    }
    
    private static func hasValidAssignmentSyntax(_ line: String) -> Bool {
        let components = line.components(separatedBy: "=")
        return components.count == 2 && !components[0].trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private static func hasValidControlFlowSyntax(_ line: String) -> Bool {
        return line.contains("(") && line.contains(")") || line.contains("{")
    }
    
    static func extractVariableNames(from code: String) -> [String] {
        let pattern = "(?:var|let)\\s+([a-zA-Z_][a-zA-Z0-9_]*)"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        
        let range = NSRange(code.startIndex..<code.endIndex, in: code)
        let matches = regex.matches(in: code, range: range)
        
        return matches.compactMap { match in
            guard let range = Range(match.range(at: 1), in: code) else { return nil }
            return String(code[range])
        }
    }
    
    static func containsForbiddenKeywords(_ code: String) -> Bool {
        let forbiddenPatterns = [
            "import\\s+",
            "NSClassFromString",
            "performSelector",
            "unsafeBitCast",
            "Unmanaged\\.",
            "malloc\\(",
            "free\\("
        ]
        
        for pattern in forbiddenPatterns {
            if code.range(of: pattern, options: .regularExpression) != nil {
                return true
            }
        }
        
        return false
    }
}
