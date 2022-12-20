//
//  ActionResultRecord.swift
//  CoinbaseWalletSDKExpo
//
//  Created by Vishnu Madhusoodanan on 12/16/22.
//

import CoinbaseWalletSDK
import ExpoModulesCore
import Foundation

struct ActionResultRecord : Record {
    @Field
    var result: String?

    @Field
    var errorMessage: String?

    @Field
    var errorCode: Int?
}
