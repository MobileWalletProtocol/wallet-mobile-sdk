//
//  InstanceMethodArgument.swift
//  coinbase_wallet_sdk
//
//  Created by Jungho Bang on 12/9/22.
//

import Foundation
import CoinbaseWalletSDK

struct InstanceMethodArgument<T: Decodable>: Decodable {
    let wallet: Wallet
    let argument: T?
}

struct NoArgument: Decodable {}
