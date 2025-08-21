import SwiftUI

struct SidebarView: View {
    @Binding var markdownDocument: String
    @Binding var selectedSlideIndex: Int
    @Binding var selectedTheme: SlideTheme
    @Binding var isFontsExpanded: Bool
    @Binding var isThemeExpanded: Bool
    @Binding var isColorsExpanded: Bool
    @Binding var isAppearanceExpanded: Bool
    @Binding var selectedTitleFont: String
    @Binding var selectedBodyFont: String
    @Binding var titleColor: Color
    @Binding var bodyColor: Color
    @Binding var backgroundColor: Color
    @Binding var appearance: AppAppearance
    @Binding var showFooter: Bool
    @Binding var presentationTitle: String
    @Binding var logoImage: NSImage?
    
    var slides: [String]
    
    var body: some View {
        VStack(spacing: 0) {
            // Top control section
            HStack {
                Button(action: {
                    addNewSlide()
                }) {
                    Label("", systemImage: "plus")
                        .labelStyle(.iconOnly)
                        .font(.system(size: 12))
                }
                .buttonStyle(.borderless)
                .help("Add New Slide")
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(.controlBackgroundColor).opacity(0.5))
            
            Divider()
            
            // Slides list
            List(selection: $selectedSlideIndex) {
                ForEach(Array(slides.enumerated()), id: \.offset) { index, slideContent in
                    SlideListItemView(
                        index: index, 
                        slideContent: slideContent, 
                        selectedTheme: selectedTheme, 
                        selectedTitleFont: selectedTitleFont, 
                        selectedBodyFont: selectedBodyFont,
                        titleColor: titleColor,
                        bodyColor: bodyColor,
                        backgroundColor: backgroundColor,
                        showFooter: showFooter,
                        presentationTitle: presentationTitle,
                        logoImage: logoImage
                    )
                    .tag(index)
                    .contextMenu {
                        Button("Duplicate Slide") {
                            // Duplicate slide functionality
                        }
                        Divider()
                        Button("Delete Slide", role: .destructive) {
                            // Delete slide functionality
                        }
                    }
                }
                .onMove { indices, newOffset in
                    // Move functionality
                }
            }
            .listStyle(.sidebar)
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
}

struct SlideListItemView: View {
    let index: Int
    let slideContent: String
    let selectedTheme: SlideTheme
    let selectedTitleFont: String
    let selectedBodyFont: String
    let titleColor: Color
    let bodyColor: Color
    let backgroundColor: Color
    let showFooter: Bool
    let presentationTitle: String
    let logoImage: NSImage?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("\(index + 1)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary)
                    .frame(width: 22, alignment: .center)
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(4)
                
                if let title = slideContent.firstMarkdownHeading(level: 1) {
                    Text(title)
                        .font(.headline)
                        .lineLimit(1)
                } else if let title = slideContent.firstMarkdownHeading(level: 2) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                } else {
                    Text("Untitled Slide")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            SlidePreviewView(
                content: slideContent, 
                theme: selectedTheme, 
                titleFont: selectedTitleFont, 
                bodyFont: selectedBodyFont,
                titleColor: titleColor,
                bodyColor: bodyColor,
                backgroundColor: backgroundColor,
                slideNumber: index + 1,
                totalSlides: 0,  // Set to actual count in the parent view
                presentationTitle: presentationTitle,
                logoImage: logoImage,
                showFooter: showFooter
            )
            .frame(height: 90)
            .cornerRadius(4)
        }
        .padding(.vertical, 2)
    }
} 