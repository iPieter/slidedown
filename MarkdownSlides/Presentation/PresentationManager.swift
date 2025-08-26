import SwiftUI
import WebKit

// State manager class to handle external state changes
class PresentationStateManager: ObservableObject {
    @Published var currentSlideIndex: Int
    private let slideCount: Int
    var onSlideChange: ((Int) -> Void)?
    
    init(initialSlideIndex: Int, slideCount: Int) {
        self.currentSlideIndex = initialSlideIndex
        self.slideCount = slideCount
    }
    
    func nextSlide() {
        if currentSlideIndex < slideCount - 1 {
            currentSlideIndex += 1
            onSlideChange?(currentSlideIndex)
        }
    }
    
    func previousSlide() {
        if currentSlideIndex > 0 {
            currentSlideIndex -= 1
            onSlideChange?(currentSlideIndex)
        }
    }
}

// Updated presentation window view with improved controls
struct PresentationWindowView: View {
    let slides: [String]
    let theme: SlideTheme
    let onClose: () -> Void
    let titleFont: String?
    let bodyFont: String?
    // Add custom color support
    let titleColor: Color?
    let bodyColor: Color?
    let backgroundColor: Color?
    // Add footer support
    let showFooter: Bool
    let presentationTitle: String?
    let logoImage: NSImage?
    
    @ObservedObject var stateManager: PresentationStateManager
    @State private var showControls: Bool = false
    
    // Update init to accept fonts and colors
    init(slides: [String], 
         theme: SlideTheme, 
         onClose: @escaping () -> Void, 
         stateManager: PresentationStateManager,
         titleFont: String? = nil,
         bodyFont: String? = nil,
         titleColor: Color? = nil,
         bodyColor: Color? = nil,
         backgroundColor: Color? = nil,
         showFooter: Bool = false,
         presentationTitle: String? = nil,
         logoImage: NSImage? = nil) {
        self.slides = slides
        self.theme = theme
        self.onClose = onClose
        self.stateManager = stateManager
        self.titleFont = titleFont
        self.bodyFont = bodyFont
        self.titleColor = titleColor
        self.bodyColor = bodyColor
        self.backgroundColor = backgroundColor
        self.showFooter = showFooter
        self.presentationTitle = presentationTitle
        self.logoImage = logoImage
    }
    
    var body: some View {
        ZStack {
            // Pass selected fonts and colors to SlideRenderView
            SlideRenderView(
                content: slides.indices.contains(stateManager.currentSlideIndex) ? slides[stateManager.currentSlideIndex] : "",
                theme: theme,
                showDecorations: false,
                titleFont: titleFont,
                bodyFont: bodyFont,
                titleColor: titleColor,
                bodyColor: bodyColor,
                backgroundColor: backgroundColor,
                slideNumber: stateManager.currentSlideIndex + 1,
                totalSlides: slides.count,
                presentationTitle: presentationTitle,
                logoImage: logoImage,
                showFooter: showFooter
            )
            
            // Navigation controls (only shown when hovering)
            if showControls {
                VStack {
                    Spacer()
                    
                    HStack {
                        Button(action: { stateManager.previousSlide() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        // Slide counter
                        Text("\(stateManager.currentSlideIndex + 1) / \(slides.count)")
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(16)
                        
                        Spacer()
                        
                        Button(action: { stateManager.nextSlide() }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor != nil ? AnyView(backgroundColor!) : theme.backgroundView)
        .onAppear {
            stateManager.onSlideChange?(stateManager.currentSlideIndex)
        }
        .onDisappear { 
            onClose() 
        }
        .onTapGesture { stateManager.nextSlide() }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                showControls = hovering
            }
        }
    }
}

// A class to manage presentation windows
class PresentationWindowManager {
    private var presentationWindow: NSWindow?
    private var windowController: NSWindowController?
    private var stateManager: PresentationStateManager?
    
    func openPresentationWindow(
        slides: [String],
        selectedSlideIndex: Int,
        selectedTheme: SlideTheme,
        titleFont: String? = nil,
        bodyFont: String? = nil,
        titleColor: Color? = nil,
        bodyColor: Color? = nil,
        backgroundColor: Color? = nil,
        showFooter: Bool = false,
        presentationTitle: String? = nil,
        logoImage: NSImage? = nil,
        onClose: @escaping () -> Void
    ) {
        // Create window with 16:9 aspect ratio
        let width: CGFloat = 1280
        let height: CGFloat = width * 9/16  // Maintain 16:9 aspect ratio
        
        let presentationWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: [.titled, .closable, .resizable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        presentationWindow.center()
        presentationWindow.title = "Slide Presentation"
        presentationWindow.isReleasedWhenClosed = false
        presentationWindow.titlebarAppearsTransparent = true
        
        // Optional: make the title only visible on hover
        let windowController = NSWindowController(window: presentationWindow)
        windowController.windowFrameAutosaveName = "PresentationWindow"
        
        // Create a StateManager to handle state changes from outside SwiftUI
        let stateManager = PresentationStateManager(
            initialSlideIndex: selectedSlideIndex,
            slideCount: slides.count
        )
        
        // Configure the presentation content
        let presentationView = PresentationWindowView(
            slides: slides,
            theme: selectedTheme,
            onClose: onClose,
            stateManager: stateManager,
            titleFont: titleFont,
            bodyFont: bodyFont,
            titleColor: titleColor,
            bodyColor: bodyColor,
            backgroundColor: backgroundColor,
            showFooter: showFooter,
            presentationTitle: presentationTitle,
            logoImage: logoImage
        )
        
        // Set up the window to maintain aspect ratio
        let hostingView = NSHostingView(rootView: presentationView)
        presentationWindow.contentView = hostingView
        presentationWindow.contentAspectRatio = NSSize(width: 16, height: 9)
        
        // Add window close notification handler
        NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: presentationWindow, queue: nil) { _ in
            onClose()
        }
        
        // Add global key monitor
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard presentationWindow.isKeyWindow else { return event }
            
            // Check if the first responder is a WebView or its subviews
            if let firstResponder = presentationWindow.firstResponder {
                // If the first responder is a WebView or contains a WebView, don't capture navigation keys
                if self.isWebViewOrContainsWebView(firstResponder) {
                    // Only capture Escape key for WebViews
                    switch event.keyCode {
                    case 53: // Escape key
                        presentationWindow.close()
                        onClose()
                        return nil
                    default:
                        return event // Allow all other keys to pass through to WebView
                    }
                }
            }
            
            // For non-WebView content, capture navigation keys as usual
            switch event.keyCode {
            case 53: // Escape key
                presentationWindow.close()
                onClose()
                return nil
            case 123: // Left arrow
                stateManager.previousSlide()
                return nil
            case 124: // Right arrow
                stateManager.nextSlide()
                return nil
            case 49: // Space bar
                stateManager.nextSlide()
                return nil
            default:
                return event
            }
        }
        
        // Add mouse tracking for title bar visibility
        NotificationCenter.default.addObserver(forName: NSWindow.didBecomeKeyNotification, object: presentationWindow, queue: nil) { _ in
            // Update window title to include slide info when the window becomes key
            presentationWindow.title = "Slide \(stateManager.currentSlideIndex + 1) of \(slides.count)"
        }
        
        // Update title when slide changes
        stateManager.onSlideChange = { index in
            presentationWindow.title = "Slide \(index + 1) of \(slides.count)"
            
            // Get the title from the slide content if possible
            if slides.indices.contains(index) {
                if let slideTitle = slides[index].firstMarkdownHeading(level: 1) {
                    presentationWindow.title = "\(slideTitle) (\(index + 1)/\(slides.count))"
                }
            }
        }
        
        presentationWindow.makeKeyAndOrderFront(nil)
        
        // Store references
        self.presentationWindow = presentationWindow
        self.windowController = windowController
        self.stateManager = stateManager
    }
    
    func closePresentationWindow() {
        presentationWindow?.close()
        presentationWindow = nil
        windowController = nil
        stateManager = nil
    }
    
    // Helper function to check if a view is a WebView or contains a WebView
    private func isWebViewOrContainsWebView(_ view: NSResponder) -> Bool {
        // Check if the view itself is a WKWebView
        if view is WKWebView {
            return true
        }
        
        // Check if the view is a NSView and contains WKWebView subviews
        if let nsView = view as? NSView {
            return containsWebView(nsView)
        }
        
        return false
    }
    
    // Recursive function to check if a view contains a WebView
    private func containsWebView(_ view: NSView) -> Bool {
        // Check if this view is a WKWebView
        if view is WKWebView {
            return true
        }
        
        // Recursively check subviews
        for subview in view.subviews {
            if containsWebView(subview) {
                return true
            }
        }
        
        return false
    }
} 
