//
//  EncryptedMessage.swift
//  WalletSegue
//
//  Created by Jungho Bang on 6/23/22.
//

import Foundation
import CryptoKit

public protocol EncryptedContent: CodableContent {
    associatedtype Unencrypted: UnencryptedContent where Unencrypted.Encrypted == Self
    
    func decrypt(with symmetricKey: SymmetricKey?) throws -> Unencrypted
}

typealias EncryptedMessage<C> = CodableMessage<C> where C: EncryptedContent

extension EncryptedMessage {
    func decrypt(with symmetricKey: SymmetricKey?) throws -> Message<C.Unencrypted> {
        return Message<C.Unencrypted>.copy(
            self,
            replaceContentWith: try self.content.decrypt(with: symmetricKey)
        )
    }
}

extension Message {
    func encrypt(with symmetricKey: SymmetricKey?) throws -> EncryptedMessage<C.Encrypted> {
        return EncryptedMessage<C.Encrypted>.copy(
            self,
            replaceContentWith: try self.content.encrypt(with: symmetricKey)
        )
    }
}
