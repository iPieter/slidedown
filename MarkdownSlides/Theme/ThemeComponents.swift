import SwiftUI

struct CodableColor: Codable {
    let red: Double
    let green: Double
    let blue: Double
    let opacity: Double
    
    init(color: Color) {
        let nsColor = NSColor(color)
        self.red = Double(nsColor.redComponent)
        self.green = Double(nsColor.greenComponent)
        self.blue = Double(nsColor.blueComponent)
        self.opacity = Double(nsColor.alphaComponent)
    }
    
    var color: Color {
        Color(NSColor(red: red, green: green, blue: blue, alpha: opacity))
    }
}

struct CustomTheme: Identifiable, Codable {
    let id: UUID
    var name: String
    private var _backgroundColor: CodableColor
    private var _titleColor: CodableColor
    private var _foregroundColor: CodableColor
    var logo: Data?  // Store logo as Data
    var defaultFont: String
    var titleFont: String
    
    var backgroundColor: Color {
        get { _backgroundColor.color }
        set { _backgroundColor = CodableColor(color: newValue) }
    }
    
    var titleColor: Color {
        get { _titleColor.color }
        set { _titleColor = CodableColor(color: newValue) }
    }
    
    var foregroundColor: Color {
        get { _foregroundColor.color }
        set { _foregroundColor = CodableColor(color: newValue) }
    }
    
    init(id: UUID, name: String, backgroundColor: Color, titleColor: Color, foregroundColor: Color, logo: Data?, defaultFont: String, titleFont: String) {
        self.id = id
        self.name = name
        self._backgroundColor = CodableColor(color: backgroundColor)
        self._titleColor = CodableColor(color: titleColor)
        self._foregroundColor = CodableColor(color: foregroundColor)
        self.logo = logo
        self.defaultFont = defaultFont
        self.titleFont = titleFont
    }
}

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

func getSystemFonts() -> [String] {
    let fontFamilyNames = NSFontManager.shared.availableFontFamilies
    return fontFamilyNames.sorted()
}

struct FontPickerRow: View {
    let title: String
    @Binding var selectedFont: String
    let fonts: [String]
    @State private var searchText = ""
    @State private var isExpanded = false
    
    var filteredFonts: [String] {
        if searchText.isEmpty {
            return fonts
        }
        return fonts.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Menu {
                    SearchBar(text: $searchText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                    
                    Divider()
                    
                    ForEach(filteredFonts, id: \.self) { font in
                        Button(action: { selectedFont = font }) {
                            HStack {
                                Text(font)
                                    .font(.custom(font, size: 13))
                                Spacer()
                                Text("Aa")
                                    .font(.custom(font, size: 11))
                                    .foregroundColor(.secondary)
                                
                                if font == selectedFont {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedFont)
                            .font(.custom(selectedFont, size: 13))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10))
                    }
                    .frame(width: 200, alignment: .leading)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search Fonts", text: $text)
                .textFieldStyle(.plain)
        }
        .padding(6)
        .background(Color(.textBackgroundColor))
        .cornerRadius(6)
    }
}

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    @Published var customThemes: [CustomTheme] = []
    
    private let themesKey = "customThemes"
    
    init() {
        loadThemes()
    }
    
    func loadThemes() {
        if let data = UserDefaults.standard.data(forKey: themesKey),
           let themes = try? JSONDecoder().decode([CustomTheme].self, from: data) {
            customThemes = themes
        }
    }
    
    func saveTheme(_ theme: CustomTheme) {
        if let index = customThemes.firstIndex(where: { $0.id == theme.id }) {
            customThemes[index] = theme
        } else {
            customThemes.append(theme)
        }
        saveThemes()
    }
    
    func deleteTheme(_ theme: CustomTheme) {
        customThemes.removeAll { $0.id == theme.id }
        saveThemes()
    }
    
    private func saveThemes() {
        if let encoded = try? JSONEncoder().encode(customThemes) {
            UserDefaults.standard.set(encoded, forKey: themesKey)
        }
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
    @Binding var showFooter: Bool
    @Binding var presentationTitle: String
    @Binding var logoImage: NSImage?
    @State private var showingAddThemeSheet = false
    @StateObject private var themeManager = ThemeManager.shared
    @State private var selectedCustomTheme: CustomTheme?
    
    private let systemFonts = getSystemFonts()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Theme selector grid
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Theme")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: { showingAddThemeSheet = true }) {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                .padding(.bottom, 4)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    // Built-in themes
                    ForEach(SlideTheme.allCases) { theme in
                        ThemeButton(theme: theme, isSelected: selectedCustomTheme == nil && theme == selectedTheme) {
                            selectedTheme = theme
                            selectedCustomTheme = nil
                            updateColorsForTheme(theme)
                        }
                    }
                    
                    // Custom themes
                    ForEach(themeManager.customThemes) { theme in
                        CustomThemeButton(
                            theme: theme,
                            isSelected: selectedCustomTheme?.id == theme.id,
                            onEdit: { editTheme(theme) },
                            onDelete: { deleteTheme(theme) }
                        ) {
                            selectedCustomTheme = theme
                            applyCustomTheme(theme)
                        }
                    }
                }
            }
            .padding([.horizontal, .bottom])
            
            Divider()
                .padding(.vertical, 8)
            
            // Footer Settings
            VStack(alignment: .leading, spacing: 8) {
                Text("Footer")
                    .font(.headline)
                    .padding(.bottom, 4)
                
                Toggle(isOn: $showFooter) {
                    Text("Show Footer")
                        .font(.system(size: 13))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Presentation Title", text: $presentationTitle)
                        .font(.system(size: 13))
                        .textFieldStyle(.roundedBorder)
                    
                    HStack {
                        Text("Logo")
                            .font(.system(size: 13))
                        
                        Spacer()
                        
                        Button("Choose Logo") {
                            selectLogo()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        
                        if logoImage != nil {
                            Button("Clear") {
                                logoImage = nil
                            }
                            .buttonStyle(.borderless)
                            .foregroundColor(.red)
                            .controlSize(.small)
                        }
                    }
                    
                    // Logo preview
                    if let logo = logoImage {
                        Image(nsImage: logo)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 40)
                            .padding(4)
                            .background(Color(.textBackgroundColor))
                            .cornerRadius(4)
                    }
                }
                .disabled(!showFooter)
                .opacity(showFooter ? 1.0 : 0.6)
            }
            .padding([.horizontal, .bottom])
            
            Divider()
                .padding(.vertical, 8)
            
            // Font selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Typography")
                    .font(.headline)
                    .padding(.bottom, 4)
                
                FontPickerRow(title: "Title Font", selectedFont: $selectedTitleFont, fonts: systemFonts)
                FontPickerRow(title: "Body Font", selectedFont: $selectedBodyFont, fonts: systemFonts)
                
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
        .sheet(isPresented: $showingAddThemeSheet) {
            CustomThemeEditor(
                isPresented: $showingAddThemeSheet,
                editingTheme: selectedCustomTheme
            )
        }
    }
    
    private func updateColorsForTheme(_ theme: SlideTheme) {
        titleColor = theme.titleColor
        bodyColor = theme.foregroundColor
        backgroundColor = theme.backgroundColor
    }
    
    private func applyCustomTheme(_ theme: CustomTheme) {
        titleColor = theme.titleColor
        bodyColor = theme.foregroundColor
        backgroundColor = theme.backgroundColor
        selectedTitleFont = theme.titleFont
        selectedBodyFont = theme.defaultFont
        if let logoData = theme.logo,
           let image = NSImage(data: logoData) {
            logoImage = image
        }
    }
    
    private func selectLogo() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.image]
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                if let image = NSImage(contentsOf: url) {
                    logoImage = image
                    
                    // Also save the logo for the current theme
                    SlideTheme.setThemeLogo(image, for: selectedTheme)
                    
                    // If there's a presentation title, save it for the theme too
                    if !presentationTitle.isEmpty {
                        SlideTheme.setThemeTitle(presentationTitle, for: selectedTheme)
                    }
                }
            }
        }
    }
    
    private func editTheme(_ theme: CustomTheme) {
        selectedCustomTheme = theme
        showingAddThemeSheet = true
    }
    
    private func deleteTheme(_ theme: CustomTheme) {
        if selectedCustomTheme?.id == theme.id {
            selectedCustomTheme = nil
            selectedTheme = .light // or any default theme
            updateColorsForTheme(selectedTheme)
        }
        themeManager.deleteTheme(theme)
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

struct CustomThemeButton: View {
    let theme: CustomTheme
    let isSelected: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                // Theme color preview with content
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(theme.backgroundColor)
                        .frame(height: 48)  // Made taller to fit content
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(isSelected ? Color.accentColor : Color(.separatorColor), lineWidth: isSelected ? 2 : 1)
                        )
                    
                    // Theme preview content
                    VStack(alignment: .leading, spacing: 2) {
                        if let logoData = theme.logo,
                           let image = NSImage(data: logoData) {
                            Image(nsImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 16)
                                .padding(.top, 4)
                        }
                        
                        Text("Title")
                            .font(.custom(theme.titleFont, size: 10))
                            .foregroundColor(theme.titleColor)
                            .padding(.horizontal, 4)
                        
                        Text("Sample text")
                            .font(.custom(theme.defaultFont, size: 8))
                            .foregroundColor(theme.foregroundColor)
                            .padding(.horizontal, 4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Edit/Delete menu
                    Menu {
                        Button("Edit", action: onEdit)
                        Button("Delete", role: .destructive, action: onDelete)
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .foregroundColor(.secondary)
                            .padding(2)
                    }
                }
                
                // Theme name
                Text(theme.name)
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

struct CustomThemeEditor: View {
    @Binding var isPresented: Bool
    var editingTheme: CustomTheme?
    @StateObject private var themeManager = ThemeManager.shared
    @State private var themeName = ""
    @State private var backgroundColor = Color.white
    @State private var titleColor = Color.black
    @State private var foregroundColor = Color.black
    @State private var selectedTitleFont = "SF Pro Display"
    @State private var selectedBodyFont = "SF Pro Text"
    @State private var logoImage: NSImage?
    private let systemFonts = getSystemFonts()
    
    init(isPresented: Binding<Bool>, editingTheme: CustomTheme? = nil) {
        self._isPresented = isPresented
        self.editingTheme = editingTheme
        
        if let theme = editingTheme {
            _themeName = State(initialValue: theme.name)
            _backgroundColor = State(initialValue: theme.backgroundColor)
            _titleColor = State(initialValue: theme.titleColor)
            _foregroundColor = State(initialValue: theme.foregroundColor)
            _selectedTitleFont = State(initialValue: theme.titleFont)
            _selectedBodyFont = State(initialValue: theme.defaultFont)
            if let logoData = theme.logo,
               let image = NSImage(data: logoData) {
                _logoImage = State(initialValue: image)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Theme Name", text: $themeName)
                ColorPickerRow(title: "Background Color", color: $backgroundColor)
                ColorPickerRow(title: "Title Color", color: $titleColor)
                ColorPickerRow(title: "Body Color", color: $foregroundColor)
                FontPickerRow(title: "Title Font", selectedFont: $selectedTitleFont, fonts: systemFonts)
                FontPickerRow(title: "Body Font", selectedFont: $selectedBodyFont, fonts: systemFonts)
                
                HStack {
                    Text("Logo")
                    Spacer()
                    Button("Choose Logo") {
                        selectLogo()
                    }
                }
                
                if let logo = logoImage {
                    Image(nsImage: logo)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                }
            }
            .padding()
            .frame(width: 400)
            .navigationTitle("New Theme")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTheme()
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func selectLogo() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.image]
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                logoImage = NSImage(contentsOf: url)
            }
        }
    }
    
    private func saveTheme() {
        let theme = CustomTheme(
            id: editingTheme?.id ?? UUID(),
            name: themeName,
            backgroundColor: backgroundColor,
            titleColor: titleColor,
            foregroundColor: foregroundColor,
            logo: logoImage?.tiffRepresentation,
            defaultFont: selectedBodyFont,
            titleFont: selectedTitleFont
        )
        
        themeManager.saveTheme(theme)
        isPresented = false
    }
} 