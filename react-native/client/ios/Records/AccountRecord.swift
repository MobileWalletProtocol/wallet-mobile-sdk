//
//  AccountRecord.swift
//  CoinbaseWalletSDKExpo
//
//  Created by Vishnu Madhusoodanan on 12/16/22.
//

import CoinbaseWalletSDK
import ExpoModulesCore
import Foundation

struct AccountRecord : Record {
    @Field
    var chain: String

    @Field
    var networkId: Int

    @Field
    var address: String
}

extension AccountRecord {
    var asAccount: Account {
        return Account(
            chain: self.chain,
            networkId: UInt(self.networkId),
            address: self.address
        )
    }
}
