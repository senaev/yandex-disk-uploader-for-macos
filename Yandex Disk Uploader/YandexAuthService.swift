//
//  YandexAuthService.swift
//  Yandex Disk Uploader
//

import Foundation
import SwiftUI
import AppKit

/// OAuth credentials — register your app at https://oauth.yandex.com and add Redirect URI: yandexdiskuploader://oauth
enum YandexOAuthConfig {
    static var clientID: String {
        (Bundle.main.object(forInfoDictionaryKey: "YandexOAuthClientID") as? String) ?? "YOUR_CLIENT_ID"
    }
    static var clientSecret: String {
        (Bundle.main.object(forInfoDictionaryKey: "YandexOAuthClientSecret") as? String) ?? "YOUR_CLIENT_SECRET"
    }
    static let redirectURI = "yandexdiskuploader://oauth"
    static let scope = "cloud_api:disk.write cloud_api:disk.read"
}

private let accessTokenKey = "yandex_disk_access_token"
private let refreshTokenKey = "yandex_disk_refresh_token"

final class YandexAuthService: ObservableObject {
    static let shared = YandexAuthService()

    @Published private(set) var isAuthorized: Bool = false
    @Published private(set) var authError: String?

    private init() {
        let hasToken = UserDefaults.standard.string(forKey: accessTokenKey) != nil
        isAuthorized = hasToken
        if !hasToken { UserDefaults.standard.set(false, forKey: "isAuthorized") }
    }

    var accessToken: String? {
        UserDefaults.standard.string(forKey: accessTokenKey)
    }

    func authorizeURL() -> URL {
        var comp = URLComponents(string: "https://oauth.yandex.com/authorize")!
        comp.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: YandexOAuthConfig.clientID),
            URLQueryItem(name: "redirect_uri", value: YandexOAuthConfig.redirectURI),
            URLQueryItem(name: "scope", value: YandexOAuthConfig.scope),
            URLQueryItem(name: "force_confirm", value: "yes")
        ]
        return comp.url!
    }

    func startAuthorization() {
        authError = nil
        NSWorkspace.shared.open(authorizeURL())
    }

    func handleCallback(url: URL) -> Bool {
        guard url.scheme == "yandexdiskuploader", url.host == "oauth" else { return false }
        guard let comp = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return true }
        if let code = comp.queryItems?.first(where: { $0.name == "code" })?.value {
            exchangeCode(code)
            return true
        }
        if let error = comp.queryItems?.first(where: { $0.name == "error_description" })?.value ?? comp.queryItems?.first(where: { $0.name == "error" })?.value {
            DispatchQueue.main.async { [weak self] in
                self?.authError = error
            }
        }
        return true
    }

    private func exchangeCode(_ code: String) {
        let url = URL(string: "https://oauth.yandex.com/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let credentials = "\(YandexOAuthConfig.clientID):\(YandexOAuthConfig.clientSecret)"
        if let data = credentials.data(using: .utf8) {
            request.setValue("Basic \(data.base64EncodedString())", forHTTPHeaderField: "Authorization")
        }
        let body = [
            "grant_type=authorization_code",
            "code=\(code.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? code)"
        ].joined(separator: "&")
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.authError = error.localizedDescription
                    return
                }
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let token = json["access_token"] as? String else {
                    self?.authError = (try? JSONSerialization.jsonObject(with: data ?? Data()) as? [String: Any]).flatMap { $0["error_description"] as? String } ?? "Invalid response"
                    return
                }
                UserDefaults.standard.set(token, forKey: accessTokenKey)
                if let refresh = json["refresh_token"] as? String {
                    UserDefaults.standard.set(refresh, forKey: refreshTokenKey)
                }
                UserDefaults.standard.set(true, forKey: "isAuthorized")
                self?.authError = nil
                self?.isAuthorized = true
            }
        }.resume()
    }

    func disconnect() {
        UserDefaults.standard.removeObject(forKey: accessTokenKey)
        UserDefaults.standard.removeObject(forKey: refreshTokenKey)
        UserDefaults.standard.set(false, forKey: "isAuthorized")
        isAuthorized = false
        authError = nil
    }
}
