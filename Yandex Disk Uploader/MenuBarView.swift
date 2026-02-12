//
//  MenuBarView.swift
//  Yandex Disk Uploader
//
//  Created by Andrei Senaev on 12. 2. 2026..
//

import SwiftUI

struct MenuBarView: View {
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack(spacing: 0) {
            Button {
                NSApp.activate(ignoringOtherApps: true)
                openWindow(id: "settings")
            } label: {
                Label("Settings...", systemImage: "gear")
            }
            .keyboardShortcut(",", modifiers: .command)
            
            Divider()
            
            Button {
                NSApp.orderFrontStandardAboutPanel(nil)
                NSApp.activate(ignoringOtherApps: true)
            } label: {
                Label("About", systemImage: "info.circle")
            }
            
            Divider()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
        }
        .frame(width: 200)
    }
}

#Preview {
    MenuBarView()
}
