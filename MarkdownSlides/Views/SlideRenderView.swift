import SwiftUI
import Down
import Foundation

// Slide rendering view used for both preview and presentation
struct SlideRenderView: View {
    let content: String
    let theme: SlideTheme
    static let baseWidth: CGFloat = 490
    static let baseHeight: CGFloat = 270
    let showDecorations: Bool
    var titleFont: String = "SF Pro Display"  // Default font
    var bodyFont: String = "SF Pro Text"  // Default font
    
    // Add custom color support
    var customTitleColor: Color?
    var customBodyColor: Color?
    var customBackgroundColor: Color?
    
    // Computed properties to determine which colors to use
    private var effectiveTitleColor: Color {
        customTitleColor ?? theme.titleColor
    }
    
    private var effectiveBodyColor: Color {
        customBodyColor ?? theme.foregroundColor
    }
    
    private var effectiveBackgroundView: some View {
        if let customBg = customBackgroundColor {
            return AnyView(customBg)
        } else {
            return theme.backgroundView
        }
    }
    
    init(content: String, theme: SlideTheme, showDecorations: Bool = true, titleFont: String? = nil, bodyFont: String? = nil, titleColor: Color? = nil, bodyColor: Color? = nil, backgroundColor: Color? = nil) {
        self.content = content
        self.theme = theme
        self.showDecorations = showDecorations
        if let titleFont = titleFont {
            self.titleFont = titleFont
        }
        if let bodyFont = bodyFont {
            self.bodyFont = bodyFont
        }
        self.customTitleColor = titleColor
        self.customBodyColor = bodyColor
        self.customBackgroundColor = backgroundColor
    }
    
    var body: some View {
        GeometryReader { geo in
            let scale = min(geo.size.width / Self.baseWidth, geo.size.height / Self.baseHeight)
            
            ZStack {
                // Use effective background
                effectiveBackgroundView
                
                VStack(alignment: .leading, spacing: 0) {
                    // Title section
                    if let title = content.firstMarkdownHeading(level: 1) {
                        Text(title)
                            .font(Font.custom(titleFont, size: 36, relativeTo: .title).weight(theme.titleFontWeight))
                            .foregroundColor(effectiveTitleColor)
                            .lineSpacing(8)
                            .tracking(-0.5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 24)
                            .padding(.top, 40)
                            .padding(.horizontal, 40)
                    }
                    
                    // Body content with proper scrolling behavior
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            // Exclude the title from the content
                            let bodyContent = removeFirstHeading(from: content)
                            
                            // Render text content using Down
                            if let attributedString = try? Down(markdownString: bodyContent).toAttributedString([.hardBreaks]) {
                                // Process the attributed string to apply custom styling
                                let styledText = applyCustomStyling(to: attributedString)
                                
                                // Render text content
                                Text(AttributedString(styledText))
                                    .font(Font.custom(bodyFont.replacingOccurrences(of: " — Template Default", with: ""), 
                                                     size: 24, relativeTo: .body))
                                    .foregroundColor(effectiveBodyColor)
                                    .lineSpacing(8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .textSelection(.enabled)
                            } else {
                                Text("Error rendering slide")
                                    .foregroundColor(.red)
                            }
                            
                            // Render images separately
                            ImageContentView(markdown: bodyContent)
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                    }
                    .scrollIndicators(showDecorations ? .visible : .hidden)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(width: Self.baseWidth, height: Self.baseHeight)
            .clipShape(RoundedRectangle(cornerRadius: showDecorations ? 8 : 0))
            .overlay(
                showDecorations ? 
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(theme.accentColor.opacity(0.3), lineWidth: 1) : nil
            )
            .shadow(
                color: showDecorations ? (theme == .dark || theme == .newYork ? .black.opacity(0.3) : .black.opacity(0.1)) : .clear, 
                radius: showDecorations ? 5 : 0,
                x: 0, 
                y: showDecorations ? 2 : 0
            )
            .scaleEffect(scale)
            .frame(width: geo.size.width, height: geo.size.height)
            .animation(.easeInOut(duration: 0.2), value: showDecorations)
        }
        .aspectRatio(16/9, contentMode: .fit)
    }
    
    // Helper to remove first heading
    private func removeFirstHeading(from markdown: String) -> String {
        let lines = markdown.components(separatedBy: .newlines)
        var foundFirstHeading = false
        
        return lines.filter { line in
            if !foundFirstHeading && line.hasPrefix("# ") {
                foundFirstHeading = true
                return false // Skip the heading
            }
            return true
        }.joined(separator: "\n")
    }
    
    // Apply custom styling to the Down-generated attributed string
    private func applyCustomStyling(to attributedString: NSAttributedString) -> NSAttributedString {
        let mutableAttrString = NSMutableAttributedString(attributedString: attributedString)
        
        // Define the full range of the string
        let fullRange = NSRange(location: 0, length: mutableAttrString.length)
        
        // Process headings to match the app's style
        mutableAttrString.enumerateAttribute(.font, in: fullRange, options: []) { value, range, _ in
            if let font = value as? NSFont {
                if font.fontDescriptor.symbolicTraits.contains(.bold) {
                    // This is likely a heading or bold text
                    if range.length > 10 || range.location == 0 {
                        // Likely a heading, make it bigger and apply theme styling
                        let newFont = NSFont(name: titleFont, size: font.pointSize * 1.2) ?? font
                        mutableAttrString.addAttribute(.font, value: newFont, range: range)
                        mutableAttrString.addAttribute(.foregroundColor, value: NSColor(effectiveTitleColor), range: range)
                    }
                }
            }
        }
        
        return mutableAttrString
    }
}

// Dedicated view for rendering images from markdown
struct ImageContentView: View {
    let markdown: String
    
    var body: some View {
        let images = extractImagesFromMarkdown(markdown)
        
        VStack(alignment: .leading, spacing: 20) {
            ForEach(images.indices, id: \.self) { index in
                let imageInfo = images[index]
                
                VStack(alignment: .center, spacing: 8) {
                    // Try to load image from URL first
                    if let url = URL(string: imageInfo.url), let nsImage = NSImage(contentsOf: url) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 180)
                            .accessibility(label: Text(imageInfo.alt))
                    } else {
                        // Fallback to bundled image
                        Image(imageInfo.url)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 180)
                            .accessibility(label: Text(imageInfo.alt))
                    }
                    
                    // Optional caption for the image
                    if !imageInfo.alt.isEmpty {
                        Text(imageInfo.alt)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
        }
    }
    
    // Helper to extract image information from markdown
    private func extractImagesFromMarkdown(_ markdown: String) -> [(alt: String, url: String)] {
        var images: [(alt: String, url: String)] = []
        
        // Regex to match standard Markdown image syntax: ![alt text](url)
        let imagePattern = "!\\[(.*?)\\]\\((.*?)\\)"
        
        if let regex = try? NSRegularExpression(pattern: imagePattern, options: []) {
            let nsString = NSString(string: markdown)
            let matches = regex.matches(in: markdown, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for match in matches {
                if match.numberOfRanges >= 3 {
                    let altRange = match.range(at: 1)
                    let urlRange = match.range(at: 2)
                    
                    let alt = nsString.substring(with: altRange)
                    let url = nsString.substring(with: urlRange)
                    
                    images.append((alt: alt, url: url))
                }
            }
        }
        
        return images
    }
}

// Sidebar preview with improved styling
struct SlidePreviewView: View {
    let content: String
    let theme: SlideTheme
    var titleFont: String?
    var bodyFont: String?
    var titleColor: Color?
    var bodyColor: Color?
    var backgroundColor: Color?
    
    var body: some View {
        SlideRenderView(
            content: content, 
            theme: theme, 
            titleFont: titleFont, 
            bodyFont: bodyFont,
            titleColor: titleColor,
            bodyColor: bodyColor,
            backgroundColor: backgroundColor
        )
        .frame(height: 90)
    }
}

// Legacy slide view (for backward compatibility)
struct SlideView: View {
    let content: String
    
    var body: some View {
        ZStack {
            Color.white
            if let attributedString = try? Down(markdownString: content).toAttributedString() {
                ScrollView {
                    Text(AttributedString(attributedString))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .textSelection(.enabled)
                }
            } else {
                Text("Error rendering slide")
                    .foregroundColor(.red)
            }
        }
        .cornerRadius(8)
        .shadow(radius: 4)
    }
} 
