//
//  ShareViewController.swift
//  YandexDiskShareExtension
//
//  Created by Andrei Senaev on 12. 2. 2026..
//

import Cocoa

class ShareViewController: NSViewController {
    
    private var messageLabel: NSTextField!
    private var infoLabel: NSTextField!
    private var sendButton: NSButton!
    private var cancelButton: NSButton!
    private var isAuthorized: Bool = false
    
    override var nibName: NSNib.Name? {
        return nil
    }
    
    override func loadView() {
        // Check authorization status from UserDefaults
        isAuthorized = UserDefaults.standard.bool(forKey: "isAuthorized")
        
        // Create the main view
        let mainView = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 200))
        self.view = mainView
        
        // Message label
        let message = isAuthorized ? "Send files to Yandex Disk?" : "Configuration Required"
        messageLabel = NSTextField(labelWithString: message)
        messageLabel.font = NSFont.systemFont(ofSize: 14, weight: isAuthorized ? .regular : .semibold)
        messageLabel.alignment = .center
        messageLabel.frame = NSRect(x: 20, y: 120, width: 360, height: 40)
        mainView.addSubview(messageLabel)
        
        // Info label
        let info = isAuthorized ? "Files will be uploaded to Yandex Disk" : "Please open Yandex Disk Uploader to authorize"
        infoLabel = NSTextField(labelWithString: info)
        infoLabel.font = NSFont.systemFont(ofSize: 11)
        infoLabel.textColor = .secondaryLabelColor
        infoLabel.alignment = .center
        infoLabel.frame = NSRect(x: 20, y: 90, width: 360, height: 20)
        mainView.addSubview(infoLabel)
        
        // Buttons container
        let buttonContainer = NSView(frame: NSRect(x: 0, y: 20, width: 400, height: 40))
        
        // Cancel button
        cancelButton = NSButton(title: "Cancel", target: self, action: #selector(cancel))
        cancelButton.bezelStyle = .rounded
        cancelButton.frame = NSRect(x: 180, y: 0, width: 100, height: 32)
        cancelButton.keyEquivalent = "\u{1b}" // Escape key
        buttonContainer.addSubview(cancelButton)
        
        // Send or Configure button
        let buttonTitle = isAuthorized ? "Send" : "Open Settings"
        let buttonAction = isAuthorized ? #selector(send) : #selector(openSettings)
        sendButton = NSButton(title: buttonTitle, target: self, action: buttonAction)
        sendButton.bezelStyle = .rounded
        sendButton.frame = NSRect(x: 290, y: 0, width: 100, height: 32)
        sendButton.keyEquivalent = "\r" // Return key
        buttonContainer.addSubview(sendButton)
        
        mainView.addSubview(buttonContainer)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Log received files
        if let inputItems = extensionContext?.inputItems as? [NSExtensionItem] {
            for item in inputItems {
                if let attachments = item.attachments {
                    NSLog("✅ Received \(attachments.count) file(s)")
                    for attachment in attachments {
                        NSLog("  - Type: \(attachment.registeredTypeIdentifiers)")
                    }
                }
            }
        }
    }
    
    @objc func send(_ sender: AnyObject?) {
        NSLog("✅ Send button clicked")
        
        // Show that we received the files
        if let inputItems = extensionContext?.inputItems as? [NSExtensionItem] {
            for item in inputItems {
                if let attachments = item.attachments {
                    NSLog("📤 Would upload \(attachments.count) file(s)")
                }
            }
        }
        
        // Complete the request successfully
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    @objc func openSettings(_ sender: AnyObject?) {
        NSLog("⚙️ Opening settings...")
        
        // Устанавливаем флаг, что нужно открыть настройки
        UserDefaults.standard.set(true, forKey: "shouldOpenSettingsOnLaunch")
        UserDefaults.standard.synchronize()
        
        // Open the main app
        let bundleURL = Bundle.main.bundleURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Yandex Disk Uploader.app")
        
        NSWorkspace.shared.open(bundleURL)
        
        // Cancel the share request
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        extensionContext?.cancelRequest(withError: cancelError)
    }
    
    @objc func cancel(_ sender: AnyObject?) {
        NSLog("❌ Cancel button clicked")
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        extensionContext?.cancelRequest(withError: cancelError)
    }
}
