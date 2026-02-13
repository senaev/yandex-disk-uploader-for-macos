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

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 4) {
                Image(systemName: "icloud.and.arrow.up.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.blue)

                Text("Yandex Disk Uploader")
                    .font(.title3)
            }
            .padding(.top, 10)
            .padding(.bottom, 4)

            SettingsTabView(
                isAuthorized: $isAuthorized,
                uploadFolder: $uploadFolder
            )

            Divider()
                .padding(.vertical, 8)

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
            .padding(.bottom, 12)
        }
        .frame(width: 500)
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
        }
        .padding(20)
    }
}

#Preview {
    ContentView()
}
