//
//  KeyStorage.swift
//  MobileWalletProtocol
//
//  Created by Jungho Bang on 6/17/22.
//

import Foundation

@available(iOS 13.0, *)
final class KeyStorage {
    
    init(host: URL) {
        let service = "wsegue.keystorage.\((host.isHttp ? host.host : host.scheme) ?? host.absoluteString)"
        
        self.defaultQuery = [
            kSecAttrService: service,
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecUseDataProtectionKeychain: true
        ]
        
        let isInitializedKey = "\(service)-initialized"
        if UserDefaults.standard.bool(forKey: isInitializedKey) != true {
            SecItemDelete(self.defaultQuery as CFDictionary)
            UserDefaults.standard.set(true, forKey: isInitializedKey)
        }
    }
    
    private let defaultQuery: [CFString: Any]
    
    private func query<K>(
        for item: KeyStorageItem<K>,
        with other: [CFString: Any] = [:]
    ) -> CFDictionary {
        var query = self.defaultQuery
        query[kSecAttrAccount] = item.name
        return query.merging(other, uniquingKeysWith: { $1 }) as CFDictionary
    }
    
    func store<K>(_ data: K, at item: KeyStorageItem<K>) throws {
        try? self.delete(item)
        
        let query = query(for: item, with: [
            kSecValueData: data.rawRepresentation
        ])
        
        let status = SecItemAdd(query, nil)
        guard status == errSecSuccess else {
            throw KeyStorage.Error.storeFailed(status.message)
        }
    }
    
    func read<K>(_ item: KeyStorageItem<K>) throws -> K? {
        let query = query(for: item, with: [
            kSecReturnData: true
        ])
        
        var item: CFTypeRef?
        switch SecItemCopyMatching(query, &item) {
        case errSecSuccess:
            guard let data = item as? Data else { return nil }
            return try K(rawRepresentation: data)  // Convert back to a key.
        case errSecItemNotFound:
            return nil
        case let status:
            throw KeyStorage.Error.readFailed(status.message)
        }
    }
    
    func delete<K>(_ item: KeyStorageItem<K>) throws {
        let query = query(for: item)
        
        switch SecItemDelete(query) {
        case errSecItemNotFound, errSecSuccess:
            break // Okay to ignore
        case let status:
            throw KeyStorage.Error.deleteFailed(status.message)
        }
    }
}

@available(iOS 13.0, *)
extension KeyStorage {
    enum Error: Swift.Error {
        case storeFailed(String)
        case readFailed(String)
        case deleteFailed(String)
    }
}

extension OSStatus {
    var message: String {
        return (SecCopyErrorMessageString(self, nil) as String?) ?? String(self)
    }
}
