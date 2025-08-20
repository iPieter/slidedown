import Foundation

struct Slide: Identifiable, Codable {
    var id = UUID()
    var content: String // Markdown content
    var assets: [String: URL] = [:] // Asset references
}

struct Presentation: Codable {
    var title: String
    var author: String
    var slides: [Slide] = []
    var currentIndex: Int = 0
} 