import SwiftUI

struct ThemePreviewView: View {
    let theme: SlideTheme
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            // Color swatch
            Rectangle()
                .fill(theme.backgroundColor)
                .frame(width: 36, height: 24)
                .overlay(
                    Rectangle()
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
            
            // Theme name
            Text(theme.rawValue)
                .font(.system(size: 14))
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
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
        HStack {
            Text(title)
                .font(.system(size: 12))
                .frame(width: 80, alignment: .leading)
            
            Spacer()
            
            ColorPicker("", selection: $color)
                .labelsHidden()
        }
        .padding(.horizontal, 12)
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Theme section
            DisclosureGroup("Theme", isExpanded: $isThemeExpanded) {
                VStack(spacing: 8) {
                    Picker("", selection: $selectedTheme) {
                        ForEach(SlideTheme.allCases) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .labelsHidden()
                    
                    // Preview of selected theme
                    Rectangle()
                        .fill(selectedTheme.backgroundColor)
                        .frame(height: 24)
                        .overlay(
                            Text("Theme Preview")
                                .font(.system(size: 12))
                                .foregroundColor(selectedTheme.foregroundColor)
                        )
                        .cornerRadius(4)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 12)
            
            Divider()
            
            // Fonts section
            DisclosureGroup("Fonts", isExpanded: $isFontsExpanded) {
                VStack(spacing: 8) {
                    // Title font
                    HStack {
                        Text("Title Font")
                            .font(.system(size: 12, weight: .medium))
                        
                        Spacer()
                        
                        Picker("", selection: $selectedTitleFont) {
                            Text("SF Pro Text").tag("SF Pro Text")
                            Text("Fira Sans").tag("Fira Sans")
                            Text("Helvetica Neue").tag("Helvetica Neue")
                            Text("Georgia").tag("Georgia")
                            Text("Avenir").tag("Avenir")
                            Text("Futura").tag("Futura")
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 150)
                    }
                    
                    // Body font
                    HStack {
                        Text("Body Font")
                            .font(.system(size: 12, weight: .medium))
                        
                        Spacer()
                        
                        Picker("", selection: $selectedBodyFont) {
                            Text("Inter — Template Default").tag("Inter — Template Default")
                            Text("Fira Sans").tag("Fira Sans")
                            Text("SF Pro Text").tag("SF Pro Text")
                            Text("Helvetica Neue").tag("Helvetica Neue")
                            Text("Georgia").tag("Georgia")
                            Text("Avenir").tag("Avenir")
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 150)
                    }
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 12)
            
            Divider()
            
            // Colors section
            DisclosureGroup("Colors", isExpanded: $isColorsExpanded) {
                VStack(alignment: .leading, spacing: 8) {
                    // Color selectors for titles, body, background
                    ColorPickerRow(title: "Titles", color: $titleColor)
                    ColorPickerRow(title: "Body", color: $bodyColor)
                    ColorPickerRow(title: "Background", color: $backgroundColor)
                    
                    // Reset colors button
                    Button("Reset Colors...") {
                        // Reset to theme defaults
                        titleColor = selectedTheme.titleColor
                        bodyColor = selectedTheme.foregroundColor
                        backgroundColor = selectedTheme.backgroundColor
                    }
                    .font(.system(size: 12))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 4)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 12)
            
            Divider()
            
            // Appearance section
            DisclosureGroup("Appearance", isExpanded: $isAppearanceExpanded) {
                HStack {
                    Text("Mode")
                        .font(.system(size: 12, weight: .medium))
                    
                    Spacer()
                    
                    HStack(spacing: 2) {
                        Button {
                            appearance = .light
                        } label: {
                            Text("Light")
                                .font(.system(size: 12))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(appearance == .light ? Color.accentColor : Color.clear)
                                .foregroundColor(appearance == .light ? .white : .primary)
                                .cornerRadius(4)
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            appearance = .dark
                        } label: {
                            Text("Dark")
                                .font(.system(size: 12))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(appearance == .dark ? Color.accentColor : Color.clear)
                                .foregroundColor(appearance == .dark ? .white : .primary)
                                .cornerRadius(4)
                        }
                        .buttonStyle(.plain)
                    }
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(6)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 12)
        }
        .padding(.vertical, 8)
    }
} 