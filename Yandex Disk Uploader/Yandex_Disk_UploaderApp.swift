//
//  Yandex_Disk_UploaderApp.swift
//  Yandex Disk Uploader
//
//  Created by Andrei Senaev on 12. 2. 2026..
//

import SwiftUI
import AppKit

extension Notification.Name {
    static let openSettingsWindow = Notification.Name("openSettingsWindow")
}

@main
struct Yandex_Disk_UploaderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        MenuBarExtra("Yandex Disk Uploader", systemImage: "icloud.and.arrow.up") {
            MenuBarContent()
        }
        
        // Окно настроек — открывается через openWindow (меню или по URL)
        Window("Yandex Disk Uploader", id: "settings") {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        
        // Скрытое окно: только чтобы OpenSettingsListener был в иерархии и ловил открытие по URL
        Window("", id: "listener") {
            OpenSettingsListener()
                .frame(width: 1, height: 1)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
    }
}

// Контент меню: открывает окно через openWindow (без NSPanel — нет task port error)
struct MenuBarContent: View {
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        Button("Settings...") {
            NSApp.setActivationPolicy(.accessory)
            NSApp.activate(ignoringOtherApps: true)
            openWindow(id: "settings")
        }
        .keyboardShortcut(",", modifiers: .command)
        
        Divider()

        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q", modifiers: .command)
    }
}

// Слушает уведомление «открыть настройки» (при открытии по URL) и вызывает openWindow
struct OpenSettingsListener: View {
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        Color.clear
            .frame(width: 1, height: 1)
            .onReceive(NotificationCenter.default.publisher(for: .openSettingsWindow)) { _ in
                NSApp.setActivationPolicy(.accessory)
                NSApp.activate(ignoringOtherApps: true)
                openWindow(id: "settings")
                // После показа окна снова фиксируем accessory (иногда система переключает на .regular)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    NSApp.setActivationPolicy(.accessory)
                }
            }
    }
}

// Делегат: всегда accessory — без иконки в Dock
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        // Как можно раньше, чтобы при запуске по URL не появиться в Dock
        NSApp.setActivationPolicy(.accessory)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        // Скрываем оба окна при старте (настройки и слушатель)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            for w in NSApp.windows {
                if w.identifier?.rawValue == "settings" || w.identifier?.rawValue == "listener" || w.title == "Yandex Disk Uploader" {
                    w.orderOut(nil)
                }
            }
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            NotificationCenter.default.post(name: .openSettingsWindow, object: nil)
        }
        return true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls where url.scheme == "yandexdiskuploader" && url.host == "settings" {
            NSApp.setActivationPolicy(.accessory)
            UserDefaults.standard.set(false, forKey: "shouldOpenSettingsOnLaunch")
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .openSettingsWindow, object: nil)
            }
            return
        }
    }
}
