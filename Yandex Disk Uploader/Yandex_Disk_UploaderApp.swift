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
        // Settings вместо Window - не открывается автоматически при первом запуске
        Settings {
            ContentView()
        }
    }
}

// Делегат для управления поведением приложения
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Проверяем, нужно ли открыть настройки (флаг от extension)
        if UserDefaults.standard.bool(forKey: "shouldOpenSettingsOnLaunch") {
            // Сбрасываем флаг
            UserDefaults.standard.set(false, forKey: "shouldOpenSettingsOnLaunch")
            UserDefaults.standard.synchronize()
            
            // Открываем настройки
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.openSettings()
            }
        } else {
            // Обычный запуск - ничего не открываем, просто регистрируем extension
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
    
    func openSettings() {
        NSApp.setActivationPolicy(.regular)
        // Открываем окно настроек (⌘,)
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
