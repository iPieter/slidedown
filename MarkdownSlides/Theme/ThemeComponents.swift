import SwiftUI

struct ThemePreviewView: View {
    let theme: SlideTheme
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            // Color swatch
            RoundedRectangle(cornerRadius: 3)
                .fill(theme.backgroundColor)
                .frame(width: 36, height: 24)
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color(.separatorColor), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
            
            // Theme name
            Text(theme.rawValue)
                .font(.system(size: 13))
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 11, weight: .bold))
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(4)
    }
}

struct ColorPickerRow: View {
    let title: String
    @Binding var color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.primary)
            
            Spacer()
            
            ColorPicker("", selection: $color)
                .labelsHidden()
                .scaleEffect(0.9)
                .frame(width: 28, height: 28)
        }
        .padding(.vertical, 4)
    }
}

struct FontPickerRow: View {
    let title: String
    @Binding var selectedFont: String
    let fonts: [String]
    
    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.primary)
            
            Spacer()
            
            Picker("", selection: $selectedFont) {
                ForEach(fonts, id: \.self) { font in
                    Text(font)
                        .font(.system(size: 13))
                        .tag(font)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 160)
        }
        .padding(.vertical, 4)
    }
}

struct ThemeSettingsView: View {
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
    
    // Available fonts
    private let titleFonts = ["SF Pro Display", "SF Pro Text", "Helvetica Neue", "Georgia", "Avenir", "Futura"]
    private let bodyFonts = ["SF Pro Text", "Inter — Template Default", "Helvetica Neue", "Georgia", "Avenir", "Times"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Theme selector grid
            VStack(alignment: .leading, spacing: 8) {
                Text("Theme")
                    .font(.headline)
                    .padding(.bottom, 4)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(SlideTheme.allCases) { theme in
                        ThemeButton(theme: theme, isSelected: theme == selectedTheme) {
                            selectedTheme = theme
                            // Update colors to match theme
                            titleColor = theme.titleColor
                            bodyColor = theme.foregroundColor
                            backgroundColor = theme.backgroundColor
                        }
                    }
                }
            }
            .padding([.horizontal, .bottom])
            
            Divider()
                .padding(.vertical, 8)
            
            // Font selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Typography")
                    .font(.headline)
                    .padding(.bottom, 4)
                
                FontPickerRow(title: "Title Font", selectedFont: $selectedTitleFont, fonts: titleFonts)
                FontPickerRow(title: "Body Font", selectedFont: $selectedBodyFont, fonts: bodyFonts)
                
                // Font preview
                VStack(alignment: .leading, spacing: 4) {
                    Text("Title Preview")
                        .font(Font.custom(selectedTitleFont, size: 14, relativeTo: .headline))
                        .fontWeight(.semibold)
                        .foregroundColor(titleColor)
                    
                    Text("Body text preview with the selected font")
                        .font(Font.custom(selectedBodyFont.replacingOccurrences(of: " — Template Default", with: ""), size: 12))
                        .foregroundColor(bodyColor)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(backgroundColor)
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color(.separatorColor), lineWidth: 1)
                )
            }
            .padding([.horizontal, .bottom])
            
            Divider()
                .padding(.vertical, 8)
            
            // Colors
            VStack(alignment: .leading, spacing: 8) {
                Text("Colors")
                    .font(.headline)
                    .padding(.bottom, 4)
                
                ColorPickerRow(title: "Title Color", color: $titleColor)
                ColorPickerRow(title: "Body Color", color: $bodyColor)
                ColorPickerRow(title: "Background", color: $backgroundColor)
                
                // Reset colors button
                Button("Reset to Theme Defaults") {
                    titleColor = selectedTheme.titleColor
                    bodyColor = selectedTheme.foregroundColor
                    backgroundColor = selectedTheme.backgroundColor
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 4)
            }
            .padding([.horizontal, .bottom])
            
            Divider()
                .padding(.vertical, 8)
            
            // App appearance
            VStack(alignment: .leading, spacing: 8) {
                Text("App Settings")
                    .font(.headline)
                    .padding(.bottom, 4)
                
                HStack {
                    Text("App Appearance")
                        .font(.system(size: 13))
                    
                    Spacer()
                    
                    Picker("", selection: $appearance) {
                        Text("Light").tag(AppAppearance.light)
                        Text("Dark").tag(AppAppearance.dark)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 120)
                }
            }
            .padding([.horizontal, .bottom])
        }
        .padding(.vertical, 8)
    }
}

// Helper components
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct ThemeButton: View {
    let theme: SlideTheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                // Theme color preview
                RoundedRectangle(cornerRadius: 4)
                    .fill(theme.backgroundColor)
                    .frame(height: 24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(isSelected ? Color.accentColor : Color(.separatorColor), lineWidth: isSelected ? 2 : 1)
                    )
                
                // Theme name
                Text(theme.rawValue)
                    .font(.system(size: 11))
                    .lineLimit(1)
                    .foregroundColor(isSelected ? .accentColor : .primary)
            }
            .padding(4)
        }
        .buttonStyle(.plain)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(6)
    }
} 