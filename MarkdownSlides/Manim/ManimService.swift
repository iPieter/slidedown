import Foundation

// A basic service to handle Manim code execution
class ManimService {
    func executeManimCode(_ code: String, completion: @escaping (Result<URL, Error>) -> Void) {
        // Create a temporary directory for Manim output
        let tempDir = FileManager.default.temporaryDirectory
        let uniqueID = UUID().uuidString
        let scriptPath = tempDir.appendingPathComponent("manim_\(uniqueID).py")
        let outputDir = tempDir.appendingPathComponent("manim_output_\(uniqueID)")
        
        // Create directory
        try? FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
        
        // Create Python script with the Manim code
        let pythonTemplate = """
        from manim import *
        
        class ManimScene(Scene):
            def construct(self):
        """
        
        // Indent the user code for the Python method
        let indentedCode = code.split(separator: "\n")
            .map { "        \($0)" }
            .joined(separator: "\n")
        
        let fullScript = pythonTemplate + "\n" + indentedCode
        
        // Write script to temp file
        do {
            try fullScript.write(to: scriptPath, atomically: true, encoding: .utf8)
            
            // Execute Manim (in a real app, do this asynchronously)
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/local/bin/python3")
            process.arguments = [
                "-m", "manim",
                scriptPath.path,
                "ManimScene",
                "-o", outputDir.path,
                "--quality", "m" // medium quality for faster rendering
            ]
            
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe
            
            try process.run()
            process.waitUntilExit()
            
            // Find the output file
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: outputDir,
                includingPropertiesForKeys: nil
            )
            
            if let videoURL = fileURLs.first(where: { $0.pathExtension == "mp4" }) {
                completion(.success(videoURL))
            } else {
                let error = NSError(
                    domain: "ManimService",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "No output file found"]
                )
                completion(.failure(error))
            }
            
        } catch {
            completion(.failure(error))
        }
    }
} 