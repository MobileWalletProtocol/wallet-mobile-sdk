//
//  ConfigParamsRecord.swift
//  CoinbaseWalletSDKExpo
//
//  Created by Vishnu Madhusoodanan on 12/16/22.
//

import ExpoModulesCore
import Foundation

struct ConfigParamsRecord : Record {
    @Field
    var callbackURL: String

    @Field
    var appID: String?

    @Field
    var appName: String?

    @Field
    var appIconURL: String?
}
