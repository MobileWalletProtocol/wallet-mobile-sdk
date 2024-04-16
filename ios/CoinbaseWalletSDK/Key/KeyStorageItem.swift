//
//  KeyStorageItem.swift
//  MobileWalletProtocol
//
//  Created by Jungho Bang on 6/17/22.
//

import Foundation

struct KeyStorageItem<K: RawRepresentableKey> {
    let name: String
    
    init(_ name: String) {
        self.name = name
    }

    static var ownPrivateKey: KeyStorageItem<PrivateKey> {
        return KeyStorageItem<PrivateKey>("wsegue.ownPrivateKey")
    }
    
    static var peerPublicKey: KeyStorageItem<PublicKey> {
        return KeyStorageItem<PublicKey>("wsegue.peerPublicKey")
    }
}
