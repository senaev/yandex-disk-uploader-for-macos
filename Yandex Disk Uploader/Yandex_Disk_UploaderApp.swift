//
//  Yandex_Disk_UploaderApp.swift
//  Yandex Disk Uploader
//
//  Created by Andrei Senaev on 12. 2. 2026..
//

import SwiftUI
import AppKit

@main
struct Yandex_Disk_UploaderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // Иконка в menu bar, по клику — панель с настройками (не показывается в Dock)
        MenuBarExtra("Yandex Disk Uploader", systemImage: "icloud.and.arrow.up") {
            ContentView()
                .frame(width: 500, height: 450)
        }
        .menuBarExtraStyle(.window)
    }
}

// Делегат: только menu bar, без окна в Dock
class AppDelegate: NSObject, NSApplicationDelegate {
    private var settingsPanel: NSPanel?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            openSettings()
        }
        return true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls where url.scheme == "yandexdiskuploader" && url.host == "settings" {
            UserDefaults.standard.set(false, forKey: "shouldOpenSettingsOnLaunch")
            DispatchQueue.main.async {
                self.openSettings()
            }
            return
        }
    }
    
    func openSettings() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { self.openSettings() }
            return
        }
        NSApp.activate(ignoringOtherApps: true)
        
        if let panel = settingsPanel, panel.isVisible {
            panel.makeKeyAndOrderFront(nil)
            return
        }
        
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 450),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        panel.title = "Yandex Disk Uploader"
        panel.isFloatingPanel = true
        panel.becomesKeyOnlyIfNeeded = false
        panel.hidesOnDeactivate = false
        panel.contentViewController = NSHostingController(rootView: ContentView())
        panel.center()
        
        settingsPanel = panel
        panel.makeKeyAndOrderFront(nil)
    }
}
