import Foundation
import SwiftUI
import Combine
import AppKit

class ShellRunner: ObservableObject {
    @Published var output: String = ""
    @Published var isRunning: Bool = false
    
    private var task: Process?
    
    func appendOutput(_ text: String) {
        DispatchQueue.main.async {
            self.output += text
        }
    }
    
    func run(executablePath: String, inputPaths: [String]) {
        guard !executablePath.isEmpty else {
             appendOutput("Error: Executable path not found. Please ensure psd_ockham is inside the app bundle.\n")
             return
        }
        
        guard !inputPaths.isEmpty else {
            appendOutput("Error: No input files selected.\n")
            return
        }
        
        self.output = ""
        self.isRunning = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.fixPermissions(executablePath: executablePath)
            
            var allSuccess = true
            
            for (index, inputPath) in inputPaths.enumerated() {
                self.appendOutput("\n--- Processing File \(index + 1) of \(inputPaths.count): \(URL(fileURLWithPath: inputPath).lastPathComponent) ---\n")
                
                let exitCode = self.runProcessSync(executablePath: executablePath, inputPath: inputPath)
                
                if exitCode != 0 {
                    allSuccess = false
                }
            }
            
            DispatchQueue.main.async {
                self.isRunning = false
                self.appendOutput("\nAll operations completed.\n")
                if allSuccess {
                     NSSound(named: "Glass")?.play()
                } else {
                     NSSound(named: "Basso")?.play()
                }
            }
        }
    }
    
    private func fixPermissions(executablePath: String) {
        appendOutput("Fixing permissions for: \(executablePath)\n")
        
        // 1. chmod +x
        let chmodTask = Process()
        chmodTask.executableURL = URL(fileURLWithPath: "/bin/chmod")
        chmodTask.arguments = ["+x", executablePath]
        
        do {
            try chmodTask.run()
            chmodTask.waitUntilExit()
            if chmodTask.terminationStatus == 0 {
                appendOutput("  ✓ chmod +x success\n")
            } else {
                appendOutput("  ⚠ chmod +x failed (status: \(chmodTask.terminationStatus))\n")
            }
        } catch {
            appendOutput("  ⚠ chmod +x error: \(error.localizedDescription)\n")
        }
        
        // 2. xattr -d com.apple.quarantine
        let xattrTask = Process()
        xattrTask.executableURL = URL(fileURLWithPath: "/usr/bin/xattr")
        xattrTask.arguments = ["-d", "com.apple.quarantine", executablePath]
        
        // We ignore output for xattr since it often fails if attribute doesn't exist, which is fine.
        do {
            try xattrTask.run()
            xattrTask.waitUntilExit()
            if xattrTask.terminationStatus == 0 {
                appendOutput("  ✓ Quarantine removed\n")
            } else {
                // Not necessarily an error if it wasn't quarantined
                appendOutput("  ℹ Quarantine check done (status: \(xattrTask.terminationStatus))\n")
            }
        } catch {
             appendOutput("  ℹ xattr check error: \(error.localizedDescription)\n")
        }
        
        appendOutput("Permissions fixed.\n\n")
    }
    
    private func runProcessSync(executablePath: String, inputPath: String) -> Int32 {
        appendOutput("Starting process for: \(inputPath)\n")
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executablePath)
        process.arguments = [inputPath]
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        // Handle output reading
        outputPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            if let str = String(data: data, encoding: .utf8), !str.isEmpty {
                self?.appendOutput(str)
            }
        }
        
        errorPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            if let str = String(data: data, encoding: .utf8), !str.isEmpty {
                self?.appendOutput(str)
            }
        }
        
        self.task = process
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let status = process.terminationStatus
            appendOutput("\nProcess finished with exit code: \(status)\n")
            
            // Clean up handlers
            outputPipe.fileHandleForReading.readabilityHandler = nil
            errorPipe.fileHandleForReading.readabilityHandler = nil
            
            return status
            
        } catch {
            appendOutput("\nError running process: \(error.localizedDescription)\n")
            
            // Clean up handlers
            outputPipe.fileHandleForReading.readabilityHandler = nil
            errorPipe.fileHandleForReading.readabilityHandler = nil
            
            return -1
        }
    }
    
    func stop() {
        if let task = task, task.isRunning {
            task.terminate()
            appendOutput("\nProcess terminated by user.\n")
        }
    }
}
