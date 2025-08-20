import SwiftUI
import Down

// Slide rendering view used for both preview and presentation
struct SlideRenderView: View {
    let content: String
    let theme: SlideTheme
    static let baseWidth: CGFloat = 490
    static let baseHeight: CGFloat = 270
    let showDecorations: Bool
    var titleFont: String = "SF Pro Text"  // Default font
    var bodyFont: String = "Inter — Template Default"  // Default font
    
    init(content: String, theme: SlideTheme, showDecorations: Bool = true, titleFont: String? = nil, bodyFont: String? = nil) {
        self.content = content
        self.theme = theme
        self.showDecorations = showDecorations
        if let titleFont = titleFont {
            self.titleFont = titleFont
        }
        if let bodyFont = bodyFont {
            self.bodyFont = bodyFont
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            let scale = min(geo.size.width / Self.baseWidth, geo.size.height / Self.baseHeight)
            
            ZStack {
                theme.backgroundView
                
                VStack(alignment: .leading, spacing: 0) {
                    // Extract first heading for title if available
                    if let title = content.firstMarkdownHeading(level: 1) {
                        Text(title)
                            // Use custom font with fallback to system font
                            .font(Font.custom(titleFont, size: 36, relativeTo: .title).weight(theme.titleFontWeight))
                            .foregroundColor(theme.titleColor)
                            .padding(.bottom, 20)
                            .padding(.top, 40)
                            .padding(.horizontal, 40)
                    }
                    
                    // Extract and render body content
                    ScrollView {
                        // Exclude the title from the content to avoid duplication
                        let bodyContent = removeFirstHeading(from: content)
                        
                        if let attributedString = try? Down(markdownString: bodyContent).toAttributedString() {
                            Text(AttributedString(attributedString))
                                // Use custom font with fallback to system font
                                .font(Font.custom(bodyFont.replacingOccurrences(of: " — Template Default", with: ""), 
                                                 size: 24, relativeTo: .body))
                                .foregroundColor(theme.foregroundColor)
                                .lineSpacing(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 40)
                                .padding(.bottom, 40)
                        } else {
                            Text("Error rendering slide")
                                .foregroundColor(.red)
                                .padding(40)
                        }
                    }
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
}

// Sidebar preview uses SlideRenderView with small frame
struct SlidePreviewView: View {
    let content: String
    let theme: SlideTheme
    var titleFont: String?
    var bodyFont: String?
    
    var body: some View {
        SlideRenderView(content: content, theme: theme, titleFont: titleFont, bodyFont: bodyFont)
            .frame(height: 90)
    }
}

// Main slide view for legacy support
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
                }
            } else {
                Text("Error rendering slide")
            }
        }
        .cornerRadius(12)
        .shadow(radius: 8)
    }
} 