import SwiftUI
import Down

struct ContentView: View {
    @State private var markdownDocument: String = "# Welcome\n\nThis is my first slide\n\n___\n\n# Second Slide\n\nContent for the second slide.\n___\n# A giraffe!\n![Image](https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fstatic.vecteezy.com%2Fsystem%2Fresources%2Fpreviews%2F020%2F304%2F879%2Fnon_2x%2Fgiraffe-in-kruger-national-park-south-africa-giraffa-camelopardalis-family-of-giraffidae-portrait-photo.JPG&f=1&nofb=1&ipt=0759ac375ce03c7b58117ab735fb63a6d32eac57f6f515d62198a5182106e01c)"
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
