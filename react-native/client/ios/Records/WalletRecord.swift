//
//  WalletRecord.swift
//  CoinbaseWalletSDKExpo
//
//  Created by Vishnu Madhusoodanan on 12/16/22.
//

import CoinbaseWalletSDK
import ExpoModulesCore
import Foundation

struct WalletIdentifierRecord : Record {
    @Field
    var platform: String = "ios"

    @Field
    var mwpScheme: String
}

struct WalletRecord : Record {
    @Field
    var name: String

    @Field
    var iconUrl: String

    @Field
    var url: String

    @Field
    var appStoreUrl: String

    @Field
    var id: WalletIdentifierRecord
}

extension WalletRecord {
    var asWallet: Wallet {
        return Wallet(
            name: self.name,
            iconUrl: URL(string:  self.iconUrl)!,
            url: URL(string: self.url)!,
            mwpScheme: URL(string: self.id.mwpScheme)!,
            appStoreUrl: URL(string: self.appStoreUrl)!
        )
    }
}
