//
//  Task.swift
//  MobileWalletProtocol
//
//  Created by Jungho Bang on 6/14/22.
//

import Foundation

@available(iOS 13.0, *)
struct Task {
    let request: RequestMessage
    let host: URL
    let handler: ResponseHandler
    let timestamp: Date
}
