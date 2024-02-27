//
//  RequestMessage.swift
//  WalletSegue
//
//  Created by Jungho Bang on 6/9/22.
//

import Foundation

public enum RequestContent: UnencryptedContent {
    case handshake(appId: String, callback: URL, initialActions: [Action]?)
    case request(actions: [Action], account: Account? = nil)
}

public typealias RequestMessage = Message<RequestContent>
