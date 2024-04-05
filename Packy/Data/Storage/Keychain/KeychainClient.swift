//
//  KeychainClient.swift
//  Packy
//
//  Created Mason Kim on 1/15/24.
//

import Foundation
import Dependencies

enum KeychainKey: String {
    case accessToken
    case refreshToken
    case memberId
}

// MARK: - Dependency Values

extension DependencyValues {
    // 변수명 소문자로 변경 필요
    var keychain: KeychainClient {
        get { self[KeychainClient.self] }
        set { self[KeychainClient.self] = newValue }
    }
}

// MARK: - KeychainClient Client

struct KeychainClient {
    var save: @Sendable (KeychainKey, String) -> Void
    var read: @Sendable (KeychainKey) -> (String?)
    var delete: @Sendable (KeychainKey) -> Void
}

extension KeychainClient: DependencyKey {
    static let liveValue: Self = {
        let controller = KeychainController()
        return Self(
            save: {
                let data = $1.data(using: .utf8)
                if let _ = controller.read($0) {
                    controller.update(data, key: $0)
                    return
                }
                controller.create(data, key: $0)
            },
            read: {
                guard let tokenData = controller.read($0) else { return nil }
                return String(data: tokenData, encoding: .utf8)
            },
            delete: {
                controller.delete($0)
            }
        )
    }()
}

private struct KeychainController {
    private let service: String = "Packy"

    func create(_ data: Data?, key: KeychainKey) {
        guard let data = data else {
            print("🗝️ '\(key)' Data nil")
            return
        }

        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key.rawValue,
            kSecValueData: data
        ]

        let status = SecItemAdd(query, nil)
        guard status == errSecSuccess else {
            print("🗝️ '\(key)' Status = \(status)")
            return
        }
        print("🗝️ '\(key)' Success!")
    }

    // MARK: Read Item

    func read(_ key: KeychainKey) -> Data? {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key.rawValue,
            kSecMatchLimit: kSecMatchLimitOne,
            kSecReturnData: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        guard status != errSecItemNotFound else {
            print("🗝️ '\(key)' Item Not Found")
            return nil
        }
        guard status == errSecSuccess else {
            return nil
        }
        print("🗝️ '\(key)' Success!")
        return result as? Data
    }

    // MARK: Update Item

    func update(_ data: Data?, key: KeychainKey) {
        guard let data = data else {
            print("🗝️ '\(key)' Data nil")
            return
        }

        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key.rawValue
        ]
        let attributes: NSDictionary = [
            kSecValueData: data
        ]

        let status = SecItemUpdate(query, attributes)
        guard status == errSecSuccess else {
            print("🗝️ '\(key)' Status = \(status)")
            return
        }
        print("🗝️ '\(key)' Success!")
    }

    // MARK: Delete Item

    func delete(_ key: KeychainKey) {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key.rawValue
        ]

        let status = SecItemDelete(query)
        guard status != errSecItemNotFound else {
            print("🗝️ '\(key)' Item Not Found")
            return
        }
        guard status == errSecSuccess else {
            return
        }
        print("🗝️ '\(key)' Success!")
    }
}
