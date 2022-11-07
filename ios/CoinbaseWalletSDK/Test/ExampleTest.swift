//
//  ExampleTest.swift
//  CoinbaseWalletSDK-Unit-Test
//
//  Created by Jungho Bang on 10/7/22.
//

import XCTest
@testable import CoinbaseWalletSDK

class ExampleTest: XCTestCase {

    func testCoinbaseWalletSDKConfigureNotCalled() {
        CoinbaseWalletSDK.configure(callback: URL(string: "https://test.com")!)
        let client = CoinbaseWalletSDK.getInstance(hostWallet: Wallet.coinbaseWallet)
        XCTAssertFalse(client?.isConnected() ?? false)
    }

}
