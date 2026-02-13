//
//  ContentView.swift
//  Yandex Disk Uploader
//
//  Created by Andrei Senaev on 12. 2. 2026..
//

import SwiftUI

struct ContentView: View {
    @AppStorage("uploadFolder") private var uploadFolder = "/uploads"
    @AppStorage("isAuthorized") private var isAuthorized = false
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "icloud.and.arrow.up.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.blue)
                
                Text("Yandex Disk Uploader")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .padding(.top, 30)
            .padding(.bottom, 20)
            
            // Tabs
            Picker("", selection: $selectedTab) {
                Text("Settings").tag(0)
                Text("How to Use").tag(1)
                Text("About").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            
            // Content
            TabView(selection: $selectedTab) {
                SettingsTabView(
                    isAuthorized: $isAuthorized,
                    uploadFolder: $uploadFolder
                )
                .tag(0)
                
                HowToUseTabView()
                    .tag(1)
                
                AboutTabView()
                    .tag(2)
            }
            .tabViewStyle(.automatic)
            .frame(height: 300)
            
            Divider()
                .padding(.vertical, 8)
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
            .padding(.bottom, 12)
        }
        .frame(width: 500, height: 450)
    }
}

struct SettingsTabView: View {
    @Binding var isAuthorized: Bool
    @Binding var uploadFolder: String
    
    var body: some View {
        VStack(spacing: 20) {
            // Authorization status
            GroupBox {
                HStack(spacing: 15) {
                    Image(systemName: isAuthorized ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(isAuthorized ? .green : .red)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(isAuthorized ? "Authorized" : "Not Authorized")
                            .font(.headline)
                        Text(isAuthorized ? "Connected to Yandex Disk" : "Click Authorize to connect")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(isAuthorized ? "Disconnect" : "Authorize") {
                        // TODO: Реализовать OAuth
                        isAuthorized.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(10)
            } label: {
                Label("Account", systemImage: "person.circle")
            }
            
            // Upload folder
            GroupBox {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Destination folder on Yandex Disk:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField("/uploads", text: $uploadFolder)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(10)
            } label: {
                Label("Upload Settings", systemImage: "folder")
            }
            
            Spacer()
        }
        .padding(20)
    }
}

struct HowToUseTabView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("How to upload files:")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 15) {
                HStack(alignment: .top, spacing: 12) {
                    Text("1️⃣")
                        .font(.title2)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Open Finder and select a file")
                            .fontWeight(.medium)
                        Text("Right-click on any file or multiple files")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack(alignment: .top, spacing: 12) {
                    Text("2️⃣")
                        .font(.title2)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Select Share menu")
                            .fontWeight(.medium)
                        Text("Find 'YandexDiskShareExtension' in the list")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack(alignment: .top, spacing: 12) {
                    Text("3️⃣")
                        .font(.title2)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Click Send to upload")
                            .fontWeight(.medium)
                        Text("Files will be uploaded to Yandex Disk")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            
            Text("💡 Share Extension works even when this app is closed")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(20)
    }
}

struct AboutTabView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "icloud.and.arrow.up.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("Yandex Disk Uploader")
                .font(.title3)
                .fontWeight(.bold)
            
            Text("Version 1.0.0")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider()
                .padding(.vertical, 8)
            
            VStack(spacing: 8) {
                Text("Share Extension for macOS")
                Text("Upload files to Yandex Disk directly from Finder")
                Text("Built with Swift & SwiftUI")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            Spacer()
            
            Text("© 2026 All rights reserved")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(20)
    }
}

#Preview {
    ContentView()
}
