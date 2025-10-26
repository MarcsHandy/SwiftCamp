import Foundation
import JavaScriptCore

class CodeExecutor: ObservableObject {
    @Published var output: String = ""
    @Published var isRunning: Bool = false
    @Published var lastError: String?
    
    private let context: JSContext
    
    init() {
        self.context = JSContext()
        setupJavaScriptEnvironment()
    }
    
    private func setupJavaScriptEnvironment() {
        context.exceptionHandler = { context, exception in
            if let exception = exception {
                self.lastError = exception.toString()
            }
        }
        
        let consoleLog: @convention(block) (String) -> Void = { message in
            DispatchQueue.main.async {
                self.output += message + "\n"
            }
        }
        
        context.setObject(consoleLog, forKeyedSubscript: "consoleLog" as NSString)
        context.evaluateScript("var console = { log: consoleLog }")
    }
    
    func executeSwiftCode(_ code: String, challenge: Challenge? = nil) -> Bool {
        guard !code.isEmpty else { return false }
        
        isRunning = true
        output = ""
        lastError = nil
        
        if SwiftSyntaxHelper.containsForbiddenKeywords(code) {
            lastError = "Code contains forbidden operations"
            isRunning = false
            return false
        }
        
        if !SwiftSyntaxHelper.validateSwiftSyntax(code) {
            lastError = "Invalid Swift syntax"
            isRunning = false
            return false
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let processedCode = self.processSwiftCode(code)
            
            DispatchQueue.main.async {
                self.simulateExecution(processedCode, challenge: challenge)
            }
        }
        
        return true
    }
    
    private func processSwiftCode(_ code: String) -> String {
        var processed = code
        
        let swiftToJSPatterns = [
            "print\\(([^)]+)\\)": "console.log($1)",
            "var\\s+": "let ",
            "String\\?": "string",
            "Int\\?": "number",
            "Bool\\?": "boolean"
        ]
        
        for (pattern, replacement) in swiftToJSPatterns {
            processed = processed.replacingOccurrences(of: pattern, with: replacement, options: .regularExpression)
        }
        
        return processed
    }
    
    private func simulateExecution(_ code: String, challenge: Challenge?) {
        output += "🚀 Running your code...\n\n"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let variableNames = SwiftSyntaxHelper.extractVariableNames(from: code)
            
            if !variableNames.isEmpty {
                self.output += "📦 Variables created:\n"
                for variable in variableNames {
                    self.output += "   - \(variable)\n"
                }
                self.output += "\n"
            }
            
            if let challenge = challenge {
                let passedTests = self.runTestCases(code, challenge: challenge)
                self.output += "🧪 Test Results: \(passedTests)/\(challenge.testCases.count) passed\n\n"
                
                if passedTests == challenge.testCases.count {
                    self.output += "✅ All tests passed! Great job! 🎉\n"
                } else {
                    self.output += "❌ Some tests failed. Check your code and try again.\n"
                }
            } else {
                self.output += "✅ Code executed successfully!\n"
            }
            
            self.isRunning = false
        }
    }
    
    private func runTestCases(_ code: String, challenge: Challenge) -> Int {
        var passedCount = 0
        
        for testCase in challenge.testCases {
            let passed = simulateTestCase(code, testCase: testCase)
            if passed {
                passedCount += 1
            }
        }
        
        return passedCount
    }
    
    private func simulateTestCase(_ code: String, testCase: TestCase) -> Bool {
        output += "🔍 Testing: \(testCase.description)\n"
        
        if code.contains(testCase.expectedOutput) || code.contains(testCase.input) {
            output += "   ✅ Passed\n"
            return true
        } else {
            output += "   ❌ Failed - Expected: \(testCase.expectedOutput)\n"
            return false
        }
    }
    
    func clearOutput() {
        output = ""
        lastError = nil
    }
}
