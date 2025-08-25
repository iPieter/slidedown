import SwiftUI
import AppKit

struct EditorView: View {
    @Binding var markdownDocument: String
    var selectedSlideIndex: Int
    var slides: [String]
    
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
            // Text editor with styled markdown
            StyledTextEditor(text: $markdownDocument)
                .font(.system(size: 15, weight: .regular, design: .monospaced))
                .lineSpacing(6)
                .padding([.horizontal], 16)
                .padding(.vertical, 12)
                .background(Color(.textBackgroundColor))
                .id("markdownEditor")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct StyledTextEditor: NSViewRepresentable {
    @Binding var text: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        guard let textView = scrollView.documentView as? NSTextView else { return scrollView }
        
        textView.delegate = context.coordinator
        textView.isRichText = false
        textView.font = .monospacedSystemFont(ofSize: 15, weight: .regular)
        textView.backgroundColor = .clear
        textView.drawsBackground = true
        textView.isAutomaticQuoteSubstitutionEnabled = true
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = true
        textView.isAutomaticSpellingCorrectionEnabled = true
        
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        
        if textView.string != text {
            textView.string = text
        }
        
        applyStylesToTextView(textView)
    }
    
    private func applyStylesToTextView(_ textView: NSTextView) {
        let text = textView.string
        let storage = textView.textStorage!
        let fullRange = NSRange(location: 0, length: text.count)
        
        // Reset attributes
        storage.removeAttribute(.foregroundColor, range: fullRange)
        storage.removeAttribute(.backgroundColor, range: fullRange)
        storage.addAttribute(.foregroundColor, value: NSColor.textColor, range: fullRange)
        
        // Style headers
        let headerPattern = "^(#{1,6})\\s+(.+)$"
        if let regex = try? NSRegularExpression(pattern: headerPattern, options: .anchorsMatchLines) {
            regex.enumerateMatches(in: text, range: fullRange) { match, _, _ in
                guard let match = match else { return }
                let headerRange = match.range(at: 0)
                
                // Create pill background for headers with padding
                let pillColor = NSColor(Color.accentColor.opacity(0.15))
                let paragraphStyle = NSMutableParagraphStyle()
                //paragraphStyle.firstLineHeadIndent = 8  // Left padding
                //paragraphStyle.headIndent = 8          // Left padding for wrapped lines
                //paragraphStyle.tailIndent = -8         // Right padding
                
                storage.addAttribute(.backgroundColor, value: pillColor, range: headerRange)
                storage.addAttribute(.foregroundColor, value: NSColor(Color.accentColor), range: headerRange)
                storage.addAttribute(.paragraphStyle, value: paragraphStyle, range: headerRange)
                storage.addAttribute(.font, value: NSFont.monospacedSystemFont(ofSize: 15, weight: .semibold), range: headerRange)
            }
        }
        
        // Style image paths with subtle markdown syntax
        let imagePattern = "(!\\[)(.*?)(\\]\\()(.*?)(\\))"
        if let regex = try? NSRegularExpression(pattern: imagePattern, options: []) {
            regex.enumerateMatches(in: text, range: fullRange) { match, _, _ in
                guard let match = match else { return }
                
                let syntaxRanges = [
                    match.range(at: 1), // ![ part
                    match.range(at: 3), // ]( part
                    match.range(at: 5)  // ) part
                ]
                
                let altTextRange = match.range(at: 2) // The alt text
                let pathRange = match.range(at: 4)    // The URL/path
                
                // Style the markdown syntax to be subtle
                for range in syntaxRanges {
                    storage.addAttribute(.foregroundColor, value: NSColor.tertiaryLabelColor, range: range)
                }
                
                // Style the alt text normally
                storage.addAttribute(.foregroundColor, value: NSColor.secondaryLabelColor, range: altTextRange)
                
                // Create pill background for the path with padding
                let pillColor = NSColor(Color(.controlBackgroundColor))
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.firstLineHeadIndent = 4  // Left padding
                paragraphStyle.headIndent = 4          // Left padding for wrapped lines
                paragraphStyle.tailIndent = -4         // Right padding
                
                storage.addAttribute(.backgroundColor, value: pillColor, range: pathRange)
                storage.addAttribute(.foregroundColor, value: NSColor.secondaryLabelColor, range: pathRange)
                storage.addAttribute(.paragraphStyle, value: paragraphStyle, range: pathRange)
            }
        }
        
        // Style URLs with padding
        let urlPattern = "(\\[)(.*?)(\\]\\()(.*?)(\\))"
        if let regex = try? NSRegularExpression(pattern: urlPattern, options: []) {
            regex.enumerateMatches(in: text, range: fullRange) { match, _, _ in
                guard let match = match else { return }
                
                let syntaxRanges = [
                    match.range(at: 1), // [ part
                    match.range(at: 3), // ]( part
                    match.range(at: 5)  // ) part
                ]
                
                let textRange = match.range(at: 2) // The link text
                let urlRange = match.range(at: 4)  // The URL
                
                // Style the markdown syntax to be subtle
                for range in syntaxRanges {
                    storage.addAttribute(.foregroundColor, value: NSColor.tertiaryLabelColor, range: range)
                }
                
                // Style the link text
                storage.addAttribute(.foregroundColor, value: NSColor(Color.blue), range: textRange)
                
                // Create pill background for the URL with padding
                let pillColor = NSColor(Color(.controlBackgroundColor))
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.firstLineHeadIndent = 4  // Left padding
                paragraphStyle.headIndent = 4          // Left padding for wrapped lines
                paragraphStyle.tailIndent = -4         // Right padding
                
                storage.addAttribute(.backgroundColor, value: pillColor, range: urlRange)
                storage.addAttribute(.foregroundColor, value: NSColor.secondaryLabelColor, range: urlRange)
                storage.addAttribute(.paragraphStyle, value: paragraphStyle, range: urlRange)
            }
        }
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: StyledTextEditor
        
        init(_ parent: StyledTextEditor) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
            parent.applyStylesToTextView(textView)
        }
        
        func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
            // Allow the change
            return true
        }
    }
}

// Helper extension to find first responder
extension NSTextView {
    static func findFirstResponder() -> NSResponder? {
        guard let window = NSApplication.shared.mainWindow ?? NSApplication.shared.keyWindow else { 
            return nil 
        }
        return window.firstResponder
    }
} 