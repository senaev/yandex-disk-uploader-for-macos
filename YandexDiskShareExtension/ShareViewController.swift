//
//  ShareViewController.swift
//  YandexDiskShareExtension
//
//  Created by Andrei Senaev on 12. 2. 2026..
//

import Cocoa
import UserNotifications

class ShareViewController: NSViewController {
    
    override var nibName: NSNib.Name? {
        return nil
    }
    
    override func loadView() {
        // Минимальная пустая вью (расширение требует view)
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 1, height: 1))
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        let isAuthorized = UserDefaults.standard.bool(forKey: "isAuthorized")
        
        if isAuthorized {
            // Сразу "отправка" (заглушка — уведомление)
            performSend()
        } else {
            // Сразу открываем настройки
            openSettings()
        }
    }
    
    private func performSend() {
        var fileCount = 0
        if let inputItems = extensionContext?.inputItems as? [NSExtensionItem] {
            for item in inputItems {
                if let attachments = item.attachments {
                    fileCount += attachments.count
                }
            }
        }
        
        NSLog("📤 Upload (stub): \(fileCount) file(s)")
        
        // Заглушка: показываем уведомление
        showUploadNotification(fileCount: fileCount)
        
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    private func showUploadNotification(fileCount: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Yandex Disk Uploader"
        content.body = fileCount == 1
            ? "File will be uploaded to Yandex Disk"
            : "\(fileCount) files will be uploaded to Yandex Disk"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        )
        
        UNUserNotificationCenter.current().add(request) { _ in }
    }
    
    private func openSettings() {
        NSLog("⚙️ Opening settings...")
        
        UserDefaults.standard.set(true, forKey: "shouldOpenSettingsOnLaunch")
        UserDefaults.standard.synchronize()
        
        guard let url = URL(string: "yandexdiskuploader://settings") else { return }
        NSWorkspace.shared.open(url)
        
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        extensionContext?.cancelRequest(withError: cancelError)
    }
}
