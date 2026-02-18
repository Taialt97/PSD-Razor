import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var inputFilePaths: [String] = []
    @StateObject private var shellRunner = ShellRunner()
    @State private var isTargeted = false
    
    var body: some View {
        VStack(spacing: 20) {
            
            // Drag and Drop Area
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                    .foregroundColor(isTargeted ? .accentColor : .secondary.opacity(0.5))
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                             .fill(isTargeted ? Color.accentColor.opacity(0.1) : Color(NSColor.controlBackgroundColor))
                    )
                
                if inputFilePaths.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "arrow.down.doc.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.secondary)
                        Text("Drop PSD Files Here")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        Text("or click to browse")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                } else {
                    VStack(spacing: 1) {
                        Image(systemName: "doc.on.doc.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.blue)
                            .shadow(radius: 2)
                        
                        VStack(spacing: 2) {
                            if inputFilePaths.count == 1 {
                                Text(URL(fileURLWithPath: inputFilePaths[0]).lastPathComponent)
                                    .font(.system(size: 13, weight: .medium))
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                    .padding(.horizontal, 8)
                                
                                Text(inputFilePaths[0])
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.head)
                                    .padding(.horizontal, 12)
                            } else {
                                Text("\(inputFilePaths.count) Files Selected")
                                    .font(.system(size: 13, weight: .medium))
                                
                                Text("Ready to process")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Button(action: {
                            withAnimation {
                                inputFilePaths = []
                                shellRunner.output = ""
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .font(.system(size: 16))
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 5)
                        .help("Clear selection")
                    }
                }
            }
            .frame(height: 140)
            .contentShape(Rectangle())
            .onTapGesture {
                if inputFilePaths.isEmpty {
                    selectInputFile()
                }
            }
            .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
                let group = DispatchGroup()
                var newPaths: [String] = []
                
                for provider in providers {
                    group.enter()
                    _ = provider.loadObject(ofClass: URL.self) { url, error in
                        if let url = url {
                            DispatchQueue.main.async {
                                newPaths.append(url.path)
                                group.leave()
                            }
                        } else {
                            group.leave()
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    if !newPaths.isEmpty {
                        withAnimation {
                            self.inputFilePaths = newPaths
                            self.shellRunner.output = ""
                        }
                    }
                }
                return true
            }
            
            // Action Button
            Button(action: {
                runScript()
            }) {
                HStack {
                    if shellRunner.isRunning {
                        ProgressView()
                            .controlSize(.small)
                            .padding(.trailing, 5)
                    }
                    Text(shellRunner.isRunning ? "Processing..." : (inputFilePaths.count > 1 ? "Reduce \(inputFilePaths.count) Files" : "Reduce File Size"))
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(inputFilePaths.isEmpty || shellRunner.isRunning)
            
            // Console Output
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Output")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                ScrollViewReader { proxy in
                    ScrollView {
                        Text(shellRunner.output)
                            .font(.system(size: 11, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .fixedSize(horizontal: false, vertical: true)
                            .id("output")
                    }
                    .frame(height: 150)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.black.opacity(0.1), lineWidth: 1)
                    )
                    .onChange(of: shellRunner.output) { _ in
                        withAnimation {
                            proxy.scrollTo("output", anchor: .bottom)
                        }
                    }
                }
            }
        }
        .padding(20)
        .frame(width: 280)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    func selectInputFile() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = [.image] 
        
        if panel.runModal() == .OK {
            withAnimation {
                inputFilePaths = panel.urls.map { $0.path }
                shellRunner.output = ""
            }
        }
    }
    
    func runScript() {
        if let scriptPath = Bundle.main.path(forResource: "psd_ockham", ofType: nil) {
            shellRunner.run(executablePath: scriptPath, inputPaths: inputFilePaths)
        } else {
             shellRunner.appendOutput("Error: 'psd_ockham' not found in bundle.\n")
        }
    }
}
