import SwiftUI

struct EditorView: View {
    @Binding var markdownDocument: String
    var selectedSlideIndex: Int
    var slides: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Editor toolbar
            HStack {
                Text("# \(selectedSlideIndex >= 0 && selectedSlideIndex < slides.count ? "Slide \(selectedSlideIndex + 1)" : "Editor")")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Add some common markdown formatting buttons
                ForEach(["bold", "italic", "list.bullet", "list.number"], id: \.self) { name in
                    Button {
                        // Insert markdown formatting based on button
                        insertMarkdownFormatting(type: name)
                    } label: {
                        Image(systemName: name)
                            .font(.system(size: 14))
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.secondary.opacity(0.05))
            
            Divider()
            
            // Editor with monospaced font
            TextEditor(text: $markdownDocument)
                .font(.system(size: 14, weight: .regular, design: .monospaced))
                .padding()
                .background(Color.clear)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func insertMarkdownFormatting(type: String) {
        // Get the NSTextView from the SwiftUI TextEditor
        let textView = NSTextView.findFirstResponder() as? NSTextView
        
        guard let selectedRange = textView?.selectedRanges.first?.rangeValue else {
            return
        }
        
        let selectedText = (markdownDocument as NSString).substring(with: selectedRange)
        var formattedText = ""
        
        switch type {
        case "bold":
            formattedText = "**\(selectedText)**"
        case "italic":
            formattedText = "*\(selectedText)*"
        case "list.bullet":
            let lines = selectedText.components(separatedBy: .newlines)
            formattedText = lines.map { "- \($0)" }.joined(separator: "\n")
        case "list.number":
            let lines = selectedText.components(separatedBy: .newlines)
            formattedText = lines.enumerated().map { "1. \($0.element)" }.joined(separator: "\n")
        default:
            return
        }
        
        if let textView = textView {
            textView.insertText(formattedText, replacementRange: selectedRange)
        }
    }
}

// Helper extension to find first responder
extension NSTextView {
    static func findFirstResponder() -> NSResponder? {
        guard let window = NSApplication.shared.mainWindow else { return nil }
        return window.firstResponder
    }
} 