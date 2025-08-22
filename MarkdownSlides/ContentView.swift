import SwiftUI
import Down

struct ContentView: View {
    @State private var markdownDocument: String = "# Welcome\n## This is my first slide\n\n___\n\n# Second Slide\n\nContent for the second slide.\n___\n# A giraffe!\n![Image](https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fstatic.vecteezy.com%2Fsystem%2Fresources%2Fpreviews%2F020%2F304%2F879%2Fnon_2x%2Fgiraffe-in-kruger-national-park-south-africa-giraffa-camelopardalis-family-of-giraffidae-portrait-photo.JPG&f=1&nofb=1&ipt=0759ac375ce03c7b58117ab735fb63a6d32eac57f6f515d62198a5182106e01c)"
    @State private var selectedSlideIndex: Int = 0
    @State private var selectedTheme: SlideTheme = .light
    @State private var isPresentationMode: Bool = false
    @State private var showThemeSettings: Bool = false
    @State private var appearance: AppAppearance = .dark
    @State private var selectedTitleFont: String = "SF Pro Display"
    @State private var selectedBodyFont: String = "SF Pro Text"
    @State private var titleColor: Color = .black
    @State private var bodyColor: Color = .black
    @State private var backgroundColor: Color = .white
    @State private var showFooter: Bool = false
    @State private var presentationTitle: String = ""
    @State private var logoImage: NSImage?
    
    // State variables for disclosure groups
    @State private var isFontsExpanded: Bool = true
    @State private var isThemeExpanded: Bool = false
    @State private var isColorsExpanded: Bool = false
    @State private var isAppearanceExpanded: Bool = false
    
    // For theme popover positioning
    @State private var themeButtonFrame: CGRect = .zero
    
    // Extracted selectedTextRange from EditorView
    @State private var selectedTextRange: NSRange?
    
    private let presentationManager = PresentationWindowManager()
    
    var slides: [String] {
        markdownDocument.splitIntoSlides()
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Main content
            HSplitView {
                // Left sidebar
                SidebarView(
                    markdownDocument: $markdownDocument,
                    selectedSlideIndex: $selectedSlideIndex,
                    selectedTheme: $selectedTheme,
                    isFontsExpanded: $isFontsExpanded,
                    isThemeExpanded: $isThemeExpanded,
                    isColorsExpanded: $isColorsExpanded,
                    isAppearanceExpanded: $isAppearanceExpanded,
                    selectedTitleFont: $selectedTitleFont,
                    selectedBodyFont: $selectedBodyFont,
                    titleColor: $titleColor,
                    bodyColor: $bodyColor,
                    backgroundColor: $backgroundColor,
                    appearance: $appearance,
                    showFooter: $showFooter,
                    presentationTitle: $presentationTitle,
                    logoImage: $logoImage,
                    slides: slides
                )
                .frame(minWidth: 200, idealWidth: 240, maxWidth: 280)
                
                // Main editor area with preview
                VStack(spacing: 0) {
                    // Editor
                    EditorView(
                        markdownDocument: $markdownDocument,
                        selectedSlideIndex: selectedSlideIndex,
                        slides: slides
                    )
                }
            }
            
            // Theme settings popdown overlay - with better alignment and native styling
            if showThemeSettings {
                VStack(alignment: .leading, spacing: 0) {
                    // Header with close button
                    HStack {
                        Text("Theme Settings")
                            .font(.system(size: 13, weight: .medium))
                        
                        Spacer()
                        
                        Button {
                            withAnimation(.easeOut(duration: 0.15)) {
                                showThemeSettings = false
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 12)
                    .padding(.horizontal, 12)
                    
                    Divider()
                        .padding(.top, 8)
                    
                    // Theme settings content with better padding
                    ScrollView {
                        ThemeSettingsView(
                            selectedTheme: $selectedTheme,
                            isFontsExpanded: $isFontsExpanded,
                            isThemeExpanded: $isThemeExpanded,
                            isColorsExpanded: $isColorsExpanded,
                            isAppearanceExpanded: $isAppearanceExpanded,
                            selectedTitleFont: $selectedTitleFont,
                            selectedBodyFont: $selectedBodyFont,
                            titleColor: $titleColor,
                            bodyColor: $bodyColor,
                            backgroundColor: $backgroundColor,
                            appearance: $appearance,
                            showFooter: $showFooter,
                            presentationTitle: $presentationTitle,
                            logoImage: $logoImage
                        )
                        .padding(.top, 8)
                    }
                    .padding([.horizontal, .bottom], 12)
                }
                .frame(width: 280)
                .background(
                    // More native-looking background
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.windowBackgroundColor))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.separatorColor), lineWidth: 0.5)
                        )
                )
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                .offset(x: -12, y: 40) // Better alignment with toolbar button
                .transition(.opacity.combined(with: .move(edge: .top)))
                .zIndex(100)
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    addNewSlide()
                } label: {
                    Label("Add Slide", systemImage: "plus.square")
                }
            }
            
            ToolbarItemGroup(placement: .automatic) {
                Button {
                    if selectedSlideIndex > 0 {
                        selectedSlideIndex -= 1
                    }
                } label: {
                    Label("Previous Slide", systemImage: "chevron.up")
                }
                .disabled(selectedSlideIndex <= 0)
                
                Button {
                    if selectedSlideIndex < slides.count - 1 {
                        selectedSlideIndex += 1
                    }
                } label: {
                    Label("Next Slide", systemImage: "chevron.down")
                }
                .disabled(selectedSlideIndex >= slides.count - 1)
            }
            
            // Add text formatting toolbar group with improved styling
            ToolbarItemGroup(placement: .automatic) {
                Group {
                    Button {
                        performAfterDelay { insertMarkdownFormatting(type: "header") }
                    } label: {
                        Image(systemName: "textformat.size")
                            .frame(width: 20, height: 20)
                    }
                    .help("Heading")
                    
                    Button {
                        performAfterDelay { insertMarkdownFormatting(type: "bold") }
                    } label: {
                        Image(systemName: "bold")
                            .frame(width: 20, height: 20)
                    }
                    .help("Bold")
                    
                    Button {
                        performAfterDelay { insertMarkdownFormatting(type: "italic") }
                    } label: {
                        Image(systemName: "italic")
                            .frame(width: 20, height: 20)
                    }
                    .help("Italic")
                }
                .buttonStyle(.bordered)
                
                Divider()
                
                Group {
                    Button {
                        performAfterDelay { insertMarkdownFormatting(type: "list.bullet") }
                    } label: {
                        Image(systemName: "list.bullet")
                            .frame(width: 20, height: 20)
                    }
                    .help("Bullet List")
                    
                    Button {
                        performAfterDelay { insertMarkdownFormatting(type: "list.number") }
                    } label: {
                        Image(systemName: "list.number")
                            .frame(width: 20, height: 20)
                    }
                    .help("Numbered List")
                }
                .buttonStyle(.bordered)
                
                Divider()
                
                Group {
                    Button {
                        performAfterDelay { insertMarkdownFormatting(type: "link") }
                    } label: {
                        Image(systemName: "link")
                            .frame(width: 20, height: 20)
                    }
                    .help("Insert Link")
                    
                    Button {
                        performAfterDelay { insertMarkdownFormatting(type: "image") }
                    } label: {
                        Image(systemName: "photo")
                            .frame(width: 20, height: 20)
                    }
                    .help("Insert Image")
                }
                .buttonStyle(.bordered)
            }
            
            // Theme settings button in toolbar
            ToolbarItem(placement: .automatic) {
                Button {
                    // Faster animation
                    withAnimation(.easeOut(duration: 0.15)) {
                        showThemeSettings.toggle()
                    }
                } label: {
                    Label("Theme", systemImage: "paintbrush")
                }
                .help("Theme Settings")
                .foregroundColor(showThemeSettings ? .accentColor : .primary)
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button {
                    openPresentationWindow()
                } label: {
                    Label(isPresentationMode ? "End Presentation" : "Start Presentation", systemImage: isPresentationMode ? "xmark.rectangle" : "play.rectangle")
                }
            }
        }
        .onAppear {
            // Setup notification observer for text selection
            NotificationCenter.default.addObserver(
                forName: NSTextView.didChangeSelectionNotification,
                object: nil,
                queue: .main
            ) { notification in
                if let textView = notification.object as? NSTextView {
                    selectedTextRange = textView.selectedRanges.first?.rangeValue
                }
            }
        }
        .onDisappear {
            // Remove notification observer when view disappears
            NotificationCenter.default.removeObserver(
                self,
                name: NSTextView.didChangeSelectionNotification,
                object: nil
            )
        }
    }
    
    // Helper method to ensure formatting is applied after button action completes
    private func performAfterDelay(_ action: @escaping () -> Void) {
        // A tiny delay to ensure the button action completes and focus is maintained
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            action()
        }
    }
    
    // Helper methods
    private func insertMarkdownFormatting(type: String) {
        print("Attempting to format text with type: \(type)")
        
        // Directly try to find the NSTextView backing our TextEditor
        guard let textView = findTextViewInWindow() else {
            print("Could not find text view")
            return
        }
        
        // Get the selected range and text
        guard let selectedRange = textView.selectedRanges.first?.rangeValue else {
            print("No selected range found")
            return
        }
        
        // Get the selected text and prepare the formatted version
        let selectedText = (textView.string as NSString).substring(with: selectedRange)
        print("Selected text: '\(selectedText)'")
        
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
        
        print("Formatted text: '\(formattedText)'")
        
        // This is the key part - we need to:
        // 1. Insert the formatted text into the NSTextView directly
        textView.insertText(formattedText, replacementRange: selectedRange)
        
        // 2. Position cursor inside formatting if needed
        if let newRange = newSelectedRange {
            textView.setSelectedRange(newRange)
        }
        
        // 3. Force update the binding to ensure the UI reflects the change
        if let updatedString = textView.string as String? {
            DispatchQueue.main.async {
                self.markdownDocument = updatedString
            }
        }
    }
    
    private func findActiveTextView() -> NSTextView? {
        // First attempt: try to get the text view that's the first responder
        if let textView = NSTextView.findFirstResponder() as? NSTextView {
            return textView
        }
        
        // Second attempt: find all text views in the window hierarchy
        return findTextViewInWindow()
    }
    
    private func findTextViewInWindow() -> NSTextView? {
        guard let window = NSApplication.shared.keyWindow ?? NSApplication.shared.mainWindow else {
            return nil
        }
        
        // Find all NSTextViews in the window
        let textViews = window.contentView?.findSubviews(ofType: NSTextView.self) ?? []
        
        if textViews.isEmpty {
            print("No NSTextViews found in window hierarchy")
            return nil
        }
        
        // Debugging info
        print("Found \(textViews.count) NSTextViews in window")
        
        // Try to find the specific NSTextView that's editing our markdown document
        for textView in textViews {
            // Check if this text view contains our markdown
            if textView.string.contains(markdownDocument.prefix(50)) {
                return textView
            }
        }
        
        // If we can't find an exact match, return the first one
        return textViews.first
    }
    
    private func addNewSlide() {
        let newSlide = "\n\n___\n\n# New Slide\n\nAdd content here"
        markdownDocument += newSlide
        // Set the selection to the new slide
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            selectedSlideIndex = slides.count - 1
        }
    }
    
    private func openPresentationWindow() {
        isPresentationMode.toggle()
        
        if isPresentationMode {
            presentationManager.openPresentationWindow(
                slides: slides,
                selectedSlideIndex: selectedSlideIndex,
                selectedTheme: selectedTheme,
                titleFont: selectedTitleFont,
                bodyFont: selectedBodyFont,
                titleColor: titleColor,
                bodyColor: bodyColor,
                backgroundColor: backgroundColor,
                showFooter: showFooter,
                presentationTitle: presentationTitle,
                logoImage: logoImage,
                onClose: {
                    isPresentationMode = false
                }
            )
        } else {
            presentationManager.closePresentationWindow()
        }
    }
}

// Extension to find subviews of specific type
extension NSView {
    func findSubviews<T: NSView>(ofType type: T.Type) -> [T] {
        var result = [T]()
        
        for subview in subviews {
            if let typedSubview = subview as? T {
                result.append(typedSubview)
            }
            
            result.append(contentsOf: subview.findSubviews(ofType: type))
        }
        
        return result
    }
} 
