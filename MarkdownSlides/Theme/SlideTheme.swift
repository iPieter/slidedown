import SwiftUI

enum SlideTheme: String, CaseIterable, Identifiable {
    case newYork = "New York"
    case sanFrancisco = "San Francisco"
    case zurich = "Zurich"
    case paris = "Paris"
    case milano = "Milano"
    case tokyo = "Tokyo"
    case vancouver = "Vancouver"
    case la = "LA"
    case copenhagen = "Copenhagen"
    case basel = "Basel"
    // Keep existing themes as fallbacks
    case light = "Light"
    case dark = "Dark"
    
    var id: String { rawValue }
    
    // Updated colors to match modern aesthetic
    var backgroundColor: Color {
        switch self {
        case .newYork: return Color(red: 0.10, green: 0.11, blue: 0.13)
        case .sanFrancisco: return Color(red: 0.95, green: 0.97, blue: 1.0)
        case .zurich: return Color(red: 0.95, green: 0.95, blue: 0.95)
        case .paris: return Color.white
        case .milano: return Color(red: 0.97, green: 0.95, blue: 0.90)
        case .tokyo: return Color(red: 0.90, green: 0.95, blue: 1.0)
        case .vancouver: return Color(red: 0.90, green: 0.98, blue: 0.95)
        case .la: return Color(red: 1.0, green: 0.95, blue: 0.95)
        case .copenhagen: return Color(red: 0.95, green: 0.98, blue: 0.92)
        case .basel: return Color(red: 0.92, green: 0.92, blue: 0.94)
        // Existing themes
        case .light: return Color(red: 0.98, green: 0.98, blue: 0.98)
        case .dark: return Color(red: 0.10, green: 0.11, blue: 0.13)
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .newYork, .dark: return Color.white
        case .sanFrancisco, .tokyo: return Color(red: 0.10, green: 0.10, blue: 0.60)
        case .la: return Color(red: 0.80, green: 0.10, blue: 0.40) 
        case .zurich, .paris, .milano, .vancouver, .copenhagen, .basel, .light: return Color(red: 0.10, green: 0.10, blue: 0.12)
        }
    }
    
    // Add title colors that can be different from body text
    var titleColor: Color {
        switch self {
        case .newYork: return Color(red: 0.95, green: 0.80, blue: 0.30) // Gold
        case .sanFrancisco: return Color(red: 0.0, green: 0.40, blue: 0.90)
        case .la: return Color(red: 0.90, green: 0.30, blue: 0.60)
        default: return foregroundColor
        }
    }
    
    var accentColor: Color {
        switch self {
        case .light: return Color(red: 0.20, green: 0.60, blue: 0.86)
        case .dark: return Color(red: 1.0, green: 0.65, blue: 0.0)
        case .newYork: return Color(red: 1.0, green: 0.85, blue: 0.40)
        case .sanFrancisco: return Color(red: 0.90, green: 0.95, blue: 1.0)
        case .zurich: return Color(red: 0.90, green: 0.95, blue: 1.0)
        case .paris: return Color(red: 0.90, green: 0.95, blue: 1.0)
        case .milano: return Color(red: 0.90, green: 0.95, blue: 1.0)
        case .tokyo: return Color(red: 0.90, green: 0.95, blue: 1.0)
        case .vancouver: return Color(red: 0.90, green: 0.95, blue: 1.0)
        case .la: return Color(red: 0.90, green: 0.95, blue: 1.0)
        case .copenhagen: return Color(red: 0.90, green: 0.95, blue: 1.0)
        case .basel: return Color(red: 0.90, green: 0.95, blue: 1.0)
        }
    }
    
    var titleFontDesign: Font.Design {
        switch self {
        case .newYork, .sanFrancisco, .zurich, .paris, .milano, .tokyo, .vancouver, .la, .copenhagen, .basel: return .rounded
        case .light, .dark: return .default
        }
    }
    
    var bodyFontDesign: Font.Design {
        switch self {
        case .newYork, .sanFrancisco, .zurich, .paris, .milano, .tokyo, .vancouver, .la, .copenhagen, .basel: return .rounded
        case .light, .dark: return .default
        }
    }
    
    // Add gradient support
    var backgroundView: AnyView {
        switch self {
        case .newYork, .sanFrancisco, .zurich, .paris, .milano, .tokyo, .vancouver, .la, .copenhagen, .basel:
            return AnyView(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.2, blue: 0.4),
                        Color(red: 0.4, green: 0.1, blue: 0.6)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        default:
            return AnyView(backgroundColor)
        }
    }
    
    // Font weight for titles
    var titleFontWeight: Font.Weight {
        switch self {
        case .newYork, .sanFrancisco, .zurich, .paris, .milano, .tokyo, .vancouver, .la, .copenhagen, .basel: return .bold
        case .light, .dark: return .bold
        }
    }
}

// Define appearance enum
enum AppAppearance {
    case light
    case dark
} 