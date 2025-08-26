import SwiftUI
import WebKit

/// WebView component that supports localStorage persistence
/// localStorage data is stored in: ~/Library/Application Support/WebKit/
struct WebView: NSViewRepresentable {
    let url: URL
    
    func makeNSView(context: Context) -> WKWebView {
        // Create a custom website data store for localStorage persistence
        let dataStore = createPersistentDataStore()
        
        // Configure web view with persistent data store
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = dataStore
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.load(URLRequest(url: url))
        
        // Configure the web view for better interaction
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsMagnification = true
        
        // Make the web view accept keyboard events
        webView.window?.makeFirstResponder(webView)
        
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        // Ensure the web view remains the first responder for keyboard events
        if let window = nsView.window {
            window.makeFirstResponder(nsView)
        }
    }
    
    // Create a persistent data store for localStorage
    private func createPersistentDataStore() -> WKWebsiteDataStore {
        // Use the default data store which automatically persists localStorage
        // to the app's container directory (~/Library/Containers/com.yourapp/Data/Library/WebKit/)
        return WKWebsiteDataStore.default()
    }
    
    // Coordinator to handle focus events
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
    }
}

struct WebViewWithFallback: View {
    let url: URL
    let fallbackText: String
    
    var body: some View {
        WebView(url: url)
            .onAppear {
                // Optional: Add loading state or error handling
            }
    }
}

// MARK: - WebView Utilities

/// Utility functions for managing WebView localStorage data
struct WebViewUtilities {
    
    /// Get the path where WebView localStorage data is stored
    static func getLocalStoragePath() -> URL {
        // WKWebView stores data in the app's container directory
        let containerURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return containerURL.appendingPathComponent("WebKit")
    }
    
    /// Clear all localStorage data for WebViews
    static func clearLocalStorageData() {
        let localStoragePath = getLocalStoragePath()
        try? FileManager.default.removeItem(at: localStoragePath)
        try? FileManager.default.createDirectory(at: localStoragePath, withIntermediateDirectories: true, attributes: nil)
    }
    
    /// Get the size of localStorage data
    static func getLocalStorageSize() -> Int64 {
        let localStoragePath = getLocalStoragePath()
        guard let enumerator = FileManager.default.enumerator(at: localStoragePath, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        
        var totalSize: Int64 = 0
        for case let fileURL as URL in enumerator {
            if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                totalSize += Int64(fileSize)
            }
        }
        
        return totalSize
    }
} 