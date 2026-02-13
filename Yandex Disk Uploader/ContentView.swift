//
//  ContentView.swift
//  Yandex Disk Uploader
//
//  Created by Andrei Senaev on 12. 2. 2026..
//

import SwiftUI

struct ContentView: View {
    @AppStorage("uploadFolder") private var uploadFolder = "/uploads"
    @EnvironmentObject private var authService: YandexAuthService

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 4) {
                Image(systemName: "icloud.and.arrow.up.fill")
                    .font(.system(size: 35))
                    .foregroundStyle(.blue)

                Text("Yandex Disk Uploader")
                    .font(.title3)
            }
            .padding(.top, 10)
            .padding(.bottom, 4)

            SettingsTabView(
                authService: authService,
                uploadFolder: $uploadFolder
            )

            HStack(spacing: 12) {
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }

                Button("Save") {
                    UserDefaults.standard.synchronize()
                    for w in NSApp.windows {
                        if w.identifier?.rawValue == "settings" || w.title == "Yandex Disk Uploader" {
                            w.close()
                            break
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.bottom, 12)
        }
        .frame(width: 500)
    }
}

struct SettingsTabView: View {
    @ObservedObject var authService: YandexAuthService
    @Binding var uploadFolder: String

    var body: some View {
        VStack(spacing: 20) {
            // Authorization status
            GroupBox {
                HStack(spacing: 15) {
                    Image(systemName: authService.isAuthorized ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(authService.isAuthorized ? .green : .red)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(authService.isAuthorized ? "Authorized" : "Not Authorized")
                            .font(.headline)
                        Text(authService.isAuthorized ? "Connected to Yandex Disk" : "Click Authorize to connect in the browser")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        if let error = authService.authError {
                            Text(error)
                                .font(.caption2)
                                .foregroundColor(.red)
                        }
                    }

                    Spacer()

                    Button(authService.isAuthorized ? "Disconnect" : "Authorize") {
                        if authService.isAuthorized {
                            authService.disconnect()
                        } else {
                            authService.startAuthorization()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(10)
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
            }
        }
        .padding(20)
    }
}

#Preview {
    ContentView()
        .environmentObject(YandexAuthService.shared)
}
