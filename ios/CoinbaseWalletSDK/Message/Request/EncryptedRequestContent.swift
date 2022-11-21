//
//  EncryptedRequestContent.swift
//  MobileWalletProtocol
//
//  Created by Jungho Bang on 6/23/22.
//

import Foundation
import CryptoKit

@available(iOS 13.0, *)
public enum EncryptedRequestContent: EncryptedContent {
    case handshake(appId: String, callback: URL, name: String?, iconUrl: URL?, initialActions: [Action]?)
    case request(data: Data)
    
    public func decrypt(with symmetricKey: SymmetricKey?) throws -> RequestContent {
        switch self {
        case let .handshake(appId, callback, name, iconUrl, initialActions):
            return .handshake(appId: appId, callback: callback, name: name, iconUrl: iconUrl, initialActions: initialActions)
        case let .request(data):
            guard let symmetricKey = symmetricKey else {
                throw MWPError.missingSymmetricKey
            }
            let request: Request = try Cipher.decrypt(data, with: symmetricKey)
            return .request(actions: request.actions, account: request.account)
        }
    }
}

@available(iOS 13.0, *)
extension RequestContent {
    public func encrypt(with symmetricKey: SymmetricKey?) throws -> EncryptedRequestContent {
        switch self {
        case let .handshake(appId, callback, name, iconUrl, initialActions):
            return .handshake(appId: appId, callback: callback, name: name, iconUrl: iconUrl, initialActions: initialActions)
        case let .request(actions, account):
            guard let symmetricKey = symmetricKey else {
                throw MWPError.missingSymmetricKey
            }
            let request = Request(actions: actions, account: account)
            return .request(data: try Cipher.encrypt(request, with: symmetricKey))
        }
    }
}

