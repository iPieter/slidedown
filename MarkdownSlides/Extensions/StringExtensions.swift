import Foundation

extension String {
    /// Splits a markdown document into slides using --- as the separator.
    func splitIntoSlides() -> [String] {
        let pattern = "\n-{3,}\n"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let nsString = self as NSString
        let range = NSRange(location: 0, length: nsString.length)
        var lastIndex = 0
        var slides: [String] = []
        regex?.enumerateMatches(in: self, options: [], range: range) { match, _, _ in
            guard let match = match else { return }
            let slideRange = NSRange(location: lastIndex, length: match.range.location - lastIndex)
            let slide = nsString.substring(with: slideRange).trimmingCharacters(in: .whitespacesAndNewlines)
            if !slide.isEmpty { slides.append(slide) }
            lastIndex = match.range.location + match.range.length
        }
        // Add the last slide
        let lastSlide = nsString.substring(from: lastIndex).trimmingCharacters(in: .whitespacesAndNewlines)
        if !lastSlide.isEmpty { slides.append(lastSlide) }
        return slides
    }
    
    func firstMarkdownHeading(level: Int) -> String? {
        let prefix = String(repeating: "#", count: level) + " "
        return self.components(separatedBy: .newlines)
            .first { $0.hasPrefix(prefix) }?
            .replacingOccurrences(of: prefix, with: "")
            .trimmingCharacters(in: .whitespaces)
    }
    
    func bodyMarkdownText() -> String {
        self.components(separatedBy: .newlines)
            .filter { !$0.hasPrefix("#") && !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .joined(separator: " ")
    }
    
    func extractManimCodeBlocks() -> [(range: Range<String.Index>, code: String)] {
        var results: [(range: Range<String.Index>, code: String)] = []
        
        // Pattern to match ```manim blocks
        let pattern = #"```manim\n([\s\S]*?)\n```"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return results
        }
        
        let nsString = self as NSString
        let range = NSRange(location: 0, length: nsString.length)
        
        let matches = regex.matches(in: self, range: range)
        
        for match in matches {
            // Get the full range of the code block
            guard let fullRange = Range(match.range, in: self) else { continue }
            
            // Get just the code content (without the ```manim and closing ```)
            guard let codeRange = Range(match.range(at: 1), in: self) else { continue }
            
            results.append((fullRange, String(self[codeRange])))
        }
        
        return results
    }
} 