import SwiftUI

struct EditorView: View {
    @Binding var markdownDocument: String
    var selectedSlideIndex: Int
    var slides: [String]
    @State private var selectedTextRange: NSRange?
    
    var slideTitle: String {
        if selectedSlideIndex >= 0 && selectedSlideIndex < slides.count,
           let title = slides[selectedSlideIndex].firstMarkdownHeading(level: 1) {
            return title
        } else {
            return "Slide \(selectedSlideIndex + 1)"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Editor toolbar with native macOS styling
            HStack(spacing: 8) {
                // Slide title with better styling
                HStack(spacing: 2) {
                    Text("\(selectedSlideIndex + 1)")
                        .font(.system(size: 12, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(.controlBackgroundColor))
                        .cornerRadius(3)
                    
                    Text(slideTitle)
                        .font(.headline)
                        .lineLimit(1)
                }
                .padding(.leading, 4)
                
                Spacer()
                
                // Text formatting toolbar
                Group {
                    Button(action: { insertMarkdownFormatting(type: "header") }) {
                        Image(systemName: "textformat.size")
                    }
                    .buttonStyle(.borderless)
                    .help("Heading")
                    
                    Button(action: { insertMarkdownFormatting(type: "bold") }) {
                        Image(systemName: "bold")
                    }
                    .buttonStyle(.borderless)
                    .help("Bold")
                    
                    Button(action: { insertMarkdownFormatting(type: "italic") }) {
                        Image(systemName: "italic")
                    }
                    .buttonStyle(.borderless)
                    .help("Italic")
                    
                    Divider()
                        .frame(height: 16)
                    
                    Button(action: { insertMarkdownFormatting(type: "list.bullet") }) {
                        Image(systemName: "list.bullet")
                    }
                    .buttonStyle(.borderless)
                    .help("Bullet List")
                    
                    Button(action: { insertMarkdownFormatting(type: "list.number") }) {
                        Image(systemName: "list.number")
                    }
                    .buttonStyle(.borderless)
                    .help("Numbered List")
                    
                    Divider()
                        .frame(height: 16)
                    
                    Button(action: { insertMarkdownFormatting(type: "link") }) {
                        Image(systemName: "link")
                    }
                    .buttonStyle(.borderless)
                    .help("Insert Link")
                    
                    Button(action: { insertMarkdownFormatting(type: "image") }) {
                        Image(systemName: "photo")
                    }
                    .buttonStyle(.borderless)
                    .help("Insert Image")
                }
                .font(.system(size: 14))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.windowBackgroundColor))
            
            Divider()
            
            // Text editor with monospaced font
            ZStack(alignment: .topLeading) {
                TextEditor(text: $markdownDocument)
                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                    .lineSpacing(4)
                    .padding([.horizontal, .bottom], 12)
                    .padding(.top, 12)
                    .background(Color(.textBackgroundColor))
                    .onReceive(NotificationCenter.default.publisher(for: NSTextView.didChangeSelectionNotification)) { _ in
                        if let textView = NSTextView.findFirstResponder() as? NSTextView {
                            selectedTextRange = textView.selectedRanges.first?.rangeValue
                        }
                    }
            }
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
        var newSelectedRange: NSRange?
        
        switch type {
        case "header":
            formattedText = "# \(selectedText)"
        case "bold":
            formattedText = "**\(selectedText)**"
            if selectedText.isEmpty {
                newSelectedRange = NSRange(location: selectedRange.location + 2, length: 0)
            }
        case "italic":
            formattedText = "*\(selectedText)*"
            if selectedText.isEmpty {
                newSelectedRange = NSRange(location: selectedRange.location + 1, length: 0)
            }
        case "list.bullet":
            let lines = selectedText.components(separatedBy: .newlines)
            formattedText = lines.map { "- \($0)" }.joined(separator: "\n")
        case "list.number":
            let lines = selectedText.components(separatedBy: .newlines)
            formattedText = lines.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n")
        case "link":
            if selectedText.isEmpty {
                formattedText = "[Link Text](https://example.com)"
                newSelectedRange = NSRange(location: selectedRange.location + 1, length: 9) // Select "Link Text"
            } else {
                formattedText = "[\(selectedText)](https://example.com)"
            }
        case "image":
            formattedText = "![Alt text](/assets/image.jpg)"
        default:
            return
        }
        
        if let textView = textView {
            textView.insertText(formattedText, replacementRange: selectedRange)
            
            // Position cursor inside formatting if needed
            if let newRange = newSelectedRange {
                textView.setSelectedRange(newRange)
            }
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