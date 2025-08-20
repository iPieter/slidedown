import SwiftUI
import Down

struct ContentView: View {
    @State private var markdownDocument: String = "# Welcome\n\nThis is my first slide\n\n___\n\n# Second Slide\n\nContent for the second slide."
    @State private var selectedSlideIndex: Int = 0
    @State private var selectedTheme: SlideTheme = .light
    @State private var isPresentationMode: Bool = false
    @State private var showThemeSelector: Bool = false
    @State private var appearance: AppAppearance = .dark
    @State private var selectedTitleFont: String = "SF Pro Text"
    @State private var selectedBodyFont: String = "Inter — Template Default"
    @State private var titleColor: Color = .black
    @State private var bodyColor: Color = .black
    @State private var backgroundColor: Color = .white
    
    // Add state variables to track disclosure group expansion states
    @State private var isFontsExpanded: Bool = true
    @State private var isThemeExpanded: Bool = false
    @State private var isColorsExpanded: Bool = false
    @State private var isAppearanceExpanded: Bool = false
    
    private let presentationManager = PresentationWindowManager()
    
    var slides: [String] {
        markdownDocument.splitIntoSlides()
    }
    
    var body: some View {
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
                slides: slides
            )
            .frame(minWidth: 240, maxWidth: 300)
            
            // Main editor area
            EditorView(
                markdownDocument: $markdownDocument,
                selectedSlideIndex: selectedSlideIndex,
                slides: slides
            )
        }
        // Create Mac-native toolbar
        .toolbar {
            // Play/Present Button
            ToolbarItem(placement: .primaryAction) {
                Button(action: { openPresentationWindow() }) {
                    Label("Present", systemImage: "play.fill")
                }
                .help("Start Presentation")
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button(action: { addNewSlide() }) {
                    Label("Add Slide", systemImage: "plus")
                }
                .help("Add new slide")
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button(action: { savePresentation() }) {
                    Label("Save", systemImage: "square.and.arrow.down")
                }
                .help("Save presentation")
            }
            
            // Format Group
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: { insertMarkdownFormatting(type: "bold") }) {
                    Image(systemName: "bold")
                }
                .help("Bold")
                
                Button(action: { insertMarkdownFormatting(type: "italic") }) {
                    Image(systemName: "italic")
                }
                .help("Italic")
                
                Button(action: { insertMarkdownFormatting(type: "list.bullet") }) {
                    Image(systemName: "list.bullet")
                }
                .help("Bullet List")
                
                Button(action: { insertMarkdownFormatting(type: "list.number") }) {
                    Image(systemName: "list.number")
                }
                .help("Numbered List")
            }
            
            // Theme Selector
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Picker("Theme", selection: $selectedTheme) {
                        ForEach(SlideTheme.allCases) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                } label: {
                    Label("Theme", systemImage: "paintbrush")
                }
            }
        }
    }
    
    // Helper methods
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
            formattedText = lines.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n")
        default:
            return
        }
        
        if let textView = textView {
            textView.insertText(formattedText, replacementRange: selectedRange)
        }
    }
    
    private func addNewSlide() {
        let newSlide = "\n\n___\n\n# New Slide\n\nAdd content here"
        markdownDocument += newSlide
        // Set the selection to the new slide
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            selectedSlideIndex = slides.count - 1
        }
    }
    
    private func savePresentation() {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.plainText]
        savePanel.nameFieldStringValue = "presentation.md"
        savePanel.title = "Save Presentation"
        savePanel.message = "Choose a location to save your presentation"
        savePanel.canCreateDirectories = true
        
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                do {
                    try markdownDocument.write(to: url, atomically: true, encoding: .utf8)
                } catch {
                    // Show error dialog in a real app
                    print("Failed to save: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func openPresentationWindow() {
        presentationManager.openPresentationWindow(
            slides: slides,
            selectedSlideIndex: selectedSlideIndex,
            selectedTheme: selectedTheme,
            titleFont: selectedTitleFont,
            bodyFont: selectedBodyFont,
            onClose: {
                // Handle any cleanup needed when the presentation window closes
            }
        )
    }
} 