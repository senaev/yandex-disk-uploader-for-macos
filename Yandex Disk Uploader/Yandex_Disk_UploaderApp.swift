//
//  Yandex_Disk_UploaderApp.swift
//  Yandex Disk Uploader
//
//  Created by Andrei Senaev on 12. 2. 2026..
//

import SwiftUI

@main
struct Yandex_Disk_UploaderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // Иконка облака в верхней панели с контекстным меню
        MenuBarExtra("Yandex Disk Uploader", systemImage: "icloud.and.arrow.up") {
            MenuBarView()
        }
        
        // Окно настроек (id для openWindow и для поиска по NSApp.windows)
        Window("Settings", id: "settings") {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}

// Делегат для управления поведением приложения
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if UserDefaults.standard.bool(forKey: "shouldOpenSettingsOnLaunch") {
            UserDefaults.standard.set(false, forKey: "shouldOpenSettingsOnLaunch")
            UserDefaults.standard.synchronize()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.openSettings()
            }
        } else {
            // Скрываем окно настроек при обычном запуске
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                for window in NSApp.windows {
                    if window.identifier?.rawValue == "settings" || window.title == "Settings" {
                        window.orderOut(nil)
                        break
                    }
                }
            }
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // При клике на иконку в Dock открываем настройки
        if !flag {
            openSettings()
        }
        return true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Закрывать приложение при закрытии последнего окна
        return true
    }
    
    func application(_ application: NSApplication, open urls: [URL]) {
        // Обработка URL scheme: yandexdiskuploader://settings
        for url in urls where url.scheme == "yandexdiskuploader" && url.host == "settings" {
            openSettings()
            return
        }
    }
    
    func openSettings() {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        // Открываем окно настроек по id или по заголовку (без приватного API)
        DispatchQueue.main.async {
            for window in NSApp.windows {
                if window.identifier?.rawValue == "settings" || window.title == "Settings" {
                    window.makeKeyAndOrderFront(nil)
                    return
                }
            }
        }
    }
}
