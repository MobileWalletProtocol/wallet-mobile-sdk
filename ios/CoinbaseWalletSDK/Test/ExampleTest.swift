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
        XCTAssertFalse(CoinbaseWalletSDK.isConfigured)
        CoinbaseWalletSDK.configure(callback: URL(string: "myappxyz://mycallback")!)
        XCTAssertTrue(CoinbaseWalletSDK.isConfigured)
    }

}
