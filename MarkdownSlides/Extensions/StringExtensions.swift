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
    
    /// Extracts URLs from markdown content
    func extractURLs() -> [URL] {
        var urls: [URL] = []
        
        // Pattern to match markdown links: [text](url)
        let linkPattern = "\\[(.*?)\\]\\((.*?)\\)"
        
        if let regex = try? NSRegularExpression(pattern: linkPattern, options: []) {
            let nsString = NSString(string: self)
            let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for match in matches {
                if match.numberOfRanges >= 3 {
                    let urlRange = match.range(at: 2)
                    let urlString = nsString.substring(with: urlRange)
                    
                    if let url = URL(string: urlString) {
                        urls.append(url)
                    }
                }
            }
        }
        
        // Also look for plain URLs in the text
        let urlPattern = "https?://[^\\s]+"
        
        if let regex = try? NSRegularExpression(pattern: urlPattern, options: []) {
            let nsString = NSString(string: self)
            let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for match in matches {
                let urlString = nsString.substring(with: match.range)
                if let url = URL(string: urlString) {
                    urls.append(url)
                }
            }
        }
        
        return urls
    }
    
    /// Checks if the content is a simple title + URL slide
    func isTitleAndURLSlide() -> Bool {
        let title = firstMarkdownHeading(level: 1)
        let bodyContent = removeFirstHeading(from: self)
        let urls = bodyContent.extractURLs()
        
        // Check if we have a title and exactly one URL, with minimal other content
        let hasTitle = title != nil && !title!.isEmpty
        let hasSingleURL = urls.count == 1
        let minimalOtherContent = bodyContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || 
                                 bodyContent.trimmingCharacters(in: .whitespacesAndNewlines) == urls.first?.absoluteString
        
        return hasTitle && hasSingleURL && minimalOtherContent
    }
    
    /// Extracts the URL from a title + URL slide
    func extractURLFromTitleAndURLSlide() -> URL? {
        guard isTitleAndURLSlide() else { return nil }
        let bodyContent = removeFirstHeading(from: self)
        return bodyContent.extractURLs().first
    }
    
    /// Helper to remove first heading from content
    private func removeFirstHeading(from content: String) -> String {
        let lines = content.components(separatedBy: .newlines)
        var result: [String] = []
        var foundFirstHeading = false
        
        for line in lines {
            if !foundFirstHeading && line.hasPrefix("#") {
                foundFirstHeading = true
                continue
            }
            result.append(line)
        }
        
        return result.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
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