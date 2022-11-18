//
//  CoinbaseWalletHostSDK.swift
//  MobileWalletProtocol
//
//  Created by Jungho Bang on 9/2/22.
//

import Foundation
import CryptoKit

@available(iOS 13.0, *)
public final class CoinbaseWalletHostSDK {
    public static func deriveSymmetricKey(
        with ownPrivateKey: PrivateKey,
        _ peerPublicKey: PublicKey
    ) throws -> SymmetricKey {
        return try Cipher.deriveSymmetricKey(with: ownPrivateKey, peerPublicKey)
    }
    
    public static func encode<C>(
        _ message: Message<C>,
        to recipient: URL,
        with symmetricKey: SymmetricKey?
    ) throws -> URL {
        return try MessageConverter.encode(message, to: recipient, with: symmetricKey)
    }
    
    public static func decode<C>(
        _ url: URL,
        with symmetricKey: SymmetricKey?
    ) throws -> Message<C> {
        return try MessageConverter.decode(url, with: symmetricKey)
    }
}
