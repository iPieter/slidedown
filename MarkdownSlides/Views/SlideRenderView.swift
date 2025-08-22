import SwiftUI
import Down
import Foundation

// Define slide layout presets
enum SlideLayout {
    case standard      // Default layout with title and content
    case titleOnly     // Only title, centered vertically
    case titleSubtitle // Title and subtitle only, centered
    case singleImage   // One centered image with optional caption
    case doubleImage   // Two images side by side
    case gridImages    // Multiple images in a grid
    case quote         // Centered quote with attribution
}

// Slide rendering view used for both preview and presentation
struct SlideRenderView: View {
    let content: String
    let theme: SlideTheme
    static let baseWidth: CGFloat = 1920  // Updated to 1080p resolution
    static let baseHeight: CGFloat = 1080  // Updated to 1080p resolution
    let showDecorations: Bool
    var titleFont: String = "SF Pro Display"  // Default font
    var bodyFont: String = "SF Pro Text"  // Default font
    
    // Add custom color support
    var customTitleColor: Color?
    var customBodyColor: Color?
    var customBackgroundColor: Color?
    
    // Add footer elements
    var slideNumber: Int?
    var totalSlides: Int?
    var presentationTitle: String?
    var logoImage: NSImage?
    var showFooter: Bool = false
    
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
    
    // Use theme-specific logo if not explicitly provided
    private var effectiveLogoImage: NSImage? {
        logoImage ?? theme.getThemeLogo()
    }
    
    // Use theme-specific presentation title if not explicitly provided
    private var effectivePresentationTitle: String {
        if let title = presentationTitle, !title.isEmpty {
            return title
        } else {
            return theme.getThemeTitle()
        }
    }
    
    // Whether to show the footer
    private var shouldShowFooter: Bool {
        showFooter || (slideNumber != nil && (effectiveLogoImage != nil || !effectivePresentationTitle.isEmpty))
    }
    
    // Determine slide layout based on content
    private var slideLayout: SlideLayout {
        // Get headings and body content
        let title = content.firstMarkdownHeading(level: 1)
        let subtitle = content.firstMarkdownHeading(level: 2)
        let bodyContent = removeFirstHeading(from: content)
        let images = extractImagesFromMarkdown(bodyContent)
        
        // Get body text content without images and handle empty content better
        let textContentWithoutImages = removeImagesFromMarkdown(bodyContent).trimmingCharacters(in: .whitespacesAndNewlines)
        let bodyTextOnly = bodyContent.bodyMarkdownText() // Use the extension method for better text extraction
        
        // Check for a title-subtitle only slide
        if title != nil && subtitle != nil && 
           textContentWithoutImages.isEmpty && 
           images.isEmpty {
            return .titleSubtitle
        }
        
        // Check for title-only slide
        if title != nil && textContentWithoutImages.isEmpty && images.isEmpty {
            return .titleOnly
        }
        
        // Check for blockquote/quote slide
        if bodyContent.contains(">") && !bodyContent.contains("![") {
            return .quote
        }
        
        print("images: \(images)")
        print("bodyTextOnly: \(bodyTextOnly)")
        
        // Image layouts
        if images.count == 1 && textContentWithoutImages.isEmpty {
            return .singleImage
        } else if images.count == 2 && textContentWithoutImages.isEmpty {
            return .doubleImage
        } else if images.count > 2 && textContentWithoutImages.isEmpty {
            return .gridImages
        }
        
        // Default to standard layout
        return .standard
    }
    
    init(content: String, theme: SlideTheme, showDecorations: Bool = true, titleFont: String? = nil, bodyFont: String? = nil, titleColor: Color? = nil, bodyColor: Color? = nil, backgroundColor: Color? = nil, slideNumber: Int? = nil, totalSlides: Int? = nil, presentationTitle: String? = nil, logoImage: NSImage? = nil, showFooter: Bool = false) {
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
        self.slideNumber = slideNumber
        self.totalSlides = totalSlides
        self.presentationTitle = presentationTitle
        self.logoImage = logoImage
        self.showFooter = showFooter
    }
    
    var body: some View {
        GeometryReader { geo in
            let scale = min(geo.size.width / Self.baseWidth, geo.size.height / Self.baseHeight)
            
            ZStack {
                // Use effective background
                effectiveBackgroundView
                
                VStack(spacing: 0) {
                    // Select appropriate layout based on content
                    Group {
                        switch slideLayout {
                        case .titleOnly:
                            titleOnlyLayout
                        case .titleSubtitle:
                            titleSubtitleLayout
                        case .singleImage:
                            singleImageLayout
                        case .doubleImage:
                            doubleImageLayout
                        case .gridImages:
                            gridImagesLayout
                        case .quote:
                            quoteLayout
                        case .standard:
                            standardLayout
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom, shouldShowFooter ? 20 : 0)
                    
                    // Footer with slide number, presentation title, and logo
                    if shouldShowFooter {
                        footerView
                    }
                }
            }
            .frame(width: Self.baseWidth, height: Self.baseHeight)
            .clipShape(RoundedRectangle(cornerRadius: showDecorations ? 16 : 0))
            .overlay(
                showDecorations ? 
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(theme.accentColor.opacity(0.3), lineWidth: 2) : nil
            )
            .shadow(
                color: showDecorations ? (theme == .dark || theme == .newYork ? .black.opacity(0.3) : .black.opacity(0.1)) : .clear, 
                radius: showDecorations ? 12 : 0,
                x: 0, 
                y: showDecorations ? 5 : 0
            )
            .scaleEffect(scale)
            .frame(width: geo.size.width, height: geo.size.height)
            .animation(.easeInOut(duration: 0.2), value: showDecorations)
        }
        .aspectRatio(16/9, contentMode: .fit)
    }
    
    // MARK: - Footer View
    
    private var footerView: some View {
        HStack(alignment: .center) {
            // Logo on the left
            if let logo = effectiveLogoImage {
                Image(nsImage: logo)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
            } else {
                // Placeholder for when no logo is provided
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 60, height: 40)
            }
            
            Spacer()
            
            // Presentation title and slide number on the right
            HStack(spacing: 8) {
                if !effectivePresentationTitle.isEmpty {
                    Text(effectivePresentationTitle)
                        .font(Font.custom(bodyFont, size: 24))
                        .foregroundColor(effectiveBodyColor.opacity(0.7))
                }
                
                if !effectivePresentationTitle.isEmpty && slideNumber != nil {
                    Text("—")
                        .font(Font.custom(bodyFont, size: 24))
                        .foregroundColor(effectiveBodyColor.opacity(0.7))
                }
                
                if let number = slideNumber {
                    Text("\(number)")
                        .font(Font.custom(bodyFont, size: 24))
                        .foregroundColor(effectiveBodyColor.opacity(0.7))
                    
                    if let total = totalSlides {
                        Text("/\(total)")
                            .font(Font.custom(bodyFont, size: 24))
                            .foregroundColor(effectiveBodyColor.opacity(0.5))
                    }
                }
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 20)
        .frame(height: 60)
    }
    
    // MARK: - Layout Views
    
    // Standard layout with title and content
    private var standardLayout: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title section
            if let title = content.firstMarkdownHeading(level: 1) {
                Text(title)
                    .font(Font.custom(titleFont, size: 96, relativeTo: .title).weight(theme.titleFontWeight))
                    .foregroundColor(effectiveTitleColor)
                    .lineSpacing(16)
                    .tracking(-0.5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 60)
                    .padding(.top, 100)
                    .padding(.horizontal, 100)
            }
            
            // Body content with proper scrolling behavior
            ScrollView {
                VStack(alignment: .leading, spacing: 40) {
                    // Exclude the title from the content
                    let bodyContent = removeFirstHeading(from: content)
                    
                    // Get the pure text content (without images)
                    let textContentWithoutImages = removeImagesFromMarkdown(bodyContent)
                    
                    // Render text content using Down
                    if !textContentWithoutImages.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, 
                       let attributedString = try? Down(markdownString: textContentWithoutImages).toAttributedString([.hardBreaks]) {
                        // Process the attributed string to apply custom styling
                        let styledText = applyCustomStyling(to: attributedString)
                        
                        // Render text content
                        Text(AttributedString(styledText))
                            .font(Font.custom(bodyFont.replacingOccurrences(of: " — Template Default", with: ""), 
                                             size: 60, relativeTo: .body))
                            .foregroundColor(effectiveBodyColor)
                            .lineSpacing(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                    }
                    
                    // Render images separately using the enhanced ImageContentView
                    ImageContentView(
                        markdown: bodyContent,
                        maxImageHeight: 720,
                        arrangement: .vertical
                    )
                    .padding(.top, 20)
                }
                .padding(.horizontal, 100)
                .padding(.bottom, 80)
            }
            .scrollIndicators(showDecorations ? .visible : .hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    // Title only layout
    private var titleOnlyLayout: some View {
        VStack(spacing: 0) {
            if let title = content.firstMarkdownHeading(level: 1) {
                Text(title)
                    .font(Font.custom(titleFont, size: 150, relativeTo: .largeTitle).weight(theme.titleFontWeight))
                    .foregroundColor(effectiveTitleColor)
                    .lineSpacing(20)
                    .tracking(-0.5)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 120)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // Title and subtitle layout
    private var titleSubtitleLayout: some View {
        VStack(spacing: 60) {
            if let title = content.firstMarkdownHeading(level: 1) {
                Text(title)
                    .font(Font.custom(titleFont, size: 150, relativeTo: .largeTitle).weight(theme.titleFontWeight))
                    .foregroundColor(effectiveTitleColor)
                    .lineSpacing(20)
                    .tracking(-0.5)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 120)
            }
            
            if let subtitle = content.firstMarkdownHeading(level: 2) {
                Text(subtitle)
                    .font(Font.custom(bodyFont, size: 90, relativeTo: .title2))
                    .foregroundColor(effectiveBodyColor.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 150)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // Single image layout
    private var singleImageLayout: some View {
        VStack(spacing: 40) {
            // Title if it exists
            if let title = content.firstMarkdownHeading(level: 1) {
                Text(title)
                    .font(Font.custom(titleFont, size: 96, relativeTo: .title).weight(theme.titleFontWeight))
                    .foregroundColor(effectiveTitleColor)
                    .lineSpacing(16)
                    .tracking(-0.5)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 80)
            }
            
            // Single centered image
            let bodyContent = removeFirstHeading(from: content)
            
            ImageContentView(
                markdown: bodyContent,
                maxImageHeight: 720,
                maxCaptionLines: 0,
                captionSize: 36,
                arrangement: .vertical
            )
            .padding(.horizontal, 100)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // Double image layout
    private var doubleImageLayout: some View {
        VStack(spacing: 40) {
            // Title if it exists
            if let title = content.firstMarkdownHeading(level: 1) {
                Text(title)
                    .font(Font.custom(titleFont, size: 96, relativeTo: .title).weight(theme.titleFontWeight))
                    .foregroundColor(effectiveTitleColor)
                    .lineSpacing(16)
                    .tracking(-0.5)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 60)
                    .padding(.bottom, 20)
            }
            
            // Two images side by side
            let bodyContent = removeFirstHeading(from: content)
            
            ImageContentView(
                markdown: bodyContent,
                maxImageHeight: 500,
                maxCaptionLines: 2,
                captionSize: 36,
                arrangement: .horizontal
            )
            .padding(.horizontal, 100)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // Grid image layout (for 3+ images)
    private var gridImagesLayout: some View {
        VStack(spacing: 40) {
            // Title if it exists
            if let title = content.firstMarkdownHeading(level: 1) {
                Text(title)
                    .font(Font.custom(titleFont, size: 96, relativeTo: .title).weight(theme.titleFontWeight))
                    .foregroundColor(effectiveTitleColor)
                    .lineSpacing(16)
                    .tracking(-0.5)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 60)
            }
            
            // Grid of images
            let bodyContent = removeFirstHeading(from: content)
            
            ImageContentView(
                markdown: bodyContent,
                maxImageHeight: 360,
                maxCaptionLines: 1,
                captionSize: 28,
                arrangement: .grid
            )
            .padding(.horizontal, 100)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // Quote layout
    private var quoteLayout: some View {
        VStack(spacing: 50) {
            // Title if it exists
            if let title = content.firstMarkdownHeading(level: 1) {
                Text(title)
                    .font(Font.custom(titleFont, size: 96, relativeTo: .title).weight(theme.titleFontWeight))
                    .foregroundColor(effectiveTitleColor)
                    .lineSpacing(16)
                    .tracking(-0.5)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 80)
            }
            
            // Extract quote and attribution
            let bodyContent = removeFirstHeading(from: content)
            if let (quote, attribution) = extractQuote(from: bodyContent) {
                VStack(spacing: 40) {
                    Text("\"\(quote)\"")
                        .font(Font.custom(bodyFont, size: 72, relativeTo: .title2).italic())
                        .foregroundColor(effectiveBodyColor)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 1200)
                        .padding(.horizontal, 60)
                    
                    if !attribution.isEmpty {
                        Text("— " + attribution)
                            .font(Font.custom(bodyFont, size: 48, relativeTo: .body))
                            .foregroundColor(effectiveBodyColor.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.vertical, 50)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Helper Methods
    
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
    
    // Extract quote and attribution from blockquote text
    private func extractQuote(from markdown: String) -> (quote: String, attribution: String)? {
        let lines = markdown.components(separatedBy: .newlines)
        var quoteLines: [String] = []
        var attributionLine = ""
        
        // Process blockquote lines
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.hasPrefix(">") {
                // Extract the text after ">"
                let quoteText = trimmedLine.dropFirst().trimmingCharacters(in: .whitespaces)
                
                // Check if it might be an attribution line (usually shorter and/or starts with --)
                if quoteText.hasPrefix("--") || quoteText.hasPrefix("—") || (quoteLines.count > 0 && quoteText.count < 30) {
                    attributionLine = quoteText.replacingOccurrences(of: "^[—-]+\\s*", with: "", options: .regularExpression)
                } else {
                    quoteLines.append(quoteText)
                }
            }
        }
        
        // Only return if we have some quote content
        if !quoteLines.isEmpty {
            return (quoteLines.joined(separator: " "), attributionLine)
        }
        
        return nil
    }
    
    // Helper to extract images
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
    
    // Remove images from markdown to get pure text content
    private func removeImagesFromMarkdown(_ markdown: String) -> String {
        let imagePattern = "!\\[(.*?)\\]\\((.*?)\\)"
        
        if let regex = try? NSRegularExpression(pattern: imagePattern, options: []) {
            let mutableString = NSMutableString(string: markdown)
            regex.replaceMatches(in: mutableString, range: NSRange(location: 0, length: mutableString.length), withTemplate: "")
            return String(mutableString)
        }
        
        return markdown
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
    var maxImageHeight: CGFloat = 720
    var maxCaptionLines: Int = 0  // 0 means unlimited
    var captionSize: CGFloat = 36
    var arrangement: ImageArrangement = .vertical
    
    // Define possible image arrangements
    enum ImageArrangement {
        case vertical   // Images stacked vertically
        case horizontal // Images side by side
        case grid       // Images in a grid (for 3+ images)
    }
    
    var body: some View {
        let images = extractImagesFromMarkdown(markdown)
        
        Group {
            switch arrangement {
            case .vertical:
                VStack(alignment: .leading, spacing: 60) {
                    ForEach(images.indices, id: \.self) { index in
                        singleImageView(imageInfo: images[index])
                    }
                }
            case .horizontal:
                HStack(alignment: .top, spacing: 60) {
                    ForEach(images.indices, id: \.self) { index in
                        singleImageView(imageInfo: images[index])
                    }
                }
            case .grid:
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 40) {
                    ForEach(images.indices, id: \.self) { index in
                        singleImageView(imageInfo: images[index])
                    }
                }
            }
        }
    }
    
    // Helper to create a consistent image view
    private func singleImageView(imageInfo: (alt: String, url: String)) -> some View {
        VStack(alignment: .center, spacing: 20) {
            // Try to load image from URL first
            if let url = URL(string: imageInfo.url), let nsImage = NSImage(contentsOf: url) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: maxImageHeight)
                    .accessibility(label: Text(imageInfo.alt))
            } else {
                // Fallback to bundled image
                Image(imageInfo.url)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: maxImageHeight)
                    .accessibility(label: Text(imageInfo.alt))
            }
            
            // Optional caption for the image
            if !imageInfo.alt.isEmpty {
                Text(imageInfo.alt)
                    .font(.system(size: captionSize))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(maxCaptionLines > 0 ? maxCaptionLines : nil)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // Helper to extract image information from markdown - moved to main view
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
    var slideNumber: Int?
    var totalSlides: Int?
    var presentationTitle: String?
    var logoImage: NSImage?
    var showFooter: Bool = false
    
    var body: some View {
        SlideRenderView(
            content: content, 
            theme: theme, 
            titleFont: titleFont, 
            bodyFont: bodyFont,
            titleColor: titleColor,
            bodyColor: bodyColor,
            backgroundColor: backgroundColor,
            slideNumber: slideNumber,
            totalSlides: totalSlides,
            presentationTitle: presentationTitle,
            logoImage: logoImage,
            showFooter: showFooter
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

