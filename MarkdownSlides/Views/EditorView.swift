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
            // Text editor with monospaced font
            TextEditor(text: $markdownDocument)
                .font(.system(size: 14, weight: .regular, design: .monospaced))
                .lineSpacing(4)
                .padding([.horizontal, .bottom], 12)
                .padding(.top, 12)
                .background(Color(.textBackgroundColor))
                .id("markdownEditor") // Add an ID to ensure TextEditor is properly refreshed
                .background(NSTextViewBridgeRepresentable(text: $markdownDocument))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// This is a bridge to help us interact with the NSTextView when it's created
struct NSTextViewBridgeRepresentable: NSViewRepresentable {
    @Binding var text: String
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.isHidden = true
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        // When this view is created or updated, attempt to properly configure the NSTextView
        DispatchQueue.main.async {
            if let scrollView = nsView.superview?.superview?.superview as? NSScrollView,
               let textView = scrollView.documentView as? NSTextView {
                
                // Make sure the text view has the correct string - ensures syncing
                if textView.string != text {
                    textView.string = text
                }
                
                // Optional - register for notifications to better track selection
                NotificationCenter.default.addObserver(
                    forName: NSTextView.didChangeSelectionNotification,
                    object: textView,
                    queue: .main
                ) { _ in
                    // This could be used to trigger actions on selection change
                    print("Selection changed in NSTextView")
                }
            }
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