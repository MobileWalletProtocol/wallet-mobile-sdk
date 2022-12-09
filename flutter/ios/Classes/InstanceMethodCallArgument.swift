//
//  InstanceMethodCallArgument.swift
//  coinbase_wallet_sdk
//
//  Created by Jungho Bang on 12/9/22.
//

import Foundation
import CoinbaseWalletSDK

struct InstanceMethodCallArgument<T: Codable>: Codable {
    let wallet: Wallet
    let arguments: T
}
