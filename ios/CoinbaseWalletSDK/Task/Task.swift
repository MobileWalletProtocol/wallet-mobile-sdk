//
//  Task.swift
//  MobileWalletProtocol
//
//  Created by Jungho Bang on 6/14/22.
//

import Foundation

struct Task {
    let request: RequestMessage
    let host: URL
    let handler: ResponseHandler
    let timestamp: Date
}
