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
    
    var slides: [String]
    
    var body: some View {
        VStack(spacing: 0) {
            // Top toolbar section
            HStack {
                Spacer()
                
                // Preview on button
                Text("Preview on")
                    .font(.system(size: 12))
                
                Picker("", selection: .constant("Desktop")) {
                    Text("Desktop").tag("Desktop")
                    Text("Mobile").tag("Mobile")
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 100)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
            .background(Color.secondary.opacity(0.05))
            
            Divider()
            
            // Main sidebar with two tabs: Slides and Settings
            TabView {
                // Slides tab
                VStack {
                    // Slide list with improved styling
                    List(selection: $selectedSlideIndex) {
                        ForEach(Array(slides.enumerated()), id: \.offset) { index, slideContent in
                            SlideListItemView(index: index, slideContent: slideContent, selectedTheme: selectedTheme, selectedTitleFont: selectedTitleFont, selectedBodyFont: selectedBodyFont)
                                .tag(index)
                                .padding(.vertical, 4)
                        }
                    }
                    .listStyle(PlainListStyle())
                    
                    
                }
                .tabItem {
                    Label("Slides", systemImage: "rectangle.on.rectangle")
                }
                .padding(.top, 4)
                
                // Theme Settings tab with all global settings
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
                        appearance: $appearance
                    )
                }
                .tabItem {
                    Label("Theme", systemImage: "paintbrush")
                }
            }
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text("\(index + 1)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary)
                
                if let title = slideContent.firstMarkdownHeading(level: 1) {
                    Text(title)
                        .font(.system(size: 12, weight: .medium))
                        .lineLimit(1)
                } else if let title = slideContent.firstMarkdownHeading(level: 2) {
                    Text(title)
                        .font(.system(size: 12, weight: .medium))
                        .lineLimit(1)
                } else {
                    Text("Slide \(index + 1)")
                        .font(.system(size: 12, weight: .medium))
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                }
            }
            
            SlidePreviewView(
                content: slideContent, 
                theme: selectedTheme, 
                titleFont: selectedTitleFont, 
                bodyFont: selectedBodyFont
            )
            .frame(height: 100)
            .cornerRadius(6)
        }
    }
} 