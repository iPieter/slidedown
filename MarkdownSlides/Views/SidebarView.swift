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
            // Top control section with improved styling
            HStack(spacing: 12) {
                Button(action: {
                    addNewSlide()
                }) {
                    Label("New Slide", systemImage: "plus")
                        .font(.system(size: 13))
                }
                .buttonStyle(.borderless)
                .help("Add New Slide")
                
                Spacer()
                
                Menu {
                    Button(action: {
                        addNewSlide()
                    }) {
                        Label("Blank Slide", systemImage: "rectangle.stack.badge.plus")
                    }
                    
                    Button(action: {
                        // Add title slide template
                    }) {
                        Label("Title Slide", systemImage: "text.badge.plus")
                    }
                    
                    Button(action: {
                        // Add image slide template
                    }) {
                        Label("Image Slide", systemImage: "photo.badge.plus")
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .menuStyle(.borderlessButton)
                .frame(width: 24)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.controlBackgroundColor).opacity(0.5))
            
            Divider()
            
            // Slides list with improved styling
            List(selection: $selectedSlideIndex) {
                ForEach(Array(slides.enumerated()), id: \.offset) { index, slideContent in
                    SlideListItemView(
                        isSelected: index == self.selectedSlideIndex,
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
                        Button(action: {
                            duplicateSlide(at: index)
                        }) {
                            Label("Duplicate Slide", systemImage: "plus.square.on.square")
                        }
                        
                        Divider()
                        
                        Button(action: {
                            deleteSlide(at: index)
                        }) {
                            Label("Delete Slide", systemImage: "trash")
                        }
                    }
                }
                .onMove { indices, newOffset in
                    moveSlides(from: indices, to: newOffset)
                }
            }
            .listStyle(.sidebar)
            .background(Color(.textBackgroundColor))
        }
    }
    
    private func addNewSlide() {
        let newSlide = "\n\n---\n\n# New Slide\n\nAdd content here"
        markdownDocument += newSlide
        // Set the selection to the new slide
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            selectedSlideIndex = slides.count - 1
        }
    }
    
    private func duplicateSlide(at index: Int) {
        guard index >= 0 && index < slides.count else { return }
        let slideContent = slides[index]
        let insertPoint = markdownDocument.range(of: slideContent)?.upperBound ?? markdownDocument.endIndex
        markdownDocument.insert(contentsOf: "\n\n---\n\(slideContent)", at: insertPoint)
    }
    
    private func deleteSlide(at index: Int) {
        guard slides.count > 1, index >= 0 && index < slides.count else { return }
        let slideContent = slides[index]
        if let range = markdownDocument.range(of: slideContent) {
            var rangeToDelete = range
            // Include the slide separator if it exists
            if index > 0 {
                rangeToDelete = (markdownDocument.range(of: "\n\n---\n", range: markdownDocument.startIndex..<range.lowerBound)?.lowerBound ?? range.lowerBound)..<range.upperBound
            }
            markdownDocument.removeSubrange(rangeToDelete)
        }
    }
    
    private func moveSlides(from source: IndexSet, to destination: Int) {
        // Implementation for moving slides
        // This would need to manipulate the markdown document string
    }
}

struct SlideListItemView: View {
    let isSelected: Bool
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
        VStack(alignment: .leading, spacing: 8) {
            // Slide header with improved styling
            HStack(spacing: 8) {
                Text("\(index + 1)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .white : .secondary)
                    .frame(width: 24, height: 18)
                    .background(isSelected ? Color.accentColor.opacity(0.3) : Color(.controlBackgroundColor))
                    .cornerRadius(4)
                
                if let title = slideContent.firstMarkdownHeading(level: 1) {
                    Text(title)
                        .font(.system(size: 13, weight: .medium))
                        .lineLimit(1)
                } else if let title = slideContent.firstMarkdownHeading(level: 2) {
                    Text(title)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                } else {
                    Text("Untitled Slide")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            
            // Slide preview with improved styling
            SlidePreviewView(
                content: slideContent, 
                theme: selectedTheme, 
                titleFont: selectedTitleFont, 
                bodyFont: selectedBodyFont,
                titleColor: titleColor,
                bodyColor: bodyColor,
                backgroundColor: backgroundColor,
                slideNumber: index + 1,
                totalSlides: 0,
                presentationTitle: presentationTitle,
                logoImage: logoImage,
                showFooter: showFooter
            )
            .cornerRadius(6)
            .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
        }
        .padding(.vertical, 4)
    }
} 
